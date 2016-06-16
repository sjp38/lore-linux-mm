Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 098836B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 16:24:25 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so99423204pat.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 13:24:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id h62si7657231pfb.176.2016.06.16.13.24.24
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 13:24:24 -0700 (PDT)
Subject: Re: [PATCH v3] Linux VM workaround for Knights Landing A/D leak
References: <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <1466090042-30908-1-git-send-email-lukasz.anaczkowski@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57630ADE.3040900@linux.intel.com>
Date: Thu, 16 Jun 2016 13:23:58 -0700
MIME-Version: 1.0
In-Reply-To: <1466090042-30908-1-git-send-email-lukasz.anaczkowski@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, hpa@zytor.com, mingo@redhat.com, tglx@linutronix.de, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com

On 06/16/2016 08:14 AM, Lukasz Anaczkowski wrote:
> For reclaim this brings the performance back to before Mel's
> flushing changes, but for unmap it disables batching.

This turns out to be pretty catastrophic for unmap.  In a workload that
uses, say 200 hardware threads and alloc/frees() a few MB/sec, this ends
up costing hundreds of thousands of extra received IPIs.  10MB=~2500
ptes, and at with 200 threads, that's 250,000 IPIs received just to free
10MB of memory.

The initial testing we did on this was on a *bunch* of threads all doing
alloc/free.  But this is bottlenecked on other things, like mmap_sem
being held for write.

The scenario that we really needed to test here was on lots of threads
doing processing and 1 thread doing alloc/free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
