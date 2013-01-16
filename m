Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id CB9A76B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:39:43 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 20:39:42 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0991038C803F
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:39:41 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G1deVp300672
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:39:40 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G1deAB023587
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 23:39:40 -0200
Message-ID: <50F604D4.407@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 17:39:32 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/17] mm/compaction: use zone_end_pfn()
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com> <1358295894-24167-18-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-18-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

On 01/15/2013 04:24 PM, Cody P Schafer wrote:
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1b52528..ea66be3 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -85,7 +85,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
>  static void __reset_isolation_suitable(struct zone *zone)
>  {
>  	unsigned long start_pfn = zone->zone_start_pfn;
> -	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +	unsigned long end_pfn = zone_end_pfn(zone);
>  	unsigned long pfn;
> 
>  	zone->compact_cached_migrate_pfn = start_pfn;
> @@ -663,7 +663,7 @@ static void isolate_freepages(struct zone *zone,
>  	 */
>  	high_pfn = min(low_pfn, pfn);
> 
> -	z_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +	z_end_pfn = zone_end_pfn(zone);
> 
>  	/*
>  	 * Isolate free pages until enough are available to migrate the
> @@ -920,7 +920,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  {
>  	int ret;
>  	unsigned long start_pfn = zone->zone_start_pfn;
> -	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> +	unsigned long end_pfn = zone_end_pfn(zone);
> 
>  	ret = compaction_suitable(zone, cc->order);
>  	switch (ret) {

I do think theses are a _wee_ bit _too_ broken out.  In this case, it's
highly beneficial to just be able to look in the same email to make sure
that, "yeah, zone_end_pfn() is the same as the code that it replaces".
The fact that it was defined 15 patches ago makes it a bit harder to
review.  It's much nicer to review if there's _one_ patch that does the
"define this new function and do all of the replacements".

Anyway, the series looks good.  Feel free to add my:

Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
