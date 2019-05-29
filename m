Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D39CC04E84
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 00:57:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D18642054F
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 00:57:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D18642054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C0AC6B027F; Tue, 28 May 2019 20:57:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 571536B0282; Tue, 28 May 2019 20:57:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 460B96B0286; Tue, 28 May 2019 20:57:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEC36B027F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 20:57:46 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 61so334663plr.21
        for <linux-mm@kvack.org>; Tue, 28 May 2019 17:57:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=UodIlrDs64vgoKY7EH+ZCKVmwYoBn5NsGUPuaAQvqVw=;
        b=QOlsGGR4dsAG1fuZzyjdnIuiMbwiTilxUBHJgP9O+Jb39uhqD67MS6L9h8Ryoxnk41
         syiQ/XwRia8uloyJBaKuFcCORfFNOCCG7p8JAXARLmUwRy0Aqu1VGzsFmHNBX2XrmJmE
         mkouM/O9j8sKVoVSJLPYndBUCmrtSh69RNvYlQrjquAslh9s1xUAIYp38fD6ianDL2CY
         IFIyY4/nwt349OV7ECJmnuqKaMR6TTMnrtTLwju6Xkdbeh9J6e+8gZg11+PAbeyZr7yI
         /9GJ983qIZUOZGyRLXF7/Yty749iF1X8T03CfcZOWDnpmFu9ONfGxkYIKMQ5zUYKMywA
         ZOEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWkezslyd7DgC8VhxcCK9H6MV1F1+8/rLyiAKssqiMgNtSXn8+A
	+GX6Fm7hwehw8Pxj23wLZJ6gPnoqVD9YFLOPH/gyCJA817TLE+oGafBSL6AP7lVDrgVALn7sWGh
	LZejePzFtpGd1f2tyaD5FfJocmbXe+dRNIlH2nHV4P/9FCB4bvmzODozOgw6IMQ5yQg==
X-Received: by 2002:a17:90a:9a87:: with SMTP id e7mr9116778pjp.90.1559091465530;
        Tue, 28 May 2019 17:57:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRAwd4lfHAWAYuLxn6ykWFBIhSgSzQwUQUxiJ2RNv2pkciDr7hBiItViQsUUvLS6zozNcz
X-Received: by 2002:a17:90a:9a87:: with SMTP id e7mr9116673pjp.90.1559091464503;
        Tue, 28 May 2019 17:57:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559091464; cv=none;
        d=google.com; s=arc-20160816;
        b=YZXeXqjzAuOiFh864rnZ5Eio7RhWvHMLCPbXZWs3sAPX7w24XzDFxZl02nSrWRZM6F
         jKqxBY81g8NLeOY5ErhZO3MRAddpIj0B8U4r+TjXMu2gdk6cMhmQRBoQulXcjXb66MVm
         XYmjiOOwEH8wJzqwk2OoPnGqLSiMtPsD9LsnmF7+TU72F8OOxx2Uu8IvVP9G4uQyS5Pc
         889oeA4GmqZQvmsyTSMwRGLJBlaoBAJuB+BU4SYKH8F0lAr5qQufYrr/ydVS0XASIS1Q
         Poi8DLUuhKA9Z3bBCSxoxZckxe8V3Vuj3ZvDfDiBbaBlsEKARigSB0UXvYSXLDffMEtu
         e70w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=UodIlrDs64vgoKY7EH+ZCKVmwYoBn5NsGUPuaAQvqVw=;
        b=NMdsq6c6JqEtElj2HXrN72ee04qLgmJg5a6DoujKHudov1fV3pCS8MC0URXRrG8rwr
         eIw6vHmxYrolQnOMeT3be1hGLWpNXtNMG37sTBObhD3Vc2KllldM7juKyhachs4umc9N
         Rhu63P0iBOhqwXyaxXFIQtr1K8po3srvWIXAOYsbdsqvcA51ne9z1TTCc7rcmTGAFufj
         ySPNq+W0jjwtqqSjYIGUETjqSNjICn/iO+JuINFOd2s6Jqnngx0lg6Pljc6MMfavfQyj
         hNxNLvW+3T46woI3sdKFng0c9FkUDNEt6BaSB1EZDsB36siIKqfORzdjUobF83R5MERw
         lvvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 92si23848632plf.299.2019.05.28.17.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 17:57:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 May 2019 17:57:42 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga004.jf.intel.com with ESMTP; 28 May 2019 17:57:41 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <josef@toxicpanda.com>,  <hughd@google.com>,  <shakeelb@google.com>,  <hdanton@sina.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [v7 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
References: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
	<1559025859-72759-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Wed, 29 May 2019 08:57:40 +0800
In-Reply-To: <1559025859-72759-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Tue, 28 May 2019 14:44:19 +0800")
Message-ID: <87sgsy6prv.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
> and some other vm counters still get inc'ed by one even though a whole
> THP (512 pages) gets swapped out.
>
> This doesn't make too much sense to memory reclaim.  For example, direct
> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
> could fulfill it.  But, if nr_reclaimed is not increased correctly,
> direct reclaim may just waste time to reclaim more pages,
> SWAP_CLUSTER_MAX * 512 pages in worst case.
>
> And, it may cause pgsteal_{kswapd|direct} is greater than
> pgscan_{kswapd|direct}, like the below:
>
> pgsteal_kswapd 122933
> pgsteal_direct 26600225
> pgscan_kswapd 174153
> pgscan_direct 14678312
>
> nr_reclaimed and nr_scanned must be fixed in parallel otherwise it would
> break some page reclaim logic, e.g.
>
> vmpressure: this looks at the scanned/reclaimed ratio so it won't
> change semantics as long as scanned & reclaimed are fixed in parallel.
>
> compaction/reclaim: compaction wants a certain number of physical pages
> freed up before going back to compacting.
>
> kswapd priority raising: kswapd raises priority if we scan fewer pages
> than the reclaim target (which itself is obviously expressed in order-0
> pages). As a result, kswapd can falsely raise its aggressiveness even
> when it's making great progress.
>
> Other than nr_scanned and nr_reclaimed, some other counters, e.g.
> pgactivate, nr_skipped, nr_ref_keep and nr_unmap_fail need to be fixed
> too since they are user visible via cgroup, /proc/vmstat or trace
> points, otherwise they would be underreported.
>
> When isolating pages from LRUs, nr_taken has been accounted in base
> page, but nr_scanned and nr_skipped are still accounted in THP.  It
> doesn't make too much sense too since this may cause trace point
> underreport the numbers as well.
>
> So accounting those counters in base page instead of accounting THP as
> one page.
>
> nr_dirty, nr_unqueued_dirty, nr_congested and nr_writeback are used by
> file cache, so they are not impacted by THP swap.
>
> This change may result in lower steal/scan ratio in some cases since
> THP may get split during page reclaim, then a part of tail pages get
> reclaimed instead of the whole 512 pages, but nr_scanned is accounted
> by 512, particularly for direct reclaim.  But, this should be not a
> significant issue.
>
> Cc: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Hillf Danton <hdanton@sina.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Looks good to me!  Thanks for your effort!

Reviewed-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

