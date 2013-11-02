Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 231D06B0035
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 22:51:09 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so4557214pdj.24
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 19:51:08 -0700 (PDT)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id gl1si6219978pac.53.2013.11.01.19.51.07
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 19:51:08 -0700 (PDT)
Message-ID: <5274688D.7050902@oracle.com>
Date: Sat, 02 Nov 2013 10:50:53 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: zram/zsmalloc issues in very low memory conditions
References: <526844E6.1080307@codeaurora.org> <20131025091924.GA4970@gmail.com> <52744E8F.3040405@codeaurora.org>
In-Reply-To: <52744E8F.3040405@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olav Haugan <ohaugan@codeaurora.org>
Cc: Minchan Kim <minchan@kernel.org>, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Olav,

On 11/02/2013 08:59 AM, Olav Haugan wrote:

> 
> I tried the above suggestion but it does not seem to have any noticeable
> impact. The system is still trying to swap out at a very high rate after
> zram reported failure to swap out. The error logging is actually so much
> that my system crashed due to excessive logging (we have a watchdog that
> is not getting pet because the kernel is busy logging kernel messages).
> 

I have a question that why the low memory killer didn't get triggered in
this situation?
Is it possible to set the LMK a bit more aggressive?

> There isn't anything that can be set to tell the fs layer to back off
> completely for a while (congestion control)?
> 

The other way I think might fix your issue is the same as your mentioned
in your previous email.
Set the congested bit for swap device also.
Like:

diff --git a/drivers/staging/zram/zram_drv.c
b/drivers/staging/zram/zram_drv.c
index 91d94b5..c4fc63e 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -474,6 +474,7 @@ static int zram_bvec_write(struct zram *zram, struct
bio_vec *bvec, u32 index,
        if (!handle) {
                pr_info("Error allocating memory for compressed page:
%u, size=%zu\n",
                        index, clen);
+               blk_set_queue_congested(zram->disk->queue, BLK_RW_ASYNC);
                ret = -ENOMEM;
                goto out;
        }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ed1b77..1c790ee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -394,8 +394,6 @@ static inline int is_page_cache_freeable(struct page
*page)
 static int may_write_to_queue(struct backing_dev_info *bdi,
                              struct scan_control *sc)
 {
-       if (current->flags & PF_SWAPWRITE)
-               return 1;

--------------------------------------------------------------

For the update of the congested state of zram, I think you can clear it
from use space eg. after LMK triggered and reclaimed some memory.

Of course this depends on zram driver to export a sysfs node like
"/sys/block/zram0/clear_congested".

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
