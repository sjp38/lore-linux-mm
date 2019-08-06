Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 529CFC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:33:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F8392086D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:33:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F8392086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B677D6B0005; Tue,  6 Aug 2019 14:33:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B186E6B0006; Tue,  6 Aug 2019 14:33:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2EBA6B0007; Tue,  6 Aug 2019 14:33:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE056B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:33:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y22so48824507plr.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:33:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Cm9hk9u0afn+ZjMDnzSZ+v/EgUHwNgOxDe/V4NqAJfw=;
        b=B326qM9GLNfslPrGSI3Stw9jQZvbKQ/y62C0JrmRVSEC/CEeYioStLm54P+vnzItWe
         /aEiJAZ9x9jcBvvMCghixHZyAb6uIAgNuc13A8OjqPMRBdult1Uy//tLEfzEZuMe9M9Q
         eBlrnKMHHu5yejzUslilcf8FUYfTqXocsDAHm8Jos5ibiRTq1nlh5RuZPMQW6Obf6wKc
         +x0subxcCC37SOLVCU1lnZhJaB930jaRGb4Nrz2SOo7SnmJRsYlbHm2cPezHRQjjVJY/
         0GxKeu3JF43+g7ZRNeXP+ETYghfmK4c/zOBDqCikxVG61g/AUgjsAtMXi7ImSPcpGtr1
         gn0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXBRtCTYSmLGhHY+H0NVc11TROyTUZF+H6C5d9Lb96mStOuk8ig
	II7/oNdJzdp7tcNzhRrlDcUE9qW9pX6Q0ClNY9DO87QzFZPYxItLkqSGrhdj8q/JfpL0dxkC+Yu
	8kkHizgrHIsA4P2iuxrxfK0kQ4wHdUWQmSM7rVFSH5QsU2a6a7pf9yx1SjC2nTWXEBA==
X-Received: by 2002:aa7:9210:: with SMTP id 16mr5259042pfo.11.1565116394091;
        Tue, 06 Aug 2019 11:33:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxrsPP5qmiLpZe0O8fnIyI0hSGXZOVZ3LDQvwTeAb7mRRFOluRkKZ94spq6wqEka+FsKtP
X-Received: by 2002:aa7:9210:: with SMTP id 16mr5258978pfo.11.1565116393225;
        Tue, 06 Aug 2019 11:33:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565116393; cv=none;
        d=google.com; s=arc-20160816;
        b=mF128fXN/Hh9as+puykq1deUnoAYz0364t4PAxeZIrn9gRKEL7AfWzKddFTE48bcJE
         9lepTfTzohVwk6RFTuK77I6claSyLVRbgPF8ZxE4TyqLAoDPedfcgqt21hir58LFfjd0
         nEBRD0SaCNYQ80///J4HjEUj5B0SmplTWnEVd39MdEI4Gnc3CzuYXrc/+kiAUjXlKt2s
         JGKTY2ZmJnDxHVzI37gZvyY7jjA9rNotuWJYUtnVS06ykjdMkKA8l4mK/En2jWHPrhkR
         mENylgEtph5j0JkWempKJ7S4/vokSLER9v8l45IROmiLjBjiXD3EblvJLHajnfdnOepC
         zXGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=Cm9hk9u0afn+ZjMDnzSZ+v/EgUHwNgOxDe/V4NqAJfw=;
        b=sDmgrWVk8S/3sNjN4RQqTAxt3yeegnwjc6WMJKFfLpir2NV7DK5LZzxRIN7uAhJz0I
         9HGPfc/Aa3F2/gazWRGDSiE2/FskPs1XC3RWCtsYh2VZZ580ijnWOlMg4yqOlzgu1TwM
         5ugbXqDA1CDTW+49fGZLPVQnYfoCi6wAT/bh8GWDX2w9MC+8cBL5d8yDA8syp/2yW2rr
         4fav/S6RmKID4E17rjRiQ2VYQeNge0PX9iTgw9Hm+Jl1Nh34F/ZGu+d9qS+VP5rvMBga
         36qauDqC2s2zleVIXUNxya4We/GpJs07rxohG1nqushCMchdZYwSkJeqVfPz7Ub3VU2g
         x/Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id j187si47327308pge.591.2019.08.06.11.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 11:33:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 11:33:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="168378909"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by orsmga008.jf.intel.com with ESMTP; 06 Aug 2019 11:33:12 -0700
Message-ID: <9a09db3d4827bc6bf49c4579d495d71015f2c5a6.camel@intel.com>
Subject: Re: [PATCH V2] fork: Improve error message for corrupted page tables
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org
Cc: Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter
 Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>,
 Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 06 Aug 2019 11:30:02 -0700
In-Reply-To: <73b77479-cdd2-6d53-14ae-25ec4c4c3d25@intel.com>
References: 
	<3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
	 <73b77479-cdd2-6d53-14ae-25ec4c4c3d25@intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-06 at 09:30 -0700, Dave Hansen wrote:
> On 8/5/19 8:05 PM, Sai Praneeth Prakhya wrote:
> > +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> > +	[MM_FILEPAGES]		= "MM_FILEPAGES",
> > +	[MM_ANONPAGES]		= "MM_ANONPAGES",
> > +	[MM_SWAPENTS]		= "MM_SWAPENTS",
> > +	[MM_SHMEMPAGES]		= "MM_SHMEMPAGES",
> > +};
> 
> One trick to ensure that this gets updated if the names are ever
> updated.  You can do:
> 
> #define NAMED_ARRAY_INDEX(x)	[x] = __stringify(x),
> 
> and
> 
> static const char * const resident_page_types[NR_MM_COUNTERS] = {
> 	NAMED_ARRAY_INDEX(MM_FILE_PAGES),
> 	NAMED_ARRAY_INDEX(MM_SHMEMPAGES),
> 	...
> };

Thanks for the suggestion Dave. I will add this in V3.
Even with this, (if ever) anyone who changes the name of page types or adds an
new entry would still need to update struct resident_page_types[]. So, I will
add the comment as suggested by Vlastimil.

> 
> That makes sure that any name changes make it into the strings.  Then
> stick a:
> 
> 	BUILD_BUG_ON(NR_MM_COUNTERS != ARRAY_SIZE(resident_page_types));
> 
> somewhere.  That makes sure that any new array indexes get a string
> added in the array.  Otherwise you get nice, early, compile-time errors.

Sure! this sounds good and a small nit-bit :)
For the BUILD_BUG_ON() to work, the definition of struct should be changed as
below

static const char * const resident_page_types[] = {
...
}

i.e. we should not specify the size of array.

Regards,
Sai

