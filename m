Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5E2126B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 08:39:28 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id l20so2239828oag.9
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 05:39:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <513A9AF7.4020909@gmail.com>
References: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com>
	<51347A6E.8010608@iskon.hr>
	<CAAO_Xo6bWo4QOvdowLG88NoQr2AEq4jxCWHQXeA8g-VBT4Yk9Q@mail.gmail.com>
	<513A9AF7.4020909@gmail.com>
Date: Thu, 14 Mar 2013 20:39:27 +0800
Message-ID: <CAJd=RBAoNyniJpaeHafpWm0w7FfC9y+9+x_Gpdb74Jtzyk81HA@mail.gmail.com>
Subject: Re: Inactive memory keep growing and how to release it?
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Lenky Gao <lenky.gao@gmail.com>, Zlatko Calusic <zlatko.calusic@iskon.hr>, Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Sat, Mar 9, 2013 at 10:14 AM, Will Huck <will.huckk@gmail.com> wrote:
> Cc experts. Hugh, Johannes,
>
> On 03/04/2013 08:21 PM, Lenky Gao wrote:
>>
>> 2013/3/4 Zlatko Calusic <zlatko.calusic@iskon.hr>:
>>>
>>> The drop_caches mechanism doesn't free dirty page cache pages. And your
>>> bash
>>> script is creating a lot of dirty pages. Run it like this and see if it
>>> helps your case:
>>>
>>> sync; echo 3 > /proc/sys/vm/drop_caches
>>
>> Thanks for your advice.
>>
>> The inactive memory still cannot be reclaimed after i execute the sync
>> command:
>>
>> # cat /proc/meminfo | grep Inactive\(file\);
>> Inactive(file):   882824 kB
>> # sync;
>> # echo 3 > /proc/sys/vm/drop_caches
>> # cat /proc/meminfo | grep Inactive\(file\);
>> Inactive(file):   777664 kB
>>
>> I find these page becomes orphaned in this function, but do not understand
>> why:
>>
>> /*
>>   * If truncate cannot remove the fs-private metadata from the page, the
>> page
>>   * becomes orphaned.  It will be left on the LRU and may even be mapped
>> into
>>   * user pagetables if we're racing with filemap_fault().
>>   *
>>   * We need to bale out if page->mapping is no longer equal to the
>> original
>>   * mapping.  This happens a) when the VM reclaimed the page while we
>> waited on
>>   * its lock, b) when a concurrent invalidate_mapping_pages got there
>> first and
>>   * c) when tmpfs swizzles a page between a tmpfs inode and swapper_space.
>>   */
>> static int
>> truncate_complete_page(struct address_space *mapping, struct page *page)
>> {
>> ...
>>
>> My file system type is ext3, mounted with the opteion data=journal and
>> it is easy to reproduce.
>>

Perhaps we have to consider page count for orphan page if it
could be reproduced with mainline.

Hillf
---
--- a/mm/vmscan.c	Sun Mar 10 13:36:26 2013
+++ b/mm/vmscan.c	Thu Mar 14 20:29:40 2013
@@ -315,14 +315,14 @@ out:
 	return ret;
 }

-static inline int is_page_cache_freeable(struct page *page)
+static inline int is_page_cache_freeable(struct page *page, int has_mapping)
 {
 	/*
 	 * A freeable page cache page is referenced only by the caller
 	 * that isolated the page, the page cache radix tree and
 	 * optional buffer heads at page->private.
 	 */
-	return page_count(page) - page_has_private(page) == 2;
+	return page_count(page) - page_has_private(page) == has_mapping + 1;
 }

 static int may_write_to_queue(struct backing_dev_info *bdi,
@@ -393,7 +393,7 @@ static pageout_t pageout(struct page *pa
 	 * swap_backing_dev_info is bust: it doesn't reflect the
 	 * congestion state of the swapdevs.  Easy to fix, if needed.
 	 */
-	if (!is_page_cache_freeable(page))
+	if (!is_page_cache_freeable(page, mapping ? 1 : 0))
 		return PAGE_KEEP;
 	if (!mapping) {
 		/*
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
