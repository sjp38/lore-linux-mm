Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6929EC74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 20:45:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2331B20844
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 20:45:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2331B20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B17A78E0095; Wed, 10 Jul 2019 16:45:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC9758E0032; Wed, 10 Jul 2019 16:45:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96A028E0095; Wed, 10 Jul 2019 16:45:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C47D8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 16:45:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j12so1890126pll.14
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:45:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=MwJLatTkf9kSjWXw64hRPS6an+x66nSUA9d6CHvSjzs=;
        b=S1M6iQT6SsVO9uXwd83Zw5G1m+6jEMWpkaKD5j3+2CPjvLy+BsyYgWfmfxspUqP4mq
         XlK5a7RsW7QSnbDzUPJKrMI0Bie7/C8Ix0Eb8GcvmyEC0ia8MYy1ExUaOUjPJ9LwIOJX
         uHs0d38JKFFVCDyWdnMlYoelGBcyxcYnxnydfwt35Qu4ZcN6NzxUsGDN+Xpj1jKfPcT1
         gPIi1ZP0XNJR7UjK1IemBg5EOTRtBs5gPIEZP71Zp5gk55uavf9HZp8LAuIlnV+1DWvS
         bJETDVCLMHBCEyvFP7YuZLQghsB/033Yukqay/m03m0IxDvgjyssyb6vdPIevB2+q7mW
         ZJ7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUsfdQOWBUpMWfCDh2CDNhGdMQ77XXTHFTaH1fWKq7zIwerJwu1
	m/dKoIeDZNPvnvWfw7TtQ70Nopdas8mHdkJihS/jraEbaju4Vn2KZaj2PCIBbNi7CiihzNzUslE
	f9sHGX1vYYwaApvEZkQSvTrI1I2ja2oCl9q/Jd+Rms5Z/Btk4nQB8hKlYHwIPYI+5fA==
X-Received: by 2002:a17:90a:bd0b:: with SMTP id y11mr280611pjr.141.1562791522047;
        Wed, 10 Jul 2019 13:45:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeULkQKJrDmZBsgmeJcRtmLLqK3jKkUsGaPWJrrBogR49wiL1pIiyZuUNTNsieEPHFczG6
X-Received: by 2002:a17:90a:bd0b:: with SMTP id y11mr280569pjr.141.1562791521321;
        Wed, 10 Jul 2019 13:45:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562791521; cv=none;
        d=google.com; s=arc-20160816;
        b=JVToN+n1QwHO+k1vSpfeUWZE5nuL0AKk+UBEavWDidnUADZvYqFqr0jKuX7uw/Y8DZ
         PNu25/Pk/768tDxFxtx7zmXrCX1logTuc/UNk/Ih0qVkDjSL+z3v63T0jKvnQXIUe7Hb
         2KOLI9Jx03BiEJNy59ic8otYjoG6WN5Mh7++BwtCtF2Y9xrofcptRwgq6rMHzML/JHMr
         Dkmef9N1r730NzNtwTOeMRKUXfGUzg8S716DCSB6bMikRK1EgJmV0v5vhUuQwX3uXpqM
         KX0X/BKHqEF24gHpHJVoHiP3BojnK7Pv599/rkesm8+d0aoSsc1E83uWrTB/WKasQvuu
         xz2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=MwJLatTkf9kSjWXw64hRPS6an+x66nSUA9d6CHvSjzs=;
        b=hc62B5rLi1FCodgkQ40DASQDfw/WG+lxBlRGeLXWAhtjuPsVsP14E8eQisD6QnXsbn
         YkIDyDfJFlIZtpMMjnJ2L/SqYqhiLLbxl4dRInFxUHpDXhTS8vHiTVxqsLPrCwIYcFZ+
         FxlYXUNOhRa7wDk/Xd9ihICuJzVKuOYJs5nHJQafkuk36ZF+jWLCL7TKgg5ACAI8CR7r
         3Lx/DkNtE97rplL/tQw9K0oSk8pmiDdjXSgsQsN8B5aRsME2G6ctdUwQUkr5Rf46l8yI
         BjLfOcwNRSK4pxeqeyRqm5MmQVvDiwVGOm/WK2Yb43r5kmAgH6IS2o8HxJiS3FKUTSIM
         qpRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 5si3026639plx.200.2019.07.10.13.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 13:45:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jul 2019 13:45:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,475,1557212400"; 
   d="scan'208";a="159871053"
Received: from akraina-mobl1.amr.corp.intel.com (HELO [10.251.14.235]) ([10.251.14.235])
  by orsmga008.jf.intel.com with ESMTP; 10 Jul 2019 13:45:20 -0700
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, david@redhat.com, mst@redhat.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com, john.starks@microsoft.com,
 mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-2-nitesh@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <3f9a7e7b-c026-3530-e985-804fc7f1ec31@intel.com>
Date: Wed, 10 Jul 2019 13:45:19 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190710195158.19640-2-nitesh@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/10/19 12:51 PM, Nitesh Narayan Lal wrote:
> +struct zone_free_area {
> +	unsigned long *bitmap;
> +	unsigned long base_pfn;
> +	unsigned long end_pfn;
> +	atomic_t free_pages;
> +	unsigned long nbits;
> +} free_area[MAX_NR_ZONES];

Why do we need an extra data structure.  What's wrong with putting
per-zone data in ... 'struct zone'?  The cover letter claims that it
doesn't touch core-mm infrastructure, but if it depends on mechanisms
like this, I think that's a very bad thing.

To be honest, I'm not sure this series is worth reviewing at this point.
 It's horribly lightly commented and full of kernel antipatterns lik

void func()
{
	if () {
		... indent entire logic
		... of function
	}
}

It has big "TODO"s.  It's virtually comment-free.  I'm shocked it's at
the 11th version and still looking like this.

> +
> +		for (zone_idx = 0; zone_idx < MAX_NR_ZONES; zone_idx++) {
> +			unsigned long pages = free_area[zone_idx].end_pfn -
> +					free_area[zone_idx].base_pfn;
> +			bitmap_size = (pages >> PAGE_HINTING_MIN_ORDER) + 1;
> +			if (!bitmap_size)
> +				continue;
> +			free_area[zone_idx].bitmap = bitmap_zalloc(bitmap_size,
> +								   GFP_KERNEL);

This doesn't support sparse zones.  We can have zones with massive
spanned page sizes, but very few present pages.  On those zones, this
will exhaust memory for no good reason.

Comparing this to Alex's patch set, it's of much lower quality and at a
much earlier stage of development.  The two sets are not really even
comparable right now.  This certainly doesn't sell me on (or even really
enumerate the deltas in) this approach vs. Alex's.

