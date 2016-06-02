Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 525566B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 10:39:28 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id y6so141106598ywe.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 07:39:28 -0700 (PDT)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id 6si190446ybm.271.2016.06.02.07.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 07:39:27 -0700 (PDT)
Received: by mail-yw0-x243.google.com with SMTP id j74so7104137ywg.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 07:39:27 -0700 (PDT)
Date: Thu, 2 Jun 2016 10:39:25 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Introduce dedicated WQ_MEM_RECLAIM workqueue to do
 lru_add_drain_all
Message-ID: <20160602143925.GJ14868@mtj.duckdns.org>
References: <1464853731-8599-1-git-send-email-shhuiw@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464853731-8599-1-git-send-email-shhuiw@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@foxmail.com>
Cc: keith.busch@intel.com, peterz@infradead.org, treding@nvidia.com, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Jun 02, 2016 at 03:48:51PM +0800, Wang Sheng-Hui wrote:
> +static int __init lru_init(void)
> +{
> +	lru_add_drain_wq = alloc_workqueue("lru-add-drain",
> +		WQ_MEM_RECLAIM | WQ_UNBOUND, 0);

Why is it unbound?

> +	if (WARN(!lru_add_drain_wq,
> +		"Failed to create workqueue lru_add_drain_wq"))
> +		return -ENOMEM;

I don't think we need an explicit warn here.  Doesn't error return
from an init function trigger boot failure anyway?

> +	return 0;
> +}
> +early_initcall(lru_init);
> +
>  void lru_add_drain_all(void)
>  {
>  	static DEFINE_MUTEX(lock);
>  	static struct cpumask has_work;
>  	int cpu;
>  
> +	struct workqueue_struct *lru_wq = lru_add_drain_wq ?: system_wq;
> +
> +	WARN_ONCE(!lru_add_drain_wq,
> +		"Use system_wq to do lru_add_drain_all()");

Ditto.  The system is crashing for sure.  What's the point of this
warning?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
