Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A97E4405B1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:58:46 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v67so55588284wrb.4
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:45 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 65si6497611wrq.89.2017.02.15.12.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 12:58:44 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id c85so232662wmi.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:44 -0800 (PST)
From: Nicolai Stange <nicstange@gmail.com>
Subject: [RFC 0/3] Regressions due to 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to populate_section_memmap()") and Kasan initialization on
Date: Wed, 15 Feb 2017 21:58:23 +0100
Message-Id: <20170215205826.13356-1-nicstange@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nicolai Stange <nicstange@gmail.com>

Hi Dan,

your recent commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
populate_section_memmap()") seems to cause some issues with respect to
Kasan initialization on x86.

This is because Kasan's initialization (ab)uses the arch provided
vmemmap_populate().

The first one is a boot failure, see [1/3]. The commit before the
aforementioned one works fine.

The second one, i.e. [2/3], is something that hit my eye while browsing
the source and I verified that this is indeed an issue by printk'ing and
dumping the page tables.

The third one are excessive warnings from vmemmap_verify() due to Kasan's
NUMA_NO_NODE page populations.


I'll be travelling the next two days and certainly not be able to respond
or polish these patches any further. Furthermore, the next merge window is
close. So please, take these three patches as bug reports only, meant to
illustrate the issues. Feel free to use, change and adopt them however
you deemed best.

That being said,
- [2/3] will break arm64 due to the current lack of a pmd_large().
- Maybe it's easier and better to restore former behaviour by letting
  Kasan's shadow initialization on x86 use vmemmap_populate_hugepages()
  directly rather than vmemmap_populate(). This would require x86_64
  implying X86_FEATURE_PSE though. I'm not sure whether this holds,
  in particular not since the vmemmap_populate() from
  arch/x86/mm/init_64.c checks for it.

Thanks,

Nicolai

Nicolai Stange (3):
  sparse-vmemmap: let vmemmap_populate_basepages() cover the whole range
  sparse-vmemmap: make vmemmap_populate_basepages() skip HP mapped
    ranges
  sparse-vmemmap: let vmemmap_verify() ignore NUMA_NO_NODE requests

 mm/sparse-vmemmap.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
