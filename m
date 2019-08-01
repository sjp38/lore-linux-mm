Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21EB4C41514
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:43:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEFF82171F
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:43:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEFF82171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CE438E0012; Thu,  1 Aug 2019 08:43:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 880A48E0001; Thu,  1 Aug 2019 08:43:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 794A38E0012; Thu,  1 Aug 2019 08:43:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5828E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 08:43:56 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k31so64649607qte.13
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 05:43:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J+9k/S68DBXDYMjK/GEbUO2G4IB9G2VugYB1lfvLjBA=;
        b=JO6FLJIW1unO2GBY0VOk/4dZSfkoYI5RO2saxItUZeGmv5mJCiagns6E5p1jeei+1E
         5mWBWc6kIrNqMHutCaaugDy7SY+jwYJ+0zh5LUShN8t7mcU84NxzO0IaOFDfUgVI8lU8
         yYk5xPb9ppd6hpHAaHCSIOQKmXai6tEjBgcQ0ZMqosxvq6emw0DYeXRGhuqJAcgNvDJ9
         LuQl+WYCj09FKJoaSVwj5xC2Zp2mWY6EiPmzfQY8EhptGvn7mnedeCTzq5MW/Ph0+rZ3
         XTkD99Ex3ZIWgkp9QMXqMGfZ5o/8VPi1WPUu9E15mu9krvDFSx7Uadrsa6mlrM1nk7wW
         IzXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXnT5X49QFRN56Dm9sZUpmAL8keRQl99MXk1M2hFsCZTvEpqXI+
	HwzAl3AtOGnQjHWDUnUM88XgfXFllLUci1e35ABRLGTCweHSeAmZHdVT/TKwdGtVoBA+zR0xG4F
	d3+9H4juxgIJzQJKSyhvuHzVSaqkMMisjXq4KcuGP+MJ2SMYNN3ozDqnMWHCmqyO6IQ==
X-Received: by 2002:a0c:b7a8:: with SMTP id l40mr92365562qve.142.1564663436148;
        Thu, 01 Aug 2019 05:43:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiVYeegCyzOIM8u8apPWxne1+5uHps4sk1BcKvHwTnVM5vqMUo4nstyak9BQ7NwgczzAi4
X-Received: by 2002:a0c:b7a8:: with SMTP id l40mr92365529qve.142.1564663435660;
        Thu, 01 Aug 2019 05:43:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564663435; cv=none;
        d=google.com; s=arc-20160816;
        b=hLqfXX9rBqDTyvVX8M9aANYvyOSfjhC4cUKQFCOdNB61Fl4iB7SV1LnqviMv7qwI2P
         DgSvyAi1gj8pCbG1rBvClm9HeBSjrmt3DqdgtsW/kmsRWEXwMwjqBpEpe4Ty/obAXZP9
         1sl3TURHHT61/v4YY18Sfpk+QcMjjbAOYIhHdhEuAlQL8zUaIyeep5bGsuvCEKLxQ52I
         +RloZAL2euo3eYLpgo6rtLtkPTH2tAvAIUVuni8BY8sgRpslc9A6Egio8EYqftyGHdtz
         FJildxoBZKnfR4sJfq28LoNwoaTR9qdEVJkzVA+CTzmPXmMIvEdOidL9cIsR4CcPHnvy
         PxxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J+9k/S68DBXDYMjK/GEbUO2G4IB9G2VugYB1lfvLjBA=;
        b=BodsV6MwxsY5hBObNKUK1QXRONVqhQ7VOG3MuhBCbH7p7OJDAiVpWYCovKChVGjmHa
         OjgzSf5KhwDOBc7ArZan0leW4n9DgYuqDpHOH0tHfqwJKn20LQ1AbsQ50XDB4B4Y45vH
         fK6oUFJSYv9iZiYZWj7WFx7SDY2wdomDq81vJ1v41YPkYE6TcNDByO3KBsuy0RQysUgH
         oDiYoOsGH9RudV30Zq/7gnQXVQPmpos08nuBdNjM6mtM+8Uu5BHrWWue4S7TmWOYSask
         BtEZYGOQ97d3ZbTG3Pk7xDvRHltYe0eKXNY0fpC+wZCFSmNLRcX/SZx6uY5sGjWQk0Bl
         Jk7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k67si35431916qkf.157.2019.08.01.05.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 05:43:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B4DDD308FF23;
	Thu,  1 Aug 2019 12:43:54 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id DE9E960A9F;
	Thu,  1 Aug 2019 12:43:52 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  1 Aug 2019 14:43:54 +0200 (CEST)
Date: Thu, 1 Aug 2019 14:43:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Message-ID: <20190801124351.GA31538@redhat.com>
References: <20190731183331.2565608-1-songliubraving@fb.com>
 <20190731183331.2565608-2-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731183331.2565608-2-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 01 Aug 2019 12:43:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/31, Song Liu wrote:
>
> +void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long haddr)
> +{
> +	struct vm_area_struct *vma = find_vma(mm, haddr);
> +	pmd_t *pmd = mm_find_pmd(mm, haddr);
> +	struct page *hpage = NULL;
> +	unsigned long addr;
> +	spinlock_t *ptl;
> +	int count = 0;
> +	pmd_t _pmd;
> +	int i;
> +
> +	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
> +
> +	if (!vma || !pmd || pmd_trans_huge(*pmd))
                            ^^^^^^^^^^^^^^^^^^^^

mm_find_pmd() returns NULL if pmd_trans_huge()

> +	/* step 1: check all mapped PTEs are to the right huge page */
> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> +		pte_t *pte = pte_offset_map(pmd, addr);
> +		struct page *page;
> +
> +		if (pte_none(*pte))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, *pte);
> +
> +		if (!PageCompound(page))
> +			return;
> +
> +		if (!hpage) {
> +			hpage = compound_head(page);
> +			if (hpage->mapping != vma->vm_file->f_mapping)

Hmm. But how can we know this is still the same vma ?

If nothing else, why vma->vm_file can't be NULL?

Say, a process unmaps this memory after khugepaged_add_pte_mapped_thp()
was called, then it does mmap(haddr, MAP_PRIVATE|MAP_ANONYMOUS), then
do_huge_pmd_anonymous_page() installs a huge page at the same address,
then split_huge_pmd() is called by any reason.

No?

