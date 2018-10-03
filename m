Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38EC36B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 13:14:20 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id u129-v6so5705595qkf.15
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:14:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6-v6si1167282qtq.299.2018.10.03.10.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 10:14:19 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
 <8736tndubn.fsf@vitty.brq.redhat.com> <20181003134444.GH4714@dhcp22.suse.cz>
 <87zhvvcf3b.fsf@vitty.brq.redhat.com>
 <49456818-238e-2d95-9df6-d1934e9c8b53@linux.intel.com>
 <87tvm3cd5w.fsf@vitty.brq.redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <06a35970-e478-18f8-eae6-4022925a5192@redhat.com>
Date: Wed, 3 Oct 2018 19:14:05 +0200
MIME-Version: 1.0
In-Reply-To: <87tvm3cd5w.fsf@vitty.brq.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Pavel Tatashin <pavel.tatashin@microsoft.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Rashmica Gupta <rashmica.g@gmail.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-s390@vger.kernel.org, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Rob Herring <robh@kernel.org>, Len Brown <lenb@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Joe Perches <joe@perches.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Philippe Ombredanne <pombredanne@nexb.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 03/10/2018 16:34, Vitaly Kuznetsov wrote:
> Dave Hansen <dave.hansen@linux.intel.com> writes:
> 
>> On 10/03/2018 06:52 AM, Vitaly Kuznetsov wrote:
>>> It is more than just memmaps (e.g. forking udev process doing memory
>>> onlining also needs memory) but yes, the main idea is to make the
>>> onlining synchronous with hotplug.
>>
>> That's a good theoretical concern.
>>
>> But, is it a problem we need to solve in practice?
> 
> Yes, unfortunately. It was previously discovered that when we try to
> hotplug tons of memory to a low memory system (this is a common scenario
> with VMs) we end up with OOM because for all new memory blocks we need
> to allocate page tables, struct pages, ... and we need memory to do
> that. The userspace program doing memory onlining also needs memory to
> run and in case it prefers to fork to handle hundreds of notfifications
> ... well, it may get OOMkilled before it manages to online anything.
> 
> Allocating all kernel objects from the newly hotplugged blocks would
> definitely help to manage the situation but as I said this won't solve
> the 'forking udev' problem completely (it will likely remain in
> 'extreme' cases only. We can probably work around it by onlining with a
> dedicated process which doesn't do memory allocation).
> 

I guess the problem is even worse. We always have two phases

1. add memory - requires memory allocation
2. online memory - might require memory allocations e.g. for slab/slub

So if we just added memory but don't have sufficient memory to start a
user space process to trigger onlining, then we most likely also don't
have sufficient memory to online the memory right away (in some scenarios).

We would have to allocate all new memory for 1 and 2 from the memory to
be onlined. I guess the latter part is less trivial.

So while onlining the memory from the kernel might make things a little
more robust, we would still have the chance for OOM / onlining failing.

-- 

Thanks,

David / dhildenb
