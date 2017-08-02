Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19BB56B063F
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 19:26:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k190so64534029pge.9
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 16:26:27 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t66si17712405pgt.865.2017.08.02.16.26.25
        for <linux-mm@kvack.org>;
        Wed, 02 Aug 2017 16:26:26 -0700 (PDT)
Date: Thu, 3 Aug 2017 08:26:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 0/7] fixes of TLB batching races
Message-ID: <20170802232624.GB32020@bbox>
References: <20170802000818.4760-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802000818.4760-1-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, Aug 01, 2017 at 05:08:11PM -0700, Nadav Amit wrote:
> It turns out that Linux TLB batching mechanism suffers from various races.
> Races that are caused due to batching during reclamation were recently
> handled by Mel and this patch-set deals with others. The more fundamental
> issue is that concurrent updates of the page-tables allow for TLB flushes
> to be batched on one core, while another core changes the page-tables.
> This other core may assume a PTE change does not require a flush based on
> the updated PTE value, while it is unaware that TLB flushes are still
> pending.
> 
> This behavior affects KSM (which may result in memory corruption) and
> MADV_FREE and MADV_DONTNEED (which may result in incorrect behavior). A
> proof-of-concept can easily produce the wrong behavior of MADV_DONTNEED.
> Memory corruption in KSM is harder to produce in practice, but was observed
> by hacking the kernel and adding a delay before flushing and replacing the
> KSM page.
> 
> Finally, there is also one memory barrier missing, which may affect
> architectures with weak memory model.
> 
> v5 -> v6:
> * Combining with Minchan Kim's patch set, adding ack's (Andrew)
> * Minor: missing header, typos (Nadav)
> * Renaming arch_generic_tlb_finish_mmu (Mel)

Thanks for intergrating/correction, Nadav.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
