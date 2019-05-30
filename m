Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B604C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 22:52:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 283AD262B2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 22:52:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 283AD262B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB9676B0281; Thu, 30 May 2019 18:52:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B42F96B0282; Thu, 30 May 2019 18:52:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A31856B0283; Thu, 30 May 2019 18:52:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81A646B0281
	for <linux-mm@kvack.org>; Thu, 30 May 2019 18:52:50 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id n190so6276686qkd.5
        for <linux-mm@kvack.org>; Thu, 30 May 2019 15:52:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=t67ZC4MNc2SNAttzYwTDhyatXWg3h6kEvUy6EU0k9QU=;
        b=uJKtsabEua4Aw09xXi+0NLndmv6wfecE7qiH9aMSLspwIx9NAccvPLfLVzvwKGUzfg
         62H4i8R6SD8PGTx43EjZr9Xx5ClqxmQ7ksQpeZZre6ZGmaCt2Ir+AZGxYSJUX/4YD/pW
         JeWAMf76VdAYAzevWyVz2JG15XUFWE3jcM1eVMnVViJANBIBfFM90l0MKQa//F9vuZIE
         jDAfoDZlO3mtkmxTODi7Ka62ntPKdQUziAGpGlBtXHXCZBM7wvKpOs07S/ug7cg4LBIl
         5kEQgs57JrG2RjUhcFr1HAQTVgEBnbXtqfm3MYsJ1+lkuWq6t6ft6a0foCywjef+COef
         cTDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUJgX04w7T4Pf81EVS8KKfsvhtpNYLaYtl1H0WGf2zINiqEofdr
	nQStJi0qZQTd5W3Gei26Jyc01T41EF76XZlz7elfqpcxVjHsbjSBcAGHzEI0On1emZSqcZveKwU
	7ffAxiswiIXc9nw14Jcx/OopvF79odbkwJuDsh6jl/+IHSKdD2hnH8S22xp1fGxEr/Q==
X-Received: by 2002:ae9:ed48:: with SMTP id c69mr5572978qkg.114.1559256770256;
        Thu, 30 May 2019 15:52:50 -0700 (PDT)
X-Received: by 2002:ae9:ed48:: with SMTP id c69mr5572942qkg.114.1559256769533;
        Thu, 30 May 2019 15:52:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559256769; cv=none;
        d=google.com; s=arc-20160816;
        b=Qhm9O0b9I2YkuMMURug76oWUCc6S9DBWsUA5CwONrLUhob5ipn3MFdOT7r331a9sOS
         TqBe9YMrynfeLF/sSxs/b24pkS2gssgNq4hD4WDK57p++SHrhjOhowK9GQwr6HvwweCc
         LbU8tWh4dkokEp0VIB1Inz1roBsLYFayRWaGmhYgoueArMGTs6O0Ryk10KNCvYh+zuUI
         rOAp5JdrCX3KpWvw+PKp6cjDSyB+y8XhjQrTkCVL9tlx3bboz6SvjTASEg7BoUWO0v9k
         pem/RZuzAtjiCKLjZU/Cc6iwIAC1ZAP8mHXWl6wds+VLq/KPZ4GITzSjvLSfcuq13UFr
         Wr+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=t67ZC4MNc2SNAttzYwTDhyatXWg3h6kEvUy6EU0k9QU=;
        b=b/RbwE4B4Wp0XV0aEGodIZtxOyoNvC73p9pgxfJcNb67fMDUz46/MuAeRCHqtKirto
         6Db9PWaGbJyiKhVSEr82MU/wvOM/NVzJ9RzpLbTZ/aaYJ3ZBY3cmzh1wemFvh0GqqijB
         7FvBaVBy5rV2b+IOloyM5OxclvPqd+XR5RxcoSfbS8Qx/rOGUk+ijOG9TUFI6EbzR/KQ
         pwwMNmT86myF6FO3HaK9WUqMS/21Vbgnevgl47yhAnj+eh/PFGNFA0fLciPWkJTn++7M
         Y3WlyRgCtZKSEQYJ1qXGplKJMeIDOUPvThOGp8+rA/MuTl+KKP9Gq4ikKCozn6re9rSc
         ch5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v31sor3335514qvf.50.2019.05.30.15.52.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 15:52:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwTE8uNShrRUaGGlmcc2h+GxOEcZ6AH8JazaRG/qhRpJu7znm1zUJrRhfEE9Idohkf2/B2tSw==
X-Received: by 2002:ad4:5146:: with SMTP id g6mr5719624qvq.136.1559256769266;
        Thu, 30 May 2019 15:52:49 -0700 (PDT)
Received: from redhat.com (pool-100-0-197-103.bstnma.fios.verizon.net. [100.0.197.103])
        by smtp.gmail.com with ESMTPSA id j33sm2606122qtc.10.2019.05.30.15.52.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 30 May 2019 15:52:48 -0700 (PDT)
Date: Thu, 30 May 2019 18:52:45 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, yang.zhang.wz@gmail.com, pagupta@redhat.com,
	riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [RFC PATCH 00/11] mm / virtio: Provide support for paravirtual
 waste page treatment
Message-ID: <20190530185143-mutt-send-email-mst@kernel.org>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 02:53:34PM -0700, Alexander Duyck wrote:
> This series provides an asynchronous means of hinting to a hypervisor
> that a guest page is no longer in use and can have the data associated
> with it dropped. To do this I have implemented functionality that allows
> for what I am referring to as "waste page treatment".
> 
> I have based many of the terms and functionality off of waste water
> treatment, the idea for the similarity occured to me after I had reached
> the point of referring to the hints as "bubbles", as the hints used the
> same approach as the balloon functionality but would disappear if they
> were touched, as a result I started to think of the virtio device as an
> aerator. The general idea with all of this is that the guest should be
> treating the unused pages so that when they end up heading "downstream"
> to either another guest, or back at the host they will not need to be
> written to swap.

A lovely analogy.

> So for a bit of background for the treatment process, it is based on a
> sequencing batch reactor (SBR)[1]. The treatment process itself has five
> stages. The first stage is the fill, with this we take the raw pages and
> add them to the reactor. The second stage is react, in this stage we hand
> the pages off to the Virtio Balloon driver to have hints attached to them
> and for those hints to be sent to the hypervisor. The third stage is
> settle, in this stage we are waiting for the hypervisor to process the
> pages, and we should receive an interrupt when it is completed. The fourth
> stage is to decant, or drain the reactor of pages. Finally we have the
> idle stage which we will go into if the reference count for the reactor
> gets down to 0 after a drain, or if a fill operation fails to obtain any
> pages and the reference count has hit 0. Otherwise we return to the first
> state and start the cycle over again.

will review the patchset closely shortly.

> This patch set is still far more intrusive then I would really like for
> what it has to do. Currently I am splitting the nr_free_pages into two
> values and having to add a pointer and an index to track where we area in
> the treatment process for a given free_area. I'm also not sure I have
> covered all possible corner cases where pages can get into the free_area
> or move from one migratetype to another.
> 
> Also I am still leaving a number of things hard-coded such as limiting the
> lowest order processed to PAGEBLOCK_ORDER, and have left it up to the
> guest to determine what size of reactor it wants to allocate to process
> the hints.
> 
> Another consideration I am still debating is if I really want to process
> the aerator_cycle() function in interrupt context or if I should have it
> running in a thread somewhere else.
> 
> [1]: https://en.wikipedia.org/wiki/Sequencing_batch_reactor
> 
> ---
> 
> Alexander Duyck (11):
>       mm: Move MAX_ORDER definition closer to pageblock_order
>       mm: Adjust shuffle code to allow for future coalescing
>       mm: Add support for Treated Buddy pages
>       mm: Split nr_free into nr_free_raw and nr_free_treated
>       mm: Propogate Treated bit when splitting
>       mm: Add membrane to free area to use as divider between treated and raw pages
>       mm: Add support for acquiring first free "raw" or "untreated" page in zone
>       mm: Add support for creating memory aeration
>       mm: Count isolated pages as "treated"
>       virtio-balloon: Add support for aerating memory via bubble hinting
>       mm: Add free page notification hook
> 
> 
>  arch/x86/include/asm/page.h         |   11 +
>  drivers/virtio/Kconfig              |    1 
>  drivers/virtio/virtio_balloon.c     |   89 ++++++++++
>  include/linux/gfp.h                 |   10 +
>  include/linux/memory_aeration.h     |   54 ++++++
>  include/linux/mmzone.h              |  100 +++++++++--
>  include/linux/page-flags.h          |   32 +++
>  include/linux/pageblock-flags.h     |    8 +
>  include/uapi/linux/virtio_balloon.h |    1 
>  mm/Kconfig                          |    5 +
>  mm/Makefile                         |    1 
>  mm/aeration.c                       |  324 +++++++++++++++++++++++++++++++++++
>  mm/compaction.c                     |    4 
>  mm/page_alloc.c                     |  220 ++++++++++++++++++++----
>  mm/shuffle.c                        |   24 ---
>  mm/shuffle.h                        |   35 ++++
>  mm/vmstat.c                         |    5 -
>  17 files changed, 838 insertions(+), 86 deletions(-)
>  create mode 100644 include/linux/memory_aeration.h
>  create mode 100644 mm/aeration.c
> 
> --

