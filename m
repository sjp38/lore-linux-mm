Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAAA6B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 05:16:40 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b205so27918542wmb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:16:40 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id o5si2716858wjy.239.2016.02.24.02.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 02:16:39 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 24 Feb 2016 10:16:38 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id DE60E1B0807D
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:16:56 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1OAGbdk32309350
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:16:37 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1O9GbJM004281
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:16:38 -0700
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name> <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad> <20160223103221.GA1418@node.shutemov.name>
 <20160223191907.25719a4d@thinkpad>
 <20160223193345.GC21820@node.shutemov.name> <20160223202233.GE27281@arm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56CD8302.9080202@de.ibm.com>
Date: Wed, 24 Feb 2016 11:16:34 +0100
MIME-Version: 1.0
In-Reply-To: <20160223202233.GE27281@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On 02/23/2016 09:22 PM, Will Deacon wrote:
> On Tue, Feb 23, 2016 at 10:33:45PM +0300, Kirill A. Shutemov wrote:
>> On Tue, Feb 23, 2016 at 07:19:07PM +0100, Gerald Schaefer wrote:
>>> I'll check with Martin, maybe it is actually trivial, then we can
>>> do a quick test it to rule that one out.
>>
>> Oh. I found a bug in __split_huge_pmd_locked(). Although, not sure if it's
>> _the_ bug.
>>
>> pmdp_invalidate() is called for the wrong address :-/
>> I guess that can be destructive on the architecture, right?
> 
> FWIW, arm64 ignores the address parameter for set_pmd_at, so this would
> only result in the TLBI nuking the wrong entries, which is going to be
> tricky to observe in practice given that we install a table entry
> immediately afterwards that maps the same pages. If s390 does more here
> (I see some magic asm using the address), that could be the answer...

This patch does not change the address for set_pmd_at, it does that for the 
pmdp_invalidate here (by keeping haddr at the start of the pmd)

--->    pmdp_invalidate(vma, haddr, pmd);
        pmd_populate(mm, pmd, pgtable);
 



Without that fix we would clearly have stale tlb entries, no?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
