Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA8426B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 14:13:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y77so15694053pfd.2
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 11:13:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 188sor4196066pgc.380.2017.09.12.11.13.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Sep 2017 11:13:06 -0700 (PDT)
Date: Tue, 12 Sep 2017 11:13:03 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170912181303.aqjj5ri3mhscw63t@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
 <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
 <431e2567-7600-3186-1489-93b855c395bd@huawei.com>
 <20170912143636.avc3ponnervs43kj@docker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170912143636.avc3ponnervs43kj@docker>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org

Hi Yisheng,

> On Tue, Sep 12, 2017 at 04:05:22PM +0800, Yisheng Xie wrote:
> > IMO, before a page is allocated, it is in buddy system, which means it is free
> > and no other 'map' on the page except direct map. Then if the page is allocated
> > to user, XPFO should unmap the direct map. otherwise the ret2dir may works at
> > this window before it is freed. Or maybe I'm still missing anything.
> 
> I agree that it seems broken. I'm just not sure why the test doesn't
> fail. It's certainly worth understanding.

Ok, so I think what's going on is that the page *is* mapped and unmapped by the
kernel as Juerg described, but only in certain cases. See prep_new_page(),
which has the following:

	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
		for (i = 0; i < (1 << order); i++)
			clear_highpage(page + i);

clear_highpage() maps and unmaps the pages, so that's why xpfo works with this
set.

I tried with CONFIG_PAGE_POISONING_ZERO=y and page_poison=y, and the
XPFO_READ_USER test does not fail, i.e. the read succeeds. So, I think we need
to include this zeroing condition in xpfo_alloc_pages(), something like the
patch below. Unfortunately, this fails to boot for me, probably for an
unrelated reason that I'll look into.

Thanks a lot!

Tycho
