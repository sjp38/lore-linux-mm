Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA8D6B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 04:42:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t24-v6so839356eds.12
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 01:42:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c12-v6si5065446edt.291.2018.10.02.01.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 01:42:29 -0700 (PDT)
Date: Tue, 2 Oct 2018 10:42:25 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
References: <20180927194601.207765-1-wonderfly@google.com>
 <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: rostedt@goodmis.org, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, xiyou.wangcong@gmail.com, Peter Feiner <pfeiner@google.com>

On Mon 2018-10-01 13:37:30, Daniel Wang wrote:
> On Mon, Oct 1, 2018 at 12:23 PM Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > > Serial console logs leading up to the deadlock. As can be seen the stack trace
> > > was incomplete because the printing path hit a timeout.
> >
> > I'm fine with having this backported.
> 
> Thanks. I can send the cherrypicks your way. Do you recommend that I
> include the three follow-up fixes though?
> 
> c14376de3a1b printk: Wake klogd when passing console_lock owner
> fd5f7cde1b85 printk: Never set console_may_schedule in console_trylock()
> c162d5b4338d printk: Hide console waiter logic into helpers
> dbdda842fe96 printk: Add console owner and waiter logic to load
> balance console writes

This list looks complete and I am fine with backporting it to 4.14.

Well, I still wonder why it helped and why you do not see it with 4.4.
I have a feeling that the console owner switch helped only by chance.
In fact, you might be affected by a race in
printk_safe_flush_on_panic() that was fixed by the commit:

554755be08fba31c7 printk: drop in_nmi check from printk_safe_flush_on_panic()

The above one commit might be enough. Well, there was one more
NMI-related race that was fixed by:

ba552399954dde1b printk: Split the code for storing a message into the log buffer
a338f84dc196f44b printk: Create helper function to queue deferred console handling
03fc7f9c99c1e7ae printk/nmi: Prevent deadlock when accessing the main log buffer in NMI

Best Regards,
Petr
