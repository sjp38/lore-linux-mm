Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1EBE6B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 22:21:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w189so113557559pfb.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 19:21:50 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u123si7038357pgc.280.2017.03.16.19.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 19:21:49 -0700 (PDT)
Date: Fri, 17 Mar 2017 10:21:58 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170317022158.GB18964@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170316193844.GA110825@stormcage.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316193844.GA110825@stormcage.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <alex.thorlton@hpe.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Thu, Mar 16, 2017 at 02:38:44PM -0500, Alex Thorlton wrote:
> On Wed, Mar 15, 2017 at 04:59:59PM +0800, Aaron Lu wrote:
> > v2 changes: Nothing major, only minor ones.
> >  - rebased on top of v4.11-rc2-mmotm-2017-03-14-15-41;
> >  - use list_add_tail instead of list_add to add worker to tlb's worker
> >    list so that when doing flush, the first queued worker gets flushed
> >    first(based on the comsumption that the first queued worker has a
> >    better chance of finishing its job than those later queued workers);
> >  - use bool instead of int for variable free_batch_page in function
> >    tlb_flush_mmu_free_batches;
> >  - style change according to ./scripts/checkpatch;
> >  - reword some of the changelogs to make it more readable.
> > 
> > v1 is here:
> > https://lkml.org/lkml/2017/2/24/245
> 
> I tested v1 on a Haswell system with 64 sockets/1024 cores/2048 threads
> and 8TB of RAM, with a 1TB malloc.  The average free() time for a 1TB
> malloc on a vanilla kernel was 41.69s, the patched kernel averaged
> 21.56s for the same test.

Thanks a lot for the test result.

> 
> I am testing v2 now and will report back with results in the next day or
> so.

Testing plain v2 shouldn't bring any surprise/difference, better set the
following param before the test(I'm planning to make them default in the
next version):
# echo 64 > /sys/devices/virtual/workqueue/batch_free_wq/max_active
# echo 1030 > /sys/kernel/debug/parallel_free/max_gather_batch_count

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
