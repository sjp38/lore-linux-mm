Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6FF1C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:00:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BA8E208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:00:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vK1kBeO5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BA8E208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22C626B0005; Wed, 19 Jun 2019 09:00:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DBEA8E0002; Wed, 19 Jun 2019 09:00:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A44C8E0001; Wed, 19 Jun 2019 09:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B02906B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:00:19 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id g2so1300988wrq.19
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:00:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=ZPtMzsXKkMBsW4PImpt9W2WqZB9B46FVHfm7jHpIiJo=;
        b=dFKlho387cmxlBRDP1Psj0vzXXho4WoNIqC3QK/jPQ9Ca2Ckde4mG0yiyW7x+ISOpu
         clBs7IeEJx9+dw64y2fmvrlIcG+U2AhSJNSfqmiI4z8DtAnhn8SDGY6qq3aiy15epXyu
         IfN5uOraeiE0UV2tnsjOuqFWMVyVFd2P7sTTTp5wwxtjulZin0UgtyjMTLU1zVLzNI7H
         osvtltpI9Mn6ZQpnlzl/AMNf6KThXlKqMDisrNFkIQrr2QWzhbJDYRowx+ZvmtSyzUnc
         c2TdzcK0ayQkOY3ogRAdf14lQkNYOmNpZin5XILlRmaxydiQx3FP4o7tvLl2VLVbHqT9
         Ti/g==
X-Gm-Message-State: APjAAAV70FhQGnRfQ9WE5+uQrVvnDKA+IIHdh8gedMKtct9fCd+NQcfq
	xmk/392fYnsV/pH6nJrv7pk0UdRjzyor3xSIM54QWXtmDnHY+E2sOvvgBfXAuv2uT0YlMxfNhmb
	l11dK/0mYhOzAMI8zGiNu9yGLvvxhmoAHalCS3J/F4CzdAooauV7dtKtPZAfhqKVaqQ==
X-Received: by 2002:a1c:a6d1:: with SMTP id p200mr8595082wme.169.1560949219255;
        Wed, 19 Jun 2019 06:00:19 -0700 (PDT)
X-Received: by 2002:a1c:a6d1:: with SMTP id p200mr8594987wme.169.1560949218328;
        Wed, 19 Jun 2019 06:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560949218; cv=none;
        d=google.com; s=arc-20160816;
        b=DdFl/3xZPZjOEW7E/lsJBA74fjlfnx/Bnnl1R937yBkNpCHJU0fHrNl0nS28IK3QR1
         6WZgje76BFooiSB4GkPOCizLUbEEs+vrNcZ5UzHgIfDW1yW6QhBSJuzHc3vRlcC3zoti
         zxTOXxpUuBXxCvXuRmiTuGMbyNAWf8zaXfebxKJJ2xnP7Xb3Ai8mCAGimaapGsi/Iefg
         Ht5lmxwTTxFFS3JncREKhs2yfMf1m9WkbuzftClIUnx2Hpp8HENowFjoE4CzQygSwDzG
         JBWsGmXzJF3lC4SKTQuNlgnJv0BlBG8wdhYvCO9p/ZwyCfug0BGF1lJOdVJQ9Y4sXNgq
         2VBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ZPtMzsXKkMBsW4PImpt9W2WqZB9B46FVHfm7jHpIiJo=;
        b=pTcEFjqYyJpSjzO34p5V1ASP7GSgcMMcECX6/W2baLiSVyrK1WHTBLlQYXNYwGJtNs
         iAdpdSVKX2OKh7lI33dB8io2UGonRBb9G4YmjUdQ5l8oRUQw+VzDGNEcaivhjQOTxt+G
         bnPeMctscJ1XKEt9TrgW5M7aG6oOoBc3FnH6ueVWgPEkzCPDHJJ7BD84XUfpW70GungB
         fg7vnVdwcL4QwYOmMKu5JZTDKQntKGoLrv0xh2Zmvqgy7FqjW8gstu2iiQv4ufSioVql
         OvwIOsa0un7jCIghlWbeOSVzFvw1FMuTCb+H+V4oZLipNwfbrAcFZlvXg65Ax8aAMGNO
         Eh2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vK1kBeO5;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor13435276wrv.19.2019.06.19.06.00.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 06:00:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vK1kBeO5;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ZPtMzsXKkMBsW4PImpt9W2WqZB9B46FVHfm7jHpIiJo=;
        b=vK1kBeO5pB0oPOUcDhnV1dVsLIUNePXri3RCN4CmmeceOkpt5LJZtl2bpaMFrvb+m2
         fDmFVykEDGN3TgFwReYK49KxvnaASFV8BJoWnTrPiF22x3vlJvkhE9qGRBZ07hzZ7MGx
         UtAIbdA9GP6hV5Nq2ijXTipBSW1CaAvPWo6I2dThCp+G0+6yhSE5oaHn4Etb81nfrb6a
         Frn3lBpbHMOukt1QrCdBneWxTJhatukKTde3+3Gy6vejF4hdiJgRuKcg5MThhH6R5pru
         rBP1sJh2IXCfD7RlxWqM1T4Ki2WZ9fkGtyAiNrHdhWD9+P84cS0wOA4KYx6PgTRZKplg
         zmNA==
X-Google-Smtp-Source: APXvYqz/0yszyumiNDTcPF0ZTqWHxmKrnjlrkVNhcbqJJZTTIj8bhkNn6GitTiH/zhNwq0HpxdGKX02YeJt+wG74Snk=
X-Received: by 2002:adf:9d81:: with SMTP id p1mr9108405wre.294.1560949217586;
 Wed, 19 Jun 2019 06:00:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com> <20190613045903.4922-4-namit@vmware.com>
 <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
 <98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com> <8072D878-BBF2-47E4-B4C9-190F379F6221@vmware.com>
In-Reply-To: <8072D878-BBF2-47E4-B4C9-190F379F6221@vmware.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 19 Jun 2019 08:00:05 -0500
Message-ID: <CAErSpo5eiweMk2rfT81Kwnpd=MZsOa01prPo_rAFp-MZ9F2xdQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
To: Nadav Amit <namit@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, 
	Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 12:40 AM Nadav Amit <namit@vmware.com> wrote:
>
> > On Jun 17, 2019, at 10:33 PM, Nadav Amit <namit@vmware.com> wrote:
> >
> >> On Jun 17, 2019, at 9:57 PM, Andrew Morton <akpm@linux-foundation.org>=
 wrote:
> >>
> >> On Wed, 12 Jun 2019 21:59:03 -0700 Nadav Amit <namit@vmware.com> wrote=
:
> >>
> >>> For efficient search of resources, as needed to determine the memory
> >>> type for dax page-faults, introduce a cache of the most recently used
> >>> top-level resource. Caching the top-level should be safe as ranges in
> >>> that level do not overlap (unlike those of lower levels).
> >>>
> >>> Keep the cache per-cpu to avoid possible contention. Whenever a resou=
rce
> >>> is added, removed or changed, invalidate all the resources. The
> >>> invalidation takes place when the resource_lock is taken for write,
> >>> preventing possible races.
> >>>
> >>> This patch provides relatively small performance improvements over th=
e
> >>> previous patch (~0.5% on sysbench), but can benefit systems with many
> >>> resources.
> >>
> >>> --- a/kernel/resource.c
> >>> +++ b/kernel/resource.c
> >>> @@ -53,6 +53,12 @@ struct resource_constraint {
> >>>
> >>> static DEFINE_RWLOCK(resource_lock);
> >>>
> >>> +/*
> >>> + * Cache of the top-level resource that was most recently use by
> >>> + * find_next_iomem_res().
> >>> + */
> >>> +static DEFINE_PER_CPU(struct resource *, resource_cache);
> >>
> >> A per-cpu cache which is accessed under a kernel-wide read_lock looks =
a
> >> bit odd - the latency getting at that rwlock will swamp the benefit of
> >> isolating the CPUs from each other when accessing resource_cache.
> >>
> >> On the other hand, if we have multiple CPUs running
> >> find_next_iomem_res() concurrently then yes, I see the benefit.  Has
> >> the benefit of using a per-cpu cache (rather than a kernel-wide one)
> >> been quantified?
> >
> > No. I am not sure how easy it would be to measure it. On the other hand=
er
> > the lock is not supposed to be contended (at most cases). At the time I=
 saw
> > numbers that showed that stores to =E2=80=9Cexclusive" cache lines can =
be as
> > expensive as atomic operations [1]. I am not sure how up to date these
> > numbers are though. In the benchmark I ran, multiple CPUs ran
> > find_next_iomem_res() concurrently.
> >
> > [1] http://sigops.org/s/conferences/sosp/2013/papers/p33-david.pdf
>
> Just to clarify - the main motivation behind the per-cpu variable is not
> about contention, but about the fact the different processes/threads that
> run concurrently might use different resources.

IIUC, the underlying problem is that dax relies heavily on ioremap(),
and ioremap() on x86 takes too long because it relies on
find_next_iomem_res() via the __ioremap_caller() ->
__ioremap_check_mem() -> walk_mem_res() path.

The fact that x86 is the only arch that does this much work in
ioremap() makes me wonder.  Is there something unique about x86
mapping attributes that requires this extra work, or is there some way
this could be reworked to avoid searching the resource map in the
first place?

Bjorn

