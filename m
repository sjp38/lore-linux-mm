Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC67A6B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:07:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n14so7656448pfh.15
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:07:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f3si353523plb.556.2017.10.13.02.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 02:07:50 -0700 (PDT)
Date: Fri, 13 Oct 2017 11:07:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dramatic lockdep slowdown in 4.14
Message-ID: <20171013090744.lvvc66qexmomsd5f@hirez.programming.kicks-ass.net>
References: <20171013090333.GA17356@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013090333.GA17356@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johan Hovold <johan@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, kernel-team@lge.com, Tony Lindgren <tony@atomide.com>, Arnd Bergmann <arnd@arndb.de>, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Fri, Oct 13, 2017 at 11:03:33AM +0200, Johan Hovold wrote:
> Hi,
> 
> I had noticed that the BeagleBone Black boot time appeared to have
> increased significantly with 4.14 and yesterday I finally had time to
> investigate it.
> 
> Boot time (from "Linux version" to login prompt) had in fact doubled
> since 4.13 where it took 17 seconds (with my current config) compared to
> the 35 seconds I now see with 4.14-rc4.
> 
> I quick bisect pointed to lockdep and specifically the following commit:
> 
> 	28a903f63ec0 ("locking/lockdep: Handle non(or multi)-acquisition
> 	               of a crosslock")
> 
> which I've verified is the commit which doubled the boot time (compared
> to 28a903f63ec0^) (added by lockdep crossrelease series [1]).
> 
> I also verified that simply disabling CONFIG_PROVE_LOCKING on 4.14-rc4
> brought boot time down to about 14 seconds.
> 
> Now since it's lockdep I guess this can't really be considered a
> regression if these changes did improve lockdep correctness, but still,
> this dramatic slow down essentially forces me to disable PROVE_LOCKING
> by default on this system.
> 
> Is this lockdep slowdown expected and desirable?

Expected yes, desirable not so much. Its the save_stack_trace() in
add_xhlock() (IIRC).

I've not yet had time to figure out what to do about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
