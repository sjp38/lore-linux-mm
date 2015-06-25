Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE866B007B
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:50:03 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so61283111pdc.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:50:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g2si46992580pdp.243.2015.06.25.14.50.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 14:50:02 -0700 (PDT)
Date: Thu, 25 Jun 2015 23:49:50 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 8/8] xen/balloon: use hotplugged pages for foreign
 mappings etc.
Message-ID: <20150625214950.GR14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-9-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435252263-31952-9-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 25, 2015 at 06:11:03PM +0100, David Vrabel wrote:
> alloc_xenballooned_pages() is used to get ballooned pages to back
> foreign mappings etc.  Instead of having to balloon out real pages,
> use (if supported) hotplugged memory.
>
> This makes more memory available to the guest and reduces
> fragmentation in the p2m.
>
> If userspace is lacking a udev rule (or similar) to online hotplugged
> regions automatically, alloc_xenballooned_pages() will timeout and
> fall back to the old behaviour of ballooning out pages.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

In general Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com> but...

> ---
>  drivers/xen/balloon.c |   32 ++++++++++++++++++++++++++------
>  include/xen/balloon.h |    1 +
>  2 files changed, 27 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 95c261c..a26c5f3 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -97,6 +97,7 @@ static xen_pfn_t frame_list[PAGE_SIZE / sizeof(unsigned long)];
>
>  /* List of ballooned pages, threaded through the mem_map array. */
>  static LIST_HEAD(ballooned_pages);
> +static DECLARE_WAIT_QUEUE_HEAD(balloon_wq);
>
>  /* Main work function, always executed in process context. */
>  static void balloon_process(struct work_struct *work);
> @@ -125,6 +126,7 @@ static void __balloon_append(struct page *page)
>  		list_add(&page->lru, &ballooned_pages);
>  		balloon_stats.balloon_low++;
>  	}
> +	wake_up(&balloon_wq);
>  }
>
>  static void balloon_append(struct page *page)
> @@ -247,7 +249,8 @@ static enum bp_state reserve_additional_memory(void)
>  	int nid, rc;
>  	unsigned long balloon_hotplug;
>
> -	credit = balloon_stats.target_pages - balloon_stats.total_pages;
> +	credit = balloon_stats.target_pages + balloon_stats.target_unpopulated
> +		- balloon_stats.total_pages;
>
>  	/*
>  	 * Already hotplugged enough pages?  Wait for them to be
> @@ -328,7 +331,7 @@ static struct notifier_block xen_memory_nb = {
>  static enum bp_state reserve_additional_memory(void)
>  {
>  	balloon_stats.target_pages = balloon_stats.current_pages;
> -	return BP_DONE;
> +	return BP_ECANCELED;
>  }
>  #endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
>
> @@ -532,13 +535,31 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
>  {
>  	int pgno = 0;
>  	struct page *page;
> +
>  	mutex_lock(&balloon_mutex);
> +
> +	balloon_stats.target_unpopulated += nr_pages;
> +
>  	while (pgno < nr_pages) {
>  		page = balloon_retrieve(true);
>  		if (page) {
>  			pages[pgno++] = page;
>  		} else {
>  			enum bp_state st;
> +
> +			st = reserve_additional_memory();
> +			if (st != BP_ECANCELED) {

...think if you use BP_ECANCELED in patch #6...

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
