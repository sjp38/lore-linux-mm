Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 692806B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 00:22:47 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t6so186287985pgt.6
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 21:22:47 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b2si14523202pll.243.2017.01.22.21.22.45
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 21:22:46 -0800 (PST)
Date: Mon, 23 Jan 2017 14:22:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20170123052244.GC11763@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <CGME20170119001317epcas1p188357c77e1f4ff08b6d3dcb76dedca06@epcas1p1.samsung.com>
 <afd38699-f1c4-f63f-7362-29c514e9ffb4@samsung.com>
 <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com>
 <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
MIME-Version: 1.0
In-Reply-To: <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Chulmin,

On Thu, Jan 19, 2017 at 03:16:11AM -0500, Chulmin Kim wrote:
> On 01/19/2017 01:21 AM, Minchan Kim wrote:
> >On Wed, Jan 18, 2017 at 10:39:15PM -0500, Chulmin Kim wrote:
> >>On 01/18/2017 09:44 PM, Minchan Kim wrote:
> >>>Hello Chulmin,
> >>>
> >>>On Wed, Jan 18, 2017 at 07:13:21PM -0500, Chulmin Kim wrote:
> >>>>Hello. Minchan, and all zsmalloc guys.
> >>>>
> >>>>I have a quick question.
> >>>>Is zsmalloc considering memory barrier things correctly?
> >>>>
> >>>>AFAIK, in ARM64,
> >>>>zsmalloc relies on dmb operation in bit_spin_unlock only.
> >>>>(It seems that dmb operations in spinlock functions are being prepared,
> >>>>but let is be aside as it is not merged yet.)
> >>>>
> >>>>If I am correct,
> >>>>migrating a page in a zspage filled with free objs
> >>>>may cause the corruption cause bit_spin_unlock will not be executed at all.
> >>>>
> >>>>I am not sure this is enough memory barrier for zsmalloc operations.
> >>>>
> >>>>Can you enlighten me?
> >>>
> >>>Do you mean bit_spin_unlock is broken or zsmalloc locking scheme broken?
> >>>Could you please describe what you are concerning in detail?
> >>>It would be very helpful if you say it with a example!
> >>
> >>Sorry for ambiguous expressions. :)
> >>
> >>Recently,
> >>I found multiple zsmalloc corruption cases which have garbage idx values in
> >>in zspage->freeobj. (not ffffffff (-1) value.)
> >>
> >>Honestly, I have no clue yet.
> >>
> >>I suspect the case when zspage migrate a zs sub page filled with free
> >>objects (so that never calls unpin_tag() which has memory barrier).
> >>
> >>
> >>Assume the page (zs subpage) being migrated has no allocated zs object.
> >>
> >>S : zs subpage
> >>D : free page
> >>
> >>
> >>CPU A : zs_page_migrate()		CPU B : zs_malloc()
> >>---------------------			-----------------------------
> >>
> >>
> >>migrate_write_lock()
> >>spin_lock()
> >>
> >>memcpy(D, S, PAGE_SIZE)   -> (1)
> >>replace_sub_page()
> >>
> >>putback_zspage()
> >>spin_unlock()
> >>migrate_write_unlock()
> >>					
> >>					spin_lock()
> >>					obj_malloc()
> >>					--> (2-a) allocate obj in D
> >>					--> (2-b) set freeobj using
> >>     						the first 8 bytes of
> >> 						the allocated obj
> >>					record_obj()
> >>					spin_unlock
> >>
> >>
> >>
> >>I think the locking has no problem, but memory ordering.
> >>I doubt whether (2-b) in CPU B really loads the data stored by (1).
> >>
> >>If it doesn't, set_freeobj in (2-b) will corrupt zspage->freeobj.
> >>After then, we will see corrupted object sooner or later.
> >
> >Thanks for the example.
> >When I cannot understand what you are pointing out.
> >
> >In above example, two CPU use same spin_lock of a class so store op
> >by memcpy in the critical section should be visible by CPU B.
> >
> >Am I missing your point?
> 
> 
> No, you are right.
> I just pointed it prematurely after only checking that arm64's spinlock
> seems not issue "dmb" operation explicitly.
> I am the one missed the basics.
> 
> Anyway, I will let you know the situation when it gets more clear.

Yeb, Thanks.

Perhaps, did you tried flush page before the writing?
I think arm64 have no d-cache alising problem but worth to try it.
Who knows :)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 46da1c4..a3a5520 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -612,6 +612,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	unsigned long element;
 
 	page = bvec->bv_page;
+	flush_dcache_page(page);
+
 	if (is_partial_io(bvec)) {
 		/*
 		 * This is a partial IO. We need to read the full page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
