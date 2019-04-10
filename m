Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F111EC10F0E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 01:18:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FDCD2133D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 01:18:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=iluvatar.ai header.i=@iluvatar.ai header.b="wgOguPYq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FDCD2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=iluvatar.ai
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02BAD6B0006; Tue,  9 Apr 2019 21:18:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1DC06B0008; Tue,  9 Apr 2019 21:18:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E33EB6B000A; Tue,  9 Apr 2019 21:18:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A86ED6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 21:18:56 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u2so617884pgi.10
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 18:18:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:content-disposition:dkim-signature:date:from:to
         :cc:subject:message-id:references:mime-version:in-reply-to
         :user-agent;
        bh=KzP1OXRAGGZZzLvdoLhRN33zXcievyZzFh84tg/kl7U=;
        b=AZxRxPoaakIdjKtj7HRgN/U2vAlCvnibIAa2rfhdDcjLO0T10FVe79WmiPYTdZlpwZ
         KM6EJwh2tb1+h+FYFf+27cmqNBkyleNUXmvY9ipZGbYc3w1vsqZqJCSe32qU2aBYE7f/
         cPWh/VZDRhbWLnt8SmZRDgjVPGP7IxEj4J0n102sA7eJw/l3QZeMdgOb3aSlesOABAdc
         EXxkgTMMjyzQGQ44xyDg/DxGVdPJurVt6MxeaHzm55VeuJLeRGyAssLuGyXbrMEcOAKz
         9RXaK6f6u4EfkvWuG9da4NUsO1r8j0iG7JFLb7WLB/7H45eBZqnIp8fak/k+VeO0z9bY
         esPw==
X-Gm-Message-State: APjAAAWrShGt0ETxRjewX31cDAXeqbUxMwUR3lHbkkUGwu96euE962QV
	5XxsAuKds1Wm1gijifPoZ3rzoh4hRjSJXq1YERFDRK8BeCG2UGs5v4Jv1oXu5LsmHUHnNYRH1w5
	jVptgOkKCQpnigxrAIkZ4hZsXf+YzaopS0KxLQuLSmlOHw82VR09BlBgEhn4N1rwFYg==
X-Received: by 2002:a65:554e:: with SMTP id t14mr27096969pgr.107.1554859136160;
        Tue, 09 Apr 2019 18:18:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXv4DqmDryo5/MsSiNaRO1wXfvh4iZ5izXtHQHuP+n6VdKMdMo8sNh/9ofE/ILxQZ3Jh8N
X-Received: by 2002:a65:554e:: with SMTP id t14mr27096879pgr.107.1554859135019;
        Tue, 09 Apr 2019 18:18:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554859135; cv=none;
        d=google.com; s=arc-20160816;
        b=UMbdROSU6tdmj0bh7cj+RnyggaMJAh7Wx9o6d7oZ+cBKrQjAxUE9Aj0uI0dD1gcakW
         o+LfjrPfIQ7I4xIlnWaIlIWB4eg3juTmvr53VGec576588Q4aBTTUoLlJ5URFlzrheRb
         NXuxNZv18Ov7eH5C+qJF65dwyiaJ+6wWDMfc2NhDHV+A6Y3QFs+wc08BtFPBjEZePTvy
         ZAtolNACWtxz70iYBNi3rmYqyIavp/p9iBzH67qrGOwVMXJ5IyI2DnWENpHvcYcfxUNW
         FnHcs5xOyPIEWAJYUIMlp9XU5oP1ZHjbhkoSGZlwyhp1ShVQEQCE6w/KpbGVOe+xpBp6
         KeKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:mime-version:references:message-id:subject
         :cc:to:from:date:dkim-signature:content-disposition;
        bh=KzP1OXRAGGZZzLvdoLhRN33zXcievyZzFh84tg/kl7U=;
        b=Xs8ZPJxg/s/GdCePGReGvam++o+JtDwkrgTgF8BHCFfkLTOaFW+Af37fpoWvB7HTTh
         4OA6qyhjA/MX+O8dFTiy94nlsI4J7Hr5KjFQvcKKUScbv/fEgL+VLMooqW8HIUXwJGg5
         hy685N3ikKKI8ATvStnWoBxG+iCpkIoyoJ9t4xS+TAeJx2lRccWgFvxgbbZs/UPMeEDC
         Fcfti9NhKmOvIQ0p+tHXyp4sShq/4AIeelu/6Q1FdQaAMjdf4w+XePyTEsKyC0v+LHnb
         fhsxxQmuc47BEl4fJ/ZFYlimu+fv7ywc615rEWGayVSSGUmZulvMaHWipvETheOA5TfH
         AoyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=wgOguPYq;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
Received: from smg.iluvatar.ai (owa.iluvatar.ai. [103.91.158.24])
        by mx.google.com with ESMTP id f1si31887427pld.32.2019.04.09.18.18.53
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 18:18:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) client-ip=103.91.158.24;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=wgOguPYq;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
X-AuditID: 0a650161-78bff700000078a3-d7-5cad447c2cf4
Received: from owa.iluvatar.ai (s-10-101-1-102.iluvatar.local [10.101.1.102])
	by smg.iluvatar.ai (Symantec Messaging Gateway) with SMTP id FA.C4.30883.C744DAC5; Wed, 10 Apr 2019 09:18:52 +0800 (HKT)
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
DKIM-Signature: v=1; a=rsa-sha256; d=iluvatar.ai; s=key_2018;
	c=relaxed/relaxed; t=1554859132; h=from:subject:to:date:message-id;
	bh=KzP1OXRAGGZZzLvdoLhRN33zXcievyZzFh84tg/kl7U=;
	b=wgOguPYq8mgGYZrxtMGfvsh8vCfDqyl+hENTlfsEjlf96vyXuLw1HiWeL/f1dZncxoi1dCf5Ftj
	jvoyONwMI3qeM2zmsq0ynXnIsutGhSGZz/zsDRkn9GD1pUJMNMCvrX/jhzVK27GohQSaPZ8dzvjxd
	8pTVvvblEhZGyBjQ734=
Received: from hsj-Precision-5520 (10.101.199.253) by
 S-10-101-1-102.iluvatar.local (10.101.1.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1415.2; Wed, 10 Apr 2019 09:18:51 +0800
Date: Wed, 10 Apr 2019 09:18:50 +0800
From: Huang Shijie <sjhuang@iluvatar.ai>
To: Ira Weiny <ira.weiny@intel.com>
CC: Matthew Wilcox <willy@infradead.org>, <akpm@linux-foundation.org>,
	<william.kucharski@oracle.com>, <palmer@sifive.com>, <axboe@kernel.dk>,
	<keescook@chromium.org>, <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190410011850.GA3640@hsj-Precision-5520>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
 <20190409010832.GA28081@hsj-Precision-5520>
 <20190409202316.GA22989@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
In-Reply-To: <20190409202316.GA22989@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Originating-IP: [10.101.199.253]
X-ClientProxiedBy: S-10-101-1-102.iluvatar.local (10.101.1.102) To
 S-10-101-1-102.iluvatar.local (10.101.1.102)
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFprCIsWRmVeSWpSXmKPExsXClcqYplvjsjbG4MY9BYs569ewWay+289m
	sf/pcxaLM925Fpd3zWGzuLfmP6vF5gkLgMTiLiaL3z/msDlwesxuuMjisXmFlsfiPS+ZPC6f
	LfXY9GkSu8eJGb9ZPD4+vcXican5OrvH501yAZxRXDYpqTmZZalF+nYJXBk/vneyF7wRr3gx
	9SVbA+N0wS5GTg4JAROJCSdXsYPYQgInGCV6P/CA2MwCOhILdn9i62LkALKlJZb/4+hi5OJg
	EXjLJNHz7QwTiCMk8B2o/utvZpAiFgFVifanQSC9bAIaEnNP3GUGsUUElCVO/7vKBlLPLPCA
	UWLP2SOMIAlhAUuJdd3HwBbzCphJbPxxD2roWUaJ1f1nGSESghInZz5hAbE5Bewl3m+5DDZV
	FGjqgW3HmUAWCwkoSLxYqQXxjJLEkr2zmCDsQonvL++yTGAUnoXkn1kI/8xCsmABI/MqRv7i
	3HS9zJzSssSSxCK9xMxNjJCoStzBeKPzpd4hRgEORiUe3oDpa2KEWBPLiitzDzFKcDArifB+
	fAMU4k1JrKxKLcqPLyrNSS0+xCjNwaIkzls20SRGSCA9sSQ1OzW1ILUIJsvEwSnVwGTwv3L7
	m68z/klWW9qp/Jg+/++OKzHH4thb18vP3Fu6IiahVnHurWCh4i1cDyJEpsTslkxoOxqatkZ5
	X0Cgv2KiVOprZr4/VZU3jSd+ED5y0EPqvm/z/FiPk/Kn+2WKORYll4mbH7wgUXzorQRz9NFw
	JZG3ouWODM9m17gET9q2+KYnf+FXdv7Zyy3nptlzstaVej0qm/t0zqIfv9ju6F86/ZfdcLFX
	0clMgbf88Ts/3hPpNFz02Vx929lZ7kGS8s9PzvH29L8+++7VT+dk3VZGff+xQt9QseRyxp79
	YldZTX7qffxkylsVdGrJWgudzFk2bB86Gpd8+ze5v/HY9g3bdgbsaHFUlebr/P1TvFOJpTgj
	0VCLuag4EQDQREnjJwMAAA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 01:23:16PM -0700, Ira Weiny wrote:
> On Tue, Apr 09, 2019 at 09:08:33AM +0800, Huang Shijie wrote:
> > On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> > > On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > > > When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
> > > > get_user_pages_fast().
> > > > 
> > > > In the following scenario, we will may meet the bug in the DMA case:
> > > > 	    .....................
> > > > 	    get_user_pages_fast(start,,, pages);
> > > > 	        ......
> > > > 	    sg_alloc_table_from_pages(, pages, ...);
> > > > 	    .....................
> > > > 
> > > > The root cause is that sg_alloc_table_from_pages() requires the
> > > > page order to keep the same as it used in the user space, but
> > > > get_user_pages_fast() will mess it up.
> > > 
> > > I don't understand how get_user_pages_fast() can return the pages in a
> > > different order in the array from the order they appear in userspace.
> > > Can you explain?
> > Please see the code in gup.c:
> > 
> > 	int get_user_pages_fast(unsigned long start, int nr_pages,
> > 				unsigned int gup_flags, struct page **pages)
> > 	{
> > 		.......
> > 		if (gup_fast_permitted(start, nr_pages)) {
> > 			local_irq_disable();
> > 			gup_pgd_range(addr, end, gup_flags, pages, &nr);               // The @pages array maybe filled at the first time.
> > 			local_irq_enable();
> > 			ret = nr;
> > 		}
> > 		.......
> > 		if (nr < nr_pages) {
> > 			/* Try to get the remaining pages with get_user_pages */
> > 			start += nr << PAGE_SHIFT;
> > 			pages += nr;                                                  // The @pages is moved forward.
> > 
> > 			if (gup_flags & FOLL_LONGTERM) {
> > 				down_read(&current->mm->mmap_sem);
> > 				ret = __gup_longterm_locked(current, current->mm,      // The @pages maybe filled at the second time
> >
> 
> Neither this nor the get_user_pages_unlocked is filling the pages a second
The get_user_pages_unlocked() will call the handle_mm_fault which will allocate a
new page for the empty PTE, and save the new page into the @pages array.


> time.  It is adding to the page array having moved start and the page array
> forward.

Yes. This will mess up the page order.

I will read the code again to check if I am wrong :)

> 
> Are you doing a FOLL_LONGTERM GUP?  Or are you in the else clause below when
> you get this bug?
I do not use FOLL_LONGTERM, I just use the FOLL_WRITE.

So it seems it runs into the else clause below.

Thanks
Huang Shijie

> 
> Ira
> 
> > 							    start, nr_pages - nr,
> > 							    pages, NULL, gup_flags);
> > 				up_read(&current->mm->mmap_sem);
> > 			} else {
> > 				/*
> > 				 * retain FAULT_FOLL_ALLOW_RETRY optimization if
> > 				 * possible
> > 				 */
> > 				ret = get_user_pages_unlocked(start, nr_pages - nr,    // The @pages maybe filled at the second time.
> > 							      pages, gup_flags);
> > 			}
> > 		}
> > 
> > 

