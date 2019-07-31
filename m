Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4781C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:59:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 888C02067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:59:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aAVijrZ1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 888C02067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 034B38E0006; Wed, 31 Jul 2019 13:59:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F26DE8E0001; Wed, 31 Jul 2019 13:59:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E14C38E0006; Wed, 31 Jul 2019 13:59:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAF1E8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:59:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so43672872pfk.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SFbQnaoqsadI4zyK9FmZVb5jRGBvcMhtkf9xAvnYNi0=;
        b=S+F5YtNh4u3TD8snXwZFyo4BWG5knq2U1fIN8saWYHJSFmdPVKqRgmEVGr96E2uw++
         Dmjchjf9nkMt6tAuYO+XbU8Q1BH3js7ho0qAd2qvNe/QODyMB6Qbya/XXAot+VdyeK/k
         cYl2pLMXRQfyx/MeMN9fBI7GX3IY5PpU16eDLAXrriPyKoocpzKbQgB2ZYGk3BRe3kfN
         cizNYdSF5wASZ/3K67Wou9wZsg2ag4kZsh0OB6bXek55kpJ0DYAsHd8nYUme7FZK7hgZ
         dZGMMcsnApF7bDS+k1leU9tI6+OLa70T+Hgu+WLEa7DF0WL+q91n23Kbazak3QJ8sLFJ
         YRKQ==
X-Gm-Message-State: APjAAAUQ0f528EO9GFPAzvzj9J/Fbm799B0jBB6gpH14h0XSsGncygnu
	IReKjyqE0l/6KlWSOhCSxb2WXNAICH3CGaJ42zAC8tBmIhhGGsH5HcHL3uG92H8CTzRsZIk99WE
	C4MJ354heo14BLb6NNSlnWWjMC91jE6zXHqHVPvXmSm77wezVEqXiLuVRi6/gCxyAdA==
X-Received: by 2002:a17:902:d917:: with SMTP id c23mr121690289plz.248.1564595962298;
        Wed, 31 Jul 2019 10:59:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPVa2zvnJfljUvuAQwt0cVA7uj32ptonDMzJlYmbHubLbkEal/gopiClPV/62gvGHU1xhm
X-Received: by 2002:a17:902:d917:: with SMTP id c23mr121690254plz.248.1564595961671;
        Wed, 31 Jul 2019 10:59:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564595961; cv=none;
        d=google.com; s=arc-20160816;
        b=qne2e93l34qPkPH6q8GhXYWnYIMrgVYjvQG0N7bwkTQC1QPR7leNezVdbgDtm3Dcsu
         m1Ljj3MdDpnjIcL8EuxzFXj04PPCUblXgKqMWvN7HzgCziAu3ouTNAoSD5rk4pMu0k1h
         1TIp5+8Ah+qWM0F/gL69Zv2CXbGZGqZKu9cKZdA1f2Rg0xaU7jOPLyRoUfMsHJHQid5G
         IwyK6iFlnJHXmijUBxhsBUOpBTxGDipoRcf1cseeConTHKuXz3pdrWFYiPE1ylpbAySe
         wv36Wp1HJHFgM2NleW6sVe4ei7/C6Kmvfd5u2ohwOxwSeKLMY3M+l3fMY1JWXd5+s74k
         zPVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SFbQnaoqsadI4zyK9FmZVb5jRGBvcMhtkf9xAvnYNi0=;
        b=qiuDVyXsqI1PAvw5SFBnlnMiPmA4/mjhG2V0ZRPcnDlSnsaHZTsKttPPiFFAk/YV4+
         DV4xe+8iqnJ+G6L4NhZn1X2bphGMkq9EPbkN9awzX/Zp7dFhEwOPdUaC4sOKjK/abbVV
         eOobl3foWrfYm6fotmBLEZM7xKwO+zTPqXyRIuuyaW2cic4k6tXFKi6mwiLUkD+Xde83
         CxiKQU/KWijAe2TkI0raQgZgvaHTGkHKX0qlZwCj4I5EiXWvneHPXcYzvXzKTPkfx28N
         UOBKegJdNtLYf1mSqXVBZYp0RThQD8jSPQLp94JunIBAa1qVmMr6OqFBIUcy6ygb2nhx
         UOow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aAVijrZ1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z186si32103916pgd.162.2019.07.31.10.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 10:59:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aAVijrZ1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SFbQnaoqsadI4zyK9FmZVb5jRGBvcMhtkf9xAvnYNi0=; b=aAVijrZ1LE/V5A1EQp4VZOkJM
	ohKRVqFkOOvbCn7csYPUyuYkpmOfxJ3MV0Is8wwvxFqh7Fs0TkJT6uMH51byCzcUZSbXTgqabZKTJ
	riUU+p7elN67dDAFSpeLVY6pOmWJbb2+bEKUbST3ls7qbj8AFNJ3xs5KYln9zmwP1pXyoghgZH+VK
	7NMQXTsEQG0TlgK6aNSp0h7O3rO2anqBNE2bnMoPlrSy7/O+MdQLi/QhGoUbg7I62V7l8FUSETVKQ
	WpFYlO/3KY/y4WTIAwbTRJXEaAAJoH/9iI0cKTeeV1+hUhy4WMpntPNj78/Z+xsf1gPn0M86snBjr
	q4sn+qwDQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hsssh-0006Re-8U; Wed, 31 Jul 2019 17:59:19 +0000
Date: Wed, 31 Jul 2019 10:59:19 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Song Liu <liu.song.a23@gmail.com>
Cc: William Kucharski <william.kucharski@oracle.com>,
	Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
	Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [RFC 0/2] iomap & xfs support for large pages
Message-ID: <20190731175919.GF4700@bombadil.infradead.org>
References: <20190731171734.21601-1-willy@infradead.org>
 <CAPhsuW66e=7g+rPhi3NU8jQRGqQEz0oQ5XJerg6ds=oxMz8U1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPhsuW66e=7g+rPhi3NU8jQRGqQEz0oQ5XJerg6ds=oxMz8U1g@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 10:50:40AM -0700, Song Liu wrote:
> On Wed, Jul 31, 2019 at 10:17 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> >
> > Christoph sent me a patch a few months ago called "XFS THP wip".
> > I've redone it based on current linus tree, plus the page_size() /
> > compound_nr() / page_shift() patches currently found in -mm.  I fixed
> > the logic bugs that I noticed in his patch and may have introduced some
> > of my own.  I have only compile tested this code.
> 
> Would Bill's set work on XFS with this set?

If there are no bugs in his code or mine ;-)

It'd also need to be wired up; something like this:

+++ b/fs/xfs/xfs_file.c
@@ -1131,6 +1131,8 @@ __xfs_filemap_fault(
        } else {
                if (write_fault)
                        ret = iomap_page_mkwrite(vmf, &xfs_iomap_ops);
+               else if (pe_size)
+                       ret = filemap_huge_fault(vmf, pe_size);
                else
                        ret = filemap_fault(vmf);
        }
@@ -1156,9 +1158,6 @@ xfs_filemap_huge_fault(
        struct vm_fault         *vmf,
        enum page_entry_size    pe_size)
 {
-       if (!IS_DAX(file_inode(vmf->vma->vm_file)))
-               return VM_FAULT_FALLBACK;
-
        /* DAX can shortcut the normal fault path on write faults! */
        return __xfs_filemap_fault(vmf, pe_size,
                        (vmf->flags & FAULT_FLAG_WRITE));

(untested)

