Message-ID: <48DA333C.2050900@redhat.com>
Date: Wed, 24 Sep 2008 15:31:56 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D17E75.80807@redhat.com> <48D1851B.70703@goop.org> <48D18919.9060808@redhat.com> <48D18C6B.5010407@goop.org> <48D2B970.7040903@redhat.com> <48D2D3B2.10503@goop.org> <48D2E65A.6020004@redhat.com> <48D2EBBB.205@goop.org> <48D2F05C.4040000@redhat.com> <48D2F571.4010504@goop.org>
In-Reply-To: <48D2F571.4010504@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Avi Kivity wrote:
>   
>>> The only direct use of pte_young() is in zap_pte_range, within a
>>> mmu_lazy region.  So syncing the A bit state on entering lazy mmu mode
>>> would work fine there.
>>>
>>>   
>>>       
>> Ugh, leaving lazy pte.a mode when entering lazy mmu mode?
>>     
>
> Well, sort of but not quite.  The kernel's announcing its about to start
> processing a batch of ptes, so the hypervisor can take the opportunity
> to update their state before processing.  "Lazy-mode" is from the
> perspective of the kernel lazily updating some state the hypervisor
> might care about, and the sync happens when leaving mode.
>
> The flip-side is when the hypervisor is lazily updating some state the
> kernel cares about, so it makes sense that the sync when the kernel
> enters its lazy mode.  But the analogy isn't very good because we don't
> really have an explicit notion of "hypervisor lazy mode", or a formal
> handoff of shared state between the kernel and hypervisor.  But in this
> case the behaviour isn't too bad.
>
>   

Handwavy.  I think the two notions are separate <insert handwavy 
counter-arguments>.

>>> The call via page_referenced_one() doesn't seem to have a very
>>> convenient hook though.  Perhaps putting something in
>>> page_check_address() would do the job.
>>>
>>>   
>>>       
>> Why there?
>>
>> Why not explicitly in the callers?  We need more than to exit lazy
>> pte.a mode, we also need to enter it again later.
>>
>>     
>
> Because that's the code that actually walks the pagetable and has the
> address of the pte; it just returns a pte_t, not a pte_t *.  It depends
> on whether you want fetch the A bit via ptep or vaddr (in general we
> pass mm, ptep and vaddr to ops which operate on the current pagetable).
>   

pte_clear_flush_young_notify_etc() seems even closer.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
