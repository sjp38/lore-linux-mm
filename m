Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D3EDC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:39:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFC7B2077B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:39:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFC7B2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E1238E00DD; Thu, 21 Feb 2019 19:39:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58F078E00D4; Thu, 21 Feb 2019 19:39:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47F458E00DD; Thu, 21 Feb 2019 19:39:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD968E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:39:36 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id q81so264423qkl.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:39:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fM95MCd9whOYAli56knJMRg2kfUG0CrSJwdeO5vDRj4=;
        b=VqDCk4cM2eVsVmRJFnU1XwZrJFu9KBPDZrfFeXqq+dewHqx9UunBNouEKyvgQVtoqw
         7ImGFIcqndeQZXD3yrNHa9Hq7uPr9yEJap9UaDk9FJCsCOQ9MdgYfPsiAIPhSi65iVLB
         FcmWn51s/sX0DOych3w2kwoXlsc6UP5IgoclK3loTMq6k6Nu9soWJzWzRkUzaeIwWzI/
         31rF775N+DEVlnEOowqg7E0JhkzWZHghN88oADT83HjIAYyuYmOS757HWJYyXuxKI6pg
         eh4iGDjPiJbBWoxcxAekqrzSVzB70YPmH4vKrr4NAW0fLis1EqGV3vY+OKtPT1eUq8Fy
         UXDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubodb8KyerjzyKxJZp4QkQweCuiC5nssEm/X2RjtR5njpqDSZGX
	1TtD5IoDdmUQrz5rxfrs+EnGJbpKG+DJhGyEvD168jenCf4U3SErSbvWr4d/QpcwiTrG1izfwG/
	vol5DJvfyBUSLgKCnCLCy3UIVfqRoMcheXbG9G0L76+FNzLpGOVKMaqxNZSmYmRQXEQ==
X-Received: by 2002:a0c:d1a7:: with SMTP id e36mr1083501qvh.127.1550795975849;
        Thu, 21 Feb 2019 16:39:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IakUT0pfQPBENXP4NKUjYSYajS9yoe7cSykcUsgVHlqTFu8z6k8CGmZQQZk65nUBqIAew7V
X-Received: by 2002:a0c:d1a7:: with SMTP id e36mr1083463qvh.127.1550795975144;
        Thu, 21 Feb 2019 16:39:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550795975; cv=none;
        d=google.com; s=arc-20160816;
        b=oJnPBaSEojbU7bMC5HyBQpDiLMdnzy6KMXEAPUYisk/S63zSWkxIi90wN37v22CpYQ
         EC3XBpxWh3tD9vYxCGjCBU45zEcLfh4AXBWVD5CHjgMtfGtjcylbxUlFSLEmKGbri+2X
         HUB869UTDuYgm/3M1TwNUihTtNcKTr9Dbtuuu6lWX3wc9sDibQwfSSUbllVbkJJhqHlF
         rnh/gnQUNbZUNaj+dxpMKgSrqX6TCGjg/w5F7YVpoNOWw5txDMNigLaOPnb7lw3Srnbo
         dwvwkRLHZ6kTUmtPtUfHRZ+GN1N8hObhxvsLSTSZqdOAm17sr/IfkKxBnGLuootpQghU
         y05Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fM95MCd9whOYAli56knJMRg2kfUG0CrSJwdeO5vDRj4=;
        b=uf5bfJGLKfnMit+oiiiHkLTYbYWcP6A4nixeX+NLQxUqLGDNwsW9UU50mo7nDRwk22
         HMdYrHjbbUE/RtpPBtX1KorYaI59mV/SDg0qkGBApGvAOFbsVuYWy+aqSuUgXhz+xFOH
         tn2uR6n5QMEqaOYo4yUAnV0/tF7Rrmd8mG1u7AvXJFMWMaomU/nVT5JIFfrM8D2/OOHS
         klDbp4xGCOTIZS4S7B1ExpRljlT8VfYaeJQ58QsfPl5J5PjIa4N2asrDqB0PgX/0Ol1K
         mIxGMNR8ER70NTzIYyMxzTGQjt04h/hkgS/4QINTj8mhe1LnQ/6WSyZewZoPN/K1cFGD
         mCsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o16si235690qta.278.2019.02.21.16.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 16:39:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4E52D5947F;
	Fri, 22 Feb 2019 00:39:34 +0000 (UTC)
Received: from redhat.com (ovpn-120-13.rdu2.redhat.com [10.10.120.13])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AE72A5C5E0;
	Fri, 22 Feb 2019 00:39:33 +0000 (UTC)
Date: Thu, 21 Feb 2019 19:39:31 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Larry Bassel <larry.bassel@oracle.com>
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: question about page tables in DAX/FS/PMEM case
Message-ID: <20190222003931.GB10607@redhat.com>
References: <20190220230622.GI19341@ubuette>
 <20190221204141.GB5201@redhat.com>
 <20190221225827.GA2764@ubuette>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221225827.GA2764@ubuette>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 22 Feb 2019 00:39:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 02:58:27PM -0800, Larry Bassel wrote:
> [adding linux-mm]
> 
> On 21 Feb 19 15:41, Jerome Glisse wrote:
> > On Wed, Feb 20, 2019 at 03:06:22PM -0800, Larry Bassel wrote:
> > > I'm working on sharing page tables in the DAX/XFS/PMEM/PMD case.
> > > 
> > > If multiple processes would use the identical page of PMDs corresponding
> > > to a 1 GiB address range of DAX/XFS/PMEM/PMDs, presumably one can instead
> > > of populating a new PUD, just atomically increment a refcount and point
> > > to the same PUD in the next level above.
> 
> Thanks for your feedback. Some comments/clarification below.
> 
> > 
> > I think page table sharing was discuss several time in the past and
> > the complexity involve versus the benefit were not clear. For 1GB
> > of virtual address you need:
> >     #pte pages = 1G/(512 * 2^12)       = 512 pte pages
> >     #pmd pages = 1G/(512 * 512 * 2^12) = 1   pmd pages
> > 
> > So if we were to share the pmd directory page we would be saving a
> > total of 513 pages for every page table or ~2MB. This goes up with
> > the number of process that map the same range ie if 10 process map
> > the same range and share the same pmd than you are saving 9 * 2MB
> > 18MB of memory. This seems relatively modest saving.
> 
> The file blocksize = page size in what I am working on would
> be 2 MiB (sharing puds/pages of pmds), I'm not trying to
> support sharing pmds/pages of ptes. And yes, the savings in this
> case is actually even less than in your example (but see my example below).
> 
> > 
> > AFAIK there is no hardware benefit from sharing the page table
> > directory within different page table. So the only benefit is the
> > amount of memory we save.
> 
> Yes, in our use case (high end Oracle database using DAX/XFS/PMEM/PMD)
> the main benefit would be memory savings:
> 
> A future system might have 6 TiB of PMEM on it and
> there might be 10000 processes each mapping all of this 6 TiB.
> Here the savings would be approximately
> (6 TiB / 2 MiB) * 8 bytes (page table size) * 10000 = 240 GiB
> (and these page tables themselves would be in non-PMEM (ordinary RAM)).

Damm you have a lot of process, must mean many cores, i want one of those :)

[...]

> > > If the process later munmaps this file or exits but there are still
> > > other users of the shared page of PMDs, I would need to
> > > detect that this has happened and act accordingly (#3 above)
> > > 
> > > Where will these page table entries be torn down?
> > > In the same code where any other page table is torn down?
> > > If this is the case, what would the cleanest way of telling that these
> > > page tables (PMDs, etc.) correspond to a DAX/FS/PMEM mapping
> > > (look at the physical address pointed to?) so that
> > > I could do the right thing here.
> > > 
> > > I understand that I may have missed something obvious here.
> > > 
> > 
> > They are many issues here are the one i can think of:
> >     - finding a pmd/pud to share, you need to walk the reverse mapping
> >       of the range you are mapping and to find if any process or other
> >       virtual address already as a pud or pmd you can reuse. This can
> >       take more time than allocating page directory pages.
> >     - if one process munmap some portion of a share pud you need to
> >       break the sharing this means that munmap (or mremap) would need
> >       to handle this page table directory sharing case first
> >     - many code path in the kernel might need update to understand this
> >       share page table thing (mprotect, userfaultfd, ...)
> >     - the locking rules is bound to be painfull
> >     - this might not work on all architecture as some architecture do
> >       associate information with page table directory and that can not
> >       always be share (it would need to be enabled arch by arch)
> 
> Yes, some architectures don't support DAX at all (note again that
> I'm not trying to share non-DAX page table here).

DAX is irrelevant here, DAX is a property of the underlying filesystem
and for the most part the core mm is blissfully unaware of it. So all
of the above apply.

> > 
> > The nice thing:
> >     - unmapping for migration, when you unmap a share pud/pmd you can
> >       decrement mapcount by share pud/pmd count this could speedup
> >       migration
> 
> A followup question: the kernel does sharing of page tables for hugetlbfs
> (also 2 MiB pages), why aren't the above issues relevant there as well
> (or are they but we support it anyhow)?

hugetlbfs is a thing on its own like no other in the kernel and i don't
think we want to repeat it. It has special case all over the mm so all
the case that can go wrong are handled by the hugetlbfs code instead of
core mm function.

I would not follow that as an example i don't think there is much love
for what hugetlbfs turned into.

Cheers,
Jérôme

