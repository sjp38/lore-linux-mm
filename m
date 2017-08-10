Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAFE6B0311
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 14:16:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i192so14454184pgc.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 11:16:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k91si4804141pld.990.2017.08.10.11.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 11:16:57 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7AIGbDI139713
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 14:16:56 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c8r86f75s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 14:16:56 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 10 Aug 2017 19:16:52 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH 05/16] mm: Protect VMA modifications using VMA sequence
 count
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170809101241.ek4fqinqaq5qfkq4@node.shutemov.name>
 <f935091a-d8f9-1951-8397-f5c464a2b922@linux.vnet.ibm.com>
 <20170810005828.qmw3p7d676hjwkss@node.shutemov.name>
 <4e552377-af38-3580-73b6-1edf685cb90d@linux.vnet.ibm.com>
 <20170810134325.j4ijsxzc56e443of@node.shutemov.name>
Date: Thu, 10 Aug 2017 20:16:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170810134325.j4ijsxzc56e443of@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <14e3185c-36e9-c9b1-25f2-98a98de94356@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 10/08/2017 15:43, Kirill A. Shutemov wrote:
> On Thu, Aug 10, 2017 at 10:27:50AM +0200, Laurent Dufour wrote:
>> On 10/08/2017 02:58, Kirill A. Shutemov wrote:
>>> On Wed, Aug 09, 2017 at 12:43:33PM +0200, Laurent Dufour wrote:
>>>> On 09/08/2017 12:12, Kirill A. Shutemov wrote:
>>>>> On Tue, Aug 08, 2017 at 04:35:38PM +0200, Laurent Dufour wrote:
>>>>>> The VMA sequence count has been introduced to allow fast detection of
>>>>>> VMA modification when running a page fault handler without holding
>>>>>> the mmap_sem.
>>>>>>
>>>>>> This patch provides protection agains the VMA modification done in :
>>>>>> 	- madvise()
>>>>>> 	- mremap()
>>>>>> 	- mpol_rebind_policy()
>>>>>> 	- vma_replace_policy()
>>>>>> 	- change_prot_numa()
>>>>>> 	- mlock(), munlock()
>>>>>> 	- mprotect()
>>>>>> 	- mmap_region()
>>>>>> 	- collapse_huge_page()
>>>>>
>>>>> I don't thinks it's anywhere near complete list of places where we touch
>>>>> vm_flags. What is your plan for the rest?
>>>>
>>>> The goal is only to protect places where change to the VMA is impacting the
>>>> page fault handling. If you think I missed one, please advise.
>>>
>>> That's very fragile approach. We rely here too much on specific compiler behaviour.
>>>
>>> Any write access to vm_flags can, in theory, be translated to several
>>> write accesses. For instance with setting vm_flags to 0 in the middle,
>>> which would result in sigfault on page fault to the vma.
>>
>> Indeed, just setting vm_flags to 0 will not result in sigfault, the real
>> job is done when the pte are updated and the bits allowing access are
>> cleared. Access to the pte is controlled by the pte lock.
>> Page fault handler is triggered based on the pte bits, not the content of
>> vm_flags and the speculative page fault is checking for the vma again once
>> the pte lock is held. So there is no concurrency when dealing with the pte
>> bits.
> 
> Suppose we are getting page fault to readable VMA, pte is clear at the
> time of page fault. In this case we need to consult vm_flags to check if
> the vma is read-accessible.
> 
> If by the time of check vm_flags happend to be '0' we would get SIGSEGV as
> the vma appears to be non-readable.
> 
> Where is my logic faulty?

The speculative page fault handler will not deliver the signal, if the page
fault can't be done in the speculative path for instance because the
vm_flags are not matching the required one, the speculative page fault is
aborted and the *classic* page fault handler is run which will do the job
again grabbing the mmap_sem.

>> Regarding the compiler behaviour, there are memory barriers and locking
>> which should prevent that.
> 
> Which locks barriers are you talking about?

When the VMA is modified and that the changes will impact the speculative
page fault handler the sequence count is touch using write_seqcount_begin()
and write_seqcount_end(). These 2 services contains calls to smp_wmb().
On the speculative path side, the calls to *_read_seqcount() contains also
memory barriers calls.

> We need at least READ_ONCE/WRITE_ONCE to access vm_flags everywhere.

I don't think READ_ONCE/WRITE_ONCE would help here, as they would not
prevent reading transcient state as the vm_flags example you mentioned.

That said, there are not so much VMA's fields used in the SPF's path and
caching them into the vmf structure under the control of the VMA's sequence
count would solve this.
I'll try to move in that direction unless anyone has a better idea.


Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
