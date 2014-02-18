Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id AB1C46B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:23:47 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so16772776pdj.18
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:23:47 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id vb2si19673225pbc.247.2014.02.18.14.23.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:23:46 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id p10so16840850pdj.15
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:23:46 -0800 (PST)
Date: Tue, 18 Feb 2014 14:23:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu
 and limit readahead pages
In-Reply-To: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402181421590.20772@chino.kir.corp.google.com>
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 18 Feb 2014, Raghavendra K T wrote:

> Currently max_sane_readahead() returns zero on the cpu having no local memory node
> which leads to readahead failure. Fix the readahead failure by returning
> minimum of (requested pages, 512). Users running application on a memory-less cpu
> which needs readahead such as streaming application see considerable boost in the
> performance.
> 
> Result:
> fadvise experiment with FADV_WILLNEED on a PPC machine having memoryless CPU
> with 1GB testfile ( 12 iterations) yielded around 46.66% improvement.
> 
> fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
> 32GB* 4G RAM  numa machine ( 12 iterations) showed no impact on the normal
> NUMA cases w/ patch.
> 
> Kernel     Avg  Stddev
> base	7.4975	3.92%
> patched	7.4174  3.26%
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> [Andrew: making return value PAGE_SIZE independent]
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

So this replaces 
mm-readaheadc-fix-readahead-fail-for-no-local-memory-and-limit-readahead-pages.patch 
in -mm correct?

> ---
>  I would like to thank Honza, David for their valuable suggestions and 
>  patiently reviewing the patches.
> 
>  Changes in V6:
>   - Just limit the readahead to 2MB on 4k pages system as suggested by Linus.
>  and make it independent of PAGE_SIZE. 
> 

I'm not sure I understand why we want to be independent of PAGE_SIZE since 
we're still relying on PAGE_CACHE_SIZE.  Don't you mean to do

#define MAX_READAHEAD	((512*PAGE_SIZE)/PAGE_CACHE_SIZE)

instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
