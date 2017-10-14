Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB3F06B0288
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 04:11:24 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p130so2813046lfe.20
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 01:11:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r71sor425714lja.32.2017.10.14.01.11.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Oct 2017 01:11:23 -0700 (PDT)
Date: Sat, 14 Oct 2017 10:11:24 +0200
From: Johan Hovold <johan@kernel.org>
Subject: Re: Dramatic lockdep slowdown in 4.14
Message-ID: <20171014081124.GB16632@localhost>
References: <20171013090333.GA17356@localhost>
 <20171014072659.f2yr6mhm5ha3eou7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171014072659.f2yr6mhm5ha3eou7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Johan Hovold <johan@kernel.org>, Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, kernel-team@lge.com, Tony Lindgren <tony@atomide.com>, Arnd Bergmann <arnd@arndb.de>, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Sat, Oct 14, 2017 at 09:26:59AM +0200, Ingo Molnar wrote:
> 
> * Johan Hovold <johan@kernel.org> wrote:
> 
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
> It's not desirable at all.
> 
> Does the patch below fix the regression for you - or does the introduction and 
> handling of ->nr_acquire hurt as well?

> -	select LOCKDEP_CROSSRELEASE
> -	select LOCKDEP_COMPLETIONS
> +#	select LOCKDEP_CROSSRELEASE
> +#	select LOCKDEP_COMPLETIONS

Disabling these options this way gives me a about boot time of 17
seconds again, so yes, that fixes the problem.

Thanks,
Johan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
