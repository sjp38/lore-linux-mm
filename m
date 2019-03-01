Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5E56C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 16:54:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CD1F20857
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 16:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CD1F20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 008E98E0004; Fri,  1 Mar 2019 11:54:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED5C28E0001; Fri,  1 Mar 2019 11:54:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9D338E0004; Fri,  1 Mar 2019 11:54:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABA7D8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 11:54:55 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y6so19362571qke.1
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 08:54:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BJVSSXVm2/ulmKC8Ka6bKJsmuBBzD5EsaoCvB88NW7Y=;
        b=XvMGWcY737yLQWRPW8ZXLTqvv5WYkU537nOAPnabCCPI2f+zyD6gthOIFjpOrZeLPe
         +BTFX6vsQr+PJO+j/T67OB+0lM1iEWWdkQot7aFVjnQaPSphb3VJb/rOgu8mSaZM9LNW
         /UgCK5CZSBHfioqX1DFR1vjHUDGFHAbYNrLcuPXY7LTxOiz/10sg6HthehF6Vf+Fnoq6
         WlYUrMagFBuWh8x0GRbbakLd06u+6jSEPj5lCtBhzwuIca6kpVmldH+jxZQEQEdb/aoN
         t9wtvfbBjb0ld6Nkbgkif1S/L0osuqeHEGQF6mol+vaP56MizANNbkCrca4NPKNMyWWt
         zk4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXUdVoKyyrd6jPt3JG8N23v1GpwbwJVOY+whYfNqbdS2GpppRXC
	wGZrMYEFbVcXwKCsIMI2MIfFe9PT8ec9XGxck0Y5MzqfrSkd5zXU/xNDQUKHrRFvcffFkg0dd71
	V6/ZnGcuQXuQeh5L52AjGXDeoP2Tnc7/2ZjRDqdYGzQKJZaX4NUq1v+qoyye5PxWR/A==
X-Received: by 2002:ac8:1662:: with SMTP id x31mr4677562qtk.55.1551459295393;
        Fri, 01 Mar 2019 08:54:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqyFaHyZqzLRaTnKx83HAti7dg56Gee0ELz3/jsAE2YTJkhsTGJ6neFC/7i3m4QZ2fM28z27
X-Received: by 2002:ac8:1662:: with SMTP id x31mr4677513qtk.55.1551459294481;
        Fri, 01 Mar 2019 08:54:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551459294; cv=none;
        d=google.com; s=arc-20160816;
        b=Uw1mS5KuauAbZ6zP5oXwIr9PbGpIXfaMUOK06DSP3YsmhXZ40wSzcjI1krBYH42D3M
         an1tsO63/ZQCJedfnqQK7lfuB81hXAnE1DBnuvaMfx5J8sUfF8lXDZgNKMGuyxP1WDgD
         zBAB9IjDSSQfU7ZNbPhoTvB2TKfwfcSi1s0iAJXePI3ICuZQn8gs7e6UA4dtP/8joMnD
         +KfYxflxRNVEu1z8LYyi0BB2qRrYA4N6+aYJzQTxGaWSXRR90BpCiZKoaBE4SfLbV3iV
         ZlfHVN4yNizeekaZcBWuoACeA0fNOqXPMlUPsU10wdjGBGb7Q1Z7rxAQ0x66eDU/H4bH
         yRUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BJVSSXVm2/ulmKC8Ka6bKJsmuBBzD5EsaoCvB88NW7Y=;
        b=cECRuqXN8+HyiCKRlQhlxOCu3f2VWJfsp/WTf5MvNN7SU5FTUEGqrmpylfV64vb6Wx
         HTvt0G7+HStBfkX8+0lOQCaX0AeGqyosGRhftgjzFclw0hhKzutkUzvxcNawQlCUv7WU
         n9pjLEJ/IXZ9io2cwSlYLqHVyHIezOM1cNAm9wLKUvFN/dsDINyoAfLN0q+5Q2DpPz3T
         0saXcMCHasJKlQV/ioftf8J9kLVCReLG+2NM0FGP3x9NMFYl35JDPxFPU4WSFMzNM8pG
         pI3V2kVNbThNIj9D1ELDhB/Z8AEt13wwsOacLJVKvnJbTVi5B3ngi4jL6/1vJsVrtXXH
         mJjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o35si4008750qvf.8.2019.03.01.08.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 08:54:54 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 884F95438D;
	Fri,  1 Mar 2019 16:54:53 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4A7965E7A8;
	Fri,  1 Mar 2019 16:54:53 +0000 (UTC)
Date: Fri, 1 Mar 2019 11:54:52 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 0/2] RFC: READ/WRITE_ONCE vma/mm cleanups
Message-ID: <20190301165452.GP14294@redhat.com>
References: <20190301035550.1124-1-aarcange@redhat.com>
 <20190301093729.wa4phctbvplt5pg3@kshutemo-mobl1>
 <3e8b2ff0-d188-5259-b488-e31355e1e8ad@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3e8b2ff0-d188-5259-b488-e31355e1e8ad@suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 01 Mar 2019 16:54:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Kirill and Vlastimil,

On Fri, Mar 01, 2019 at 02:04:38PM +0100, Vlastimil Babka wrote:
> On 3/1/19 10:37 AM, Kirill A. Shutemov wrote:
> > On Thu, Feb 28, 2019 at 10:55:48PM -0500, Andrea Arcangeli wrote:
> >> Hello,
> >>
> >> This was a well known issue for more than a decade, but until a few
> >> months ago we relied on the compiler to stick to atomic accesses and
> >> updates while walking and updating pagetables.
> >>
> >> However now the 64bit native_set_pte finally uses WRITE_ONCE and
> >> gup_pmd_range uses READ_ONCE as well.
> >>
> >> This convert more racy VM places to avoid depending on the expected
> >> compiler behavior to achieve kernel runtime correctness.
> >>
> >> It mostly guarantees gcc to do atomic updates at 64bit granularity
> >> (practically not needed) and it also prevents gcc to emit code that
> >> risks getting confused if the memory unexpectedly changes under it
> >> (unlikely to ever be needed).
> >>
> >> The list of vm_start/end/pgoff to update isn't complete, I covered the
> >> most obvious places, but before wasting too much time at doing a full
> >> audit I thought it was safer to post it and get some comment. More
> >> updates can be posted incrementally anyway.
> > 
> > The intention is described well to my eyes.
> > 
> > Do I understand correctly, that it's attempt to get away with modifying
> > vma's fields under down_read(mmap_sem)?

The issue is that we already get away with it, but we do it without
READ/WRITE_ONCE. The patch should changes nothing, it should only
reduce the dependency on the compiler to do what we expect.

> If that's the intention, then IMHO it's not that well described. It
> talks about "racy VM places" but e.g. the __mm_populate() changes are
> for code protected by down_read(). So what's going on here?

expand_stack can move anonymous vma vm_end up or vm_start/pgoff down,
while we hold the mmap_sem for writing. See the location of the three
WRITE_ONCE in the patch.

So whenever we deal with a vma that we don't know if it's filebacked
(filebacked vmas cannot growsup/down) and that we don't know if it has
VM_GROWSDOWN/UP set, we shall use READ_ONCE to access
vm_start/end/pgoff. This is the only thing the patch is about, and it
should make no runtime difference at all, but then the WRITE_ONCE in
native_set_pte also should make no runtime difference just like the
READ_ONCE in gup_pmd_range should make no runtime difference. I mean
we don't trust the compiler with gup_fast but then we trust it with
expand_stack vs find_vma.

