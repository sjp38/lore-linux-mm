Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 99C6E6B0384
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 14:24:42 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 14:24:41 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C6B6C6E8066
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 14:24:38 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PIObN4169204
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 14:24:37 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PIOYRn010123
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:24:35 -0600
Message-ID: <4FE8ACDD.3070007@linux.vnet.ibm.com>
Date: Mon, 25 Jun 2012 13:24:29 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com> <20120625165915.GA20464@kroah.com> <4FE89BA1.3030709@linux.vnet.ibm.com> <20120625171939.GA29371@kroah.com>
In-Reply-To: <20120625171939.GA29371@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/25/2012 12:19 PM, Greg Kroah-Hartman wrote:
> On Mon, Jun 25, 2012 at 12:10:57PM -0500, Seth Jennings wrote:
>> On 06/25/2012 11:59 AM, Greg Kroah-Hartman wrote:
>>> On Mon, Jun 25, 2012 at 11:14:37AM -0500, Seth Jennings wrote:
>>>> This patch adds generic pages mapping methods that
>>>> work on all archs in the absence of support for
>>>> local_tlb_flush_kernel_range() advertised by the
>>>> arch through __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE
>>>
>>> Is this #define something that other arches define now?  Or is this
>>> something new that you are adding here?
>>
>> Something new I'm adding.
> 
> Ah, ok.
> 
>> The precedent for this approach is the __HAVE_ARCH_* defines
>> that let the arch independent stuff know if a generic
>> function needs to be defined or if there is an arch specific
>> function.
>>
>> You can "grep -R __HAVE_ARCH_* arch/x86/" to see the ones
>> that already exist.
>>
>> I guess I should have called it
>> __HAVE_ARCH_LOCAL_TLB_FLUSH_KERNEL_RANGE though, not
>> __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE.
> 
> You need to get the mm developers to agree with this before I can take
> it.
> 
> But, why even depend on this?  Can't you either live without it

The whole point of the patch is _not_ to depend on it.  It
just performs worse without it.  We could just rip out all
the the page table assisted page mapping, but, for the
arches that have support for it, we'd be degrading
performance in exchange for portability.  Why choose when we
can have both?

> , or just implement it for all arches somehow?

It can be implemented for some arches and already is for
some (MIPS, ARM, at least).  But for some arches, I imagine
this can't be implemented due to hardware limitations.

A benefit of this approach is the arches opt-in to the
optimized zsmalloc by implementing
local_tlb_flush_kernel_range() without having to change
anything in zsmalloc.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
