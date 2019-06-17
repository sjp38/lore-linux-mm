Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83AEEC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:32:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37A9A2089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:32:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="a91I+xSD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37A9A2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE9EF8E0004; Mon, 17 Jun 2019 18:32:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A99D58E0001; Mon, 17 Jun 2019 18:32:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9628D8E0004; Mon, 17 Jun 2019 18:32:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7408E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:32:58 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id d13so5480131oth.20
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:32:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7qbPiWISZ/3YLAH4qk20thx5mPsENn7iQ0jZWGyMcis=;
        b=B+69njoCK7jPMdhCgzpMLRv2Xbz1mQcQX8s6gOImuLd13mGJNq8XY2eTJPwRw/tpm1
         yxtMRIuk+3pkC9bZOZCtVv3ior61UsVMXxfScyqWoyPlAcQYX22Sntc8tSQF+s5W53vd
         1IgxVBY2leHstR0G26Ch2eIR0y94W4Rs5ZLwqQEKSTGNrBg9egKTbw5//v7djWGCzwGe
         Hkzn2TapeuoBBK3x3SEBVOLmK+g6nYI7o/mpgWQAMJ7bTLcCI/SYjiiEE+V9O+CpXt1P
         Hp7SaMjC+p9234Z/0Fag3qymxuJS+9qL/GBi7mGOn/tS81lkZ9542YaCLPGKxoacTY/A
         PEZw==
X-Gm-Message-State: APjAAAUADbLc86PrPV3Ix4pWmTbJ7w269HhNx+7XQyXRF6LVG1+at8Bl
	FfFmd4wYe+0zK8Bhm1++bAAO246EH/6YARgHf6/x1bsU0VrxdCUXmJh9c0oXI1ELu4zXVo02gpe
	MlqYtXKlgqKBMR+l5RuySO2WhSLwrAtLhXJcC8nscfP8MpYALbu7IjfnAgxMOW4+L3g==
X-Received: by 2002:a9d:6289:: with SMTP id x9mr13887023otk.82.1560810778008;
        Mon, 17 Jun 2019 15:32:58 -0700 (PDT)
X-Received: by 2002:a9d:6289:: with SMTP id x9mr13886973otk.82.1560810777273;
        Mon, 17 Jun 2019 15:32:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560810777; cv=none;
        d=google.com; s=arc-20160816;
        b=HpAVOK0VFoLz4qzynHmE46Dtf1ppJpri5Da3yUeJbEvaliREAwmOF9XwqqRBQiqsph
         WVlydWJRI9SB7zxFY6cp8rU2tQjFOL0RkRHpjVVDJv0KpqEdrlG4vsEyxj9XX9cg2vC8
         l9odvgezOsDDNsrYQWVBZ1Y5t/oS/xfnuKKX4QkiMZVnrXdjBQZ04k5qpUOMuOqU2s36
         Qfz0EHVnLZABfZlUurvNNgAlkoqLPW2CwYolOolf94XmzqvPU1fk1N6/JTjyhJtV2VRW
         C3KeyMVf8TtmfV73q08j9mqOlLxuborTH6tKHXiKntdLfF1Gqeg/amREGWA9hzbpvuJ7
         oeBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7qbPiWISZ/3YLAH4qk20thx5mPsENn7iQ0jZWGyMcis=;
        b=Sp3ulups5AKaMMEEjcGcwc7lDt2XkX8vNEXr369GsxZPgGB3R2x8Qth03xMBFIzXeJ
         KioKUNMoDRkJFYjJ5oyothNYj6VXNZHlpOIRzc4NcIs9T75CcgLNIqVo+sGD3i9Tgy2b
         +CxsqC4ilPtexlnZbAl2Tcigx6Itn9B5fzono4WPmOfEG+bNQ4afhLAvJua48nfzhrDw
         KRUztSdj84oasSiTzHast8ffuZkpW3tk6YwzcUp775hqLXAozg3Qb6fG6U8K6HL+JFQs
         AFY6sfi+nidjWmOz1MohjIo6AvbXI2B1Dxx5S4S/QqTmVz+zAK9D8SP+FKVmhuBnfOA+
         XQmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=a91I+xSD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k16sor6202330otf.68.2019.06.17.15.32.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 15:32:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=a91I+xSD;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7qbPiWISZ/3YLAH4qk20thx5mPsENn7iQ0jZWGyMcis=;
        b=a91I+xSDVHvK1ZEOenRvvjE4vhGbnMM5IGQHmISQyRGCfz3lejo/r5ImOKIR368oej
         og0AcK5XFYS27XW+i5wQU/6RiEwpPUjImiPaOtWcOb4m8k9WnyQ3oOtutHO8Ue2cfUUe
         J0zRHWGOGVEFk7FiSUmXM7W2dI9bYseIgHTZXjQ04eE2lFmfvM0lLFnS4bIcUVi26/I4
         wF/BDJYOiaJYlZLvZSKIR4rt0ihW1MNP5fI5G8+xBCuY16R60CgJsByQAXLL4+0yBgrd
         suSnDakVYOMj+yqj5I159f1jj8m1ODIYx74Dh4Jo8kqLO6mwqXJntHs16+YD0/dMeu7E
         Yw1Q==
X-Google-Smtp-Source: APXvYqyZduYLHmzANdLJ0kTwAX72WJK5Ko0NIP/u/YQenpWDUe/hI/lIxpeqTuIX+3U32POBJeb5hXTJ8kaoay7kw2o=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr18184303otk.363.1560810776909;
 Mon, 17 Jun 2019 15:32:56 -0700 (PDT)
MIME-Version: 1.0
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190617222156.v6eaujbdrmkz35wr@master>
In-Reply-To: <20190617222156.v6eaujbdrmkz35wr@master>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 15:32:45 -0700
Message-ID: <CAPcyv4hdsvNL0QfA2ACHAaGZE+21RmAnfKYfrZsKGKUxu3eKRQ@mail.gmail.com>
Subject: Re: [PATCH v9 02/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Jane Chu <jane.chu@oracle.com>, 
	Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 3:22 PM Wei Yang <richard.weiyang@gmail.com> wrote:
>
> On Wed, Jun 05, 2019 at 02:57:59PM -0700, Dan Williams wrote:
> >Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> >sub-section active bitmask, each bit representing a PMD_SIZE span of the
> >architecture's memory hotplug section size.
> >
> >The implications of a partially populated section is that pfn_valid()
> >needs to go beyond a valid_section() check and read the sub-section
> >active ranges from the bitmask. The expectation is that the bitmask
> >(subsection_map) fits in the same cacheline as the valid_section() data,
> >so the incremental performance overhead to pfn_valid() should be
> >negligible.
> >
> >Cc: Michal Hocko <mhocko@suse.com>
> >Cc: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Logan Gunthorpe <logang@deltatee.com>
> >Cc: Oscar Salvador <osalvador@suse.de>
> >Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> >Tested-by: Jane Chu <jane.chu@oracle.com>
> >Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >---
> > include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
> > mm/page_alloc.c        |    4 +++-
> > mm/sparse.c            |   35 +++++++++++++++++++++++++++++++++++
> > 3 files changed, 66 insertions(+), 2 deletions(-)
> >
> >diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >index ac163f2f274f..6dd52d544857 100644
> >--- a/include/linux/mmzone.h
> >+++ b/include/linux/mmzone.h
> >@@ -1199,6 +1199,8 @@ struct mem_section_usage {
> >       unsigned long pageblock_flags[0];
> > };
> >
> >+void subsection_map_init(unsigned long pfn, unsigned long nr_pages);
> >+
> > struct page;
> > struct page_ext;
> > struct mem_section {
> >@@ -1336,12 +1338,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
> >
> > extern int __highest_present_section_nr;
> >
> >+static inline int subsection_map_index(unsigned long pfn)
> >+{
> >+      return (pfn & ~(PAGE_SECTION_MASK)) / PAGES_PER_SUBSECTION;
> >+}
> >+
> >+#ifdef CONFIG_SPARSEMEM_VMEMMAP
> >+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> >+{
> >+      int idx = subsection_map_index(pfn);
> >+
> >+      return test_bit(idx, ms->usage->subsection_map);
> >+}
> >+#else
> >+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> >+{
> >+      return 1;
> >+}
> >+#endif
> >+
> > #ifndef CONFIG_HAVE_ARCH_PFN_VALID
> > static inline int pfn_valid(unsigned long pfn)
> > {
> >+      struct mem_section *ms;
> >+
> >       if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> >               return 0;
> >-      return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
> >+      ms = __nr_to_section(pfn_to_section_nr(pfn));
> >+      if (!valid_section(ms))
> >+              return 0;
> >+      return pfn_section_valid(ms, pfn);
> > }
> > #endif
> >
> >@@ -1373,6 +1399,7 @@ void sparse_init(void);
> > #define sparse_init() do {} while (0)
> > #define sparse_index_init(_sec, _nid)  do {} while (0)
> > #define pfn_present pfn_valid
> >+#define subsection_map_init(_pfn, _nr_pages) do {} while (0)
> > #endif /* CONFIG_SPARSEMEM */
> >
> > /*
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index c6d8224d792e..bd773efe5b82 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -7292,10 +7292,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> >
> >       /* Print out the early node map */
> >       pr_info("Early memory node ranges\n");
> >-      for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
> >+      for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> >               pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
> >                       (u64)start_pfn << PAGE_SHIFT,
> >                       ((u64)end_pfn << PAGE_SHIFT) - 1);
> >+              subsection_map_init(start_pfn, end_pfn - start_pfn);
> >+      }
>
> Just curious about why we set subsection here?
>
> Function free_area_init_nodes() mostly handles pgdat, if I am correct. Setup
> subsection here looks like touching some lower level system data structure.

Correct, I'm not sure how it ended up there, but it was the source of
a bug that was fixed with this change:

https://lore.kernel.org/lkml/CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com/

