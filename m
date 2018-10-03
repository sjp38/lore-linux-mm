Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A82446B0008
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 10:34:23 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v14-v6so5136376qkg.8
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 07:34:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i11-v6si1001029qvb.29.2018.10.03.07.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 07:34:22 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
In-Reply-To: <49456818-238e-2d95-9df6-d1934e9c8b53@linux.intel.com>
References: <20180928150357.12942-1-david@redhat.com> <20181001084038.GD18290@dhcp22.suse.cz> <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com> <20181002134734.GT18290@dhcp22.suse.cz> <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com> <8736tndubn.fsf@vitty.brq.redhat.com> <20181003134444.GH4714@dhcp22.suse.cz> <87zhvvcf3b.fsf@vitty.brq.redhat.com> <49456818-238e-2d95-9df6-d1934e9c8b53@linux.intel.com>
Date: Wed, 03 Oct 2018 16:34:03 +0200
Message-ID: <87tvm3cd5w.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Pavel Tatashin <pavel.tatashin@microsoft.com>, Paul Mackerras <paulus@samba.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Rashmica Gupta <rashmica.g@gmail.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-s390@vger.kernel.org, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Rob Herring <robh@kernel.org>, Len Brown <lenb@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, Dan Williams <dan.j.williams@intel.com>, Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Joe Perches <joe@perches.com>, =?utf-8?B?SsOpcsO0?= =?utf-8?B?bWU=?= Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Philippe Ombredanne <pombredanne@nexb.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> On 10/03/2018 06:52 AM, Vitaly Kuznetsov wrote:
>> It is more than just memmaps (e.g. forking udev process doing memory
>> onlining also needs memory) but yes, the main idea is to make the
>> onlining synchronous with hotplug.
>
> That's a good theoretical concern.
>
> But, is it a problem we need to solve in practice?

Yes, unfortunately. It was previously discovered that when we try to
hotplug tons of memory to a low memory system (this is a common scenario
with VMs) we end up with OOM because for all new memory blocks we need
to allocate page tables, struct pages, ... and we need memory to do
that. The userspace program doing memory onlining also needs memory to
run and in case it prefers to fork to handle hundreds of notfifications
... well, it may get OOMkilled before it manages to online anything.

Allocating all kernel objects from the newly hotplugged blocks would
definitely help to manage the situation but as I said this won't solve
the 'forking udev' problem completely (it will likely remain in
'extreme' cases only. We can probably work around it by onlining with a
dedicated process which doesn't do memory allocation).

-- 
Vitaly
