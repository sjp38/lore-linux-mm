Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB1E16B06FB
	for <linux-mm@kvack.org>; Sat, 12 May 2018 23:30:17 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id a14-v6so7960347plt.7
        for <linux-mm@kvack.org>; Sat, 12 May 2018 20:30:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6-v6sor1656906pgv.434.2018.05.12.20.30.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 May 2018 20:30:16 -0700 (PDT)
Date: Sat, 12 May 2018 20:32:20 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Message-ID: <20180513033220.GA654@sol.localdomain>
References: <94eb2c03c9bc75aff2055f70734c@google.com>
 <001a113f711a528a3f0560b08e76@google.com>
 <20180512215222.GC817@sol.localdomain>
 <201805131106.GFF73973.OOtMVQFSFOJFHL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805131106.GFF73973.OOtMVQFSFOJFHL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com, peter@hurleysoftware.com, dvyukov@google.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Hi Tetsuo,

On Sun, May 13, 2018 at 11:06:17AM +0900, Tetsuo Handa wrote:
> Eric Biggers wrote:
> > The bug that this reproducer reproduces was fixed a while ago by commit
> > 966031f340185e, so I'm marking this bug report fixed by it:
> > 
> > #syz fix: n_tty: fix EXTPROC vs ICANON interaction with TIOCINQ (aka FIONREAD)
> 
> Nope. Commit 966031f340185edd ("n_tty: fix EXTPROC vs ICANON interaction with
> TIOCINQ (aka FIONREAD)") is "Wed Dec 20 17:57:06 2017 -0800" but the last
> occurrence on linux.git (commit 008464a9360e31b1 ("Merge branch 'for-linus' of
> git://git.kernel.org/pub/scm/linux/kernel/git/jikos/hid")) is only a few days ago
> ("Wed May 9 10:49:52 2018 -1000").
> 
> > 
> > Note that the error message was not always "BUG: workqueue lockup"; it was also
> > sometimes like "watchdog: BUG: soft lockup - CPU#5 stuck for 22s!".
> > 
> > syzbot still is hitting the "BUG: workqueue lockup" error sometimes, but it must
> > be for other reasons.  None has a reproducer currently.
> 
> The last occurrence on linux.git is considered as a duplicate of
> 
>   [upstream] INFO: rcu detected stall in n_tty_receive_char_special
>   https://syzkaller.appspot.com/bug?id=3d7481a346958d9469bebbeb0537d5f056bdd6e8
> 
> which we already have a reproducer at
> https://groups.google.com/d/msg/syzkaller-bugs/O4DbPiJZFBY/YCVPocx3AgAJ
> and debug output is available at
> https://groups.google.com/d/msg/syzkaller-bugs/O4DbPiJZFBY/TxQ7WS5ZAwAJ .
> 
> We are currently waiting for comments from Peter Hurley who added that code.
> 

Actually I did verify that the C reproducer is fixed by the commit I said, and I
also simplified the reproducer and turned it into an LTP test
(http://lists.linux.it/pipermail/ltp/2018-May/008071.html).  Like I said, syzbot
is still occasionally hitting the same "BUG: workqueue lockup" error, but
apparently for other reasons.  The one on 008464a9360e31b even looks like it's
in the TTY layer too, and it very well could be a very similar bug, but based on
what I observed it's not the same bug that syzbot reproduced on f3b5ad89de16f5d.
Generally it's best to close syzbot bug reports once the original cause is
fixed, so that syzbot can continue to report other bugs with the same signature.
Otherwise they sit on the syzbot dashboard where few people are looking at them.
Though of course, if you are up to it, you're certainly free to look into any of
the crashes already there even before a new bug report gets created.

Note also that a "workqueue lockup" can be caused by almost anything in the
kernel, I think.  This one for example is probably in the sound subsystem:
https://syzkaller.appspot.com/text?tag=CrashReport&x=1767232b800000

Thanks!

Eric
