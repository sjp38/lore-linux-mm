Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8017BC433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 09:07:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37B9F2089F
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 09:07:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="v8w3omLd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37B9F2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4DBF6B0005; Mon,  9 Sep 2019 05:07:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFD256B0006; Mon,  9 Sep 2019 05:07:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEC5B6B0007; Mon,  9 Sep 2019 05:07:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9F16B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 05:07:06 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E95D4824CA2F
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:07:05 +0000 (UTC)
X-FDA: 75914802810.04.shock50_3ae46925cf09
X-HE-Tag: shock50_3ae46925cf09
X-Filterd-Recvd-Size: 6375
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:07:05 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id c20so3235870eds.1
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 02:07:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4SKyZYA96ZSRssF5bkYvn8/ZaoQgr/75nnF3v6r+aa4=;
        b=v8w3omLdQptz1DFzG6nBTgRTann5rTwOgCIpzFAUG6tuIXQysQUnfXsX6/y/3pY3P9
         uuS7yln7izn8sa95u0TM8CxgbGe80u+X7t+BlonTv/Ols4bkZ2vzfkF1DV9YLxLMbFWT
         xMTJREdPJWH3jVZBD9E+ZKhbm9fxBa7VvxrMdRD31hii4MCogV1JmJclv2q1d2hOR8mU
         ZmP3pZ6SwqNXdDC1we1lskq5l3t193Mkb/3/NHR7WEDq49Askf9VlLY7UIB/Uu8JTBTS
         Nb6KVgXuECh0+jAIrDzxGYdOgJP/buaC0u2KcFllDTZyMTRwGgl/GCSf7CPvpXRD1ygX
         8PnA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=4SKyZYA96ZSRssF5bkYvn8/ZaoQgr/75nnF3v6r+aa4=;
        b=d+JL7AoBrI//QSYopnE8q3IuYJ3bP1rq5m0oHXeB7eZLeMYhjUXUQUGISarDtoxgCf
         rzVUDl6jpQZ2+3scx2TRK096IKilY/E55Z1q7s3zfj/MU45xDloU2sCG9NP4nt6JTYdJ
         t2GH7lDhS7Sc0HFhNEtM3YXDnW0tFVrdWV4wVPOY5UMxeRiyI6ae+X8gIT7RZlboMk5p
         PgMuYP6OajiFvGgJqC4VkQZ0OTmagyo5hqn2bQG1PtYXY+8LdN2mC4IjdNJMNdoaWi1n
         EKCWX2vVRxNRfarpFCzJZbpdNHqNFI6YA46VCPSj9sOwZXtyQGTRoa5kl3osfp1mIkWg
         o2qw==
X-Gm-Message-State: APjAAAVD6h/WptTZbVxwaKUZOhn/wzetuvR20AGtqjo7zUPDSfhd6uu7
	ga/bTvNqlixE5tozdiIvOTCtWA==
X-Google-Smtp-Source: APXvYqyy8JsEYXIXPZAEHqSPlkNj11nYxwtRGAlvmsF3QvGEid/LtADgJQP/uhTJkNkMTa1lQpdZXQ==
X-Received: by 2002:a17:906:af98:: with SMTP id mj24mr18377781ejb.199.1568020023846;
        Mon, 09 Sep 2019 02:07:03 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id t21sm1658127ejs.37.2019.09.09.02.07.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 02:07:03 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 94FB410022D; Mon,  9 Sep 2019 12:07:01 +0300 (+03)
Date: Mon, 9 Sep 2019 12:07:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
	catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, willy@infradead.org,
	mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
	will@kernel.org, linux-arm-kernel@lists.infradead.org,
	osalvador@suse.de, yang.zhang.wz@gmail.com, pagupta@redhat.com,
	konrad.wilk@oracle.com, nitesh@redhat.com, riel@surriel.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	ying.huang@intel.com, pbonzini@redhat.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, alexander.h.duyck@linux.intel.com,
	kirill.shutemov@linux.intel.com
Subject: Re: [PATCH v9 1/8] mm: Add per-cpu logic to page shuffling
Message-ID: <20190909090701.7ebz4foxyu3rxzvc@box>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172512.10910.74435.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190907172512.10910.74435.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Sep 07, 2019 at 10:25:12AM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Change the logic used to generate randomness in the suffle path so that we

Typo.

> can avoid cache line bouncing. The previous logic was sharing the offset
> and entropy word between all CPUs. As such this can result in cache line
> bouncing and will ultimately hurt performance when enabled.
> 
> To resolve this I have moved to a per-cpu logic for maintaining a unsigned
> long containing some amount of bits, and an offset value for which bit we
> can use for entropy with each call.
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  mm/shuffle.c |   33 +++++++++++++++++++++++----------
>  1 file changed, 23 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/shuffle.c b/mm/shuffle.c
> index 3ce12481b1dc..9ba542ecf335 100644
> --- a/mm/shuffle.c
> +++ b/mm/shuffle.c
> @@ -183,25 +183,38 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat)
>  		shuffle_zone(z);
>  }
>  
> +struct batched_bit_entropy {
> +	unsigned long entropy_bool;
> +	int position;
> +};
> +
> +static DEFINE_PER_CPU(struct batched_bit_entropy, batched_entropy_bool);
> +
>  void add_to_free_area_random(struct page *page, struct free_area *area,
>  		int migratetype)
>  {
> -	static u64 rand;
> -	static u8 rand_bits;
> +	struct batched_bit_entropy *batch;
> +	unsigned long entropy;
> +	int position;
>  
>  	/*
> -	 * The lack of locking is deliberate. If 2 threads race to
> -	 * update the rand state it just adds to the entropy.
> +	 * We shouldn't need to disable IRQs as the only caller is
> +	 * __free_one_page and it should only be called with the zone lock
> +	 * held and either from IRQ context or with local IRQs disabled.
>  	 */
> -	if (rand_bits == 0) {
> -		rand_bits = 64;
> -		rand = get_random_u64();
> +	batch = raw_cpu_ptr(&batched_entropy_bool);
> +	position = batch->position;
> +
> +	if (--position < 0) {
> +		batch->entropy_bool = get_random_long();
> +		position = BITS_PER_LONG - 1;
>  	}
>  
> -	if (rand & 1)
> +	batch->position = position;
> +	entropy = batch->entropy_bool;
> +
> +	if (1ul & (entropy >> position))

Maybe something like this would be more readble:

	if (entropy & BIT(position))

>  		add_to_free_area(page, area, migratetype);
>  	else
>  		add_to_free_area_tail(page, area, migratetype);
> -	rand_bits--;
> -	rand >>= 1;
>  }
> 
> 

-- 
 Kirill A. Shutemov

