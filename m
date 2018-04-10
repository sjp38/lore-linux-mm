Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAA96B0007
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:12:12 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r129-v6so10926258itc.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:12:12 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id h3si1851977iob.110.2018.04.10.07.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 07:12:10 -0700 (PDT)
Date: Tue, 10 Apr 2018 09:12:08 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC] mm, slab: reschedule cache_reap() on the same CPU
In-Reply-To: <20180410081531.18053-1-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.20.1804100907160.27333@nuc-kabylake>
References: <20180410081531.18053-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

On Tue, 10 Apr 2018, Vlastimil Babka wrote:

> cache_reap() is initially scheduled in start_cpu_timer() via
> schedule_delayed_work_on(). But then the next iterations are scheduled via
> schedule_delayed_work(), thus using WORK_CPU_UNBOUND.

That is a bug.. cache_reap must run on the same cpu since it deals with
the per cpu queues of the current cpu. Scheduled_delayed_work() used to
guarantee running on teh same cpu.

> This patch makes sure schedule_delayed_work_on() is used with the proper cpu
> when scheduling the next iteration. The cpu is stored with delayed_work on a
> new slab_reap_work_struct super-structure.

The current cpu is readily available via smp_processor_id(). Why a
super structure?

> @@ -4074,7 +4086,8 @@ static void cache_reap(struct work_struct *w)
>  	next_reap_node();
>  out:
>  	/* Set up the next iteration */
> -	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
> +	schedule_delayed_work_on(reap_work->cpu, work,
> +					round_jiffies_relative(REAPTIMEOUT_AC));

schedule_delayed_work_on(smp_processor_id(), work, round_jiffies_relative(REAPTIMEOUT_AC));

instead all of the other changes?
