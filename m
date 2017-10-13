Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 60A7A6B0253
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:35:16 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b190so1931813lfg.11
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:35:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u1sor97745lja.26.2017.10.13.02.35.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 02:35:14 -0700 (PDT)
Date: Fri, 13 Oct 2017 11:35:16 +0200
From: Johan Hovold <johan@kernel.org>
Subject: Re: Dramatic lockdep slowdown in 4.14
Message-ID: <20171013093516.GB17356@localhost>
References: <20171013090333.GA17356@localhost>
 <20171013090744.lvvc66qexmomsd5f@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013090744.lvvc66qexmomsd5f@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johan Hovold <johan@kernel.org>, Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, kernel-team@lge.com, Tony Lindgren <tony@atomide.com>, Arnd Bergmann <arnd@arndb.de>, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Thorsten Leemhuis <regressions@leemhuis.info>

On Fri, Oct 13, 2017 at 11:07:44AM +0200, Peter Zijlstra wrote:
> On Fri, Oct 13, 2017 at 11:03:33AM +0200, Johan Hovold wrote:
> > Hi,
> > 
> > I had noticed that the BeagleBone Black boot time appeared to have
> > increased significantly with 4.14 and yesterday I finally had time to
> > investigate it.
> > 
> > Boot time (from "Linux version" to login prompt) had in fact doubled
> > since 4.13 where it took 17 seconds (with my current config) compared to
> > the 35 seconds I now see with 4.14-rc4.
> > 
> > I quick bisect pointed to lockdep and specifically the following commit:
> > 
> > 	28a903f63ec0 ("locking/lockdep: Handle non(or multi)-acquisition
> > 	               of a crosslock")
> > 
> > which I've verified is the commit which doubled the boot time (compared
> > to 28a903f63ec0^) (added by lockdep crossrelease series [1]).
> > 
> > I also verified that simply disabling CONFIG_PROVE_LOCKING on 4.14-rc4
> > brought boot time down to about 14 seconds.
> > 
> > Now since it's lockdep I guess this can't really be considered a
> > regression if these changes did improve lockdep correctness, but still,
> > this dramatic slow down essentially forces me to disable PROVE_LOCKING
> > by default on this system.
> > 
> > Is this lockdep slowdown expected and desirable?
> 
> Expected yes, desirable not so much. Its the save_stack_trace() in
> add_xhlock() (IIRC).
> 
> I've not yet had time to figure out what to do about that.

Thanks for confirming. Do you think it makes sense to track this as a
4.14 regression to avoid having others spend time on tracking this down
meanwhile? (Adding Thorsten on CC.)

Johan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
