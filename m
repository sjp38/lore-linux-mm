Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 486BA6B00A0
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:42:36 -0400 (EDT)
Message-ID: <5034FD71.3000406@redhat.com>
Date: Wed, 22 Aug 2012 11:40:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch]readahead: fault retry breaks mmap file read random detection
References: <20120822034012.GA24099@kernel.org>
In-Reply-To: <20120822034012.GA24099@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, akpm@linux-foundation.org

On 08/21/2012 11:40 PM, Shaohua Li wrote:
> .fault now can retry. The retry can break state machine of .fault. In
> filemap_fault, if page is miss, ra->mmap_miss is increased. In the second try,
> since the page is in page cache now, ra->mmap_miss is decreased. And these are
> done in one fault, so we can't detect random mmap file access.
>
> Add a new flag to indicate .fault is tried once. In the second try, skip
> ra->mmap_miss decreasing. The filemap_fault state machine is ok with it.

> Index: linux/arch/avr32/mm/fault.c
> ===================================================================
> --- linux.orig/arch/avr32/mm/fault.c	2012-08-22 09:51:23.035526683 +0800
> +++ linux/arch/avr32/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
> @@ -152,6 +152,7 @@ good_area:
>   			tsk->min_flt++;
>   		if (fault & VM_FAULT_RETRY) {
>   			flags &= ~FAULT_FLAG_ALLOW_RETRY;
> +			flags |= FAULT_FLAG_TRIED;

Is there any place where you set FAULT_FLAG_TRIED
where FAULT_FLAG_ALLOW_RETRY is not cleared?

In other words, could we use the absence of the
FAULT_FLAG_ALLOW_RETRY as the test, avoiding the
need for a new bit flag?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
