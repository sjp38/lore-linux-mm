Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 919936B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 03:01:17 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so157493208pac.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 00:01:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id o126si22843420pfo.30.2016.05.13.00.01.16
        for <linux-mm@kvack.org>;
        Fri, 13 May 2016 00:01:16 -0700 (PDT)
Subject: Re: why the count nr_file_pages is not equal to nr_inactive_file +
 nr_active_file ?
References: <573550D8.9030507@huawei.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <dce01643-7aa9-e779-e4ac-b74439f5074d@intel.com>
Date: Fri, 13 May 2016 15:00:58 +0800
MIME-Version: 1.0
In-Reply-To: <573550D8.9030507@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/13/2016 11:58 AM, Xishi Qiu wrote:
> I find the count nr_file_pages is not equal to nr_inactive_file + nr_active_file.
> There are 8 cpus, 2 zones in my system.
> 
> I think may be the pagevec trigger the problem, but PAGEVEC_SIZE is only 14.
> Does anyone know the reason?

One thing I can see is the ram backed filesystem where the page is
counted as NR_FILE_PAGE but go into the anonymous LRU list instead of
the file LRU list.

See function shmem_getpage_gfp.

An example:
[aaron@aaronlu ~]$ head -11 /proc/vmstat 
nr_free_pages 194472
nr_alloc_batch 58
nr_inactive_anon 483386
nr_active_anon 298161
nr_inactive_file 452791
nr_active_file 1942376
nr_unevictable 84
nr_mlock 84
nr_anon_pages 445332
nr_mapped 93553
nr_file_pages 2731481
[aaron@aaronlu ~]$ fallocate -l 400M /dev/shm/test
[aaron@aaronlu ~]$ head -11 /proc/vmstat 
nr_free_pages 94808
nr_alloc_batch 838
nr_inactive_anon 582385
nr_active_anon 298371
nr_inactive_file 452795
nr_active_file 1942380
nr_unevictable 84
nr_mlock 84
nr_anon_pages 445543
nr_mapped 93658
nr_file_pages 2830488

The nr_file_pages increased with nr_inactive_anon while the
nr_{in}active_file don't see much change.

Regards,
Aaron

> 
> Thanks,
> Xishi Qiu
> 
> root@hi3650:/ # cat /proc/vmstat 
> nr_free_pages 54192
> nr_inactive_anon 39830
> nr_active_anon 28794
> nr_inactive_file 432444
> nr_active_file 20659
> nr_unevictable 2363
> nr_mlock 0
> nr_anon_pages 65249
> nr_mapped 19742
> nr_file_pages 462723
> nr_dirty 20
> nr_writeback 0
> ...
> 
> 
> nr_inactive_file 432444
> nr_active_file 20659
> total is 453103
> 
> nr_file_pages 462723
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
