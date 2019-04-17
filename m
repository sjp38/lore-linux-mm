Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 025C3C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:39:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B3612073F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:39:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B3612073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1596B0005; Wed, 17 Apr 2019 13:39:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27686B0006; Wed, 17 Apr 2019 13:39:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEF666B0007; Wed, 17 Apr 2019 13:39:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5D36B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:39:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e22so11583907edd.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:39:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0Bjj66UgYfd9aJhB7K12bDsdK/ykgg2ctUzSpYhYKZU=;
        b=P1988AafS9hEARYIZpkHyQ/lV8ssG67sRxXVyi/lNP02fUxc0SHN5QWt9ph+1+nRhK
         VOu6SEjVsd5WG43aB+W/SxIOjDwKdEpJSWzN3mylObXrykyk/FGmK1eDNcW8MCgXIddU
         EYFCC+CD3NSBqbj3xmZPDLWjbiXnmCkpoZsnH+AvEQBaXRYDlhPW/Rbce9N/Lsc2KENA
         Lpu6lAbXLnpGmUQVQFKGfOpnCvaOytIU7xez+Lfjk0D8kToSvzCxv6MYdmoCR5v4ewp/
         Eie93FwthPBW84V/5c5A40tkp5n2x06dSCrlkbRqaOVKQoFNGPStNA8gjrkVeHvbUY18
         mKJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVEWweayPRxXaZf/mLEO7CKMuxIykm3n2Qtx1dYnCAp9Yybhpos
	8zdq7pYYhAismMC+BcKiuma3yjNDrBrbhsIYX9bL7MTJraR/2y/vUxX+1BOrloe+K3k6++Ae6j9
	xps6hKc1bNmuQHHNWGjy4JqMjvvO30boBsnf8nObr49YFsDUCEcFVImrHdXEK6ohHRA==
X-Received: by 2002:a50:ad11:: with SMTP id y17mr17453142edc.184.1555522795974;
        Wed, 17 Apr 2019 10:39:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyw63QChPvvIith/EAUctNa6II/W9wQqvvCURa0qAQ4vVEZhCSy+J9yhCgSninHcaupvyjV
X-Received: by 2002:a50:ad11:: with SMTP id y17mr17453096edc.184.1555522794994;
        Wed, 17 Apr 2019 10:39:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555522794; cv=none;
        d=google.com; s=arc-20160816;
        b=JCdb7kP6mXHRO1FK3f16ewPmsJ7RkEeJ4gOv8EugJgllrEGPev/eT+vnedoOQWIzHH
         BY+cEGAcst2NHvpWi+EjajBzvlHg648rfxNC5Oz1nIBxJWrosEHfeb+wlj/vlOGudo/+
         v+bRNOzuQa9by5ZJcGobnj8x7plqdUt84rbs70wRvktk7LYhD+SxvWEx2mhB/b4rCAIm
         /Xr7OkgC91t9WvuplKXZG2TXE0alGFdTPv4D1zYhVD3XhOQlpU+mvhEl7kpVeZloHzAa
         7fTjTN6PYrUgD81QDMHZ9dRgG5zu8llo5O11JOzuE8VA0qfTXCvDXpM0zMb+6i92aGXc
         F7rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0Bjj66UgYfd9aJhB7K12bDsdK/ykgg2ctUzSpYhYKZU=;
        b=GzCOlovOuwN4cSMNRRhRv7dPVdjqQC63VibRzJreNzczrMEYCUK4nRVLl/QL1D1WFY
         8EmHfKjtMAlenOQ9IZBYdmCJZZPT86ZWsrCGYeyPzYQjSCi2GPzYl563Gv4CseBCYyHO
         sWF8swmTLbqgyUqQAkC3etQj/hJutBdT7f1EvEizFfg6PDuACsnt96R9J+uAGkvPjalV
         4ZateF6jBc7bZ+Oz6b7oXxN1x6IikPyLlrx80YLt3ieJbyCqAwgH7FMLw/P+p8ZEmMzk
         gyyXvTabc3x5QVhzePfVkWqeF1luSS3wvkTXzFlfnI+ymCKf6iv7AGzmg442CZJnOaJi
         kCuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f9si410702ejk.68.2019.04.17.10.39.54
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 10:39:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DB00C15AB;
	Wed, 17 Apr 2019 10:39:53 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C0CFD3F59C;
	Wed, 17 Apr 2019 10:39:50 -0700 (PDT)
Date: Wed, 17 Apr 2019 18:39:48 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	robin.murphy@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, osalvador@suse.de, david@redhat.com,
	cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
Message-ID: <20190417173948.GB15589@lakrids.cambridge.arm.com>
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
 <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 10:15:35PM +0530, Anshuman Khandual wrote:
> On 04/17/2019 07:51 PM, Mark Rutland wrote:
> > On Wed, Apr 17, 2019 at 03:28:18PM +0530, Anshuman Khandual wrote:
> >> On 04/15/2019 07:18 PM, Mark Rutland wrote:
> >>> On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:

> >>>> +	spin_unlock(&init_mm.page_table_lock);
> >>>
> >>> What precisely is the page_table_lock intended to protect?
> >>
> >> Concurrent modification to kernel page table (init_mm) while clearing entries.
> > 
> > Concurrent modification by what code?
> > 
> > If something else can *modify* the portion of the table that we're
> > manipulating, then I don't see how we can safely walk the table up to
> > this point without holding the lock, nor how we can safely add memory.
> > 
> > Even if this is to protect something else which *reads* the tables,
> > other code in arm64 which modifies the kernel page tables doesn't take
> > the lock.
> > 
> > Usually, if you can do a lockless walk you have to verify that things
> > didn't change once you've taken the lock, but we don't follow that
> > pattern here.
> > 
> > As things stand it's not clear to me whether this is necessary or
> > sufficient.
> 
> Hence lets take more conservative approach and wrap the entire process of
> remove_pagetable() under init_mm.page_table_lock which looks safe unless
> in the worst case when free_pages() gets stuck for some reason in which
> case we have bigger memory problem to deal with than a soft lock up.

Sorry, but I'm not happy with _any_ solution until we understand where
and why we need to take the init_mm ptl, and have made some effort to
ensure that the kernel correctly does so elsewhere. It is not sufficient
to consider this code in isolation.

IIUC, before this patch we never clear non-leaf entries in the kernel
page tables, so readers don't presently need to take the ptl in order to
safely walk down to a leaf entry.

For example, the arm64 ptdump code never takes the ptl, and as of this
patch it will blow up if it races with a hot-remove, regardless of
whether the hot-remove code itself holds the ptl.

Note that the same applies to the x86 ptdump code; we cannot assume that
just because x86 does something that it happens to be correct.

I strongly suspect there are other cases that would fall afoul of this,
in both arm64 and generic code.

Thanks,
Mark.

