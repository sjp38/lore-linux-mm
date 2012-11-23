Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 889EF6B004D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 06:44:47 -0500 (EST)
Received: from webcorp2g.yandex-team.ru (webcorp2g.yandex-team.ru [95.108.252.6])
	by forward17.mail.yandex.net (Yandex) with ESMTP id 92FA110613F3
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 15:44:43 +0400 (MSK)
From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Question about __zone_reclaim()
MIME-Version: 1.0
Message-Id: <92581353671083@webcorp2g.yandex-team.ru>
Date: Fri, 23 Nov 2012 15:44:43 +0400
Content-Transfer-Encoding: 7bit
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi!

I have a question about __zone_reclaim() function:

mm/vmscan.c:
static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
{
        <cut>
	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
        if (nr_slab_pages0 > zone->min_slab_pages) {
               <cut>
                for (;;) {
                        unsigned long lru_pages = zone_reclaimable_pages(zone);

                        /* No reclaimable slab or very low memory pressure */
                        if (!shrink_slab(&shrink, sc.nr_scanned, lru_pages))
                                break;

                        /* Freed enough memory */
                        nr_slab_pages1 = zone_page_state(zone,
                                                        NR_SLAB_RECLAIMABLE);
                        if (nr_slab_pages1 + nr_pages <= nr_slab_pages0)
                                break;
                }
                <cut>

Why we don't stop the for cycle if we meet zone->min_slab_pages watermark?

Is it an issue or do I miss something?

IMHO, we should add something like this:
                        if (nr_slab_pages1 < zone->min_slab_pages)
                                break;

Thank you!

Regards,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
