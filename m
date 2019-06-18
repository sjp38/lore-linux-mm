Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60DF0C31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27B89206B7
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:04:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27B89206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98EB38E0006; Mon, 17 Jun 2019 21:04:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93F218E0005; Mon, 17 Jun 2019 21:04:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 854538E0006; Mon, 17 Jun 2019 21:04:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF448E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:04:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 140so8075694pfa.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:04:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cdByMJwdR/5Wd35d4Q7xqyMd0MGPrKJfLu6+jtzSWz0=;
        b=nQqwmEcqKQOpkTWdhUMiWzVN/nHWyEYKkZRPKRFObBStpweyb9nCg+Wda+i+Dnan81
         A7ggcTMxx6+vhaQMTsuSPEac4hGim1uevORnsRKEF7h1DqIj4ufO4lE1Lo5aeEaMDSfp
         cALENOz7LEAbYVziJYSY8t960eAcERgcoe698484E/FgnagNKoIMlGhM11SiH9YI4D+S
         +y3/0l1CE0E64s7hPYI3xSXsMByOGX4odKVhfeZwX9vlNRf0DORac/Q1IAQS0ekhJ00X
         ROZ70MdoypgkX7XuRbEdbEthvzP/haL+8N2VQ9s8LJyUQ40qu6OZDiOLNKmDPabzHDL+
         zLVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVkaBd5uZxN3l8m+uxQrkaRRDqzj/MCgUUUFnBoZx0T5tmidgp2
	dUxJDUJ/uA65R5JzPHDDgFVK5X7lsV72WeOdAa0bfmq8qSZJbS92R+iQOLp55vzeeH+O7JnNSjw
	6CCCprCAR7TR7UWBeJJRH5oLDh6CSpe9SJ8qTsZrwart9ZIiiV5AYWH+Fv2ZSWlC8jA==
X-Received: by 2002:a62:ae01:: with SMTP id q1mr61076566pff.219.1560819857962;
        Mon, 17 Jun 2019 18:04:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4peKhtxBs7cJaHUyBmDpFMXsQmuMnhd/GanPL1Lzf83/xfSZ4+sR+EaJt406IeEU4rn7e
X-Received: by 2002:a62:ae01:: with SMTP id q1mr61076501pff.219.1560819856994;
        Mon, 17 Jun 2019 18:04:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560819856; cv=none;
        d=google.com; s=arc-20160816;
        b=rcgFsfO2MWvCgr3qwhdEsSOGzlGhe91bal9LtFJDzEN9cFSZlBobAlXfjVOaaBAs6V
         6Nj4Q+m4rN6mejU/TZX9LGQgVQiGhoVQ4P33Ej+9yIYA/IONC/mqAECgfveoyZ6KeA+A
         mo8m9nmPXMRMYtbq8mLO+3ObdkEGlooDXHPg7AvrC58RkpVSG78QzZmxtqcaVkia0H6U
         t8fdbs8pB9ysM2LANPA3J1NJgi25TqTpIv0OjV06UZ97QNcJuglbgArv8xkcWUc1cSiX
         N1ajOFLEGcGxKslVm4zH5Rm8hVEJ3bGLCuuYkcRMAT0x+0kp1+Oq62Y2Kaw3VxijbV1E
         Z5FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=cdByMJwdR/5Wd35d4Q7xqyMd0MGPrKJfLu6+jtzSWz0=;
        b=ZrfefGaUdaqjEPU1nFvZPgbS1uEb4hmBP0vXm8I5d83TmqPTWkU9XtL8gXf4mY9sIm
         pSHoIddkWA+l38bILjDwENH232Zh6vZPxkKFOKZ4NoC/TGya9Sjbv8C9D6ENLk3POawq
         WyQWolAaX0Ott+kxVUimmLusVwlxzcsQVdA2hAB7f52qkaR20kRKibiBGHRN3qMQFFfg
         N4Q/44luW5337MeHCSgDPbJozQiB0pYrHMxMYVm6gBfeSt2xowEZTqmyTYWeNlU1wjFc
         WLdrBsWrJHTPZHFNQJp/jStr5V8Q92IPlJzgLV/Y1M9K10tE4D/xy5VrWFb1BaD66nR/
         r8gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id v126si12792082pgb.484.2019.06.17.18.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:04:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 18:04:16 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by FMSMGA003.fm.intel.com with ESMTP; 17 Jun 2019 18:04:14 -0700
Date: Tue, 18 Jun 2019 09:03:51 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v9 02/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
Message-ID: <20190618010351.GC18161@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190617222156.v6eaujbdrmkz35wr@master>
 <CAPcyv4hdsvNL0QfA2ACHAaGZE+21RmAnfKYfrZsKGKUxu3eKRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hdsvNL0QfA2ACHAaGZE+21RmAnfKYfrZsKGKUxu3eKRQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 03:32:45PM -0700, Dan Williams wrote:
>On Mon, Jun 17, 2019 at 3:22 PM Wei Yang <richard.weiyang@gmail.com> wrote:
>>
>> On Wed, Jun 05, 2019 at 02:57:59PM -0700, Dan Williams wrote:
>> >Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
>> >sub-section active bitmask, each bit representing a PMD_SIZE span of the
>> >architecture's memory hotplug section size.
>> >
>> >The implications of a partially populated section is that pfn_valid()
>> >needs to go beyond a valid_section() check and read the sub-section
>> >active ranges from the bitmask. The expectation is that the bitmask
>> >(subsection_map) fits in the same cacheline as the valid_section() data,
>> >so the incremental performance overhead to pfn_valid() should be
>> >negligible.
>> >
>> >Cc: Michal Hocko <mhocko@suse.com>
>> >Cc: Vlastimil Babka <vbabka@suse.cz>
>> >Cc: Logan Gunthorpe <logang@deltatee.com>
>> >Cc: Oscar Salvador <osalvador@suse.de>
>> >Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> >Tested-by: Jane Chu <jane.chu@oracle.com>
>> >Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> >---
>> > include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
>> > mm/page_alloc.c        |    4 +++-
>> > mm/sparse.c            |   35 +++++++++++++++++++++++++++++++++++
>> > 3 files changed, 66 insertions(+), 2 deletions(-)
>> >
>> >diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> >index ac163f2f274f..6dd52d544857 100644
>> >--- a/include/linux/mmzone.h
>> >+++ b/include/linux/mmzone.h
>> >@@ -1199,6 +1199,8 @@ struct mem_section_usage {
>> >       unsigned long pageblock_flags[0];
>> > };
>> >
>> >+void subsection_map_init(unsigned long pfn, unsigned long nr_pages);
>> >+
>> > struct page;
>> > struct page_ext;
>> > struct mem_section {
>> >@@ -1336,12 +1338,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
>> >
>> > extern int __highest_present_section_nr;
>> >
>> >+static inline int subsection_map_index(unsigned long pfn)
>> >+{
>> >+      return (pfn & ~(PAGE_SECTION_MASK)) / PAGES_PER_SUBSECTION;
>> >+}
>> >+
>> >+#ifdef CONFIG_SPARSEMEM_VMEMMAP
>> >+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
>> >+{
>> >+      int idx = subsection_map_index(pfn);
>> >+
>> >+      return test_bit(idx, ms->usage->subsection_map);
>> >+}
>> >+#else
>> >+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
>> >+{
>> >+      return 1;
>> >+}
>> >+#endif
>> >+
>> > #ifndef CONFIG_HAVE_ARCH_PFN_VALID
>> > static inline int pfn_valid(unsigned long pfn)
>> > {
>> >+      struct mem_section *ms;
>> >+
>> >       if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>> >               return 0;
>> >-      return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>> >+      ms = __nr_to_section(pfn_to_section_nr(pfn));
>> >+      if (!valid_section(ms))
>> >+              return 0;
>> >+      return pfn_section_valid(ms, pfn);
>> > }
>> > #endif
>> >
>> >@@ -1373,6 +1399,7 @@ void sparse_init(void);
>> > #define sparse_init() do {} while (0)
>> > #define sparse_index_init(_sec, _nid)  do {} while (0)
>> > #define pfn_present pfn_valid
>> >+#define subsection_map_init(_pfn, _nr_pages) do {} while (0)
>> > #endif /* CONFIG_SPARSEMEM */
>> >
>> > /*
>> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> >index c6d8224d792e..bd773efe5b82 100644
>> >--- a/mm/page_alloc.c
>> >+++ b/mm/page_alloc.c
>> >@@ -7292,10 +7292,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>> >
>> >       /* Print out the early node map */
>> >       pr_info("Early memory node ranges\n");
>> >-      for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
>> >+      for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
>> >               pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
>> >                       (u64)start_pfn << PAGE_SHIFT,
>> >                       ((u64)end_pfn << PAGE_SHIFT) - 1);
>> >+              subsection_map_init(start_pfn, end_pfn - start_pfn);
>> >+      }
>>
>> Just curious about why we set subsection here?
>>
>> Function free_area_init_nodes() mostly handles pgdat, if I am correct. Setup
>> subsection here looks like touching some lower level system data structure.
>
>Correct, I'm not sure how it ended up there, but it was the source of
>a bug that was fixed with this change:
>
>https://lore.kernel.org/lkml/CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com/

So this one is moved to sparse_init_nid().

The bug is strange, while the code now is more reasonable to me.

Thanks :-)

>_______________________________________________
>Linux-nvdimm mailing list
>Linux-nvdimm@lists.01.org
>https://lists.01.org/mailman/listinfo/linux-nvdimm

-- 
Wei Yang
Help you, Help me

