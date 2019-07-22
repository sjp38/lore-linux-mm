Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC9E2C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 17:50:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9496921955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 17:50:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n1SlHMSo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9496921955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 319DE6B0007; Mon, 22 Jul 2019 13:50:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C9F88E0003; Mon, 22 Jul 2019 13:50:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1910C8E0001; Mon, 22 Jul 2019 13:50:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5FAE6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 13:50:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so17225938pgv.0
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 10:50:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/LORfxhH4cPCyhMYt6N2Wj9cKNe2qt9hnR1X3sMowdQ=;
        b=iR30h19NFmE1bkb7gLtGCruRRP/SYQtv0lh2+DBiP48z7vPvRR+0TGikOuuX3doTt3
         BK9wXMAQCaw54MBgSDvYCqyl6pNdodnyuUZH87WWKK956Xev301VaqjJjgldtHeoHfsk
         l/5ZznK1ceWWYbaV+BtwxP0nhdojp4AzYiNwjIl7OGr/algsl+fIbv5gr5AYPNvwkyX+
         fUVEOiTsMAa/EzspkJeYzNuN8A2PNhEuzZu8BMJlCcAOf2rsCb7AdlpicCgbOucfB2+g
         ukQqc5nhMbhMtrVhloJL2inOuJH7AZutb/cPMtpz6HHo2HM0cKptLQ+HI3Rs/OkMgGHP
         yz8g==
X-Gm-Message-State: APjAAAX6eUBWbB335NS4j4oFC2MxeBMXY9o+tKfiQT1vT37SjoNH6Ur0
	zlSnusVmB3iPC59KfXkmJYbDfBZzwcAONeYKaHzmhyn1a25w+L5ov6ibaAv995w04b5qdcdxWG5
	xKOKteUHJrOkS/Kiq2OBw0P02PhJbAn9BwgsFskDK6XfJCKrYFeWNLQp5oNoOBXgg7g==
X-Received: by 2002:a17:902:2929:: with SMTP id g38mr56797905plb.163.1563817830485;
        Mon, 22 Jul 2019 10:50:30 -0700 (PDT)
X-Received: by 2002:a17:902:2929:: with SMTP id g38mr56797870plb.163.1563817829838;
        Mon, 22 Jul 2019 10:50:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563817829; cv=none;
        d=google.com; s=arc-20160816;
        b=p+23t/56l88TdKkVIqIG6GNBGDxRqjirq4zJSRhaFK3GW5tDxjQitY+Z6ABWkHwDXH
         mqQDSTkETU8PRapXbNnv5YiqGyXR0FEXh5s+mnVP2I2BQ9xb4o53SpFB2MRzmTY8fHBq
         Q7TLw+TMlulYCfMWsKGoBiGmyCF7sQmln+h8e53WXLJJtb1zDIwCjxHm6iXYUeqM+YAb
         en6MXJT+YhXp8m5J89kIhw9r4v/zaidJXdp6Hsgld8FiqPhhWO0+KrGtqBRzmlDTMgaS
         4WftjS692jJhQBfkEL6tjYzIFYpBwYihtKGbCb6w2YdEf01QYNS7HMmbISMzQCtUdESl
         zy5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=/LORfxhH4cPCyhMYt6N2Wj9cKNe2qt9hnR1X3sMowdQ=;
        b=gvEfjwp1GRWnRU/N8IkcRrO/UeyHJ7J7bP9KpbpJT3lDwWwehUWxAkaku3s2leYP5k
         wIYvUnvY+0XTv+lY2qwXJ3QUGXw1tTC5Up4OzAStwfqf6DHaoBEUNuLuz552uOZwLJSh
         lv8VWbV9gOgSp1Nvz5moU+LZIvgeyj1Ge6/VBMBECkEXhNvwqnH1uUctIdGhogMirxKk
         tiAhm4aVuQGYPaIrF+oyqGXBdRvKP0n4l9+zvh8qMtMHEZCxxk/MVaLdCBpQU/ZLuL8k
         ZeKu52P73M3Lraw5jYTW/wuaF5myCqOUGhvZ+mxAUOETp/Zb1rtPXzodXJUYUNwlEyOI
         bj3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n1SlHMSo;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor21494768pfd.59.2019.07.22.10.50.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 10:50:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n1SlHMSo;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=/LORfxhH4cPCyhMYt6N2Wj9cKNe2qt9hnR1X3sMowdQ=;
        b=n1SlHMSojQt0P7r4oOYQHnxtZpqyOPYp6kEQKFu9QtR2xjN41TFnIsvdRCN+aCtxPl
         4k3OiuK9FPft3Q4bXlV4mmO1yp2bxWNtUE1rsSa4pnvA9Bs7PR2Xr6ODcmZR6dvZnF7W
         tbm6cXf5r+0tUaqTxfRb7v8NZgjzLCiDBMWZFhhYTf7yPXHdIVEoVrJmzknZF4BL/M19
         iDyHcbXXPQjpRFq74i/6P8XHmdaBtL2B0x5StS3f+oxCxdIOUQwRKblPX4SXmXRlUO9z
         ta+dSgEQrvq1LWUSPv600HB+SGa25QRnyYIYPcLSw9vXg8nvthD5S/omzUjpaEJSmOqU
         nesQ==
X-Google-Smtp-Source: APXvYqz1ZJ0Sw8KehKmYgjC5235A6lpjGgfo2wFuW+DCqMntVVX0am9/kqG+nW9cfKzlFJdJFG+tNg==
X-Received: by 2002:aa7:9118:: with SMTP id 24mr1343927pfh.56.1563817829565;
        Mon, 22 Jul 2019 10:50:29 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id t2sm35502130pgo.61.2019.07.22.10.50.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 10:50:29 -0700 (PDT)
Date: Mon, 22 Jul 2019 23:20:22 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: William Kucharski <william.kucharski@oracle.com>
Cc: arnd@arndb.de, sivanich@sgi.com, gregkh@linuxfoundation.org,
	ira.weiny@intel.com, jhubbard@nvidia.com, jglisse@redhat.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
Message-ID: <20190722175022.GB12278@bharath12345-Inspiron-5559>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
 <1563724685-6540-3-git-send-email-linux.bhar@gmail.com>
 <1BA84A99-4EB5-4520-BFBD-CD60D5B7AED9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1BA84A99-4EB5-4520-BFBD-CD60D5B7AED9@oracle.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 09:20:38PM -0600, William Kucharski wrote:
> I suspect I'm being massively pedantic here, but the comments for atomic_pte_lookup() note:
> 
>  * Only supports Intel large pages (2MB only) on x86_64.
>  *	ZZZ - hugepage support is incomplete
> 
> That makes me wonder how many systems using this hardware are actually configured with CONFIG_HUGETLB_PAGE.
> 
> I ask as in the most common case, this is likely introducing a few extra instructions and possibly an additional branch to a routine that is called per-fault.
> 
> So the nit-picky questions are:
> 
> 1) Does the code really need to be cleaned up in this way?
> 
> 2) If it does, does it make more sense (given the way pmd_large() is handled now in atomic_pte_lookup()) for this to be coded as:
> 
> if (unlikely(is_vm_hugetlb_page(vma)))
> 	*pageshift = HPAGE_SHIFT;
> else
> 	*pageshift = PAGE_SHIFT;
> 
> In all likelihood, these questions are no-ops, and the optimizer may even make my questions completely moot, but I thought I might as well ask anyway.
> 
That sounds reasonable. I am not really sure as to how much of 
an improvement it would be, the condition will be evaluated eitherways
AFAIK? Eitherways, the ternary operator does not look good. I ll make a
version 2 of this.
> > On Jul 21, 2019, at 9:58 AM, Bharath Vedartham <linux.bhar@gmail.com> wrote:
> > 
> > is_vm_hugetlb_page has checks for whether CONFIG_HUGETLB_PAGE is defined
> > or not. If CONFIG_HUGETLB_PAGE is not defined is_vm_hugetlb_page will
> > always return false. There is no need to have an uneccessary
> > CONFIG_HUGETLB_PAGE check in the code.
> > 
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Dimitri Sivanich <sivanich@sgi.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> > drivers/misc/sgi-gru/grufault.c | 11 +++--------
> > 1 file changed, 3 insertions(+), 8 deletions(-)
> > 
> > diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
> > index 61b3447..75108d2 100644
> > --- a/drivers/misc/sgi-gru/grufault.c
> > +++ b/drivers/misc/sgi-gru/grufault.c
> > @@ -180,11 +180,8 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
> > {
> > 	struct page *page;
> > 
> > -#ifdef CONFIG_HUGETLB_PAGE
> > 	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> > -#else
> > -	*pageshift = PAGE_SHIFT;
> > -#endif
> > +
> > 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
> > 		return -EFAULT;
> > 	*paddr = page_to_phys(page);
> > @@ -238,11 +235,9 @@ static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
> > 		return 1;
> > 
> > 	*paddr = pte_pfn(pte) << PAGE_SHIFT;
> > -#ifdef CONFIG_HUGETLB_PAGE
> > +
> > 	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> > -#else
> > -	*pageshift = PAGE_SHIFT;
> > -#endif
> > +
> > 	return 0;
> > 
> > err:
> > -- 
> > 2.7.4
> > 
> 

