Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6FF6B4285
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:59:28 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n39so16674235qtn.18
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:59:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j7si578069qkb.6.2018.11.26.07.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 07:59:27 -0800 (PST)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <b01a956b-080c-c643-6473-eb132b9f7200@redhat.com>
 <20181123190653.6da91461@kitsune.suse.cz>
 <fad04d80-4e72-1bd8-3e67-a3f7dd0bc2fa@redhat.com>
 <b64a0e1e-6aaa-66a9-2fb7-12daa6383ce1@redhat.com>
 <20181126152015.7464c786@naga>
From: David Hildenbrand <david@redhat.com>
Message-ID: <2d05e5d1-c5b5-8884-e642-89421685052f@redhat.com>
Date: Mon, 26 Nov 2018 16:59:14 +0100
MIME-Version: 1.0
In-Reply-To: <20181126152015.7464c786@naga>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Michal_Such=c3=a1nek?= <msuchanek@suse.de>
Cc: Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Rashmica Gupta <rashmica.g@gmail.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Dan Williams <dan.j.williams@intel.com>, linux-s390@vger.kernel.org, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Len Brown <lenb@kernel.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Joe Perches <joe@perches.com>, devel@linuxdriverproject.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 26.11.18 15:20, Michal Suchánek wrote:
> On Mon, 26 Nov 2018 14:33:29 +0100
> David Hildenbrand <david@redhat.com> wrote:
> 
>> On 26.11.18 13:30, David Hildenbrand wrote:
>>> On 23.11.18 19:06, Michal Suchánek wrote:  
> 
>>>>
>>>> If we are going to fake the driver information we may as well add the
>>>> type attribute and be done with it.
>>>>
>>>> I think the problem with the patch was more with the semantic than the
>>>> attribute itself.
>>>>
>>>> What is normal, paravirtualized, and standby memory?
>>>>
>>>> I can understand DIMM device, baloon device, or whatever mechanism for
>>>> adding memory you might have.
>>>>
>>>> I can understand "memory designated as standby by the cluster
>>>> administrator".
>>>>
>>>> However, DIMM vs baloon is orthogonal to standby and should not be
>>>> conflated into one property.
>>>>
>>>> paravirtualized means nothing at all in relationship to memory type and
>>>> the desired online policy to me.  
>>>
>>> Right, so with whatever we come up, it should allow to make a decision
>>> in user space about
>>> - if memory is to be onlined automatically  
>>
>> And I will think about if we really should model standby memory. Maybe
>> it is really better to have in user space something like (as Dan noted)
> 
> If it is possible to designate the memory as standby or online in the
> s390 admin interface and the kernel does have access to this
> information it makes sense to forward it to userspace (as separate
> s390-specific property). If not then you need to make some kind of
> assumption like below and the user can tune the script according to
> their usecase.

Also true, standby memory really represents a distinct type of memory
block (memory seems to be there but really isn't). Right now I am
thinking about something like this (tried to formulate it on a very
generic level because we can't predict which mechanism might want to
make use of these types in the future).


/*
 * Memory block types allow user space to formulate rules if and how to
 * online memory blocks. The types are exposed to user space as text
 * strings in sysfs. While the typical online strategies are described
 * along with the types, there are use cases where that can differ (e.g.
 * use MOVABLE zone for more reliable huge page usage, use NORMAL zone
 * due to zone imbalance or because memory unplug is not intended).
 *
 * MEMORY_BLOCK_NONE:
 *  No memory block is to be created (e.g. device memory). Used internally
 *  only.
 *
 * MEMORY_BLOCK_REMOVABLE:
 *  This memory block type should be treated as if it can be
 *  removed/unplugged from the system again. E.g. there is a hardware
 *  interface to unplug such memory. This memory block type is usually
 *  onlined to the MOVABLE zone, to e.g. make offlining of it more
 *  reliable. Examples include ACPI and PPC DIMMs.
 *
 * MEMORY_BLOCK_UNREMOVABLE:
 *  This memory block type should be treated as if it can not be
 *  removed/unplugged again. E.g. there is no hardware interface to
 *  unplug such memory. This memory block type is usually onlined to
 *  the NORMAL zone, as offlining is not beneficial. Examples include boot
 *  memory on most architectures and memory added via balloon devices.
 *
 * MEMORY_BLOCK_STANDBY:
 *  The memory block type should be treated as if it can be
 *  removed/unplugged again, however the actual memory hot(un)plug is
 *  performed by onlining/offlining. In virtual environments, such memory
 *  is usually added during boot and never removed. Onlining memory will
 *  result in memory getting allocated to a VM. This memory type is usually
 *  not onlined automatically but explicitly by the administrator. One
 *  example is standby memory on s390x.
 */

> 
>>
>> if (isS390x() && type == "dimm") {
>> 	/* don't online, on s390x system DIMMs are standby memory */
>> }
> 
> Thanks
> 
> Michal
> 


-- 

Thanks,

David / dhildenb
