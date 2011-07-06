Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C27FA9000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 05:01:49 -0400 (EDT)
Received: by vxg38 with SMTP id 38so6969816vxg.14
        for <linux-mm@kvack.org>; Wed, 06 Jul 2011 02:01:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLHQP=-srK_uYYBsPb7+rUBnPZG7bzwtCd-rRaQa4ikUFg@mail.gmail.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	<20110629130038.GA7909@in.ibm.com>
	<CAOJsxLHQP=-srK_uYYBsPb7+rUBnPZG7bzwtCd-rRaQa4ikUFg@mail.gmail.com>
Date: Wed, 6 Jul 2011 12:01:45 +0300
Message-ID: <CAOJsxLF0me+=Rk8RnxNS=9=_pmwwAntu1c930F6ySEUD2zZkGw@mail.gmail.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory Power Management
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Lameter <cl@linux.com>

On Wed, Jul 6, 2011 at 11:45 AM, Pekka Enberg <penberg@kernel.org> wrote:
> Hi Ankita,
>
> [ I don't really know anything about memory power management but
> =A0here's my two cents since you asked for it. ]
>
> On Wed, Jun 29, 2011 at 4:00 PM, Ankita Garg <ankita@in.ibm.com> wrote:
>> I) Dynamic Power Transition
>>
>> The goal here is to ensure that as much as possible, on an idle system,
>> the memory references do not get spread across the entire RAM, a problem
>> similar to memory fragmentation. The proposed approach is as below:
>>
>> 1) One of the first things is to ensure that the memory allocations do
>> not spill over to more number of regions. Thus the allocator needs to
>> be aware of the address boundary of the different regions.
>
> Why does the allocator need to know about address boundaries? Why
> isn't it enough to make the page allocator and reclaim policies favor usi=
ng
> memory from lower addresses as aggressively as possible? That'd mean
> we'd favor the first memory banks and could keep the remaining ones
> powered off as much as possible.
>
> IOW, why do we need to support scenarios such as this:
>
> =A0 bank 0 =A0 =A0 bank 1 =A0 bank 2 =A0 =A0bank3
> =A0| online =A0| offline | online =A0| offline |
>
> instead of using memory compaction and possibly something like the
> SLUB defragmentation patches to turn the memory map into this:
>
> =A0 bank 0 =A0 =A0 bank 1 =A0 bank 2 =A0 bank3
> =A0| online =A0| online =A0| offline | offline |
>
>> 2) At the time of allocation, before spilling over allocations to the
>> next logical region, the allocator needs to make a best attempt to
>> reclaim some memory from within the existing region itself first. The
>> reclaim here needs to be in LRU order within the region. =A0However, if
>> it is ascertained that the reclaim would take a lot of time, like there
>> are quite a fe write-backs needed, then we can spill over to the next
>> memory region (just like our NUMA node allocation policy now).
>
> I think a much more important question is what happens _after_ we've
> allocated and free'd tons of memory few times. AFAICT, memory
> regions don't help with that kind of fragmentation that will eventually
> happen anyway.

Btw, I'd also decouple the 'memory map' required for PASR from
memory region data structure and use page allocator hooks for letting
the PASR driver know about allocated and unallocated memory. That
way the PASR driver could automatically detect if full banks are
unused and power them off. That'd make memory power management
transparent to the VM regardless of whether we're using hardware or
software poweroff.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
