Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 851CC6B009E
	for <linux-mm@kvack.org>; Fri, 29 May 2015 17:26:17 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so62204206pdb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 14:26:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b2si10156792pdj.13.2015.05.29.14.26.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 14:26:16 -0700 (PDT)
Date: Fri, 29 May 2015 14:26:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: change irqs_disabled() test to spin_is_locked() in
 mem_cgroup_swapout
Message-Id: <20150529142614.37792b9ff867626dcf5e0f08@linux-foundation.org>
In-Reply-To: <20150529104815.2d2e880c@sluggy>
References: <20150529104815.2d2e880c@sluggy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Clark Williams <williams@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Steven Rostedt <rostedt@goodmis.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

On Fri, 29 May 2015 10:48:15 -0500 Clark Williams <williams@redhat.com> wrote:

> The irqs_disabled() check in mem_cgroup_swapout() fails on the latest
> RT kernel because RT mutexes do not disable interrupts when held. Change
> the test for the lock being held to use spin_is_locked.
>
> ...
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5845,7 +5845,7 @@ void mem_cgroup_swapout(struct page *page,
> swp_entry_t entry) page_counter_uncharge(&memcg->memory, 1);
>  
>  	/* XXX: caller holds IRQ-safe mapping->tree_lock */
> -	VM_BUG_ON(!irqs_disabled());
> +	VM_BUG_ON(!spin_is_locked(&page_mapping(page)->tree_lock));
>  
>  	mem_cgroup_charge_statistics(memcg, page, -1);
>  	memcg_check_events(memcg, page);

spin_is_locked() returns zero on uniprocessor builds.  The results will
be unhappy.  

I suggest just deleting the check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
