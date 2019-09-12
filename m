Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54195C4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 12:02:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3E5120856
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 12:02:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="X9BwuCAM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3E5120856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8483A6B0005; Thu, 12 Sep 2019 08:02:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F81A6B0006; Thu, 12 Sep 2019 08:02:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E7286B0007; Thu, 12 Sep 2019 08:02:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0235.hostedemail.com [216.40.44.235])
	by kanga.kvack.org (Postfix) with ESMTP id 4E97D6B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:02:56 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E36A1181AC9BA
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 12:02:55 +0000 (UTC)
X-FDA: 75926132310.08.fact51_70caaba29ff10
X-HE-Tag: fact51_70caaba29ff10
X-Filterd-Recvd-Size: 12780
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 12:02:54 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id w2so1314471qkf.2
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 05:02:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NJ+V9WdH/Mr55CbE+4tCVIXroMyvqDzfmVNb8fYQdC4=;
        b=X9BwuCAMyL0HkIMHQZTrYkcKYoxesQQBc03dGTAerff++yYqnueCFUG+9R5d+jXfsD
         ILAnkSwukAjd9PMBWa9h1go0l+VstSm5Hci3nDYtrAlFN5FC8VzMhHh/wM1ypkfVi7I5
         xC2NQpOkaZGRGDDblnEmqtsCDwJjKPhPf1gxSpyhFJAfAnHkZToO0QVL3o7qmb6yq3kl
         /fPKJ36uZKtumx4PMe051elYi1fZr6YsGFpQtmalR3a03is+1tETesXYb8nLmi7YOgWT
         YbiZACAjO9JVtxcJOF8Fl8Vh+s/Y/AMgZMpVqQHjcJCPht1J5olzVhZ4edarhiUmbZFX
         4ajw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=NJ+V9WdH/Mr55CbE+4tCVIXroMyvqDzfmVNb8fYQdC4=;
        b=gQKa16vU15+0rN6Tok/3mtNE0sDH1OmayJ+f5XBZ8NuWyIH5iOd4v8nvf3NBwgvuFR
         bXOesjt/oWgtNxzpSC8RN/G5KpApGXWwMp0mPfrE2F5AebmOQTgNRWY886vtuUrbLZEb
         LZS+gaKnjxCS0rW5piZPf4PE8NU0v9Df/p3Q8J4poTk2xVzwdWr0tqkV3lG+7grWFvb4
         5mQ5pm2dg50GyGC3ZxX4KTlpQyam1Wmf2j5IignipFMVUA2/QFP5S7eNKed0//3BIR6S
         SzEmj0UHLKwykge6nRIsRWKefHQ+mH4S65LEmsrqKUJPH+jDVCDCvj+DChmrNtBxw2Rt
         aptw==
X-Gm-Message-State: APjAAAUlNBlwB4fNKxnNOxsp2JwxswV3KuV2WzSOdgUbyyhAKAFKQgkz
	ZXblpnbk4kc3U0kS/sSE+S+1/A==
X-Google-Smtp-Source: APXvYqxW3gfyTl86Ie7fIUSZxIf33R/kZjhqzOjknmiTByk8wlOSZatDorFjLent8xT63ngd7QqDdQ==
X-Received: by 2002:a05:620a:7c8:: with SMTP id 8mr1592111qkb.299.1568289774048;
        Thu, 12 Sep 2019 05:02:54 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id a72sm12098951qkg.77.2019.09.12.05.02.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Sep 2019 05:02:53 -0700 (PDT)
Message-ID: <1568289769.5576.138.camel@lca.pw>
Subject: Re: [PATCH] zswap: Add CONFIG_ZSWAP_IO_SWITCH
From: Qian Cai <cai@lca.pw>
To: Hui Zhu <teawaterz@linux.alibaba.com>, sjenning@redhat.com, 
 ddstreet@ieee.org, akpm@linux-foundation.org, mhocko@suse.com,
 willy@infradead.org,  chris@chris-wilson.co.uk, hannes@cmpxchg.org,
 ziqian.lzq@antfin.com,  osandov@fb.com, ying.huang@intel.com,
 aryabinin@virtuozzo.com, vovoy@chromium.org,  richard.weiyang@gmail.com,
 jgg@ziepe.ca, dan.j.williams@intel.com,  rppt@linux.ibm.com,
 jglisse@redhat.com, b.zolnierkie@samsung.com, axboe@kernel.dk, 
 dennis@kernel.org, josef@toxicpanda.com, tj@kernel.org, oleg@redhat.com, 
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Thu, 12 Sep 2019 08:02:49 -0400
In-Reply-To: <1568258490-25359-1-git-send-email-teawaterz@linux.alibaba.com>
References: <1568258490-25359-1-git-send-email-teawaterz@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-09-12 at 11:21 +0800, Hui Zhu wrote:
> I use zswap to handle the swap IO issue in a VM that uses a swap file.
> This VM has 4G memory and 2 CPUs.  And I set up 4G swap in /swapfile.
> This is test script:
> cat 1.sh
> ./usemem --sleep 3600 -M -a -n 1 $((3 * 1024 * 1024 * 1024)) &
> sleep 10
> echo 1 > /proc/sys/vm/drop_caches
> ./usemem -S -f /test2 $((2 * 1024 * 1024 * 1024)) &
> while [ True ]; do ./usemem -a -n 1 $((1 * 1024 * 1024 * 1024)); done
> 
> Without ZSWAP:
> echo 100 > /proc/sys/vm/swappiness
> swapon /swapfile
> sh 1.sh
> ...
> ...
> 1207959552 bytes / 2076479 usecs = 568100 KB/s
> 61088 usecs to free memory
> 1207959552 bytes / 2035439 usecs = 579554 KB/s
> 55073 usecs to free memory
> 2415919104 bytes / 24054408 usecs = 98081 KB/s
> 3741 usecs to free memory
> 1207959552 bytes / 1954371 usecs = 603594 KB/s
> 53161 usecs to free memory
> ...
> ...
> 
> With ZSWAP:
> echo 100 > /proc/sys/vm/swappiness
> swapon /swapfile
> echo lz4 > /sys/module/zswap/parameters/compressor
> echo zsmalloc > /sys/module/zswap/parameters/zpool
> echo 0 > /sys/module/zswap/parameters/same_filled_pages_enabled
> echo 20 > /sys/module/zswap/parameters/max_pool_percent
> echo 1 > /sys/module/zswap/parameters/enabled
> sh 1.sh
> 1207959552 bytes / 3619283 usecs = 325934 KB/s
> 194825 usecs to free memory
> 1207959552 bytes / 3439563 usecs = 342964 KB/s
> 218419 usecs to free memory
> 2415919104 bytes / 19508762 usecs = 120935 KB/s
> 5632 usecs to free memory
> 1207959552 bytes / 3329369 usecs = 354315 KB/s
> 179764 usecs to free memory
> 
> The normal io speed is increased from 98081 KB/s to 120935 KB/s.
> But I found 2 issues of zswap in this machine:
> 1. Because the disk of VM has the file cache in the host layer,
>    so normal swap speed is higher than with zswap.
> 2. Because zswap need allocates memory to store the compressed pages,
>    it will make memory capacity worse.
> For example:
> Command "./usemem -a -n 1 $((7 * 1024 * 1024 * 1024))" request 7G memory
> from this machine.
> It will work OK without zswap but got OOM when zswap is opened.
> 
> This commit adds CONFIG_ZSWAP_IO_SWITCH that try to handle the issues
> and let zswap keep save IO.
> It add two parameters read_in_flight_limit and write_in_flight_limit to
> zswap.
> In zswap_frontswap_store, pages will be stored to zswap only when
> the IO in flight number of swap device is bigger than
> zswap_read_in_flight_limit or zswap_write_in_flight_limit
> when zswap is enabled.
> Then the zswap just work when the IO in flight number of swap device
> is low.

There isn't sufficient information for users to decide when they should enable
this kconfig. Also, It describes your specific workload, but not clear to me how
this benefit other people's workloads in general.

> 
> This is the test result:
> echo 100 > /proc/sys/vm/swappiness
> swapon /swapfile
> echo lz4 > /sys/module/zswap/parameters/compressor
> echo zsmalloc > /sys/module/zswap/parameters/zpool
> echo 0 > /sys/module/zswap/parameters/same_filled_pages_enabled
> echo 20 > /sys/module/zswap/parameters/max_pool_percent
> echo 1 > /sys/module/zswap/parameters/enabled
> echo 3 > /sys/module/zswap/parameters/read_in_flight_limit
> echo 50 > /sys/module/zswap/parameters/write_in_flight_limit
> sh 1.sh
> ...
> 1207959552 bytes / 2320861 usecs = 508280 KB/s
> 106164 usecs to free memory
> 1207959552 bytes / 2343916 usecs = 503280 KB/s
> 79386 usecs to free memory
> 2415919104 bytes / 20136015 usecs = 117167 KB/s
> 4411 usecs to free memory
> 1207959552 bytes / 1833403 usecs = 643419 KB/s
> 70452 usecs to free memory
> ...
> killall usemem
> ./usemem -a -n 1 $((7 * 1024 * 1024 * 1024))
> 8455716864 bytes / 14457505 usecs = 571159 KB/s
> 365961 usecs to free memory
> 
> Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
> ---
>  include/linux/swap.h |  3 +++
>  mm/Kconfig           | 11 +++++++++++
>  mm/page_io.c         | 16 +++++++++++++++
>  mm/zswap.c           | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 85 insertions(+)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index de2c67a..82b621f 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -389,6 +389,9 @@ extern void end_swap_bio_write(struct bio *bio);
>  extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
>  	bio_end_io_t end_write_func);
>  extern int swap_set_page_dirty(struct page *page);
> +#ifdef CONFIG_ZSWAP_IO_SWITCH
> +extern void swap_io_in_flight(struct page *page, unsigned int inflight[2]);
> +#endif
>  
>  int add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
>  		unsigned long nr_pages, sector_t start_block);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 56cec63..d077e51 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -546,6 +546,17 @@ config ZSWAP
>  	  they have not be fully explored on the large set of potential
>  	  configurations and workloads that exist.
>  
> +config ZSWAP_IO_SWITCH
> +	bool "Compressed cache for swap pages according to the IO status"
> +	depends on ZSWAP
> +	def_bool n
> +	help
> +	  Add two parameters read_in_flight_limit and write_in_flight_limit to
> +	  ZSWAP.  When ZSWAP is enabled, pages will be stored to zswap only
> +	  when the IO in flight number of swap device is bigger than
> +	  zswap_read_in_flight_limit or zswap_write_in_flight_limit.
> +	  If unsure, say "n".
> +
>  config ZPOOL
>  	tristate "Common API for compressed memory storage"
>  	help
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 24ee600..e66b050 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -434,3 +434,19 @@ int swap_set_page_dirty(struct page *page)
>  		return __set_page_dirty_no_writeback(page);
>  	}
>  }
> +
> +#ifdef CONFIG_ZSWAP_IO_SWITCH
> +void swap_io_in_flight(struct page *page, unsigned int inflight[2])
> +{
> +	struct swap_info_struct *sis = page_swap_info(page);
> +
> +	if (!sis->bdev) {
> +		inflight[0] = 0;
> +		inflight[1] = 0;
> +		return;
> +	}
> +
> +	part_in_flight_rw(bdev_get_queue(sis->bdev), sis->bdev->bd_part,
> +					  inflight);
> +}
> +#endif
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 0e22744..1255645 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -62,6 +62,13 @@ static u64 zswap_reject_compress_poor;
>  static u64 zswap_reject_alloc_fail;
>  /* Store failed because the entry metadata could not be allocated (rare) */
>  static u64 zswap_reject_kmemcache_fail;
> +#ifdef CONFIG_ZSWAP_IO_SWITCH
> +/* Store failed because zswap_read_in_flight_limit or
> + * zswap_write_in_flight_limit is bigger than IO in flight number of
> + * swap device
> + */
> +static u64 zswap_reject_io;
> +#endif
>  /* Duplicate store was encountered (rare) */
>  static u64 zswap_duplicate_entry;
>  
> @@ -114,6 +121,22 @@ static bool zswap_same_filled_pages_enabled = true;
>  module_param_named(same_filled_pages_enabled, zswap_same_filled_pages_enabled,
>  		   bool, 0644);
>  
> +#ifdef CONFIG_ZSWAP_IO_SWITCH
> +/* zswap will not try to store the page if zswap_read_in_flight_limit is
> + * bigger than IO read in flight number of swap device
> + */
> +static unsigned int zswap_read_in_flight_limit;
> +module_param_named(read_in_flight_limit, zswap_read_in_flight_limit,
> +		   uint, 0644);
> +
> +/* zswap will not try to store the page if zswap_write_in_flight_limit is
> + * bigger than IO write in flight number of swap device
> + */
> +static unsigned int zswap_write_in_flight_limit;
> +module_param_named(write_in_flight_limit, zswap_write_in_flight_limit,
> +		   uint, 0644);
> +#endif
> +
>  /*********************************
>  * data structures
>  **********************************/
> @@ -1009,6 +1032,34 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  		goto reject;
>  	}
>  
> +#ifdef CONFIG_ZSWAP_IO_SWITCH
> +	if (zswap_read_in_flight_limit || zswap_write_in_flight_limit) {
> +		unsigned int inflight[2];
> +		bool should_swap = false;
> +
> +		swap_io_in_flight(page, inflight);
> +
> +		if (zswap_write_in_flight_limit &&
> +			inflight[1] < zswap_write_in_flight_limit)
> +			should_swap = true;
> +
> +		if (zswap_read_in_flight_limit &&
> +			(should_swap ||
> +			 (!should_swap && !zswap_write_in_flight_limit))) {
> +			if (inflight[0] < zswap_read_in_flight_limit)
> +				should_swap = true;
> +			else
> +				should_swap = false;
> +		}
> +
> +		if (should_swap) {
> +			zswap_reject_io++;
> +			ret = -EIO;
> +			goto reject;
> +		}
> +	}
> +#endif
> +
>  	/* reclaim space if needed */
>  	if (zswap_is_full()) {
>  		zswap_pool_limit_hit++;
> @@ -1264,6 +1315,10 @@ static int __init zswap_debugfs_init(void)
>  			   zswap_debugfs_root, &zswap_reject_kmemcache_fail);
>  	debugfs_create_u64("reject_compress_poor", 0444,
>  			   zswap_debugfs_root, &zswap_reject_compress_poor);
> +#ifdef CONFIG_ZSWAP_IO_SWITCH
> +	debugfs_create_u64("reject_io", 0444,
> +			   zswap_debugfs_root, &zswap_reject_io);
> +#endif
>  	debugfs_create_u64("written_back_pages", 0444,
>  			   zswap_debugfs_root, &zswap_written_back_pages);
>  	debugfs_create_u64("duplicate_entry", 0444,

