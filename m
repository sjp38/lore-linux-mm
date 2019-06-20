Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC333C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 843C12070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:19:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="TyqKBNvB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 843C12070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 107098E0006; Thu, 20 Jun 2019 12:19:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B7EB8E0001; Thu, 20 Jun 2019 12:19:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F11688E0006; Thu, 20 Jun 2019 12:19:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA0B38E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:19:56 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id s197so1517706oih.14
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:19:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yuGyF1gaAxnc5NCYYEX6kiZekDv13zqB0UQA2n5aQis=;
        b=Dpqo/b77cvQWfNijjbsEkm2ZLv/dYSZYALCv+Xnn9RbNyz7GqIvXZaDq32wGt9fhCy
         65MVsxmQrh0ZKZY0DlxecYA63fZwX5uVJzVGKR+g8qiAKLBCoz0SCY+k5lNEK/R1IbmK
         VnGuFpkaQ8TRnEH10kwSOtaC/Fta6jkUSktE2FMCvm//rR9L79/NRC8O+/0Qh8HdCDYo
         xn1IYluUE85hbltv0F/H6jeNV13DFqxuyibNXNEqkmxEv9uIhk4CNYyAyn2OhDzqG1AN
         7xtg3xJe7qZ/JXtgLc9nEbAr4RwDSNveziFSNONqO4rpcBz02tHasvzkjuitoSw4xtXy
         NWWA==
X-Gm-Message-State: APjAAAXr1/jBqOPz3hBOdpJ6VGRcxqWQK6zffSB0gOclVx5t5DfNyvAN
	xbEwO/Ql6fHuatsuNYODZOXE7AveV6q6KK1PS2xwWna4HaJPUKjnuimXDcIpodaNN33h/jWju0P
	C4PAz0a0uG9osbpL//FJCDH2qDRI71sD7qJorYHATDrrFmsyS+nxgcNpPltu+jMNAXQ==
X-Received: by 2002:a05:6830:12d6:: with SMTP id a22mr8488130otq.236.1561047596413;
        Thu, 20 Jun 2019 09:19:56 -0700 (PDT)
X-Received: by 2002:a05:6830:12d6:: with SMTP id a22mr8488087otq.236.1561047595861;
        Thu, 20 Jun 2019 09:19:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561047595; cv=none;
        d=google.com; s=arc-20160816;
        b=Le6CcaExEt0WAGUTkMCrQQUEGHFGC8gGVOotyiCcd59Kfy1hAwHx25pWs6E6vt9Zq4
         4UkKl9DJ9ZH3HkeCY9194j7bdJTrzlcFSL6TB/v4r3t33FDEArXCriJhzANMsSkUT5AW
         lJ6TWfwxr1CrCBzROAauIROC08342H3+71U9NC5daU6HFT2D0JaOM/ZbabTl7gglFJqX
         Bx0JfuiQ+Ao26VdzXn0wWCUvfkbE7j1KSWno79YPRqt0ZKJ6sJv0MzSZTJlYW9GKd7WQ
         VhsftiKgU3w2E88msGNBTsYl+0Sc/+eRfpZ0JUk5EUA46BNte9/oJujl/+b88iyG0sZf
         dYJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yuGyF1gaAxnc5NCYYEX6kiZekDv13zqB0UQA2n5aQis=;
        b=1CGa2T1QVZU+00Ktbor9QZ990m434CglCtC7TsRgDlx1unYBmDl8rhx6XMNZdoAL9Y
         GqtYs6N39LEfKtBPCgCub3IynO44SP9Xeqkym6mTSCPx9HgONfr1XyeTpUaDm0mrRFqU
         F5BNc9rFj0psnIehcIg7LgJhyl0LpBr/SJpeEwT3nHFO6B2boV1Q921zV0piJ9AgRNir
         8wVlHXi6sPPyr3dIrlgdRtlg8mJxsaSnWbmLjjvx1zgj7RiPFfVPP7N+QbSR9yoY4wpX
         gahDhhpU1nk78569ECnrZm0Rfl14uqXm09W7OdYvVzNmUUjFQxsoHydzFZRDOfC/+mXg
         csNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=TyqKBNvB;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x206sor8000576oif.28.2019.06.20.09.19.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 09:19:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=TyqKBNvB;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yuGyF1gaAxnc5NCYYEX6kiZekDv13zqB0UQA2n5aQis=;
        b=TyqKBNvBRHg2N7hM9S8c6U4FOJz5mxm6Kd+KBEMqs2GVrceDbu2B5Yv+Tpqg9S34ys
         MaHgCO6/ySGOZphnnrTbgImRuL2QMVoCGG2VWkmL5W3Uon95vGsNjpaeOGPEgMJOT3L9
         5WEJx442dDZs/YbNnY0UQilkmAx8XpdOKM4CFfFFAge3HyxFPgiIP95x0HYvSNAaMKy6
         1mXvvW5okLy4jiD7hQSkY3gSwkQy7MxiqZoOpVEppM+LOHSdZJYPl7dVTiAul4GD3HrH
         y9JAaW9RA4lNlRmSX3HsfKvWxmHRadsFz/qNFrGo4+gaTh+E4u2Ot15NvBhXkJk5Bz/Z
         edQg==
X-Google-Smtp-Source: APXvYqycTrfFCdUGQlxbLBM8sq/vvF4AR0qE564N7NnNzy2gB1lQelj0Er/vC+yiQUqqVAU2Tj/69BOUevu0+1dRykA=
X-Received: by 2002:aca:d60c:: with SMTP id n12mr4630027oig.105.1561047595403;
 Thu, 20 Jun 2019 09:19:55 -0700 (PDT)
MIME-Version: 1.0
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
 <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
 <70f3559b-2832-67eb-0715-ed9f856f6ed9@redhat.com>
In-Reply-To: <70f3559b-2832-67eb-0715-ed9f856f6ed9@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Jun 2019 09:19:43 -0700
Message-ID: <CAPcyv4jzELzrf-p6ujUwdXN2FRe0WCNhpTziP2-z4-8uBSSp7A@mail.gmail.com>
Subject: Re: [PATCH v10 08/13] mm/sparsemem: Prepare for sub-section ranges
To: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 3:31 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 19.06.19 07:52, Dan Williams wrote:
> > Prepare the memory hot-{add,remove} paths for handling sub-section
> > ranges by plumbing the starting page frame and number of pages being
> > handled through arch_{add,remove}_memory() to
> > sparse_{add,remove}_one_section().
> >
> > This is simply plumbing, small cleanups, and some identifier renames. No
> > intended functional changes.
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Cc: Oscar Salvador <osalvador@suse.de>
> > Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  include/linux/memory_hotplug.h |    5 +-
> >  mm/memory_hotplug.c            |  114 +++++++++++++++++++++++++---------------
> >  mm/sparse.c                    |   16 ++----
> >  3 files changed, 81 insertions(+), 54 deletions(-)
[..]
> > @@ -528,31 +556,31 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
> >   * sure that pages are marked reserved and zones are adjust properly by
> >   * calling offline_pages().
> >   */
> > -void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> > +void __remove_pages(struct zone *zone, unsigned long pfn,
> >                   unsigned long nr_pages, struct vmem_altmap *altmap)
> >  {
> > -     unsigned long i;
> >       unsigned long map_offset = 0;
> > -     int sections_to_remove;
> > +     int i, start_sec, end_sec;
>
> As mentioned in v9, use "unsigned long" for start_sec and end_sec please.

Honestly I saw you and Andrew going back and forth about "unsigned
long i" that I thought this would be handled by a follow on patchset
when that debate settled.

