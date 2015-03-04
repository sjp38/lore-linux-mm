Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A8DFB6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 11:33:06 -0500 (EST)
Received: by wghn12 with SMTP id n12so47930257wgh.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:33:06 -0800 (PST)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id o12si9231314wiv.103.2015.03.04.08.33.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 08:33:04 -0800 (PST)
Received: by widem10 with SMTP id em10so32193536wid.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:33:04 -0800 (PST)
Message-ID: <54F733BD.7060807@plexistor.com>
Date: Wed, 04 Mar 2015 18:33:01 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] DAX: Fix mmap-write not updating c/mtime
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

Hi

First submitted an xfstest (generic/080) that demonstrates our current problem.

   When run on ext4-dax mount, and I'd imagine Dave's xfs-dax mount this test
   fails, on regular mount it works just fine.

then 2 patches to fix it.

The main problem is that current mm/memory.c will no call us with page_mkwrite
if we do not have an actual page mapping, which is what DAX uses.
The solution presented here introduces a new pfn_mkwrite to solve this problem.
Please see patch-2 for details.

I've been running with this patch for 4 month both HW and VMs with no apparent
danger, but see patch-2 I played it safe.

List of patches:
[PATCH 1/2] generic: 080 test that mmap-write updates c/mtime

	This one is for Dave Chinner to submit to xfstests

[PATCH 1/2] mm: New pfn_mkwrite same as page_mkwrite for VM_PFNMAP

	This patch I need help with please look into it?

[PATCH 2/2] dax: use pfn_mkwrite to update mtime

Please review and comment.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
