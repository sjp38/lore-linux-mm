Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 9C75F6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 19:51:10 -0400 (EDT)
Received: by mail-qe0-f50.google.com with SMTP id q19so4640413qeb.23
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 16:51:09 -0700 (PDT)
Date: Tue, 13 Aug 2013 19:51:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
Message-ID: <20130813235104.GK28996@mtj.dyndns.org>
References: <520AAF9C.1050702@tilera.com>
 <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com>
 <20130813232904.GJ28996@mtj.dyndns.org>
 <520AC4F7.9090604@tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520AC4F7.9090604@tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Tue, Aug 13, 2013 at 07:44:55PM -0400, Chris Metcalf wrote:
> int lru_add_drain_all(void)
> {
>         static struct cpumask mask;

Instead of cpumask,

>         static DEFINE_MUTEX(lock);

you can DEFINE_PER_CPU(struct work_struct, ...).

>         for_each_online_cpu(cpu) {
>                 if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
>                     pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
>                     pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
>                     need_activate_page_drain(cpu))
>                         cpumask_set_cpu(cpu, &mask);

and schedule the work items directly.

>         }
> 
>         rc = schedule_on_cpu_mask(lru_add_drain_per_cpu, &mask);

Open coding flushing can be a bit bothersome but you can create a
per-cpu workqueue and schedule work items on it and then flush the
workqueue instead too.

No matter how flushing is implemented, the path wouldn't have any
memory allocation, which I thought was the topic of the thread, no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
