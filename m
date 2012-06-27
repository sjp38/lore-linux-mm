Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DB2DD6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:35:08 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 14:35:07 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7B7A938C81CF
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:33:45 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RIXjsN131716
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:33:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5S04aRL010872
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:04:37 -0400
Message-ID: <4FEB5204.3090707@linux.vnet.ibm.com>
Date: Wed, 27 Jun 2012 13:33:40 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9FDD.6030102@kernel.org> <4FEAA4AA.3000406@intel.com> <4FEAA7A1.9020307@kernel.org> <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default>
In-Reply-To: <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Alex Shi <alex.shi@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/27/2012 10:12 AM, Dan Magenheimer wrote:
>> From: Minchan Kim [mailto:minchan@kernel.org]
>> Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
>>
>> On 06/27/2012 03:14 PM, Alex Shi wrote:
>>>
>>> On 06/27/2012 01:53 PM, Minchan Kim wrote:
>>> Different CPU type has different balance point on the invlpg replacing
>>> flush all. and some CPU never get benefit from invlpg, So, it's better
>>> to use different value for different CPU, not a fixed
>>> INVLPG_BREAK_EVEN_PAGES.
>>
>> I think it could be another patch as further step and someone who are
>> very familiar with architecture could do better than.
>> So I hope it could be merged if it doesn't have real big problem.
>>
>> Thanks for the comment, Alex.
> 
> Just my opinion, but I have to agree with Alex.  Hardcoding
> behavior that is VERY processor-specific is a bad idea.  TLBs should
> only be messed with when absolutely necessary, not for the
> convenience of defending an abstraction that is nice-to-have
> but, in current OS kernel code, unnecessary.

I agree that it's not optimal.  The selection based on CPUID
is part of Alex's patchset, and I'll be glad to use that
code when it gets integrated.

But the real discussion is are we going to:
1) wait until Alex's patches to be integrated, degrading
zsmalloc in the meantime or
2) put in some simple temporary logic that works well (not
best) for most cases

> IIUC, zsmalloc only cares that the breakeven point is greater
> than two.  An arch-specific choice of (A) two page flushes
> vs (B) one all-TLB flush should be all that is necessary right
> now.  (And, per separate discussion, even this isn't really
> necessary either.)
> 
> If zsmalloc _ever_ gets extended to support items that might
> span three or more pages, a more generic TLB flush-pages-vs-flush-all
> approach may be warranted and, by then, may already exist in some
> future kernel.  Until then, IMHO, keep it simple.

I guess I'm not following.  Are you supporting the removal
of the "break even" logic?  I added that logic as a
compromise for Peter's feedback:

http://lkml.org/lkml/2012/5/17/177

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
