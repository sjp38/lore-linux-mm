Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE7166B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 09:32:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b189so2743080wmd.5
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 06:32:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q20si1095257edc.14.2017.11.14.06.32.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 06:32:01 -0800 (PST)
Date: Tue, 14 Nov 2017 15:32:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: drop hotplug lock from lru_add_drain_all
Message-ID: <20171114143200.brmgskoqxjlrhrzx@dhcp22.suse.cz>
References: <20171114135348.28704-1-mhocko@kernel.org>
 <alpine.DEB.2.20.1711141512180.2044@nanos>
 <20171114142347.syzyd6tlnpe2afur@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114142347.syzyd6tlnpe2afur@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 14-11-17 15:23:47, Michal Hocko wrote:
[...]
> +/*
> + * Doesn't need any cpu hotplug locking because we do rely on per-cpu
> + * kworkers being shut down before our page_alloc_cpu_dead callback is
> + * executed on the offlined cpu
> + */
>  void lru_add_drain_all(void)
>  {
>  	static DEFINE_MUTEX(lock);

Ble the part of the comment didn't go through

diff --git a/mm/swap.c b/mm/swap.c
index 8bfdcab9f83e..1ab8122d2d0c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -688,6 +688,13 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
+/*
+ * Doesn't need any cpu hotplug locking because we do rely on per-cpu
+ * kworkers being shut down before our page_alloc_cpu_dead callback is
+ * executed on the offlined cpu.
+ * Calling this function with cpu hotplug locks held can actually lead
+ * to obscure indirect dependencies via WQ context.
+ */
 void lru_add_drain_all(void)
 {
 	static DEFINE_MUTEX(lock);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
