Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A304B6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 19:29:10 -0400 (EDT)
Received: by mail-qe0-f48.google.com with SMTP id 9so4718099qea.35
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 16:29:09 -0700 (PDT)
Date: Tue, 13 Aug 2013 19:29:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
Message-ID: <20130813232904.GJ28996@mtj.dyndns.org>
References: <520AAF9C.1050702@tilera.com>
 <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello,

On Tue, Aug 13, 2013 at 06:53:32PM -0400, Chris Metcalf wrote:
>  int lru_add_drain_all(void)
>  {
> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
> +	return schedule_on_each_cpu_cond(lru_add_drain_per_cpu,
> +					 lru_add_drain_cond, NULL);

It won't nest and doing it simultaneously won't buy anything, right?
Wouldn't it be better to protect it with a mutex and define all
necessary resources statically (yeah, cpumask is pain in the ass and I
think we should un-deprecate cpumask_t for static use cases)?  Then,
there'd be no allocation to worry about on the path.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
