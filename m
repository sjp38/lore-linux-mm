Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC0B16B0011
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:32:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q6so6072448pgv.12
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 08:32:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc5-v6si174377plb.506.2018.03.19.08.32.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 08:32:04 -0700 (PDT)
Date: Mon, 19 Mar 2018 16:29:36 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: get_user_pages returning 0 (was Re: kernel BUG at
 drivers/vhost/vhost.c:LINE!)
Message-ID: <20180319152936.GI6955@suse.cz>
Reply-To: dsterba@suse.cz
References: <001a11427716098c150567bcd12f@google.com>
 <20180319161406-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180319161406-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: " Michael S. Tsirkin " <mst@redhat.com>
Cc: syzbot <syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com>, Michel Lespinasse <walken@google.com>, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, aarcange@redhat.com, jasowang@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Mon, Mar 19, 2018 at 05:09:28PM +0200,  Michael S. Tsirkin  wrote:
> Hello!
> The following code triggered by syzbot 
> 
>         r = get_user_pages_fast(log, 1, 1, &page);
>         if (r < 0)
>                 return r;
>         BUG_ON(r != 1);
> 
> Just looking at get_user_pages_fast's documentation this seems
> impossible - it is supposed to only ever return # of pages
> pinned or errno.
> 
> However, poking at code, I see at least one path that might cause this:
> 
>                         ret = faultin_page(tsk, vma, start, &foll_flags,
>                                         nonblocking);
>                         switch (ret) {
>                         case 0:
>                                 goto retry;
>                         case -EFAULT:
>                         case -ENOMEM:
>                         case -EHWPOISON:
>                                 return i ? i : ret;
>                         case -EBUSY:
>                                 return i;
> 
> which originally comes from:
> 
> commit 53a7706d5ed8f1a53ba062b318773160cc476dde
> Author: Michel Lespinasse <walken@google.com>
> Date:   Thu Jan 13 15:46:14 2011 -0800
> 
>     mlock: do not hold mmap_sem for extended periods of time
>     
>     __get_user_pages gets a new 'nonblocking' parameter to signal that the
>     caller is prepared to re-acquire mmap_sem and retry the operation if
>     needed.  This is used to split off long operations if they are going to
>     block on a disk transfer, or when we detect contention on the mmap_sem.
>     
>     [akpm@linux-foundation.org: remove ref to rwsem_is_contended()]
>     Signed-off-by: Michel Lespinasse <walken@google.com>
>     Cc: Hugh Dickins <hughd@google.com>
>     Cc: Rik van Riel <riel@redhat.com>
>     Cc: Peter Zijlstra <peterz@infradead.org>
>     Cc: Nick Piggin <npiggin@kernel.dk>
>     Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>     Cc: Ingo Molnar <mingo@elte.hu>
>     Cc: "H. Peter Anvin" <hpa@zytor.com>
>     Cc: Thomas Gleixner <tglx@linutronix.de>
>     Cc: David Howells <dhowells@redhat.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> I started looking into this, if anyone has any feedback meanwhile,
> that would be appreciated.
> 
> In particular I don't really see why would this trigger
> on commit 8f5fd927c3a7576d57248a2d7a0861c3f2795973:
> 
> Merge: 8757ae2 093e037
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Fri Mar 16 13:37:42 2018 -0700
> 
>     Merge tag 'for-4.16-rc5-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/kdave/linux
> 
> is btrfs used on these systems?

There were 3 patches pulled by that tag, none of them is even remotely
related to the reported bug, AFAICS. If there's some impact, it must be
indirect, obvious bugs like NULL pointer would exhibit in a different
way and leave at least some trace in the stacks.
