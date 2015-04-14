Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 17FAC6B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 05:26:24 -0400 (EDT)
Received: by widdi4 with SMTP id di4so105107629wid.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 02:26:23 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id gq3si2622034wib.51.2015.04.14.02.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 02:26:22 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 14 Apr 2015 10:26:20 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2E62917D806A
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 10:26:51 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3E9QFRR39583802
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 09:26:15 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3E9QEuC030634
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 03:26:15 -0600
Message-ID: <552CDD35.2030901@linux.vnet.ibm.com>
Date: Tue, 14 Apr 2015 11:26:13 +0200
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com> <9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com> <20150413115811.GA12354@node.dhcp.inet.fi> <552BB972.3010704@linux.vnet.ibm.com> <20150413131357.GC12354@node.dhcp.inet.fi> <552BC2CA.80309@linux.vnet.ibm.com>	<552BC619.9080603@parallels.com> <20150413140219.GA14480@node.dhcp.inet.fi> <20150413135951.b3d9f431892dbfa7156cc1b0@linux-foundation.org>
In-Reply-To: <20150413135951.b3d9f431892dbfa7156cc1b0@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

On 13/04/2015 22:59, Andrew Morton wrote:
> On Mon, 13 Apr 2015 17:02:19 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
>>> Kirill, if I'm right with it, can you suggest the header where to put
>>> the "generic" mremap hook's (empty) body?
>>
>> I initially thought it would be enough to put it into
>> <asm-generic/mmu_context.h>, expecting it works as
>> <asm-generic/pgtable.h>. But that's not the case.
>>
>> It probably worth at some point rework all <asm/mmu_context.h> to include
>> <asm-generic/mmu_context.h> at the end as we do for <asm/pgtable.h>.
>> But that's outside the scope of the patchset, I guess.
>>
>> I don't see any better candidate for such dummy header. :-/
> 
> Do away with __HAVE_ARCH_REMAP and do it like this:
> 
> arch/x/include/asm/y.h:
> 
> 	extern void arch_remap(...);
> 	#define arch_remap arch_remap
> 
> include/linux/z.h:
> 
> 	#include <asm/y.h>
> 
> 	#ifndef arch_remap
> 	static inline void arch_remap(...) { }
> 	#define arch_remap arch_remap
> 	#endif

Hi Andrew,

I like your idea, but I can't find any good candidate for <asm/y.h> and
<linux/z.h>.

I tried with <linux/mm.h> and <asm/mmu_context.h> but
<asm/mmu_context.h> is already including <linux/mm.h>.

Do you have any suggestion ?

Another option could be to do it like the actual arch_unmap() in
<asm-generic/mm_hooks.h> but this is the opposite of your idea, and Ingo
was not comfortable with this idea due to the impact of the other
architectures.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
