Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5BF1C31E51
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:16:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76AF42084B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:16:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="AL3abFEy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76AF42084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 100C56B0003; Tue, 18 Jun 2019 23:16:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B23B8E0002; Tue, 18 Jun 2019 23:16:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBB658E0001; Tue, 18 Jun 2019 23:16:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3D4E6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:16:05 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a8so4185122otf.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:16:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Tu2elvIo3lc5H4la84p5WxQwTInH29KDgwWpb5ulefs=;
        b=UrdW9xgBpDLSXXWtdgP7aQjt+9fM/AUf1F5Kv+1fCdH74E8el8ZSNLztRZ6pfwSDM9
         XRYRTTV7mCsJrLEDeeJNIPRn/CeiI6dD3i4GEgGMXJEZfUGs6/3tIXI4HTHKkCemYP9E
         +KhUkc5F2CsG+seKGIhFAgRJfeutXSyYGri6WC+BvPdztA9sLCTev1fuaiQM+8QBi2iJ
         Hcd9XwaaoTK58yPNsT86BfiQ96d4K2BwSmyLxuechgMI235VR7NcSWrV60HxKvAHNKa7
         qJbIPUvRk1keK0DGm/NNHwU8xQgL6Nrg8STYDH/eMLxeG2pz9WbiKUtK63epY/t7xfSX
         ObSQ==
X-Gm-Message-State: APjAAAU6xj21nl5tH+KtiqQO6/FdE/8pbTnjqTmY2yHV6vYjwdYlNHOG
	XEj3f0jpDBqgk48F2Nw68PIGra5yxLt6nAjYxgKqL3jZiJIAoA/3BfbIVH7j971HtybiNpNRsgp
	JuzwaE75q2RXsi9+cNPiLa/py/xD4cvgQjt3Jnf1pPdFsjiu9Vpb07j85dWjV5ONmgA==
X-Received: by 2002:a05:6830:2090:: with SMTP id y16mr3421132otq.109.1560914165338;
        Tue, 18 Jun 2019 20:16:05 -0700 (PDT)
X-Received: by 2002:a05:6830:2090:: with SMTP id y16mr3421105otq.109.1560914164621;
        Tue, 18 Jun 2019 20:16:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560914164; cv=none;
        d=google.com; s=arc-20160816;
        b=R6xzEpL1PiPF2i4J1DzK+2dNGnqpsMPhqQRRPCyKx0VPUladcW9T2HPtJIEd9njiS7
         ojEPAz2u8iYQLk5wrw1tFJ2Z02x2+RID0Y093tWs3bOIYndbTmEF/NPAt1JL1c2+SStx
         t3ps5A7NOELkFLHtQkK9b3c85jZsKb4a021mLk5wkBJQHQ+nIiYXpWme91yaSBdHTjRu
         WeZujk5fIiKTwb7lnYxbY16jaKHSyTgHRgdmkVONzcV1PePYF0huT2PMojxh4FiNFJeJ
         /5SWKS2FwIclc2PcYzqHggPHry4zfXs1V5biPerpr1piZN/NFeB2v7EAtUls0IcWjrRe
         ZjXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Tu2elvIo3lc5H4la84p5WxQwTInH29KDgwWpb5ulefs=;
        b=FelcBN+YdWf4IcNrTNLrW5ajxLwUVKcAL5TKc7XCVNDDj7D61WpexewLfOIzmW2YC7
         FzOG/+vMipcp1n95oKi/4bViu9MOm9TAWgO1hCKWBM/jLHHQjt4NJPOvFwWg++054Ruj
         YxupibE35fEfQT4E0jAgK+3u7TPF6aH5f05uipNeNJXRCLp8paPAMBCWNkifVI2mNSQQ
         iN8jPXyJPClkaWmjD6m7JGqM7xKaSB7m7UTLXtQtqXM/PkxcUZ8TakxhLyEbRDFxb6Yg
         RwCrhsZ7n0SlggTggFoL0wyfQOrjZakYi+RLnpG0sG5/sDD7f6WOiyBVxFjfXNDNe3Ju
         BGxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=AL3abFEy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15sor8376556otq.7.2019.06.18.20.16.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 20:16:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=AL3abFEy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Tu2elvIo3lc5H4la84p5WxQwTInH29KDgwWpb5ulefs=;
        b=AL3abFEyAhPgyf7b+wwbfJ7Mq17OxejNJl9ONmkJ6rsvau+HzH11X6uOrsSYF+u65s
         lbMc96W4ihrKAOq+YGiljuH8yyIMYDou5NYM0Vu8OLHU68V1DgMfKyNbIuJejz/yD7Ep
         vaw4wDa26jAutVYR8eAtoWTbjHwKuIxlmk7JwbpuxzG8WS51r8lKLxMfRtOVoi5GPL2m
         4NZIBau3JxwtRQGkGEDFJGcFgs8z8IwY20g/0eKMQrqPf+vePGnEqT2mxg1tYRoQqeoj
         vYEtmw7b/SNvdYVTYcNkyJ/UDVQHX0XX9Vo3FegMlniL9JojhGMAELpBVUm79AkOkMXW
         Q4Xw==
X-Google-Smtp-Source: APXvYqy0xbhZUYpgcAboSLOnn/RUnhR5KI0rSjLavEsHE779lyY8IdU2qT66JmtEB7XHcy2j7qS3wWkkfEVX7Jcms64=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr59171433otn.71.1560914164312;
 Tue, 18 Jun 2019 20:16:04 -0700 (PDT)
MIME-Version: 1.0
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190617222156.v6eaujbdrmkz35wr@master> <CAPcyv4hdsvNL0QfA2ACHAaGZE+21RmAnfKYfrZsKGKUxu3eKRQ@mail.gmail.com>
In-Reply-To: <CAPcyv4hdsvNL0QfA2ACHAaGZE+21RmAnfKYfrZsKGKUxu3eKRQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 18 Jun 2019 20:15:52 -0700
Message-ID: <CAPcyv4jR30VL1X=W_PaSafr7EL9VVZnvjpKkccp_FqiRwzXKew@mail.gmail.com>
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

On Mon, Jun 17, 2019 at 3:32 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Mon, Jun 17, 2019 at 3:22 PM Wei Yang <richard.weiyang@gmail.com> wrote:
> >
> > On Wed, Jun 05, 2019 at 02:57:59PM -0700, Dan Williams wrote:
> > >Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> > >sub-section active bitmask, each bit representing a PMD_SIZE span of the
> > >architecture's memory hotplug section size.
> > >
> > >The implications of a partially populated section is that pfn_valid()
> > >needs to go beyond a valid_section() check and read the sub-section
> > >active ranges from the bitmask. The expectation is that the bitmask
> > >(subsection_map) fits in the same cacheline as the valid_section() data,
> > >so the incremental performance overhead to pfn_valid() should be
> > >negligible.
> > >
> > >Cc: Michal Hocko <mhocko@suse.com>
> > >Cc: Vlastimil Babka <vbabka@suse.cz>
> > >Cc: Logan Gunthorpe <logang@deltatee.com>
> > >Cc: Oscar Salvador <osalvador@suse.de>
> > >Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> > >Tested-by: Jane Chu <jane.chu@oracle.com>
> > >Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > >---
> > > include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
> > > mm/page_alloc.c        |    4 +++-
> > > mm/sparse.c            |   35 +++++++++++++++++++++++++++++++++++
> > > 3 files changed, 66 insertions(+), 2 deletions(-)
> > >
> > >diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > >index ac163f2f274f..6dd52d544857 100644
> > >--- a/include/linux/mmzone.h
> > >+++ b/include/linux/mmzone.h
> > >@@ -1199,6 +1199,8 @@ struct mem_section_usage {
> > >       unsigned long pageblock_flags[0];
> > > };
> > >
> > >+void subsection_map_init(unsigned long pfn, unsigned long nr_pages);
> > >+
> > > struct page;
> > > struct page_ext;
> > > struct mem_section {
> > >@@ -1336,12 +1338,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
> > >
> > > extern int __highest_present_section_nr;
> > >
> > >+static inline int subsection_map_index(unsigned long pfn)
> > >+{
> > >+      return (pfn & ~(PAGE_SECTION_MASK)) / PAGES_PER_SUBSECTION;
> > >+}
> > >+
> > >+#ifdef CONFIG_SPARSEMEM_VMEMMAP
> > >+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> > >+{
> > >+      int idx = subsection_map_index(pfn);
> > >+
> > >+      return test_bit(idx, ms->usage->subsection_map);
> > >+}
> > >+#else
> > >+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> > >+{
> > >+      return 1;
> > >+}
> > >+#endif
> > >+
> > > #ifndef CONFIG_HAVE_ARCH_PFN_VALID
> > > static inline int pfn_valid(unsigned long pfn)
> > > {
> > >+      struct mem_section *ms;
> > >+
> > >       if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> > >               return 0;
> > >-      return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
> > >+      ms = __nr_to_section(pfn_to_section_nr(pfn));
> > >+      if (!valid_section(ms))
> > >+              return 0;
> > >+      return pfn_section_valid(ms, pfn);
> > > }
> > > #endif
> > >
> > >@@ -1373,6 +1399,7 @@ void sparse_init(void);
> > > #define sparse_init() do {} while (0)
> > > #define sparse_index_init(_sec, _nid)  do {} while (0)
> > > #define pfn_present pfn_valid
> > >+#define subsection_map_init(_pfn, _nr_pages) do {} while (0)
> > > #endif /* CONFIG_SPARSEMEM */
> > >
> > > /*
> > >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > >index c6d8224d792e..bd773efe5b82 100644
> > >--- a/mm/page_alloc.c
> > >+++ b/mm/page_alloc.c
> > >@@ -7292,10 +7292,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> > >
> > >       /* Print out the early node map */
> > >       pr_info("Early memory node ranges\n");
> > >-      for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
> > >+      for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> > >               pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
> > >                       (u64)start_pfn << PAGE_SHIFT,
> > >                       ((u64)end_pfn << PAGE_SHIFT) - 1);
> > >+              subsection_map_init(start_pfn, end_pfn - start_pfn);
> > >+      }
> >
> > Just curious about why we set subsection here?
> >
> > Function free_area_init_nodes() mostly handles pgdat, if I am correct. Setup
> > subsection here looks like touching some lower level system data structure.
>
> Correct, I'm not sure how it ended up there, but it was the source of
> a bug that was fixed with this change:
>
> https://lore.kernel.org/lkml/CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com/

On second thought I'm going to keep subsection_map_init() in
free_area_init_nodes(), but instead teach pfn_valid() to return true
for all "early" sections. There are code paths that use pfn_valid() as
a coarse check before validating against pgdat for real validity of
online memory. It is sufficient and safe for those to assume that all
early sections are fully pfn_valid, while ZONE_DEVICE hotplug can see
the more precise subsection_map.

