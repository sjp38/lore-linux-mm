Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB2076B0007
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 02:27:08 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v10so4900871wrv.22
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 23:27:08 -0800 (PST)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id p21si6666262wmc.11.2018.01.28.23.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jan 2018 23:27:07 -0800 (PST)
Date: Mon, 29 Jan 2018 08:23:57 +0100
From: Florian Westphal <fw@strlen.de>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180129072357.GD5906@breakpoint.cc>
References: <001a1144b0caee2e8c0563d9de0a@google.com>
 <201801290020.w0T0KK8V015938@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801290020.w0T0KK8V015938@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, aarcange@redhat.com, yang.s@alibaba-inc.com, mhocko@suse.com, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com

Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> syzbot wrote:
> > syzbot hit the following crash on net-next commit
> > 6bb46bc57c8e9ce947cc605e555b7204b44d2b10 (Fri Jan 26 16:00:23 2018 +0000)
> > Merge branch 'cxgb4-fix-dump-collection-when-firmware-crashed'
> > 
> > C reproducer is attached.
> > syzkaller reproducer is attached.
> > Raw console output is attached.
> > compiler: gcc (GCC) 7.1.1 20170620
> > .config is attached.
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+8630e35fc7287b392aac@syzkaller.appspotmail.com
> > It will help syzbot understand when the bug is fixed. See footer for  
> > details.
> > If you forward the report, please keep this part and the footer.
> > 
> > [ 3685]     0  3685    17821        1   184320        0             0 sshd
> > [ 3692]     0  3692     4376        0    32768        0             0  
> > syzkaller025682
> > [ 3695]     0  3695     4376        0    36864        0             0  
> > syzkaller025682
> > Kernel panic - not syncing: Out of memory and no killable processes...
> > 
> 
> This sounds like too huge vmalloc() request where size is controlled by userspace.

Right.

Before eacd86ca3b036e55e172b7279f101cef4a6ff3a4
this used 

              info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY,

would it help to re-add that?

> vmalloc() once became killable by commit 5d17a73a2ebeb8d1 ("vmalloc: back
> off when the current task is killed") but then became unkillable by commit
> b8c8a338f75e052d ("Revert "vmalloc: back off when the current task is
> killed""). Therefore, we can't handle this problem from MM side.
> Please consider adding some limit from networking side.

I don't know what "some limit" would be.  I would prefer if there was
a way to supress OOM Killer in first place so we can just -ENOMEM user.

AFAIU NOWARN|NORETRY does that, so I would propose to just read-add it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
