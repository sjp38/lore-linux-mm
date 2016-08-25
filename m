Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA8BA6B0264
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 02:09:50 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so64487022pab.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 23:09:50 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id g90si13776801pfa.13.2016.08.24.23.09.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 23:09:50 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id ti13so13870629pac.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 23:09:49 -0700 (PDT)
Date: Thu, 25 Aug 2016 15:09:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC 0/4] ZRAM: make it just store the high compression rate page
Message-ID: <20160825060957.GA568@swordfish>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

Hello,

On (08/22/16 16:25), Hui Zhu wrote:
> 
> Current ZRAM just can store all pages even if the compression rate
> of a page is really low.  So the compression rate of ZRAM is out of
> control when it is running.
> In my part, I did some test and record with ZRAM.  The compression rate
> is about 40%.
> 
> This series of patches make ZRAM can just store the page that the
> compressed size is smaller than a value.
> With these patches, I set the value to 2048 and did the same test with
> before.  The compression rate is about 20%.  The times of lowmemorykiller
> also decreased.

I haven't looked at the patches in details yet. can you educate me a bit?
is your test stable? why the number of lowmemorykill-s has decreased?
... or am reading "The times of lowmemorykiller also decreased" wrong?

suppose you have X pages that result in bad compression size (from zram
point of view). zram stores such pages uncompressed, IOW we have no memory
savings - swapped out page lands in zsmalloc PAGE_SIZE class. now you
don't try to store those pages in zsmalloc, but keep them as unevictable.
so the page still occupies PAGE_SIZE; no memory saving again. why did it
improve LMK?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
