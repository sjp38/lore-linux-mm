Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE4D0C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:12:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67F4020B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:12:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="dzc5ZzSl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67F4020B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 141856B000E; Tue,  6 Aug 2019 07:12:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F2C26B0010; Tue,  6 Aug 2019 07:12:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F236C6B0266; Tue,  6 Aug 2019 07:12:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0ABE6B000E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:12:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so53617689edr.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:12:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IVUZ3vCUTZaoNKcACCnsP7M9ScGcHtHaH8K8c7i8HGE=;
        b=e3rPS72OccER/k9PnCFR9+Q3nj657xerMswLW+a1p7T+oO23JFCVfO+26YVaV6yK5h
         hbXCz29805R5OHz7oM9+sACIWIGTaYygN5ShgM97DRa/tqKMk9+34cN4pxvMrBrCkgwp
         BnZyVocsHVTlcFMQJ9/EUof/7yJdA8SrMH+AVQ+DKydMPQxhiV/EghhIRqlQV13DwBep
         cmjlFuDEiLQz0DpMs9W6WOFrtLgSDBJ+KxGFlNbAdYXGIuCa/8btWncrPD8c4iwcgOBu
         qXCIu1K28nL3upz3yVNfkN+fwhWgphGhm+/fYHLiEY0XsqGkRWMmf2wKfet3dJW8Jov7
         5f8A==
X-Gm-Message-State: APjAAAVUG0RjvE8ZhriJuxwvvq8sO7/Y3g/wwvJ8OcKJDEEBzQ3yhyqE
	RlonKJscxcNGT94zrwqxFvAk2OEal9GWEpn/4F/Puvap+KsUNdOjFMM/M/Ar9vy4ktKWeU51A2n
	yOGa6ALK8iT3LBi5BjjvOsUE5gzONM/2EXEBs24H5BNqwitg4yUMFl7jouEFPDoPZng==
X-Received: by 2002:a50:b566:: with SMTP id z35mr3228123edd.129.1565089933127;
        Tue, 06 Aug 2019 04:12:13 -0700 (PDT)
X-Received: by 2002:a50:b566:: with SMTP id z35mr3228063edd.129.1565089932329;
        Tue, 06 Aug 2019 04:12:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565089932; cv=none;
        d=google.com; s=arc-20160816;
        b=ucX/oFIKmFkMpC5mi9oXEq14Mcf7sTp+HePjSY2SChfqvShqXwaOzywGXnwPHnKnew
         D6bOtWZaIxQmC1olYeK9aLVRfdfs03ifa4uHmTRkmssLmoZFLUzv4S8Bk4v/vOTyhssZ
         FCaWCHbC96ns3iG+DP7M7A8nVop5TLW7wnFwnAg/ttG+0LD3NjuQz4wr/SKUZfR5iNbr
         tCJEIi/QX7SMXnnr66JPwST2rznW2W8EULDKWrepBpMS80a7+uGH77riG7Svr8lQAb9F
         hfsg78L+v5/+9jmv6VX3dg56z+b/Ox3hqknzVckk93SflnrbcXXZyoc7SyNWzjQvHuJu
         jzTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IVUZ3vCUTZaoNKcACCnsP7M9ScGcHtHaH8K8c7i8HGE=;
        b=r6a1mNyoQuY01X1wSrea1aJSSk1+rITj8dq0R+3uKcrWsLksZLtBNa6WCnGxEdR98v
         ac5gIB4+idwN4/cKW0/H6gavnH/A6xtT4YSgLRiA7LYj8m9gz/MXbmIq72T/IkljI0r8
         PGkCy0bg4ZnRajB1fSs6yLqcQNaO2fXeKRi3mV/Ic4Oa4dcVBKeINiNAJ0A9mfENfWM7
         7gXher0Kb/Mg8jHBlqkl6fWNdo7TpUa/JDWv23OMwxSpMBYtJkz0Avn+N8mgjgNh/hPu
         9AfkTbnSV3L00T1GMkxPeVy6+7q45P2QAdcoUB/nir/Y6c8bAujaZuUuqv75VNH8sil2
         e5nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dzc5ZzSl;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z2sor67284563edb.16.2019.08.06.04.12.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 04:12:12 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dzc5ZzSl;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IVUZ3vCUTZaoNKcACCnsP7M9ScGcHtHaH8K8c7i8HGE=;
        b=dzc5ZzSlafWAy4fTC2ybrGXSCublaxnDUYbea0pzEG0z1VVySMMflBJVhE69+xqsxQ
         ESDT9/Cp7bfZI3bAbHXvis/zbWvnBL2Tt5UimOA9lpTrAdZc/C2ry9LQNpbmWXzDlqEI
         Uv2TeJm+Zisvbj8s0NnelXo1te8MM6RBy56cFCUBrFEBGLwOhQJX5pQ5s/Fi5zOv1P3N
         vxUj4YVvG++IvGchx4EZYQq6T2UHYO58Gx0S8bgicbKPJVYzkmuJrWWXexEv9O9yPDpe
         TLWBH3Igl7oDCOQj92KYngp53w9jybNVCctzRFInXAgzw/hzdUgcgskgBuK259f86s2x
         WiOQ==
X-Google-Smtp-Source: APXvYqztbyBgleEnQ54uuSvw10HgZnTrh29ZTTFUfYTHSJDyykKw0nXSNOlE5//gAzIYtisxx3tk1Q==
X-Received: by 2002:a50:f98a:: with SMTP id q10mr3146171edn.267.1565089931994;
        Tue, 06 Aug 2019 04:12:11 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c48sm20888241edb.10.2019.08.06.04.12.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 04:12:11 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id CC6D01003C7; Tue,  6 Aug 2019 14:12:10 +0300 (+03)
Date: Tue, 6 Aug 2019 14:12:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: William Kucharski <william.kucharski@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Message-ID: <20190806111210.7xpmjsd4hq54vuml@box>
References: <20190731082513.16957-1-william.kucharski@oracle.com>
 <20190731082513.16957-3-william.kucharski@oracle.com>
 <20190801123658.enpchkjkqt7cdkue@box>
 <c8d02a3b-e1ad-2b95-ce15-13d3ed4cca87@oracle.com>
 <20190805132854.5dnqkfaajmstpelm@box.shutemov.name>
 <19A86A16-B440-4B73-98FE-922A09484DFD@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19A86A16-B440-4B73-98FE-922A09484DFD@oracle.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 09:56:45AM -0600, William Kucharski wrote:
> >> I don't really care if the start of the VMA is suitable, just whether I can map
> >> the current faulting page with a THP. As far as I know, there's nothing wrong
> >> with mapping all the pages before the VMA hits a properly aligned bound with
> >> PAGESIZE pages and then aligned chunks in the middle with THP.
> > 
> > You cannot map any paged as huge into wrongly aligned VMA.
> > 
> > THP's ->index must be aligned to HPAGE_PMD_NR, so if the combination VMA's
> > ->vm_start and ->vm_pgoff doesn't allow for this, you must fallback to
> > mapping the page with PTEs. I don't see it handled properly here.
> 
> It was my assumption that if say a VMA started at an address say one page
> before a large page alignment, you could map that page with a PAGESIZE
> page but if VMA size allowed, there was a fault on the next page, and
> VMA size allowed, you could map that next range with a large page, taking
> taking the approach of mapping chunks of the VMA with the largest page
> possible.
> 
> Is it that the start of the VMA must always align or that the entire VMA
> must be properly aligned and a multiple of the PMD size (so you either map
> with all large pages or none)?

IIUC, you are missing ->vm_pgoff from the picture. The newly allocated
page must land into page cache aligned on HPAGE_PMD_NR boundary. In other
word you cannout have huge page with ->index, let say, 1.

VMA is only suitable for at least one file-THP page if:

 - (vma->vm_start >> PAGE_SHIFT) % (HPAGE_PMD_NR - 1) is equal to
    vma->vm_pgoff % (HPAGE_PMD_NR - 1)

    This guarantees right alignment in the backing page cache.

 - *and* vma->vm_end - round_up(vma->vm_start, HPAGE_PMD_SIZE) is equal or
   greater than HPAGE_PMD_SIZE.

Does it make sense?

> 
> >> This is the page that content was just read to; readpage() will unlock the page
> >> when it is done with I/O, but the page needs to be locked before it's inserted
> >> into the page cache.
> > 
> > Then you must to lock the page properly with lock_page().
> > 
> > __SetPageLocked() is fine for just allocated pages that was not exposed
> > anywhere. After ->readpage() it's not the case and it's not safe to use
> > __SetPageLocked() for them.
> 
> In the current code, it's assumed it is not exposed, because a single read
> of a large page that does no readahead before the page is inserted into the
> cache means there are no external users of the page.

You've exposed the page to the filesystem once you call ->readpage().
It *may* track the page somehow after the call.

-- 
 Kirill A. Shutemov

