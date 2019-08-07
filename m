Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 475E1C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:13:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFD352229C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:13:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFD352229C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A09136B0008; Wed,  7 Aug 2019 12:13:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BD0C6B000A; Wed,  7 Aug 2019 12:13:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8838D6B000C; Wed,  7 Aug 2019 12:13:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 508056B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 12:13:57 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so52816999pld.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 09:13:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nf5Yi0RszZon8GeZ3EGx/9NJnTKej9HSo4gx01EFB74=;
        b=kpF+8Po2KUlp//jUzDPfmzoYBQ/hBLZg2puLVNy5zhVc4mMw0qSo9l0LqYJPs/QPMb
         oHJCsZw0UCn5YDhlNGdQF46UUfXmGBplAjj206UR5gSyuIvGEQ5nqEZDIAV4UDLrX1QX
         sIYQ+l1rxd9Ay24Oy45c9E2mw+wsAY/n9I9QSLd1wButN5di4lBbeKD2fm5mbuSq1rCU
         UWuWTw5YvJONYXi00fFdO6KHdgDzthUJm58DkpoE0Ci1fQUbE6FAmVgJfPHRsxzc61Si
         LiDmS79EtNTfj83JMQA/Ha+5OVe2sV1K6p/ypBpmJzEhpn32JhW9SDrd3V0laXqV79SM
         +hIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUNpwGoUMewgcutMIlPuepc9n4EbOuII81J+qWELzFG9eU9G513
	b9tN41BWk8V31qF4o+SLL9SR/WMe9UqgSmc7j5n4x53zXH68T0rwFtw8XNWoW1CR5DoRe7YYYmT
	v0u93a57Fa1x+VxVt7eV+59UMCPgOqiJPd6SIKtd7fwWi3D6+85YjeAMk21HDbsjHUQ==
X-Received: by 2002:a63:c013:: with SMTP id h19mr8449048pgg.108.1565194436526;
        Wed, 07 Aug 2019 09:13:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJIgeFeyuFFHOMLanowX2lMFKbS/yLs32neD3m63mg1v41S7ayMbazCKviCyC3XMGRGmsn
X-Received: by 2002:a63:c013:: with SMTP id h19mr8448974pgg.108.1565194435439;
        Wed, 07 Aug 2019 09:13:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565194435; cv=none;
        d=google.com; s=arc-20160816;
        b=uawqebI2fBUgl9js3QR13GAlc/WfED8GNLF1i9fVoQn4FIrZC81IirvnusdGNxm1Sc
         44qXzDemmdKsSBBMAn6tqUzljf0EmfdBiwXd/DlwM84YuNcnsuV3NTlBhNE6y7StmAzn
         880QeBBJS0QepbdBEw4DBOGKt2I6HgSDXUsv8JtUm/7wSHIPekPgYeNordjCJjfBCyi2
         J8wvp1FBOXa0rAJWe9dSUFlLX1RUI5M88glnTJYapRHUIYtVU6BEfrWUbnAsNRAjsxEP
         QI2xoi2HlqYvlwxSDyI0Fge714JCL9UY7DLSNAd3BEHWP6vMWCecrRORm9IicP3nTivN
         O+xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nf5Yi0RszZon8GeZ3EGx/9NJnTKej9HSo4gx01EFB74=;
        b=E62p7PkmvP3DjDrCm+bzMd2KXp0DHkHGb6pxicMskO+QFpKJIxnrjFmQqYUEe70DCB
         JoXjEly8P1TwAYWjAsu0Fd8KtbtukrdmsywwUAsCQdedsjB3kfMOLT+FKFMCHCWX3tUw
         Tlo/Aamjr6wuUxvTwKjrffjp5lVEsWg+8k8k6QoEnqAf8a/nRpgT6xiFgXK7UqUGKppt
         n1eobOebe/voipxzgog0xjxdeJ5RJFYwSzz2aXTtJKzVayWcePvx2WylZMYxTjI7TXzn
         BmVgtNlYBb5xrA0IZT3oq8etPKyZkQqO7bq7qEUEIkoY5uy6Riu+ktE6JeZ/QyqY4rYC
         +xXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id y8si44179135plk.428.2019.08.07.09.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 09:13:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Aug 2019 09:13:54 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,357,1559545200"; 
   d="scan'208";a="182325788"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by FMSMGA003.fm.intel.com with ESMTP; 07 Aug 2019 09:13:53 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hvOZV-0006Ja-5r; Thu, 08 Aug 2019 00:13:53 +0800
Date: Thu, 8 Aug 2019 00:12:59 +0800
From: kbuild test robot <lkp@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: kbuild-all@01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 04/24] shrinker: defer work only to kswapd
Message-ID: <201908080021.L0zJBvz1%lkp@intel.com>
References: <20190801021752.4986-5-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-5-david@fromorbit.com>
X-Patchwork-Hint: ignore
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[cannot apply to v5.3-rc3 next-20190807]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Dave-Chinner/mm-xfs-non-blocking-inode-reclaim/20190804-042311
reproduce:
        # apt-get install sparse
        # sparse version: v0.6.1-rc1-7-g2b96cd8-dirty
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)

>> mm/vmscan.c:539:70: sparse: sparse: incorrect type in argument 1 (different base types) @@    expected struct atomic64_t [usertype] *v @@    got ruct atomic64_t [usertype] *v @@
>> mm/vmscan.c:539:70: sparse:    expected struct atomic64_t [usertype] *v
>> mm/vmscan.c:539:70: sparse:    got struct atomic_t [usertype] *
   arch/x86/include/asm/irqflags.h:54:9: sparse: sparse: context imbalance in 'check_move_unevictable_pages' - unexpected unlock

vim +539 mm/vmscan.c

   498	
   499	static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
   500					    struct shrinker *shrinker, int priority)
   501	{
   502		unsigned long freed = 0;
   503		int64_t freeable_objects = 0;
   504		int64_t scan_count;
   505		int64_t scanned_objects = 0;
   506		int64_t next_deferred = 0;
   507		int64_t deferred_count = 0;
   508		long new_nr;
   509		int nid = shrinkctl->nid;
   510		long batch_size = shrinker->batch ? shrinker->batch
   511						  : SHRINK_BATCH;
   512	
   513		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
   514			nid = 0;
   515	
   516		scan_count = shrink_scan_count(shrinkctl, shrinker, priority,
   517						&freeable_objects);
   518		if (scan_count == 0 || scan_count == SHRINK_EMPTY)
   519			return scan_count;
   520	
   521		/*
   522		 * If kswapd, we take all the deferred work and do it here. We don't let
   523		 * direct reclaim do this, because then it means some poor sod is going
   524		 * to have to do somebody else's GFP_NOFS reclaim, and it hides the real
   525		 * amount of reclaim work from concurrent kswapd operations. Hence we do
   526		 * the work in the wrong place, at the wrong time, and it's largely
   527		 * unpredictable.
   528		 *
   529		 * By doing the deferred work only in kswapd, we can schedule the work
   530		 * according the the reclaim priority - low priority reclaim will do
   531		 * less deferred work, hence we'll do more of the deferred work the more
   532		 * desperate we become for free memory. This avoids the need for needing
   533		 * to specifically avoid deferred work windup as low amount os memory
   534		 * pressure won't excessive trim caches anymore.
   535		 */
   536		if (current_is_kswapd()) {
   537			int64_t	deferred_scan;
   538	
 > 539			deferred_count = atomic64_xchg(&shrinker->nr_deferred[nid], 0);
   540	
   541			/* we want to scan 5-10% of the deferred work here at minimum */
   542			deferred_scan = deferred_count;
   543			if (priority)
   544				do_div(deferred_scan, priority);
   545			scan_count += deferred_scan;
   546	
   547			/*
   548			 * If there is more deferred work than the number of freeable
   549			 * items in the cache, limit the amount of work we will carry
   550			 * over to the next kswapd run on this cache. This prevents
   551			 * deferred work windup.
   552			 */
   553			if (deferred_count > freeable_objects * 2)
   554				deferred_count = freeable_objects * 2;
   555	
   556		}
   557	
   558		/*
   559		 * Avoid risking looping forever due to too large nr value:
   560		 * never try to free more than twice the estimate number of
   561		 * freeable entries.
   562		 */
   563		if (scan_count > freeable_objects * 2)
   564			scan_count = freeable_objects * 2;
   565	
   566		trace_mm_shrink_slab_start(shrinker, shrinkctl, deferred_count,
   567					   freeable_objects, scan_count,
   568					   scan_count, priority);
   569	
   570		/*
   571		 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
   572		 * defer the work to a context that can scan the cache.
   573		 */
   574		if (shrinkctl->will_defer)
   575			goto done;
   576	
   577		/*
   578		 * Normally, we should not scan less than batch_size objects in one
   579		 * pass to avoid too frequent shrinker calls, but if the slab has less
   580		 * than batch_size objects in total and we are really tight on memory,
   581		 * we will try to reclaim all available objects, otherwise we can end
   582		 * up failing allocations although there are plenty of reclaimable
   583		 * objects spread over several slabs with usage less than the
   584		 * batch_size.
   585		 *
   586		 * We detect the "tight on memory" situations by looking at the total
   587		 * number of objects we want to scan (total_scan). If it is greater
   588		 * than the total number of objects on slab (freeable), we must be
   589		 * scanning at high prio and therefore should try to reclaim as much as
   590		 * possible.
   591		 */
   592		while (scan_count >= batch_size ||
   593		       scan_count >= freeable_objects) {
   594			unsigned long ret;
   595			unsigned long nr_to_scan = min_t(long, batch_size, scan_count);
   596	
   597			shrinkctl->nr_to_scan = nr_to_scan;
   598			shrinkctl->nr_scanned = nr_to_scan;
   599			ret = shrinker->scan_objects(shrinker, shrinkctl);
   600			if (ret == SHRINK_STOP)
   601				break;
   602			freed += ret;
   603	
   604			count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
   605			scan_count -= shrinkctl->nr_scanned;
   606			scanned_objects += shrinkctl->nr_scanned;
   607	
   608			cond_resched();
   609		}
   610	
   611	done:
   612		if (deferred_count)
   613			next_deferred = deferred_count - scanned_objects;
   614		else if (scan_count > 0)
   615			next_deferred = scan_count;
   616		/*
   617		 * move the unused scan count back into the shrinker in a
   618		 * manner that handles concurrent updates. If we exhausted the
   619		 * scan, there is no need to do an update.
   620		 */
   621		if (next_deferred > 0)
   622			new_nr = atomic_long_add_return(next_deferred,
   623							&shrinker->nr_deferred[nid]);
   624		else
   625			new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
   626	
   627		trace_mm_shrink_slab_end(shrinker, nid, freed, deferred_count, new_nr,
   628						scan_count);
   629		return freed;
   630	}
   631	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

