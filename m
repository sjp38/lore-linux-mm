Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C64CC28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:10:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33201257EA
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:10:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="lpkY7WCI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33201257EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A45D46B026B; Thu, 30 May 2019 07:10:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F63D6B026C; Thu, 30 May 2019 07:10:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BDCF6B026D; Thu, 30 May 2019 07:10:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C91C6B026B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:10:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f15so6377635ede.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 04:10:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hSkSGsERCoxbVMjuBLGVoXhettT+4ucAo/Muobuws1w=;
        b=cg2TFAJuxHz/UXfp76fph/vPBZAu2P+CEIFV3hx2uDmQeaEYIlzY19mcEx6iWDGZx8
         v+kqlC3frjHbL3L4OLcvm9zC3eJ1JVAsxwDBs4kqnQ4SYFXKTPSYMoPO511Zfw6PIBq1
         S0kYMpzSEyuCgWoQ9NYu0TdutgNlQLts/SxGtTyGteZt+84+DMafOqeV9JK3Rkc0sVpJ
         U6rsKCXU0clkKbVoeiJRdbsUQKjdcgnGMgFbUGFkee312UFJcxPLUxxl3bMvMuy0aE7Z
         zPn8CocBzBZA0XuN0yeuMl/izv6f5NjAx3hiyuD83V2YzCY3nqlJ0VblMxnxC5ICv+7N
         s7SQ==
X-Gm-Message-State: APjAAAXKDBOjpkKA5r9WkE6CyCzQcnHqx1k1Y8h3Py//lbjmTb0wkHEc
	qtrG/Rwm43cYV6u690/m/rrsNnbZcxX7mVkWXS65R8CfprKvSP5K8lrG05g2yA5PGIfJ8nW4CoB
	9cuHqXGwrlYyaogWEBWnqpRZHyxoJJcKpdsaIwjlgK9OWINxu9tONWI27BHxtaiU1ug==
X-Received: by 2002:a50:bae4:: with SMTP id x91mr3855446ede.76.1559214618845;
        Thu, 30 May 2019 04:10:18 -0700 (PDT)
X-Received: by 2002:a50:bae4:: with SMTP id x91mr3855380ede.76.1559214618066;
        Thu, 30 May 2019 04:10:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559214618; cv=none;
        d=google.com; s=arc-20160816;
        b=lncu+sc0ogcg4pT8LU9hgIN4f8tpIAblUhC3BMfmYGT2i3UWdEnfDfqAcIHi0jcQ5Y
         D6/EqLweBNsK+YdPj8vvDwSgP14Zn54roubhUtlC0WraIafhSQkOUQhEVxaSTioNsmuv
         JXlCVNGxXFNRkhLHpTnmLPo6+sfMRd5rq+CK2p9nEEJuYi82iv35qhv3NcQ8t6AwUnjN
         i/R60Wi6afvntYMlDcxisBUB9lrhLGMqH7xMgJXbH81Mx5/AuEWF8p10PjAP0fveHBcf
         +wkQW2p+jSvAgqYluCbWS0077JJ0tEYZzWjvopAn9kc3JO0BnMI3Leyw5EFeLkWNGhx6
         Pvbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hSkSGsERCoxbVMjuBLGVoXhettT+4ucAo/Muobuws1w=;
        b=YUJxzYXaO8WRlofVEbyiJjIi+kHFvwXYC9qm6maLcbcIFEfu7cGJmUELnsuNVgAHnx
         bmuQE6EIb3qh0dOQoBinQ3YihAIf5Onbe9CwlLEzRYv6MVR8THNwGsp7E5jS40aUpQ86
         NWg2mVemY4V+Y12xCz/RfgR6LDYOOKzyqgiFVzxwKBEpqKD9RdJT9Y/kbnVSSQoF6vRD
         xSyWpJfSUjds4Kml1FZqtM92VWLV95d2CboG8kgoDjM3C5ewo2EtyUHGyO0W/ZwPTV/K
         kHp4MPT52jwsPgtq36eCjerAeSbs8/XuiRKhsQZV9DmeJW9dEHRTmUDG9XqZnNJh/n9c
         S5Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=lpkY7WCI;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s53sor2287928eda.4.2019.05.30.04.10.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 04:10:18 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=lpkY7WCI;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hSkSGsERCoxbVMjuBLGVoXhettT+4ucAo/Muobuws1w=;
        b=lpkY7WCIeRrNPvejtIJrZOSMqBOD2vDAEol+ZNroa6YsXWMIJbffjnG++O0mHhs/s2
         i1cbel557QTceaU6PiiqPPXPIEn4ltxuN9kVRbGA3cvMEx55Td2NymONssG41sIWudKS
         aG3LojlM+mL9pGk8pgG8SNcX7gtiEbRMRLhB4IJS1wbypMnIO+Uaz2fqjQeGZVb3WMtM
         p6QY7EGsDqLuwY+6AMB5xpWilqj9hXwD/uRZuMBer9TjERT+BqLFHdsUXDX1y9tHCF8z
         dSOHLSOq+f+GpDbUXTkBSycGjbDinpnrR2PCZwaoYO3kXZaNREuCBs8SlhNKrfX0UJ7x
         bkag==
X-Google-Smtp-Source: APXvYqyW4R+ymHjIY8r1F5s9hVOwh6JcUfNtfsYZlmiMn7r4TUnwNLPTQqYnMzNAsKVlV7WZfDDmBA==
X-Received: by 2002:a50:ba13:: with SMTP id g19mr3698011edc.236.1559214617675;
        Thu, 30 May 2019 04:10:17 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id v15sm378833ejj.23.2019.05.30.04.10.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 04:10:16 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 424FB1041ED; Thu, 30 May 2019 14:10:15 +0300 (+03)
Date: Thu, 30 May 2019 14:10:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, namit@vmware.com,
	peterz@infradead.org, oleg@redhat.com, rostedt@goodmis.org,
	mhiramat@kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, chad.mynhier@oracle.com,
	mike.kravetz@oracle.com
Subject: Re: [PATCH uprobe, thp 1/4] mm, thp: allow preallocate pgtable for
 split_huge_pmd_address()
Message-ID: <20190530111015.bz2om5aelsmwphwa@box>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-2-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529212049.2413886-2-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:20:46PM -0700, Song Liu wrote:
> @@ -2133,10 +2133,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
>  	VM_BUG_ON(!is_pmd_migration_entry(*pmd) && !pmd_trans_huge(*pmd)
>  				&& !pmd_devmap(*pmd));
> +	/* only file backed vma need preallocate pgtable*/
> +	VM_BUG_ON(vma_is_anonymous(vma) && prealloc_pgtable);
>  
>  	count_vm_event(THP_SPLIT_PMD);
>  
> -	if (!vma_is_anonymous(vma)) {
> +	if (prealloc_pgtable) {
> +		pgtable_trans_huge_deposit(mm, pmd, prealloc_pgtable);
> +		mm_inc_nr_pmds(mm);
> +	} else if (!vma_is_anonymous(vma)) {
>  		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
>  		/*
>  		 * We are going to unmap this huge page. So

Nope. This going to leak a page table for architectures where
arch_needs_pgtable_deposit() is true.

-- 
 Kirill A. Shutemov

