Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41825C04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAB222177E
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:49:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ngKRs85U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAB222177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C33F6B0007; Thu,  9 May 2019 12:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 825946B0008; Thu,  9 May 2019 12:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69EB56B000A; Thu,  9 May 2019 12:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31D196B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:49:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 61so805110plr.21
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gE30E8WxB7hYkwUgNS86rgGRZVvaab/3r9G8N035r+M=;
        b=ddysf4ubtKId+UfH6xBU7JRw9gMGk9/Rsm3tvCs1J/zFB4dSNCdaHpi3oUAczIj+Z7
         6hvF9FhVGvAb6nbtQ/qMacqZUWdQcPjf0zzBWsZLAdo0UszTfynQOrZfWVNszLvCYoAc
         6txS3q7ACrmWdXKojthnoxSjQZjB+K8m78RW6fU41d3Y86jbPfSAyia8znTvF44qOlqs
         /CDHn9LgUlcN55MWcb/zuwwbP1kJDjh0xC/qtROjuEjRn/xswIhCdrxGvcucO6A3bO/C
         zJg4Sn1Zxg3nOOR+94Qa8G17lV3ZqTkwdgmRqZFF592ZZocYyu8kQgDiDrDmtHTwGrJu
         W8Sw==
X-Gm-Message-State: APjAAAXOjajPxaLo3asag2/tXaDoT8efvVn681iDV/6rrCLa84nWOXKt
	MFjC/Bd3LaCorZu1ipqB92B0dOLB+b/g8W6ONJxvjuiPru9v3IUQ+0hP70xqnpAZSDf9M6ubhOj
	WAmNiBh9WccSwsjZLqYejWrnxRW3b1Lc/vT9RAseNXoBHAetf3YBx6JqOOdbcF6hLhw==
X-Received: by 2002:aa7:9ac4:: with SMTP id x4mr6705494pfp.43.1557420557717;
        Thu, 09 May 2019 09:49:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJnENtUYQ4r4ZLhFzaSJtQvgCw2zm9JTPk1UaKq1ygUO/xdHBjzu0zxkueREY1g5j2IOwF
X-Received: by 2002:aa7:9ac4:: with SMTP id x4mr6705401pfp.43.1557420556975;
        Thu, 09 May 2019 09:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557420556; cv=none;
        d=google.com; s=arc-20160816;
        b=KxwNSKKFeIjWh/1SvKGzNbXVWE2/t8KBM6nBmH53QOyQWDBgNo6c9u7aRAi4Evgwci
         yLgZcxoH7yo+io1wZflEF5LSDsXD++gnJ2LFjDO3IFGsWKOCwaSNHzmrIEGKkloPD51u
         NefR9XTHT02KYDuVdfJhv8BBdHeOOLplmVqBkMYzSVA5H/vGDMuhiFW9Rqu1xq8KzLys
         RoV1x43fi+FaFQ4lItFqgzLU0WU0MiWzSccPBk4UkPsfsx8MUwDOYdYgoS2gzBXUQM8V
         CY2PwZ+kiwmWV2Tw+pbEPIF2MxQOxYZprQYBRAOb7TQm4TXT3ul0KdcxPKqOsvKrBsUq
         FTMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gE30E8WxB7hYkwUgNS86rgGRZVvaab/3r9G8N035r+M=;
        b=IEPLJ5QL/w7kNExe+0PqPxQLer9j5vpFwWlEHT0gdESftduIOce7asn0lvXImhTNNd
         x6eYgm5G1z+3NJygPNiYRYrKO6ppuR+8kQJrQat1TQD9bVmK5wzaguyX+KFGwCGvpZnA
         igZ9queNTn0xnhDeUSZLf4Ow0Kx3EYoapapIAvTq9aaZ5RNn5Zx0p9e9VBBgY9Q9zaVt
         rUReXPjiCfwEvohZYzlXlU+qUJ/5hQGi5+Vt7grfYhKyYg+QU4eCpNP1DnTnzkgibZ7o
         xzxL0iswxeruBmyi+KCt7u0ykHHzxjEj+aXwsRs0ywrKqVFABVXCQzjGXq90SSpW5l2c
         Z0mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ngKRs85U;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f7si3820372pgq.522.2019.05.09.09.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 09:49:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ngKRs85U;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=gE30E8WxB7hYkwUgNS86rgGRZVvaab/3r9G8N035r+M=; b=ngKRs85UnQEDP1Ga/hab969hD
	GJhNmb9d7tPvBnkqLCuslGiXSWmVI/YSrhJAMIgJuJwkw746cyxl7cwv8I6dGzS6Junajeay76jrx
	HR2KCrYlqSTd3LCJXwhsGsmRX2EzQ5w4lmVfrYKm9xKmhkuTwxeDVt10+iLMa0liuT/qBloRrFU9+
	+s9EaOjVbm3Po1En6NrE1SP2yh58GpTqxbb0d2n15TtyBbMpGFzuaUU9mOnubwtx3OetcFPcCQx0z
	N8Xo9IhQywCFx1ybna0TEVHom1/suyCkds4AdGVeWmPkgZ5kmq0oABWghyswJnZyRZly6+T9heD12
	/O8LeqsOw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOmEM-0004xN-Cr; Thu, 09 May 2019 16:49:14 +0000
Date: Thu, 9 May 2019 09:49:14 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Larry Bassel <larry.bassel@oracle.com>
Cc: mike.kravetz@oracle.com, dan.j.williams@intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Message-ID: <20190509164914.GA3862@bombadil.infradead.org>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 09:05:33AM -0700, Larry Bassel wrote:
> This is based on (but somewhat different from) what hugetlbfs
> does to share/unshare page tables.

Wow, that worked out far more cleanly than I was expecting to see.

> @@ -4763,6 +4763,19 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
>  				unsigned long *start, unsigned long *end)
>  {
>  }
> +
> +unsigned long page_table_shareable(struct vm_area_struct *svma,
> +				   struct vm_area_struct *vma,
> +				   unsigned long addr, pgoff_t idx)
> +{
> +	return 0;
> +}
> +
> +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> +{
> +	return false;
> +}

I don't think you need these stubs, since the only caller of them is
also gated by MAY_SHARE_FSDAX_PMD ... right?

> +	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
> +		if (svma == vma)
> +			continue;
> +
> +		saddr = page_table_shareable(svma, vma, addr, idx);
> +		if (saddr) {
> +			spmd = huge_pmd_offset(svma->vm_mm, saddr,
> +					       vma_mmu_pagesize(svma));
> +			if (spmd) {
> +				get_page(virt_to_page(spmd));
> +				break;
> +			}
> +		}
> +	}

I'd be tempted to reduce the indentation here:

	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
		if (svma == vma)
			continue;

		saddr = page_table_shareable(svma, vma, addr, idx);
		if (!saddr)
			continue;

		spmd = huge_pmd_offset(svma->vm_mm, saddr,
					vma_mmu_pagesize(svma));
		if (spmd)
			break;
	}


> +	if (!spmd)
> +		goto out;

... and move the get_page() down to here, so we don't split the
"when we find it" logic between inside and outside the loop.

	get_page(virt_to_page(spmd));

> +
> +	ptl = pmd_lockptr(mm, spmd);
> +	spin_lock(ptl);
> +
> +	if (pud_none(*pud)) {
> +		pud_populate(mm, pud,
> +			    (pmd_t *)((unsigned long)spmd & PAGE_MASK));
> +		mm_inc_nr_pmds(mm);
> +	} else {
> +		put_page(virt_to_page(spmd));
> +	}
> +	spin_unlock(ptl);
> +out:
> +	pmd = pmd_alloc(mm, pud, addr);
> +	i_mmap_unlock_write(mapping);

I would swap these two lines.  There's no need to hold the i_mmap_lock
while allocating this PMD, is there?  I mean, we don't for the !may_share
case.

