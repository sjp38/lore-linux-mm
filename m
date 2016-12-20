Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 890EC6B0351
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 15:27:40 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id p16so134057913qta.5
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 12:27:40 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p35si13190926qtf.205.2016.12.20.12.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 12:27:39 -0800 (PST)
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context register 1
References: <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
 <20161217.221442.430708127662119954.davem@davemloft.net>
 <62091365-2797-ed99-847f-7281f4666633@oracle.com>
 <20161220.133334.158286071772728328.davem@davemloft.net>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a7d768e1-fb34-79f2-8caf-eb5af66bdc43@oracle.com>
Date: Tue, 20 Dec 2016 12:27:28 -0800
MIME-Version: 1.0
In-Reply-To: <20161220.133334.158286071772728328.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@oracle.com, nitin.m.gupta@oracle.com, vijay.ac.kumar@oracle.com, julian.calaby@gmail.com, adam.buchbinder@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org

On 12/20/2016 10:33 AM, David Miller wrote:
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Sun, 18 Dec 2016 16:06:01 -0800
> 
>> Ok, let me try to find a way to eliminate these loads unless the application
>> is using shared context.
>>
>> Part of the issue is a 'backwards compatibility' feature of the processor
>> which loads/overwrites register 1 every time register 0 is loaded.  Somewhere
>> in the evolution of the processor, a feature was added so that register 0
>> could be loaded without overwriting register 1.  That could be used to
>> eliminate the extra load in some/many cases.  But, that would likely lead
>> to more runtime kernel patching based on processor level.  And, I don't
>> really want to add more of that if possible.  Or, perhaps we only enable
>> the shared context ID feature on processors which have the ability to work
>> around the backwards compatibility feature.
> 
> Until the first process uses shared mappings, you should not touch the
> context 1 register in any way for any reason at all.
> 
> And even once a process _does_ use shared mappings, you only need to
> access the context 1 register in 2 cases:
> 
> 1) TLB processing for the processes using shared mappings.
> 
> 2) Context switch MMU state handling, where either the previous or
>    next process is using shared mappings.

I agree.

But, we still need to address the issue of existing code that is
overwriting context register 1 today.  Due to that backwards
compatibility feature, code like:

	mov	SECONDARY_CONTEXT, %g3
	stxa	%g2, [%g3] ASI_DMMU

will store not only to register 0, but register 1 as well.

In this RFC, I used an ugly brute force method of always restoring
register 1 after storing register 0 to make sure any unique value
in register 1 was preserved.  I agree this is not acceptable and needs
to be fixed.  We could check if register 1 is in use and only do the
save/restore in that case.  But, that is still an additional check.

The Sparc M7 processor has new ASIs to handle this better:
ASI	ASI Name	R/W	VA 	Per Strand	Description
0x21	ASI_MMU 	RW	0x28 	Y 		I/DMMUPrimary Context
							register 0 (no Primary
							Context register 1
							update)
0x21	ASI_MMU		RW	0x30	Y 		DMMUSecondary Context
							register 0 (no Secondary
							Context register 1
							update)
More details at,
http://www.oracle.com/technetwork/server-storage/sun-sparc-enterprise/documentation/sparc-architecture-supplement-3093429.pdf

Of course, this could only be used on processors where the new ASIs are
available.

Still need to think about the best way to handle this.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
