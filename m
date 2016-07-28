Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D88876B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 02:52:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so38678038pfg.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:52:43 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id oy8si10833934pac.126.2016.07.27.23.52.42
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 23:52:43 -0700 (PDT)
Date: Thu, 28 Jul 2016 15:57:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: walk the zone in pageblock_nr_pages steps
Message-ID: <20160728065724.GB28136@js1304-P5Q-DELUXE>
References: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com>
 <7fcafdb1-86fa-9245-674b-db1ae53d1c77@suse.cz>
 <57971FDE.20507@huawei.com>
 <473964c8-23cd-cee7-b25c-6ef020547b9a@suse.cz>
 <57972DD3.3050909@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57972DD3.3050909@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Jul 26, 2016 at 05:30:59PM +0800, zhong jiang wrote:
> On 2016/7/26 16:53, Vlastimil Babka wrote:
> > On 07/26/2016 10:31 AM, zhong jiang wrote:
> >> On 2016/7/26 14:24, Vlastimil Babka wrote:
> >>> On 07/26/2016 05:08 AM, zhongjiang wrote:
> >>>> From: zhong jiang <zhongjiang@huawei.com>
> >>>>
> >>>> when walking the zone, we can happens to the holes. we should
> >>>> not align MAX_ORDER_NR_PAGES, so it can skip the normal memory.

Do you have any system to trigger this problem?

I'm not familiar with CONFIG_HOLES_IN_ZONE system, but, as Vlastimil saids,
skip by pageblock size also has similar problem that skip the normal memory
because hole's granularity would not be pageblock size.

Anyway, if you want not to skip the normal memory, following code would work.
I think that it is a better way since it doesn't depend on hole's granularity.

Thanks.

--------->8-----------
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1a4690..4184db2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1276,6 +1276,11 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
         * not matter as the mixed block count will still be correct
         */
        for (; pfn < end_pfn; ) {
+               if (!pfn_valid_within(pfn)) {
+                       pfn++;
+                       continue;
+               }
+
                if (!pfn_valid(pfn)) {
                        pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
                        continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
