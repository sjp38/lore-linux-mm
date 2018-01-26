Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC4C6B000E
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 05:08:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id z83so46358wmc.5
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 02:08:18 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 93sor3563307wrh.35.2018.01.26.02.08.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jan 2018 02:08:16 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [LSF/MM TOPIC] CMA and larger page sizes
Message-ID: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
Date: Fri, 26 Jan 2018 02:08:14 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

CMA as it's currently designed requires alignment to the pageblock size c.f.

         /*
          * Sanitise input arguments.
          * Pages both ends in CMA area could be merged into adjacent unmovable
          * migratetype page by page allocator's buddy algorithm. In the case,
          * you couldn't get a contiguous memory, which is not what we want.
          */
         alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
                           max_t(unsigned long, MAX_ORDER - 1, pageblock_order));


On arm64 with 64K page size and transparent huge page, this gives an alignment
of 512MB. This is quite restrictive and can eat up significant portions of
memory on smaller memory targets. Adjusting the configuration options really
isn't ideal for distributions that aim to have a single image which runs on
all targets.

Approaches I've thought about:
- Making CMA alignment less restrictive (and dealing with the fallout from
the comment above)
- Command line option to force a reasonable alignment

There's been some interest in other CMA topics so this might go along well.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
