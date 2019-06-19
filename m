Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D0D4C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 02:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1F242147A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 02:14:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1F242147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59A3C6B0003; Tue, 18 Jun 2019 22:14:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 572178E0002; Tue, 18 Jun 2019 22:14:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 487368E0001; Tue, 18 Jun 2019 22:14:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9C16B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:14:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t2so1498232pgs.21
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 19:14:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lXIwq2et7+1nl9RF9VU3uZIxQRm53WsNmChJKxITb98=;
        b=bU6SQqknUZ9bBX135CbAmhyIc+1POA1DSEER+f8GqH7VOGnjFRjapBjKfns/fOrt6L
         AIz0mm8iZDWfEdmDKsd3mCb3mVECJ4+ZJI5kwqA9nacdxF39Ud3YEnhSn/hKoftgRr0R
         kci9R2U9J5uo4+0jgYN9q23+doiBu5K9uoH5MrMN5uwDGC5SvoGkq9yT55uAgujvXcPS
         NMgIkwpvjfnPtkvtB8w+xVR3NY8OekrMQcyhJ4wkHcyrL1Tm52wZi4cX6KoWKG2V0OMj
         pGXKG/Jf1hTJJAj+TCNr4Jpb2pVOzdSp5MAxdPf//c/v2J4anNLtVXG2Yv+fvH2Ec6ZA
         JBdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXMHR0EV7/eRpR4ztcXgVBVeglQomgzDdLykwQmR7ankjbANf5Z
	8pPv8/buOZxlnQcNts7s+iL/0opbIcOfmyUnS+Bm3b8mVDgLNH4C7NogsxHgX1Ow+62tI+fjrIS
	PL0+YPaePmBIio9mhfcTvwzpav4SdPC13+Wn9GpNOLIUKC551yNQNJzM5aehO0Egnyw==
X-Received: by 2002:a17:902:8696:: with SMTP id g22mr90577496plo.249.1560910457620;
        Tue, 18 Jun 2019 19:14:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwv9WQDUwRWrRDyCW4ZNicgnv5si0b7E/fGiLHcScGj2xqEeprCJBAXbCdPYIA03XxX0hT0
X-Received: by 2002:a17:902:8696:: with SMTP id g22mr90577450plo.249.1560910456756;
        Tue, 18 Jun 2019 19:14:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560910456; cv=none;
        d=google.com; s=arc-20160816;
        b=jcNR015zN+C80t81aniu+EC9unJwclHaYMrG+zwCwzl6S4Urc2Na8sWSAlQKzo7CwQ
         8vxpZV0ES4sEjGTAv1AFJBy2v5I33hHoVW7mckbFOGlzo3+te7512vDvPCxjYTdK3uNS
         kXs82L1UWZsnNisFAYo+DHebnpICuMhsLI4O+QiG3BdHJLzqOESwP/YRTKae7V0vtbmR
         6t3s0kiljhArGXYL1KUcQGep4eSYZiS8E+ZLX2vV+B77Q14ZP2s3JUoQoFggW8jBmpFE
         VXX+9d8X2EHODF5tGSWQqXqjgHxtoq+evaBhrTXo6XTMe3ulXhIvTUauR88ksvtqkv8C
         3k8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=lXIwq2et7+1nl9RF9VU3uZIxQRm53WsNmChJKxITb98=;
        b=dRj+o7o1gMWwWZ+zdL8whBtuZwbbmDTm/miTKSWANuzpHNX+uxJb+XwB8bPdzjr/Jn
         yogkjYUcSu+GKS7YBtIyfH4esqV1nBBvanMNwEEkynHTFLgiZdU8W4BZwJFC4/TBJAGQ
         t3LOWAs7XmKa3U71NpBqiDxNG9X2eRt0GoCdroqGRr1KdyrAuyS+KB66IFBhIWVar2e1
         JxejIKdDlcha/fYEJU5lLXO0VK31pFD7njSKfKFu+vl6OceGJy29eLOyrtUFQ5XOaqzw
         FEfuNOlJXRaCGBFD1mcKDdP0Re+NlkovkaJApQkYVoA7Af0vv9qLvVWM9D79+78WfnaP
         WOuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q10si13798463plr.412.2019.06.18.19.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 19:14:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 19:14:16 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,391,1557212400"; 
   d="scan'208";a="168110531"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by FMSMGA003.fm.intel.com with ESMTP; 18 Jun 2019 19:14:13 -0700
Date: Wed, 19 Jun 2019 10:13:50 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v9 01/12] mm/sparsemem: Introduce struct mem_section_usage
Message-ID: <20190619021350.GA11514@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977187407.2443951.16503493275720588454.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190616131123.fkjs4kyg32aryjq6@master>
 <CAPcyv4hw2W3=CkrUmWtvu3cAdo3GLRhG0=G_RO7xQBugNB2htA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hw2W3=CkrUmWtvu3cAdo3GLRhG0=G_RO7xQBugNB2htA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 02:56:09PM -0700, Dan Williams wrote:
>On Sun, Jun 16, 2019 at 6:11 AM Wei Yang <richard.weiyang@gmail.com> wrote:
>>
>> On Wed, Jun 05, 2019 at 02:57:54PM -0700, Dan Williams wrote:
>> >Towards enabling memory hotplug to track partial population of a
>> >section, introduce 'struct mem_section_usage'.
>> >
>> >A pointer to a 'struct mem_section_usage' instance replaces the existing
>> >pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
>> >'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
>> >house a new 'subsection_map' bitmap.  The new bitmap enables the memory
>> >hot{plug,remove} implementation to act on incremental sub-divisions of a
>> >section.
>> >
>> >The default SUBSECTION_SHIFT is chosen to keep the 'subsection_map' no
>> >larger than a single 'unsigned long' on the major architectures.
>> >Alternatively an architecture can define ARCH_SUBSECTION_SHIFT to
>> >override the default PMD_SHIFT. Note that PowerPC needs to use
>> >ARCH_SUBSECTION_SHIFT to workaround PMD_SHIFT being a non-constant
>> >expression on PowerPC.
>> >
>> >The primary motivation for this functionality is to support platforms
>> >that mix "System RAM" and "Persistent Memory" within a single section,
>> >or multiple PMEM ranges with different mapping lifetimes within a single
>> >section. The section restriction for hotplug has caused an ongoing saga
>> >of hacks and bugs for devm_memremap_pages() users.
>> >
>> >Beyond the fixups to teach existing paths how to retrieve the 'usemap'
>> >from a section, and updates to usemap allocation path, there are no
>> >expected behavior changes.
>> >
>> >Cc: Michal Hocko <mhocko@suse.com>
>> >Cc: Vlastimil Babka <vbabka@suse.cz>
>> >Cc: Logan Gunthorpe <logang@deltatee.com>
>> >Cc: Oscar Salvador <osalvador@suse.de>
>> >Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> >Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> >Cc: Paul Mackerras <paulus@samba.org>
>> >Cc: Michael Ellerman <mpe@ellerman.id.au>
>> >Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> >---
>> > arch/powerpc/include/asm/sparsemem.h |    3 +
>> > include/linux/mmzone.h               |   48 +++++++++++++++++++-
>> > mm/memory_hotplug.c                  |   18 ++++----
>> > mm/page_alloc.c                      |    2 -
>> > mm/sparse.c                          |   81 +++++++++++++++++-----------------
>> > 5 files changed, 99 insertions(+), 53 deletions(-)
>> >
>> >diff --git a/arch/powerpc/include/asm/sparsemem.h b/arch/powerpc/include/asm/sparsemem.h
>> >index 3192d454a733..1aa3c9303bf8 100644
>> >--- a/arch/powerpc/include/asm/sparsemem.h
>> >+++ b/arch/powerpc/include/asm/sparsemem.h
>> >@@ -10,6 +10,9 @@
>> >  */
>> > #define SECTION_SIZE_BITS       24
>> >
>> >+/* Reflect the largest possible PMD-size as the subsection-size constant */
>> >+#define ARCH_SUBSECTION_SHIFT 24
>> >+
>> > #endif /* CONFIG_SPARSEMEM */
>> >
>> > #ifdef CONFIG_MEMORY_HOTPLUG
>> >diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> >index 427b79c39b3c..ac163f2f274f 100644
>> >--- a/include/linux/mmzone.h
>> >+++ b/include/linux/mmzone.h
>> >@@ -1161,6 +1161,44 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
>> > #define SECTION_ALIGN_UP(pfn) (((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
>> > #define SECTION_ALIGN_DOWN(pfn)       ((pfn) & PAGE_SECTION_MASK)
>> >
>> >+/*
>> >+ * SUBSECTION_SHIFT must be constant since it is used to declare
>> >+ * subsection_map and related bitmaps without triggering the generation
>> >+ * of variable-length arrays. The most natural size for a subsection is
>> >+ * a PMD-page. For architectures that do not have a constant PMD-size
>> >+ * ARCH_SUBSECTION_SHIFT can be set to a constant max size, or otherwise
>> >+ * fallback to 2MB.
>> >+ */
>> >+#if defined(ARCH_SUBSECTION_SHIFT)
>> >+#define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
>> >+#elif defined(PMD_SHIFT)
>> >+#define SUBSECTION_SHIFT (PMD_SHIFT)
>> >+#else
>> >+/*
>> >+ * Memory hotplug enabled platforms avoid this default because they
>> >+ * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, but
>> >+ * this is kept as a backstop to allow compilation on
>> >+ * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
>> >+ */
>> >+#define SUBSECTION_SHIFT 21
>> >+#endif
>> >+
>> >+#define PFN_SUBSECTION_SHIFT (SUBSECTION_SHIFT - PAGE_SHIFT)
>> >+#define PAGES_PER_SUBSECTION (1UL << PFN_SUBSECTION_SHIFT)
>> >+#define PAGE_SUBSECTION_MASK ((~(PAGES_PER_SUBSECTION-1)))
>>
>> One pair of brackets could be removed, IMHO.
>
>Sure.
>
>>
>> >+
>> >+#if SUBSECTION_SHIFT > SECTION_SIZE_BITS
>> >+#error Subsection size exceeds section size
>> >+#else
>> >+#define SUBSECTIONS_PER_SECTION (1UL << (SECTION_SIZE_BITS - SUBSECTION_SHIFT))
>> >+#endif
>> >+
>> >+struct mem_section_usage {
>> >+      DECLARE_BITMAP(subsection_map, SUBSECTIONS_PER_SECTION);
>> >+      /* See declaration of similar field in struct zone */
>> >+      unsigned long pageblock_flags[0];
>> >+};
>> >+
>> > struct page;
>> > struct page_ext;
>> > struct mem_section {
>> >@@ -1178,8 +1216,7 @@ struct mem_section {
>> >        */
>> >       unsigned long section_mem_map;
>> >
>> >-      /* See declaration of similar field in struct zone */
>> >-      unsigned long *pageblock_flags;
>> >+      struct mem_section_usage *usage;
>> > #ifdef CONFIG_PAGE_EXTENSION
>> >       /*
>> >        * If SPARSEMEM, pgdat doesn't have page_ext pointer. We use
>> >@@ -1210,6 +1247,11 @@ extern struct mem_section **mem_section;
>> > extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
>> > #endif
>> >
>> >+static inline unsigned long *section_to_usemap(struct mem_section *ms)
>> >+{
>> >+      return ms->usage->pageblock_flags;
>>
>> Do we need to consider the case when ms->usage is NULL?
>
>No, this routine safely assumes it is always set.

Then everything looks good to me.

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>_______________________________________________
>Linux-nvdimm mailing list
>Linux-nvdimm@lists.01.org
>https://lists.01.org/mailman/listinfo/linux-nvdimm

-- 
Wei Yang
Help you, Help me

