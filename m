Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id D6D6F6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:01:37 -0400 (EDT)
Received: by lbcga7 with SMTP id ga7so7661639lbc.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:01:37 -0700 (PDT)
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com. [209.85.215.41])
        by mx.google.com with ESMTPS id r10si17700664lal.5.2015.04.28.16.01.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:01:36 -0700 (PDT)
Received: by layy10 with SMTP id y10so7639650lay.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:01:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5540101D.7020800@redhat.com>
References: <20150428221553.GA5770@node.dhcp.inet.fi> <55400CA7.3050902@redhat.com>
 <CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com> <5540101D.7020800@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 Apr 2015 16:01:15 -0700
Message-ID: <CALCETrVuvbSrA=Ekz3fc2oE5psPyqEvL0YN7JvCCkOx-D18N3w@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Apr 28, 2015 at 3:56 PM, Rik van Riel <riel@redhat.com> wrote:
> On 04/28/2015 06:54 PM, Andy Lutomirski wrote:
>> On Tue, Apr 28, 2015 at 3:41 PM, Rik van Riel <riel@redhat.com> wrote:
>>> On 04/28/2015 06:15 PM, Kirill A. Shutemov wrote:
>>>> On Tue, Apr 28, 2015 at 01:42:10PM -0700, Andy Lutomirski wrote:
>>>>> At some point, I'd like to implement PCID on x86 (if no one beats me
>>>>> to it, and this is a low priority for me), which will allow us to skip
>>>>> expensive TLB flushes while context switching.  I have no idea whether
>>>>> ARM can do something similar.
>>>>
>>>> I talked with Dave about implementing PCID and he thinks that it will be
>>>> net loss. TLB entries will live longer and it means we would need to trigger
>>>> more IPIs to flash them out when we have to. Cost of IPIs will be higher
>>>> than benifit from hot TLB after context switch.
>>>
>>> I suspect that may depend on how you do the shootdown.
>>>
>>> If, when receiving a TLB shootdown for a non-current PCID, we just flush
>>> all the entries for that PCID and remove the CPU from the mm's
>>> cpu_vm_mask_var, we will never receive more than one shootdown IPI for
>>> a non-current mm, but we will still get the benefits of TLB longevity
>>> when dealing with eg. pipe workloads where tasks take turns running on
>>> the same CPU.
>>
>> I had a totally different implementation idea in mind.  It goes
>> something like this:
>>
>> For each CPU, we allocate a fixed number of PCIDs, e.g. 0-7.  We have
>> a per-cpu array of the mm [1] that owns each PCID.  On context switch,
>> we look up the new mm in the array and, if there's a PCID mapped, we
>> switch cr3 and select that PCID.  If there is no PCID mapped, we
>> choose one (LRU?  clock replacement?), switch cr3 and select and
>> invalidate that PCID.
>>
>> When it's time to invalidate a TLB entry on an mm that's active
>> remotely, we really don't want to send an IPI to a CPU that doesn't
>> actually have that mm active.  Instead we bump some kind of generation
>> counter in the mm_struct that will cause the next switch to that mm
>> not to match the PCID list.  To keep this working, I think we also
>> need to update the per-cpu PCID list with our generation counter
>> either when we context switch out or when we process a TLB shootdown
>> IPI.
>
> If we do that, we can also get rid of TLB shootdowns for
> idle CPUs in lazy TLB mode.
>
> Very nice, if the details work out.
>

I wonder if we could treat the non-PCID case just like the PCID case
but with only one PCID.  Maybe get rid of the mm vs active_mm
distinction.  Maybe not, though -- if nothing else, we still need to
kick our pgd out from idle or kthread CPUs before we free it.

The reason I thought of PCIDs this way is that 12 bits isn't nearly
enough to get away with allocating each mm its own PCID.  Rather than
trying to shoehorn them in, it seemed like a better approach would be
to only use a very small number, since keeping around TLB entries that
are more than a few context switches old seems mostly useless.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
