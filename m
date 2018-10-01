Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 558956B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 05:34:42 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d1-v6so13219607qth.21
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 02:34:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h13-v6si510473qkg.356.2018.10.01.02.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 02:34:41 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
Date: Mon, 1 Oct 2018 11:34:25 +0200
MIME-Version: 1.0
In-Reply-To: <20181001084038.GD18290@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On 01/10/2018 10:40, Michal Hocko wrote:
> On Fri 28-09-18 17:03:57, David Hildenbrand wrote:
> [...]
> 
> I haven't read the patch itself but I just wanted to note one thing
> about this part
> 
>> For paravirtualized devices it is relevant that memory is onlined as
>> quickly as possible after adding - and that it is added to the NORMAL
>> zone. Otherwise, it could happen that too much memory in a row is added
>> (but not onlined), resulting in out-of-memory conditions due to the
>> additional memory for "struct pages" and friends. MOVABLE zone as well
>> as delays might be very problematic and lead to crashes (e.g. zone
>> imbalance).
> 
> I have proposed (but haven't finished this due to other stuff) a
> solution for this. Newly added memory can host memmaps itself and then
> you do not have the problem in the first place. For vmemmap it would
> have an advantage that you do not really have to beg for 2MB pages to
> back the whole section but you would get it for free because the initial
> part of the section is by definition properly aligned and unused.

So the plan is to "host metadata for new memory on the memory itself".
Just want to note that this is basically impossible for s390x with the
current mechanisms. (added memory is dead, until onlining notifies the
hypervisor and memory is allocated). It will also be problematic for
paravirtualized memory devices (e.g. XEN's "not backed by the
hypervisor" hacks).

This would only be possible for memory DIMMs, memory that is completely
accessible as far as I can see. Or at least, some specified "first part"
is accessible.

Other problems are other metadata like extended struct pages and friends.

(I really like the idea of adding memory without allocating memory in
the hypervisor in the first place, please keep me tuned).

And please note: This solves some problematic part ("adding too much
memory to the movable zone or not onlining it"), but not the issue of
zone imbalance in the first place. And not one issue I try to tackle
here: don't add paravirtualized memory to the movable zone.

> 
> I yet have to think about the whole proposal but I am missing the most
> important part. _Who_ is going to use the new exported information and
> for what purpose. You said that distributions have hard time to
> distinguish different types of onlinining policies but isn't this
> something that is inherently usecase specific?
> 

Let's think about a distribution. We have a clash of use cases here
(just what you describe). What I propose solves one part of it ("handle
what you know how to handle right in the kernel").

1. Users of DIMMs usually expect that they can be unplugged again. That
is why you want to control how to online memory in user space (== add it
to the movable zone).

2. Users of standby memory (s390) expect that memory will never be
onlined automatically. It will be onlined manually.

3. Users of paravirtualized devices (esp. Hyper-V) don't care about
memory unplug in the sense of MOVABLE at all. They (or Hyper-V!) will
add a whole bunch of memory and expect that everything works fine. So
that memory is onlined immediately and that memory is added to the
NORMAL zone. Users never want the MOVABLE zone.

1. is a reason why distributions usually don't configure
"MEMORY_HOTPLUG_DEFAULT_ONLINE", because you really want the option for
MOVABLE zone. That however implies, that e.g. for x86, you have to
handle all new memory in user space, especially also HyperV memory.
There, you then have to check for things like "isHyperV()" to decide
"oh, yes, this should definitely not go to the MOVABLE zone".

As you know, I am working on virtio-mem, which can basically be combined
with 1 or 2. And user space has no idea about the difference between
added memory blocks. Was it memory from a DIMM (== ZONE_MOVABLE)? Was it
memory from a paravirtualized device (== ZONE_NORMAL)? Was it standby
memory? (don't online)


That part, I try to solve with this interface.

To answer your question: User space will only care about "normal" memory
and then decide how to online it (for now, usually MOVABLE, because
that's what customers expect with DIMMs). The use case of DIMMS, we
don't know and therefore we can't expose. The use case of the other
cases, we know exactly already in the kernel.

Existing user space hacks will continue to work but can be replaces by a
new check against "normal" memory block types.

Thanks for looking into this!

-- 

Thanks,

David / dhildenb
