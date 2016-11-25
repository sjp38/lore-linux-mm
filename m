Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCC36B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:02:09 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r94so117248956ioe.7
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 04:02:09 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v9si10657811ith.91.2016.11.25.04.02.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 04:02:07 -0800 (PST)
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161123064925.9716-1-mhocko@kernel.org>
	<20161123064925.9716-3-mhocko@kernel.org>
	<201611232335.JFC30797.VOOtOMFJFHLQSF@I-love.SAKURA.ne.jp>
	<20161123153544.GN2864@dhcp22.suse.cz>
In-Reply-To: <20161123153544.GN2864@dhcp22.suse.cz>
Message-Id: <201611252100.ADG04225.MFOSOVtHJFFLQO@I-love.SAKURA.ne.jp>
Date: Fri, 25 Nov 2016 21:00:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 23-11-16 23:35:10, Tetsuo Handa wrote:
> > If __alloc_pages_nowmark() called by __GFP_NOFAIL could not find pages
> > with requested order due to fragmentation, __GFP_NOFAIL should invoke
> > the OOM killer. I believe that risking kill all processes and panic the
> > system eventually is better than __GFP_NOFAIL livelock.
>
> I violently disagree. Just imagine a driver which asks for an order-9
> page and cannot really continue without it so it uses GFP_NOFAIL. There
> is absolutely no reason to disrupt or even put the whole system down
> just because of this particular request. It might take for ever to
> continue but that is to be expected when asking for such a hard
> requirement.

Did we find such in-tree drivers? If any, we likely already know it via
WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1)); in buffered_rmqueue().
Even if there were such out-of-tree drivers, we don't need to take care of
out-of-tree drivers.

> > Unfortunately, there seems to be cases where the
> > caller needs to use GFP_NOFS rather than GFP_KERNEL due to unclear dependency
> > between memory allocation by system calls and memory reclaim by filesystems.
>
> I do not understand your point here. Syscall is an entry point to the
> kernel where we cannot recurse to the FS code so GFP_NOFS seems wrong
> thing to ask.

Will you look at http://marc.info/?t=120716967100004&r=1&w=2 which lead to
commit a02fe13297af26c1 ("selinux: prevent rentry into the FS") and commit
869ab5147e1eead8 ("SELinux: more GFP_NOFS fixups to prevent selinux from
re-entering the fs code") ? My understanding is that mkdir() system call
caused memory allocation for inode creation and that memory allocation
caused memory reclaim which had to be !__GFP_FS.

And whether we need to use GFP_NOFS at specific point is very very unclear.
For example, security_inode_init_security() calls call_int_hook() macro
which calls smack_inode_init_security() if Smack is active.
smack_inode_init_security() uses GFP_NOFS for memory allocation.
security_inode_init_security() also calls evm_inode_init_security(), and
evm_inode_init_security() uses GFP_NOFS for memory allocation.
Looks consistent? Yes.

But evm_inode_init_security() also calls evm_init_hmac() which in turn calls
init_desc() which uses GFP_KERNEL for memory allocation. This is not consistent.

And security_inode_init_security() also calls initxattrs() callback which is
provided by filesystem code. For example, btrfs_initxattrs() is called if
security_inode_init_security() is called by btrfs. And btrfs_initxattrs() is
using GFP_KERNEL for memory allocation. This is not consistent too.

Either we are needlessly using GFP_NOFS with risk of retry-forever loop or
we are wrongly using GFP_KERNEL with risk of memory reclaim deadlock.
Apart from we need to make these GFP_NOFS/GFP_KERNEL usages consistent
(although whether we need to use GFP_NOFS is very very unclear),
I do want to allow memory allocations from functions which are called by
system calls to invoke the OOM-killer (e.g. __GFP_MAY_OOMKILL) rather than
risk retry-forever loop (or fail that request) even if we need to use GFP_NOFS.
Also, I'm willing to give up memory allocations from functions which are
called by system calls if SIGKILL is pending (i.e. __GFP_KILLABLE).

Did you understand my point?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
