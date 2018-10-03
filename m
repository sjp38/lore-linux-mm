Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF536B026B
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 13:00:48 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 17-v6so5647701qkj.19
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:00:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e35-v6si1342835qkh.112.2018.10.03.10.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 10:00:47 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
 <20181003135407.GI4714@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <9fef1f7d-2d7c-03f1-00e3-5fa657eda019@redhat.com>
Date: Wed, 3 Oct 2018 19:00:29 +0200
MIME-Version: 1.0
In-Reply-To: <20181003135407.GI4714@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On 03/10/2018 15:54, Michal Hocko wrote:
> On Tue 02-10-18 17:25:19, David Hildenbrand wrote:
>> On 02/10/2018 15:47, Michal Hocko wrote:
> [...]
>>> Zone imbalance is an inherent problem of the highmem zone. It is
>>> essentially the highmem zone we all loved so much back in 32b days.
>>> Yes the movable zone doesn't have any addressing limitations so it is a
>>> bit more relaxed but considering the hotplug scenarios I have seen so
>>> far people just want to have full NUMA nodes movable to allow replacing
>>> DIMMs. And then we are back to square one and the zone imbalance issue.
>>> You have those regardless where memmaps are allocated from.
>>
>> Unfortunately yes. And things get more complicated as you are adding a
>> whole DIMMs and get notifications in the granularity of memory blocks.
>> Usually you are not interested in onlining any memory block of that DIMM
>> as MOVABLE as soon as you would have to online one memory block of that
>> DIMM as NORMAL - because that can already block the whole DIMM.
> 
> For the purpose of the hotremove, yes. But as Dave has noted people are
> (ab)using zone movable for other purposes - e.g. large pages.

That might be right for some very special use cases. For most of users
this is not the case (meaning it should be the default but if the user
wants to change it, he should be allowed to change it).

>  
> [...]
>>> Then the immediate question would be why to use memory hotplug for that
>>> at all? Why don't you simply start with a huge pre-allocated physical
>>> address space and balloon memory in an out per demand. Why do you want
>>> to inject new memory during the runtime?
>>
>> Let's assume you have a guest with 20GB size and eventually want to
>> allow to grow it to 4TB. You would have to allocate metadata for 4TB
>> right from the beginning. That's definitely now what we want. That is
>> why memory hotplug is used by e.g. XEN or Hyper-V. With Hyper-V, the
>> hypervisor even tells you at which places additional memory has been
>> made available.
> 
> Then you have to live with the fact that your hot added memory will be
> self hosted and find a way for ballooning to work with that. The price
> would be that some part of the memory is not really balloonable in the
> end.
> 
>>>> 1. is a reason why distributions usually don't configure
>>>> "MEMORY_HOTPLUG_DEFAULT_ONLINE", because you really want the option for
>>>> MOVABLE zone. That however implies, that e.g. for x86, you have to
>>>> handle all new memory in user space, especially also HyperV memory.
>>>> There, you then have to check for things like "isHyperV()" to decide
>>>> "oh, yes, this should definitely not go to the MOVABLE zone".
>>>
>>> Why do you need a generic hotplug rule in the first place? Why don't you
>>> simply provide different set of rules for different usecases? Let users
>>> decide which usecase they prefer rather than try to be clever which
>>> almost always hits weird corner cases.
>>>
>>
>> Memory hotplug has to work as reliable as we can out of the box. Letting
>> the user make simple decisions like "oh, I am on hyper-V, I want to
>> online memory to the normal zone" does not feel right.
> 
> Users usually know what is their usecase and then it is just a matter of
> plumbing (e.g. distribution can provide proper tools to deploy those
> usecases) to chose the right and for user obscure way to make it work.

I disagree. If we can ship sane defaults, we should do that and allow to
make changes later on. This is how distributions have been working for
ever. But yes, allowing to make modifications is always a good idea to
tailor it to some special case user scenarios. (tuned or whatever we
have in place).

> 
>> But yes, we
>> should definitely allow to make modifications. So some sane default rule
>> + possible modification is usually a good idea.
>>
>> I think Dave has a point with using MOVABLE for huge page use cases. And
>> there might be other corner cases as you correctly state.
>>
>> I wonder if this patch itself minus modifying online/offline might make
>> sense. We can then implement simple rules in user space
>>
>> if (normal) {
>> 	/* customers expect hotplugged DIMMs to be unpluggable */
>> 	online_movable();
>> } else if (paravirt) {
>> 	/* paravirt memory should as default always go to the NORMAL */
>> 	online();
>> } else {
>> 	/* standby memory will never get onlined automatically */
>> }
>>
>> Compared to having to guess what is to be done (isKVM(), isHyperV,
>> isS390 ...) and failing once this is no longer unique (e.g. virtio-mem
>> and ACPI support for x86 KVM).
> 
> I am worried that exporing a type will just push us even further to the
> corner. The current design is really simple and 2 stage and that is good
> because it allows for very different usecases. The more specific the API
> be the more likely we are going to hit "I haven't even dreamed somebody
> would be using hotplug for this thing". And I would bet this will happen
> sooner or later.

Exposing the type of memory is in my point of view just forwarding facts
to user space. We should not export arbitrary information, that is true.

> 
> Just look at how the whole auto onlining screwed the API to workaround
> an implementation detail. It has created a one purpose behavior that
> doesn't suite many usecases. Yet we have to live with that because
> somebody really relies on it. Let's not repeat same errors.
> 

Let me rephrase: You state that user space has to make the decision and
that user should be able to set/reconfigure rules. That is perfectly fine.

But then we should give user space access to sufficient information to
make a decision. This might be the type of memory as we learned (what
some part of this patch proposes), but maybe later more, e.g. to which
physical device memory belongs (e.g. to hotplug it all movable or all
normal) ...

-- 

Thanks,

David / dhildenb
