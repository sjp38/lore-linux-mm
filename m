Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E78C9C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8535C24F14
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:17:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Ylkho9VZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8535C24F14
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6D6B6B000D; Tue,  4 Jun 2019 00:17:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1E126B0010; Tue,  4 Jun 2019 00:17:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C33866B0266; Tue,  4 Jun 2019 00:17:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 991886B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 00:17:57 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id e3so10014143otk.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 21:17:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hltidb8QtHOPGObUrHtf/4ZtTKSopSnDSqcRsOo2rxw=;
        b=RGgfwJw3qBszRAT9rjo427kzuSNiMkwCiKimfKLFvVm5vI8j0G55SENevxfGKtzeEh
         HSrzcE9iQSqCrLfA+QxJOW+oWJFm45IDrHxgGj5O2iNryf60v6AeqijLsCLCGkbZDmZS
         JrhaJkhf5Lok1Kd/xcAcjhhVela18pYG3Gs/21Vf2jvA62y6Od2mLf8Qz94BqriNJi4C
         J6ssSlfqAPIUQsJavFhhVrYMdZK5Qv5QLRxcthJfXZGSNhSXVqDGNVcASiYPQ1naubwC
         tTHSXUaupVAayvOfgTqGXUH68OVX4Xz1FgLLDgn/62NfUr1Un39RYTA3H51a//YZnKAp
         QMhA==
X-Gm-Message-State: APjAAAWOXtFut/+px6e7nRL6ya7FciIrK6N3EZDPDMEAIYBNIEOwcvic
	idlrt7HHiyIfrfLdCdBveOW6XkwMzzmw5vGIvzHAB5bPBRL9QTJhLOwg5uj7clHidOtq7P0nwtB
	ZaJruNVEmrfB56W1LJri/BwZZzEH2myYyTjMZVSmYFTCJNPcL9RQvN8uQZBArjXz72g==
X-Received: by 2002:a9d:18d:: with SMTP id e13mr3730064ote.32.1559621877206;
        Mon, 03 Jun 2019 21:17:57 -0700 (PDT)
X-Received: by 2002:a9d:18d:: with SMTP id e13mr3730022ote.32.1559621876396;
        Mon, 03 Jun 2019 21:17:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559621876; cv=none;
        d=google.com; s=arc-20160816;
        b=CZptvnSnxpSQqGkBLHrCacG/TcFPhFL3IznIvbZIYkBiBcst/hhq3ncN6yPx+B9bjq
         p/YWxEjVwA75vMAstdqRZXcvCC1suGbTQYICjNoCi5jtojVlLYnl+PnFw0V10jNAphQJ
         CG7Pc+p10CZKmfFDd7mmdWhKthoXRS/CmFSWvq+7ni8LnYZ21lrcSj+mE3Qf8J5dMqEA
         BBaBEQZ0//JnMxHEYsD7FN35iR6io4ftWw7oAbz/QZ+UCqBGBMyj3tmO9oiAPw2/7Mla
         6SDG7raWkFZSxNwsniLnjVRUZUWMvLRVGCD6NYmJ6KwYZ9qORmZBFHRpwvYdAmAmSH+y
         CWAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hltidb8QtHOPGObUrHtf/4ZtTKSopSnDSqcRsOo2rxw=;
        b=wVe6IyMPiYuqVlGG9+P64ag8x5+CPv8yERLqkHir6KcceYPaydgbDhfrANd7xQZODj
         /l5dxoYruk56hMdtrLDd2wSy1RPq5s3P+vCVY+WO2miY9dlGh3xpdCq4Jee+a/NRvo0V
         1aebVKmwHXzt49VfsK5jchiBCaHPzgSdStKtK3D9HURCacmnZi0Imuqb3xY+En0EjmGs
         1N2QGLrpbuBJAhkAOksXsJeRswy3cDTqWuXxeNOV5SL5EdKL1+/WLJ+2bIn2qOBegUls
         HBpPQyJTp7hEjUOlqHqSCc59s+nzZ35aKgPvHmhwAUNbuWuXn0kqALlWZwMzFFJ8MYsT
         WiqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ylkho9VZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e14sor7717107oti.87.2019.06.03.21.17.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 21:17:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ylkho9VZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hltidb8QtHOPGObUrHtf/4ZtTKSopSnDSqcRsOo2rxw=;
        b=Ylkho9VZmxrfNPZuXnkJqmPSoMFRbrUkdrtYfi9TjOfn5rg1xJOod4IoGWz/MBoi1z
         SKaIfklCToaQ05NrOxSCmDKfVaQoJciFCLThIiUTVOm8h1cZYWNBEvS31DqUaCzTt7lj
         D85LvLurfQi+AwomNGxJ4J+bTDtmYwVSStL+Z0WY44DZdbovZH7MZN8azhTPVgTtpj8l
         aGi+QoS4/idCbF/AJjecqoBpmBYZDsC82qz3wGtO4cB+aYfi2CQK94fw5Z47Mfhfru48
         1J8TMQPUj+L4my+E+d5z6GzzvleTKb8BJSaUOx3aFfZQhvuVA7Weh4QDbpGZDAsPTth0
         6YUw==
X-Google-Smtp-Source: APXvYqwo/LUbj2pYOXZO3ffCZPIeLTijVrKjdQTitvOc7MYQLuagna3P5yWym8s7Wsy/jQis1++NrNsm5wG+0k9zBSo=
X-Received: by 2002:a9d:6e96:: with SMTP id a22mr3655013otr.207.1559621875900;
 Mon, 03 Jun 2019 21:17:55 -0700 (PDT)
MIME-Version: 1.0
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677657023.2336373.4452495266651002382.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190503125634.GH15740@linux>
In-Reply-To: <20190503125634.GH15740@linux>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 3 Jun 2019 21:17:44 -0700
Message-ID: <CAPcyv4jx-+QJC3Aw-wY9PWshCWpu2VZKZz=PjTO7jN5Ojxz+pg@mail.gmail.com>
Subject: Re: [PATCH v7 09/12] mm/sparsemem: Support sub-section hotplug
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 3, 2019 at 5:56 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Wed, May 01, 2019 at 10:56:10PM -0700, Dan Williams wrote:
> > The libnvdimm sub-system has suffered a series of hacks and broken
> > workarounds for the memory-hotplug implementation's awkward
> > section-aligned (128MB) granularity. For example the following backtrace
> > is emitted when attempting arch_add_memory() with physical address
> > ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
> > within a given section:
> >
> >  WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
> >  devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
> >  [..]
> >  Call Trace:
> >    dump_stack+0x86/0xc3
> >    __warn+0xcb/0xf0
> >    warn_slowpath_fmt+0x5f/0x80
> >    devm_memremap_pages+0x3b5/0x4c0
> >    __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
> >    pmem_attach_disk+0x19a/0x440 [nd_pmem]
> >
> > Recently it was discovered that the problem goes beyond RAM vs PMEM
> > collisions as some platform produce PMEM vs PMEM collisions within a
> > given section. The libnvdimm workaround for that case revealed that the
> > libnvdimm section-alignment-padding implementation has been broken for a
> > long while. A fix for that long-standing breakage introduces as many
> > problems as it solves as it would require a backward-incompatible change
> > to the namespace metadata interpretation. Instead of that dubious route
> > [1], address the root problem in the memory-hotplug implementation.
> >
> > [1]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  mm/sparse.c |  223 ++++++++++++++++++++++++++++++++++++++++-------------------
> >  1 file changed, 150 insertions(+), 73 deletions(-)
> >
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 198371e5fc87..419a3620af6e 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -83,8 +83,15 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
> >       unsigned long root = SECTION_NR_TO_ROOT(section_nr);
> >       struct mem_section *section;
> >
> > +     /*
> > +      * An existing section is possible in the sub-section hotplug
> > +      * case. First hot-add instantiates, follow-on hot-add reuses
> > +      * the existing section.
> > +      *
> > +      * The mem_hotplug_lock resolves the apparent race below.
> > +      */
> >       if (mem_section[root])
> > -             return -EEXIST;
> > +             return 0;
>
> Just a sidenote: we do not bail out on -EEXIST, so it should be fine if we
> stick with it.
> But if not, I would then clean up sparse_add_section:
>
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -901,13 +901,12 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
>         int ret;
>
>         ret = sparse_index_init(section_nr, nid);
> -       if (ret < 0 && ret != -EEXIST)
> +       if (ret < 0)
>                 return ret;
>
>         memmap = section_activate(nid, start_pfn, nr_pages, altmap);
>         if (IS_ERR(memmap))
>                 return PTR_ERR(memmap);
> -       ret = 0;

Good catch, folded the cleanup.

>
>
> > +
> > +     if (!mask)
> > +             rc = -EINVAL;
> > +     else if (mask & ms->usage->map_active)
>
>         else if (ms->usage->map_active) should be enough?
>
> > +             rc = -EEXIST;
> > +     else
> > +             ms->usage->map_active |= mask;
> > +
> > +     if (rc) {
> > +             if (usage)
> > +                     ms->usage = NULL;
> > +             kfree(usage);
> > +             return ERR_PTR(rc);
> > +     }
> > +
> > +     /*
> > +      * The early init code does not consider partially populated
> > +      * initial sections, it simply assumes that memory will never be
> > +      * referenced.  If we hot-add memory into such a section then we
> > +      * do not need to populate the memmap and can simply reuse what
> > +      * is already there.
> > +      */
>
> This puzzles me a bit.
> I think we cannot have partially populated early sections, can we?

Yes, at boot memory need not be section aligned it has historically
been handled as a un-removable section of memory with holes.

> And how we even come to hot-add memory into those?
>
> Could you please elaborate a bit here?

Those sections are excluded from add_memory_resource() adding more
memory, but arch_add_memory() with sub-section support can fill in the
subsection holes in mem_map.

>
> > +     ms = __pfn_to_section(start_pfn);
> >       section_mark_present(ms);
> > -     sparse_init_one_section(ms, section_nr, memmap, usage);
> > +     sparse_init_one_section(ms, section_nr, memmap, ms->usage);
> >
> > -out:
> > -     if (ret < 0) {
> > -             kfree(usage);
> > -             depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
> > -     }
> > +     if (ret < 0)
> > +             section_deactivate(start_pfn, nr_pages, nid, altmap);
>
> Uhm, if my eyes do not trick me, ret is only used for the return value from
> sparse_index_init(), so this is not needed. Can we get rid of it?

Yes, these can go.

Apologies for the delay and missing these comments in the v8 posting.

