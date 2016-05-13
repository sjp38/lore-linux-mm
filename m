Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52C1B6B025E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 03:35:38 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id sq19so19754729igc.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 00:35:38 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id n79si6627939ota.43.2016.05.13.00.35.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 May 2016 00:35:37 -0700 (PDT)
Message-ID: <573582DE.3030302@huawei.com>
Date: Fri, 13 May 2016 15:31:42 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: why the count nr_file_pages is not equal to nr_inactive_file
 + nr_active_file ?
References: <573550D8.9030507@huawei.com> <dce01643-7aa9-e779-e4ac-b74439f5074d@intel.com>
In-Reply-To: <dce01643-7aa9-e779-e4ac-b74439f5074d@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/5/13 15:00, Aaron Lu wrote:

> On 05/13/2016 11:58 AM, Xishi Qiu wrote:
>> I find the count nr_file_pages is not equal to nr_inactive_file + nr_active_file.
>> There are 8 cpus, 2 zones in my system.
>>
>> I think may be the pagevec trigger the problem, but PAGEVEC_SIZE is only 14.
>> Does anyone know the reason?
> 
> One thing I can see is the ram backed filesystem where the page is
> counted as NR_FILE_PAGE but go into the anonymous LRU list instead of
> the file LRU list.
> 
> See function shmem_getpage_gfp.
> 
> An example:
> [aaron@aaronlu ~]$ head -11 /proc/vmstat 
> nr_free_pages 194472
> nr_alloc_batch 58
> nr_inactive_anon 483386
> nr_active_anon 298161
> nr_inactive_file 452791
> nr_active_file 1942376
> nr_unevictable 84
> nr_mlock 84
> nr_anon_pages 445332
> nr_mapped 93553
> nr_file_pages 2731481
> [aaron@aaronlu ~]$ fallocate -l 400M /dev/shm/test
> [aaron@aaronlu ~]$ head -11 /proc/vmstat 
> nr_free_pages 94808
> nr_alloc_batch 838
> nr_inactive_anon 582385
> nr_active_anon 298371
> nr_inactive_file 452795
> nr_active_file 1942380
> nr_unevictable 84
> nr_mlock 84
> nr_anon_pages 445543
> nr_mapped 93658
> nr_file_pages 2830488
> 
> The nr_file_pages increased with nr_inactive_anon while the
> nr_{in}active_file don't see much change.
> 
> Regards,
> Aaron
> 

Hi Aaron,

Thanks for your reply, but I find the count of nr_shmem is very small
in my system.

root@hi3650:/ # cat /proc/vmstat 
nr_free_pages 54192
nr_inactive_anon 39830
nr_active_anon 28794
nr_inactive_file 432444
nr_active_file 20659
nr_unevictable 2363
nr_mlock 0
nr_anon_pages 65249
nr_mapped 19742
nr_file_pages 462723
nr_dirty 20
nr_writeback 0
nr_slab_reclaimable 259333
nr_slab_unreclaimable 33463
nr_page_table_pages 3456
nr_kernel_stack 892
nr_unstable 0
nr_bounce 11
nr_vmscan_write 292032
nr_vmscan_immediate_reclaim 47204474
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 128
nr_dirtied 69574
nr_written 356299
nr_anon_transparent_hugepages 0
nr_free_cma 7519
nr_swapcache 41972
nr_dirty_threshold 6982
nr_dirty_background_threshold 99297


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
