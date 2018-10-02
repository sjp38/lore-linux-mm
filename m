Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 943066B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:25:35 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id i14-v6so2058015qtf.13
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:25:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p69-v6si11500152qvp.269.2018.10.02.08.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 08:25:34 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
Date: Tue, 2 Oct 2018 17:25:19 +0200
MIME-Version: 1.0
In-Reply-To: <20181002134734.GT18290@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On 02/10/2018 15:47, Michal Hocko wrote:
> On Mon 01-10-18 11:34:25, David Hildenbrand wrote:
>> On 01/10/2018 10:40, Michal Hocko wrote:
>>> On Fri 28-09-18 17:03:57, David Hildenbrand wrote:
>>> [...]
>>>
>>> I haven't read the patch itself but I just wanted to note one thing
>>> about this part
>>>
>>>> For paravirtualized devices it is relevant that memory is onlined as
>>>> quickly as possible after adding - and that it is added to the NORMAL
>>>> zone. Otherwise, it could happen that too much memory in a row is added
>>>> (but not onlined), resulting in out-of-memory conditions due to the
>>>> additional memory for "struct pages" and friends. MOVABLE zone as well
>>>> as delays might be very problematic and lead to crashes (e.g. zone
>>>> imbalance).
>>>
>>> I have proposed (but haven't finished this due to other stuff) a
>>> solution for this. Newly added memory can host memmaps itself and then
>>> you do not have the problem in the first place. For vmemmap it would
>>> have an advantage that you do not really have to beg for 2MB pages to
>>> back the whole section but you would get it for free because the initial
>>> part of the section is by definition properly aligned and unused.
>>
>> So the plan is to "host metadata for new memory on the memory itself".
>> Just want to note that this is basically impossible for s390x with the
>> current mechanisms. (added memory is dead, until onlining notifies the
>> hypervisor and memory is allocated). It will also be problematic for
>> paravirtualized memory devices (e.g. XEN's "not backed by the
>> hypervisor" hacks).
> 
> OK, I understand that not all usecases can use self memmap hosting
> others do not have much choice left though. You have to allocate from
> somewhere. Well and alternative would be to have no memmap until
> onlining but I am not sure how much work that would be.
> 
>> This would only be possible for memory DIMMs, memory that is completely
>> accessible as far as I can see. Or at least, some specified "first part"
>> is accessible.
>>
>> Other problems are other metadata like extended struct pages and friends.
> 
> I wouldn't really worry about extended struct pages. Those should be
> used for debugging purposes mostly. Ot at least that was the case last
> time I've checked.

Yes, I guess that is true. Being able to add and online memory without
the need for additional (external) memory would be the ultimate goal,
but highly complicated. But steps into that direction is a good idea.

> 
>> (I really like the idea of adding memory without allocating memory in
>> the hypervisor in the first place, please keep me tuned).
>>
>> And please note: This solves some problematic part ("adding too much
>> memory to the movable zone or not onlining it"), but not the issue of
>> zone imbalance in the first place. And not one issue I try to tackle
>> here: don't add paravirtualized memory to the movable zone.
> 
> Zone imbalance is an inherent problem of the highmem zone. It is
> essentially the highmem zone we all loved so much back in 32b days.
> Yes the movable zone doesn't have any addressing limitations so it is a
> bit more relaxed but considering the hotplug scenarios I have seen so
> far people just want to have full NUMA nodes movable to allow replacing
> DIMMs. And then we are back to square one and the zone imbalance issue.
> You have those regardless where memmaps are allocated from.

Unfortunately yes. And things get more complicated as you are adding a
whole DIMMs and get notifications in the granularity of memory blocks.
Usually you are not interested in onlining any memory block of that DIMM
as MOVABLE as soon as you would have to online one memory block of that
DIMM as NORMAL - because that can already block the whole DIMM.

> 
>>> I yet have to think about the whole proposal but I am missing the most
>>> important part. _Who_ is going to use the new exported information and
>>> for what purpose. You said that distributions have hard time to
>>> distinguish different types of onlinining policies but isn't this
>>> something that is inherently usecase specific?
>>>
>>
>> Let's think about a distribution. We have a clash of use cases here
>> (just what you describe). What I propose solves one part of it ("handle
>> what you know how to handle right in the kernel").
>>
>> 1. Users of DIMMs usually expect that they can be unplugged again. That
>> is why you want to control how to online memory in user space (== add it
>> to the movable zone).
> 
> Which is only true if you really want to hotremove them. I am not going
> to tell how much I believe in this usecase but movable policy is not
> generally applicable here.

Customers expect this to work and the both of us know that we can't make
any guarantees. At least MOVABLE makes it more likely to work. NORMAL is
basically impossible.

> 
>> 2. Users of standby memory (s390) expect that memory will never be
>> onlined automatically. It will be onlined manually.
> 
> yeah
> 
>> 3. Users of paravirtualized devices (esp. Hyper-V) don't care about
>> memory unplug in the sense of MOVABLE at all. They (or Hyper-V!) will
>> add a whole bunch of memory and expect that everything works fine. So
>> that memory is onlined immediately and that memory is added to the
>> NORMAL zone. Users never want the MOVABLE zone.
> 
> Then the immediate question would be why to use memory hotplug for that
> at all? Why don't you simply start with a huge pre-allocated physical
> address space and balloon memory in an out per demand. Why do you want
> to inject new memory during the runtime?

Let's assume you have a guest with 20GB size and eventually want to
allow to grow it to 4TB. You would have to allocate metadata for 4TB
right from the beginning. That's definitely now what we want. That is
why memory hotplug is used by e.g. XEN or Hyper-V. With Hyper-V, the
hypervisor even tells you at which places additional memory has been
made available.

> 
>> 1. is a reason why distributions usually don't configure
>> "MEMORY_HOTPLUG_DEFAULT_ONLINE", because you really want the option for
>> MOVABLE zone. That however implies, that e.g. for x86, you have to
>> handle all new memory in user space, especially also HyperV memory.
>> There, you then have to check for things like "isHyperV()" to decide
>> "oh, yes, this should definitely not go to the MOVABLE zone".
> 
> Why do you need a generic hotplug rule in the first place? Why don't you
> simply provide different set of rules for different usecases? Let users
> decide which usecase they prefer rather than try to be clever which
> almost always hits weird corner cases.
> 

Memory hotplug has to work as reliable as we can out of the box. Letting
the user make simple decisions like "oh, I am on hyper-V, I want to
online memory to the normal zone" does not feel right. But yes, we
should definitely allow to make modifications. So some sane default rule
+ possible modification is usually a good idea.

I think Dave has a point with using MOVABLE for huge page use cases. And
there might be other corner cases as you correctly state.

I wonder if this patch itself minus modifying online/offline might make
sense. We can then implement simple rules in user space

if (normal) {
	/* customers expect hotplugged DIMMs to be unpluggable */
	online_movable();
} else if (paravirt) {
	/* paravirt memory should as default always go to the NORMAL */
	online();
} else {
	/* standby memory will never get onlined automatically */
}

Compared to having to guess what is to be done (isKVM(), isHyperV,
isS390 ...) and failing once this is no longer unique (e.g. virtio-mem
and ACPI support for x86 KVM).

-- 

Thanks,

David / dhildenb
