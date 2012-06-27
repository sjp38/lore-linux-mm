Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 856596B0081
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:42:24 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 17:42:22 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 303D338C801D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:52 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RLfp0J32505882
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RLfnSq001466
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:41:51 -0300
Message-ID: <4FEB7E19.8040702@linux.vnet.ibm.com>
Date: Wed, 27 Jun 2012 16:41:45 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9FDD.6030102@kernel.org> <4FEAA4AA.3000406@intel.com> <4FEAA7A1.9020307@kernel.org> <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default> <4FEB5204.3090707@linux.vnet.ibm.com> <80ad7298-23de-4c5e-9a8d-483198ae4ef1@default>
In-Reply-To: <80ad7298-23de-4c5e-9a8d-483198ae4ef1@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Alex Shi <alex.shi@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/27/2012 04:15 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> I guess I'm not following.  Are you supporting the removal
>> of the "break even" logic?  I added that logic as a
>> compromise for Peter's feedback:
>>
>> http://lkml.org/lkml/2012/5/17/177
> 
> Yes, as long as I am correct that zsmalloc never has to map/flush
> more than two pages at a time, I think dealing with the break-even
> logic is overkill.

The implementation of local_flush_tlb_kernel_range()
shouldn't be influenced by zsmalloc at all.  Additionally,
we can't assume that zsmalloc will always be the only user
of this function.

> I see Peter isn't on this dist list... maybe
> you should ask him if he agrees, as long as we are only always
> talking about flush-two-TLB-pages vs flush-all.

Yes, I'm planning to send out the next version of patches
tomorrow (minus the first that has already been accepted)
and I'll include him like I should have the first time :-/

> (And, of course, per previous discussion, I think even mapping/flushing
> two TLB pages is unnecessary and overkill required only for protecting an
> abstraction, but will stop beating that dead horse. ;-)

With this patchset, I actually quantified the the
performance gain with page table assisted mapping vs mapping
via copy, and there is a significant 40% difference in
single-threaded performance.

You can do the test yourself by commenting out the
#define __HAVE_ARCH_LOCAL_FLUSH_TLB_KERNEL_RANGE
in tlbflush.h which will cause the new mapping via copy
method to be used.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
