Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0593DC76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 03:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 943D2206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 03:20:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 943D2206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 196946B0003; Thu, 25 Jul 2019 23:20:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 120256B0005; Thu, 25 Jul 2019 23:20:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F29988E0002; Thu, 25 Jul 2019 23:20:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBB016B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:20:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so32040343pgk.16
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:20:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=hagU+U6M35C3mpB5PKk7c4uyB/4T5xiknS2lmZf42r8=;
        b=nuG4eWaotFsnFRW98UyRCZwIdu70PhMzg3QBszc/PaA4eqqczjbk/emqVAmNPuBqth
         Oo/zJDsHIzfFPMDJeQwPKjP040Pq5UWVHJf49lz82M47k5C+wb0uFGWUaSyjuhAybsNw
         L+wNmWkGxWmJmgwDS/VB0KJnRgkQQ8Na/kzTyExrQi3a5jT959a8tvN8/IKT0B2G5MXa
         y8nJ/98wo07TwTE58HlEgrgwet5H/kpsdNB3TPsRWxbmm98MFD8oyo+6vTJbT4uatdYp
         ymXOmuf1nHcsj58u7uLbxKdqIGKRSOrqm+0SFnkDjgMFUzyrYXt/gKTLv7RNMvLYhvHd
         eBDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX3o0Gg9Yqc/FlVVQh7hjjUqaKn1QI6KHGyVulGnEVmLG3SRqPJ
	g77gbwAcN6uVwMN6l3Ckzso0K1DmwUTZvg2RWW66vbOgtC+7e2JI67SBBlpTRlEBJgYsms2gPIu
	fCgnYGu1tloJfOmkrLVC3dbeNR4e/D9ih8wKrFBnyiSPUcwpf1B2oZp7UzArRhWqRWA==
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr98089676pjp.70.1564111258458;
        Thu, 25 Jul 2019 20:20:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziqxEs8lZjbtW/3xpIPwX5nCCDa8idRJ41catyzv24CHAl6D9dd2AeYl8JFuVCW8r/j5O6
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr98089628pjp.70.1564111257683;
        Thu, 25 Jul 2019 20:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564111257; cv=none;
        d=google.com; s=arc-20160816;
        b=TnvspQMSVRr0qDeaHRWqFhc6qkveIdSm9YO988TFOj4E3EWs3Rnmpx+JHC2HnQFSio
         ExJHsa3GJkWS1JCR4kIt+xoSU4s3rbZYKrbf+izyVWaAY4Z4j10ZpzDMSeDAOa8m1Fai
         GG+r+DUYXlYOkbOC7RXPa4cVcfdMLrMev0XfWTY5dije5gotT8Ycrx3VQZLHo7K6AK3U
         5yx5y97jpEns+hKSZ93GmknYHZ/HVfzIcYSYx9BbVCIJxdHq6prNoEIOl0rg21Ex+MEa
         MIIo1WPKDPpDbL6nkg5oRH3DDq3eYAOKmCkvP+DJB2v7cEC/7W5M3EJARjtmjOVuLwlC
         UIHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=hagU+U6M35C3mpB5PKk7c4uyB/4T5xiknS2lmZf42r8=;
        b=Ofh3lzUQUzk3o9dMJS6djZcBwBzJSlwpCcOS/4vCeE6AuP5DGK/L40VvSc/fR97Noh
         DhFEJVweohWa7ZEmcOHNVFgB4+ufxMs+WuOWVRLOjoUgG1tHQCmti6oqX0BTGoeMWfRn
         xetTyqtz3kwrWlOW9aL3GVNgN4QT10cruGnl1sly5V8btoxJpbQGTnhR89Qr1m6BUi8v
         bMCK4f3MYfzKqJDf+vuvEh/lle715+TmCdM1/XBdIQNu4tO1BsF9IS/1XNbQMxuPFJwD
         oX6rZEYPw0BvTTDvk1zPHFKf3ehbeLaw1NGDp+jL8t2HC/+j5ok+5zO5Tj8iV8+fuRbb
         v1sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x9si19400973plo.98.2019.07.25.20.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 20:20:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 20:20:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,309,1559545200"; 
   d="scan'208";a="369406245"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga005.fm.intel.com with ESMTP; 25 Jul 2019 20:20:56 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,  huang ying <huang.ying.caritas@gmail.com>,  Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,  <linux-mm@kvack.org>
Subject: Re: kernel BUG at mm/swap_state.c:170!
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
	<CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
	<CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
	<878ssqbj56.fsf@yhuang-dev.intel.com>
	<CABXGCsOhimxC17j=jApoty-o1roRhKYoe+oiqDZ3c1s2r3QxFw@mail.gmail.com>
	<87zhl59w2t.fsf@yhuang-dev.intel.com>
	<20190725114408.GV363@bombadil.infradead.org>
Date: Fri, 26 Jul 2019 11:20:55 +0800
In-Reply-To: <20190725114408.GV363@bombadil.infradead.org> (Matthew Wilcox's
	message of "Thu, 25 Jul 2019 04:44:08 -0700")
Message-ID: <87a7d17a7c.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox <willy@infradead.org> writes:

> On Tue, Jul 23, 2019 at 01:08:42PM +0800, Huang, Ying wrote:
>> @@ -2489,6 +2491,14 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>>  	/* complete memcg works before add pages to LRU */
>>  	mem_cgroup_split_huge_fixup(head);
>>  
>> +	if (PageAnon(head) && PageSwapCache(head)) {
>> +		swp_entry_t entry = { .val = page_private(head) };
>> +
>> +		offset = swp_offset(entry);
>> +		swap_cache = swap_address_space(entry);
>> +		xa_lock(&swap_cache->i_pages);
>> +	}
>> +
>>  	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
>>  		__split_huge_page_tail(head, i, lruvec, list);
>>  		/* Some pages can be beyond i_size: drop them from page cache */
>> @@ -2501,6 +2511,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>>  		} else if (!PageAnon(page)) {
>>  			__xa_store(&head->mapping->i_pages, head[i].index,
>>  					head + i, 0);
>> +		} else if (swap_cache) {
>> +			__xa_store(&swap_cache->i_pages, offset + i,
>> +				   head + i, 0);
>
> I tried something along these lines (though I think I messed up the offset
> calculation which is why it wasn't working for me).  My other concern
> was with the case where SWAPFILE_CLUSTER was less than HPAGE_PMD_NR.
> Don't we need to drop the lock and look up a new swap_cache if offset >=
> SWAPFILE_CLUSTER?

In swapfile.c, there is

#ifdef CONFIG_THP_SWAP
#define SWAPFILE_CLUSTER	HPAGE_PMD_NR
...
#else
#define SWAPFILE_CLUSTER	256
...
#endif

So, if a THP is in swap cache, then SWAPFILE_CLUSTER equals
HPAGE_PMD_NR.


And there is one swap address space for each 64M swap space.  So one THP
will be in one swap address space.

In swap.h, there is

/* One swap address space for each 64M swap space */
#define SWAP_ADDRESS_SPACE_SHIFT	14
#define SWAP_ADDRESS_SPACE_PAGES	(1 << SWAP_ADDRESS_SPACE_SHIFT)

Best Regards,
Huang, Ying

