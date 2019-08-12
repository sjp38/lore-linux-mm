Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 095BAC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 14:40:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B01D7206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 14:40:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="obyctRCg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B01D7206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514D96B0003; Mon, 12 Aug 2019 10:40:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C6106B0005; Mon, 12 Aug 2019 10:40:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38D5E6B0006; Mon, 12 Aug 2019 10:40:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id 132996B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 10:40:49 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B7F7A37E1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:40:48 +0000 (UTC)
X-FDA: 75814037376.24.toes31_7b69f6508a642
X-HE-Tag: toes31_7b69f6508a642
X-Filterd-Recvd-Size: 4688
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:40:47 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id i11so1052668edq.0
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 07:40:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TVVRSVkI8qvD2lGSoeUmZF8tCfKzDhhlBaSpCOxArnc=;
        b=obyctRCgWgERgLG9YsSV9pgUbXG+BwvEDlG9jtBCQVI1C6bvH5m/SwrLIrfFLjvksi
         Nb++0xO4rLuuFAiTrBT5bfKhZ+5NertpHGXDs+rkxTUxu4hTb0OZXIaFsOM7Tn66afMB
         kTPWRhTNqDQYBIXl3kU5jXapTQTYVkExo/dj4/fjNi8ouR1H402RS2li23UO7n+SNKeP
         Er1e0U/BhDsZtcVRjl6/ZmkLMLJZxy7ds6Ru9Sd2mJSb3IWvTK8Tfob+eVyC+2mdKFAC
         cnnSMRtKT0qLrb/oOKAFUOf9aKSemCcD+3010yGECqQfCkG0uGy57ishKgoJNuCWlBYb
         kKOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=TVVRSVkI8qvD2lGSoeUmZF8tCfKzDhhlBaSpCOxArnc=;
        b=OYi5rAlcj6g6C1anwCXuTx62HSn2Yfq+ltF8ASRhyguQFEBFD3ye14livliD4iLk2r
         LSOKw1Nq33PurV7/ciodSNvGq4U5eTXNGDkBwqAQ0W1i3H86FoHjKt1tqymZ/d/DDrDv
         jhUdCfhFICGYMPYvJJYDl5SnrAMyn5EVu+rhB0sFBulrA2WF+dou7owAgRuIa91Ku3+d
         GhNIjxEfvNIQ1y7oKuzToPAaOegb2uXR+HCuZFq3LLKZ9UFt0w42J77M6QvKa/huHuFX
         KSdtQVMEocjYJN0xTo4Sg/swTCyTGdzegUfE/dxruAFlzusZa9ukC8yKHckBcXmYCvxk
         a47Q==
X-Gm-Message-State: APjAAAVVCqi8e8KDA2cjivJj8Ib685F794HplAXA65PUalwXX6OQVoL7
	CkUv6BINv6FAuiuJq/HWXK++PA==
X-Google-Smtp-Source: APXvYqypBJ+RY3iZXTAN7jD6cDv1ks62aJk3l8+yGMMR5/FdUnFK+mmnVy1HnYwJVFkIV/LR1grkLg==
X-Received: by 2002:a50:a48a:: with SMTP id w10mr37395870edb.1.1565620846694;
        Mon, 12 Aug 2019 07:40:46 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id r19sm1618456edy.52.2019.08.12.07.40.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Aug 2019 07:40:46 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id CB894100854; Mon, 12 Aug 2019 17:40:45 +0300 (+03)
Date: Mon, 12 Aug 2019 17:40:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Song Liu <songliubraving@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190812144045.tkvipsyit3nccvuk@box>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box>
 <20190812132257.GB31560@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812132257.GB31560@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 03:22:58PM +0200, Oleg Nesterov wrote:
> On 08/12, Kirill A. Shutemov wrote:
> >
> > On Fri, Aug 09, 2019 at 06:01:18PM +0000, Song Liu wrote:
> > > +		if (pte_none(*pte) || !pte_present(*pte))
> > > +			continue;
> >
> > You don't need to check both. Present is never none.
> 
> Agreed.
> 
> Kirill, while you are here, shouldn't retract_page_tables() check
> vma->anon_vma (and probably do mm_find_pmd) under vm_mm->mmap_sem?
> 
> Can't it race with, say, do_cow_fault?

vma->anon_vma can race, but it doesn't matter. False-negative is fine.
It's attempt to avoid taking mmap_sem where it can be not productive.

mm_find_pmd() cannot race with do_cow_fault() since the page is locked.
__do_fault() has to return locked page before we touch page tables.
It is somewhat subtle, but I wanted to avoid taking mmap_sem where it is
possible.

-- 
 Kirill A. Shutemov

