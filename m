Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A35A36B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:57:56 -0400 (EDT)
Received: by wizk4 with SMTP id k4so151582085wiz.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 04:57:56 -0700 (PDT)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id t8si7730042wjr.69.2015.04.15.04.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 04:57:55 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 15 Apr 2015 12:57:53 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5332617D8062
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 12:58:26 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3FBvoh158982590
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 11:57:50 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3FBvmc7005950
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:57:49 -0400
Message-ID: <552E523A.1020905@linux.vnet.ibm.com>
Date: Wed, 15 Apr 2015 13:57:46 +0200
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com> <9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com> <20150413115811.GA12354@node.dhcp.inet.fi> <552BB972.3010704@linux.vnet.ibm.com> <20150413131357.GC12354@node.dhcp.inet.fi> <552BC2CA.80309@linux.vnet.ibm.com>	<552BC619.9080603@parallels.com> <20150413140219.GA14480@node.dhcp.inet.fi> <20150413135951.b3d9f431892dbfa7156cc1b0@linux-foundation.org> <552CDD35.2030901@linux.vnet.ibm.com> <20150414123853.a3e61b7fa95b6c634e0fcce0@linux-foundation.org>
In-Reply-To: <20150414123853.a3e61b7fa95b6c634e0fcce0@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

On 14/04/2015 21:38, Andrew Morton wrote:
> On Tue, 14 Apr 2015 11:26:13 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
> 
>>> Do away with __HAVE_ARCH_REMAP and do it like this:
>>>
>>> arch/x/include/asm/y.h:
>>>
>>> 	extern void arch_remap(...);
>>> 	#define arch_remap arch_remap
>>>
>>> include/linux/z.h:
>>>
>>> 	#include <asm/y.h>
>>>
>>> 	#ifndef arch_remap
>>> 	static inline void arch_remap(...) { }
>>> 	#define arch_remap arch_remap
>>> 	#endif
>>
>> Hi Andrew,
>>
>> I like your idea, but I can't find any good candidate for <asm/y.h> and
>> <linux/z.h>.
>>
>> I tried with <linux/mm.h> and <asm/mmu_context.h> but
>> <asm/mmu_context.h> is already including <linux/mm.h>.
>>
>> Do you have any suggestion ?
>>
>> Another option could be to do it like the actual arch_unmap() in
>> <asm-generic/mm_hooks.h> but this is the opposite of your idea, and Ingo
>> was not comfortable with this idea due to the impact of the other
>> architectures.
> 
> I don't see any appropriate header files for this.  mman.h is kinda
> close.
> 
> So we create new header files, that's not a problem.  I'm torn between
> 
> a) include/linux/mm-arch-hooks.h (and 31
>    arch/X/include/asm/mm-arch-hooks.h).  Mandate: mm stuff which can be
>    overridded by arch
> 
> versus
> 
> b) include/linux/mremap.h (+31), with a narrower mandate.
> 
> 
> This comes up fairly regularly so I suspect a) is better.  We'll add
> things to it over time, and various bits of existing ad-hackery can be
> moved over as cleanups.

Thanks for the advice,

I'll do a), starting with the arch_remap macro, adding the 30 "empty"
arch/x/include/asm/mm-arch-hooks.h files, and implementing arch_remap
for powerpc.

Then, if the first patch is accepted, I may move the arch_*() stuff
defined in include/asm-generic/mm_hooks.h into
include/linux/mm-arch-hooks.h and filled some
arch/X/include/asm/mm-arch-hooks.h. The file
include/asm-generic/mm_hooks.h will then become empty, and been removed.

Cheers,
Laurent.


  * Anglais - detecte
  * Francais
  * Anglais

  * Francais
  * Anglais

 <javascript:void(0);>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
