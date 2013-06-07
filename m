Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D6B996B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 16:43:04 -0400 (EDT)
Date: Fri, 7 Jun 2013 13:43:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] non-swapcache pages in end_swap_bio_read()
Message-Id: <20130607134303.a9bcff78691c38b03a8b3dde@linux-foundation.org>
In-Reply-To: <1370636598-5405-1-git-send-email-artem.savkov@gmail.com>
References: <20130607152653.GA3586@blaptop>
	<1370636598-5405-1-git-send-email-artem.savkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Savkov <artem.savkov@gmail.com>
Cc: minchan.kernel.2@gmail.com, dan.magenheimer@oracle.com, rjw@sisk.pl, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat,  8 Jun 2013 00:23:18 +0400 Artem Savkov <artem.savkov@gmail.com> wrote:

> There is no guarantee that page in end_swap_bio_read is in swapcache so we need
> to check it before calling page_swap_info(). Otherwise kernel hits a bug on
> like the one below.
> Introduced in "mm: remove compressed copy from zram in-memory"
> 
> kernel BUG at mm/swapfile.c:2361!

Fair enough.

> --- a/mm/page_io.c
> +++ b/mm/page_io.c
>
> ...
>
> +		/*
> +		 * There is no guarantee that the page is in swap cache, so
> +		 * we need to check PG_swapcache before proceeding with this
> +		 * optimization.
> +		 */

My initial thought was "how the heck can this not be a swapcache page".
So let's add the important details to this comment.

> +		if (unlikely(PageSwapCache(page))) {

Surely this is "likely".

> +			struct swap_info_struct *sis;
> +
> +			sis = page_swap_info(page);
> +			if (sis->flags & SWP_BLKDEV) {
> +				/*
> +				 * The swap subsystem performs lazy swap slot freeing,
> +				 * expecting that the page will be swapped out again.
> +				 * So we can avoid an unnecessary write if the page
> +				 * isn't redirtied.
> +				 * This is good for real swap storage because we can
> +				 * reduce unnecessary I/O and enhance wear-leveling
> +				 * if an SSD is used as the as swap device.
> +				 * But if in-memory swap device (eg zram) is used,
> +				 * this causes a duplicated copy between uncompressed
> +				 * data in VM-owned memory and compressed data in
> +				 * zram-owned memory.  So let's free zram-owned memory
> +				 * and make the VM-owned decompressed page *dirty*,
> +				 * so the page should be swapped out somewhere again if
> +				 * we again wish to reclaim it.
> +				 */

This comment now makes a horrid mess in an 80-col display.  I think we
may as well remove a tabstop here.

> +				struct gendisk *disk = sis->bdev->bd_disk;
> +				if (disk->fops->swap_slot_free_notify) {
> +					swp_entry_t entry;
> +					unsigned long offset;
> +
> +					entry.val = page_private(page);
> +					offset = swp_offset(entry);
> +
> +					SetPageDirty(page);
> +					disk->fops->swap_slot_free_notify(sis->bdev,
> +							offset);
> +				}
>  			}
>  		}
>  	}

Result:

--- a/mm/page_io.c~mm-remove-compressed-copy-from-zram-in-memory-fix-2-fix
+++ a/mm/page_io.c
@@ -81,51 +81,54 @@ void end_swap_bio_read(struct bio *bio,
 				imajor(bio->bi_bdev->bd_inode),
 				iminor(bio->bi_bdev->bd_inode),
 				(unsigned long long)bio->bi_sector);
-	} else {
-		SetPageUptodate(page);
+		goto out;
+	}
+
+	SetPageUptodate(page);
+
+	/*
+	 * There is no guarantee that the page is in swap cache - the software
+	 * suspend code (at least) uses end_swap_bio_read() against a non-
+	 * swapcache page.  So we must check PG_swapcache before proceeding with
+	 * this optimization.
+	 */
+	if (likely(PageSwapCache(page))) {
+		struct swap_info_struct *sis;
+
+		sis = page_swap_info(page);
+		if (sis->flags & SWP_BLKDEV) {
+			/*
+			 * The swap subsystem performs lazy swap slot freeing,
+			 * expecting that the page will be swapped out again.
+			 * So we can avoid an unnecessary write if the page
+			 * isn't redirtied.
+			 * This is good for real swap storage because we can
+			 * reduce unnecessary I/O and enhance wear-leveling
+			 * if an SSD is used as the as swap device.
+			 * But if in-memory swap device (eg zram) is used,
+			 * this causes a duplicated copy between uncompressed
+			 * data in VM-owned memory and compressed data in
+			 * zram-owned memory.  So let's free zram-owned memory
+			 * and make the VM-owned decompressed page *dirty*,
+			 * so the page should be swapped out somewhere again if
+			 * we again wish to reclaim it.
+			 */
+			struct gendisk *disk = sis->bdev->bd_disk;
+			if (disk->fops->swap_slot_free_notify) {
+				swp_entry_t entry;
+				unsigned long offset;
+
+				entry.val = page_private(page);
+				offset = swp_offset(entry);
 
-		/*
-		 * There is no guarantee that the page is in swap cache, so
-		 * we need to check PG_swapcache before proceeding with this
-		 * optimization.
-		 */
-		if (unlikely(PageSwapCache(page))) {
-			struct swap_info_struct *sis;
-
-			sis = page_swap_info(page);
-			if (sis->flags & SWP_BLKDEV) {
-				/*
-				 * The swap subsystem performs lazy swap slot freeing,
-				 * expecting that the page will be swapped out again.
-				 * So we can avoid an unnecessary write if the page
-				 * isn't redirtied.
-				 * This is good for real swap storage because we can
-				 * reduce unnecessary I/O and enhance wear-leveling
-				 * if an SSD is used as the as swap device.
-				 * But if in-memory swap device (eg zram) is used,
-				 * this causes a duplicated copy between uncompressed
-				 * data in VM-owned memory and compressed data in
-				 * zram-owned memory.  So let's free zram-owned memory
-				 * and make the VM-owned decompressed page *dirty*,
-				 * so the page should be swapped out somewhere again if
-				 * we again wish to reclaim it.
-				 */
-				struct gendisk *disk = sis->bdev->bd_disk;
-				if (disk->fops->swap_slot_free_notify) {
-					swp_entry_t entry;
-					unsigned long offset;
-
-					entry.val = page_private(page);
-					offset = swp_offset(entry);
-
-					SetPageDirty(page);
-					disk->fops->swap_slot_free_notify(sis->bdev,
-							offset);
-				}
+				SetPageDirty(page);
+				disk->fops->swap_slot_free_notify(sis->bdev,
+						offset);
 			}
 		}
 	}
 
+out:
 	unlock_page(page);
 	bio_put(bio);
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
