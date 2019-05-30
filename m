Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B4C5C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF5A8257F6
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:14:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="nFa3Aq2Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF5A8257F6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D9CB6B0010; Thu, 30 May 2019 07:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 363F86B026B; Thu, 30 May 2019 07:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E0596B026C; Thu, 30 May 2019 07:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF80E6B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:14:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so8189527edc.4
        for <linux-mm@kvack.org>; Thu, 30 May 2019 04:14:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XNn/kmlHnCSr6ANgnhJMJQoNGplaEoHdHhfpn+42U/U=;
        b=VbbptUUKUdSqDAW6JHjvZxBG28gWVpDZafDQNNF+VUFV5Bc0Q+VVkYlk916QlVcUne
         qN0McuIW+AmhrdNAlOGs4nAeEqD1G36j/KG2ai2Rp7R0dpx7Ve5kgbcGt0wfk8O/H5Ru
         4JIjRHmjE1FtWbx5+T+gicsbFa+ZP9QoR7azLXcKw/QX2EG+00CYUIQa9MygSR4qJnI4
         +breVV4381W9dBTviByAcI2pZ57C8CYwMtqQSxHXagRIPEz5eVUyPS7+vzpWJYfhskVD
         XRNyXE3cl8gIwJYT1nQWhdZlZ6HssVZBYSqc2Qya4+NJU/okDwDp3PciPw0swmYbmDlA
         rbjw==
X-Gm-Message-State: APjAAAVXAoeliHYRj9nQaul2nW9He13Mh1k7USB8eoGCp4jMjK1syIiO
	9Y/jakc19ng3T6w5+2M8VG3o8NE8sVfe1nJ1AG0HvfLKOssPuvF90MrTKk7k1qWK/08QnwFhJJC
	Jwz2xTSmnA/Jnk+ogoUJ/jBdiYMZJiaXaGglKOqHndmXs8w9v7mcu2B8M511LxbdEpA==
X-Received: by 2002:a17:906:300b:: with SMTP id 11mr2866519ejz.291.1559214859291;
        Thu, 30 May 2019 04:14:19 -0700 (PDT)
X-Received: by 2002:a17:906:300b:: with SMTP id 11mr2866470ejz.291.1559214858625;
        Thu, 30 May 2019 04:14:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559214858; cv=none;
        d=google.com; s=arc-20160816;
        b=hzMIan4xA6fF0K17XWW7Nhex9CPnfMOYU7IcDoupJuj7yiJfPmQicrt1WG6vDR7MEO
         uQKNHnBYbNggEvsIPLZ2s0XiFj5KmD355JMdt7JiYadW//g0vXL5Mi5RKkw81jU8dufr
         7qzuvtPJx5388ghtzEwHKHU9PwUX3hYzaqWLZy61f16FbQ4XqUx6CI51ZW2Jqh/XVCSv
         UmH2LmKqrDrqc6pAVn/KCffnvR22++7kXy5X4QzOVmRAh7S9ovMu9VGg6S9Tz8drCi7y
         oa7Drim3J4p1Ma20RI9+iewMn/95pPMrSMWBSS7E/4ZduJELsBMpLJ+ceKekSKBbh8vA
         y3Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XNn/kmlHnCSr6ANgnhJMJQoNGplaEoHdHhfpn+42U/U=;
        b=HWb+CB60J5SFLFkOBFzmAT93lbpn67hi2Kr0n6RM15YkZyqEVb4q50hzORe8mDyMtT
         mDQpIuHhtYuO6vI8ljsn3S0Yp/8rHD0J6ZZEe2jSZpOEacXV9OP13CSV7Cf+3vYcq2So
         jROOhiZ0nAMqJ4yDvxFd8ojULax+FfwNLPR1+/t+1iL75jPADusBHHOlVYMzJnSrdWUM
         PwGaoFSD5UgCRSMzHZI0qEgCyK3uBw1xWgBgUfWW4fACJ2qefjChKDLcUfcrdP/72iG+
         Ha7uVS4z1etL8LKEQLcE6wq/AhmlkF2tHuXr3WmKoXO4kVVZFGJ6ho63SfW14WWdo9UO
         A6MA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=nFa3Aq2Q;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1sor754374ejz.22.2019.05.30.04.14.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 04:14:18 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=nFa3Aq2Q;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XNn/kmlHnCSr6ANgnhJMJQoNGplaEoHdHhfpn+42U/U=;
        b=nFa3Aq2QY1/b/SmZh7j75KjetoNNh4Q4nF7KjkG89Hf33Lzx/kDlxz2Qaxm9vSqVu+
         dWKMTXTdpkAf3SlD2sCfX+PWajqNbRsWssTuwLzhMoG+a8MWU/cofO8M+Yq3ZHu7GKiS
         4d5eIV53uGfKWdX96tH/kb4YscGd5+m/aiSiYfsOUwTgppVfpXv4x1O3tJM5jNTNArAJ
         +30E1PCsoPxEbPJnRjT8frtFj5kSYKUlF56xcNYLEju/YnD9uf4z5j+Ybjo9vNYG22fM
         3pL263zsGHS7FD+H4sq1/q5Qj1Iy0BbIgmFYjVMUYwkcyvwUksMi4/tpF0Anq+27MwDI
         WmhQ==
X-Google-Smtp-Source: APXvYqzkMPjNWxInx+lzce0w2B8z+OegERN/BaKqbY7ZAOBHZ4GjYaNpaklTSY6DfeQu2yRFAGAiFA==
X-Received: by 2002:a17:906:6993:: with SMTP id i19mr2872115ejr.119.1559214858205;
        Thu, 30 May 2019 04:14:18 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id v22sm383992eji.13.2019.05.30.04.14.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 04:14:17 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 4B18C1041ED; Thu, 30 May 2019 14:14:16 +0300 (+03)
Date: Thu, 30 May 2019 14:14:16 +0300
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
Message-ID: <20190530111416.ph6xqd4anjlm54i6@box>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-2-songliubraving@fb.com>
 <20190530111015.bz2om5aelsmwphwa@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530111015.bz2om5aelsmwphwa@box>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 02:10:15PM +0300, Kirill A. Shutemov wrote:
> On Wed, May 29, 2019 at 02:20:46PM -0700, Song Liu wrote:
> > @@ -2133,10 +2133,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> >  	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
> >  	VM_BUG_ON(!is_pmd_migration_entry(*pmd) && !pmd_trans_huge(*pmd)
> >  				&& !pmd_devmap(*pmd));
> > +	/* only file backed vma need preallocate pgtable*/
> > +	VM_BUG_ON(vma_is_anonymous(vma) && prealloc_pgtable);
> >  
> >  	count_vm_event(THP_SPLIT_PMD);
> >  
> > -	if (!vma_is_anonymous(vma)) {
> > +	if (prealloc_pgtable) {
> > +		pgtable_trans_huge_deposit(mm, pmd, prealloc_pgtable);
> > +		mm_inc_nr_pmds(mm);
> > +	} else if (!vma_is_anonymous(vma)) {
> >  		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
> >  		/*
> >  		 * We are going to unmap this huge page. So
> 
> Nope. This going to leak a page table for architectures where
> arch_needs_pgtable_deposit() is true.

And I don't there's correct handling of dirty bit.

And what about DAX? Will it blow up? I think so.

-- 
 Kirill A. Shutemov

