Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D04136B007E
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 00:17:44 -0500 (EST)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id o255HeYP001129
	for <linux-mm@kvack.org>; Fri, 5 Mar 2010 05:17:41 GMT
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by spaceape12.eur.corp.google.com with ESMTP id o255Hasb030802
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 21:17:37 -0800
Received: by pwi1 with SMTP id 1so94415pwi.26
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 21:17:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100305032106.GA12065@cmpxchg.org>
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com>
	<20100305032106.GA12065@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 4 Mar 2010 21:17:16 -0800
Message-ID: <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 4, 2010 at 7:21 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, Mar 04, 2010 at 01:21:41PM -0800, Greg Thelen wrote:
>> On several systems I am seeing a boot panic if I use mmotm
>> (stamp-2010-03-02-18-38). =A0If I remove
>> bootmem-avoid-dma32-zone-by-default.patch then no panic is seen. =A0I
>> find that:
>> * 2.6.33 boots fine.
>> * 2.6.33 + mmotm w/o bootmem-avoid-dma32-zone-by-default.patch: boots fi=
ne.
>> * 2.6.33 + mmotm (including
>> bootmem-avoid-dma32-zone-by-default.patch): panics.
>> Here's the panic seen with earlyprintk using 2.6.33 + mmotm:
>> [ =A0 =A00.000000] =A0modified: 0000000000000000 - 0000000000010000 (res=
erved)
>> [ =A0 =A00.000000] =A0modified: 0000000000010000 - 000000000009fc00 (usa=
ble)
>> [ =A0 =A00.000000] =A0modified: 000000000009fc00 - 00000000000a0000 (res=
erved)
>> [ =A0 =A00.000000] =A0modified: 00000000000e8000 - 0000000000100000 (res=
erved)
>> [ =A0 =A00.000000] =A0modified: 0000000000100000 - 000000000fff0000 (usa=
ble)
>> [ =A0 =A00.000000] =A0modified: 000000000fff0000 - 0000000010000000 (ACP=
I data)
>> [ =A0 =A00.000000] =A0modified: 00000000fffbd000 - 0000000100000000 (res=
erved)
>> [ =A0 =A00.000000] init_memory_mapping: 0000000000000000-000000000fff000=
0
> 256MB of memory, right?

yes, I am testing in a 256MB VM.

>> The kernel was built with 'make mrproper && make defconfig && make
>> ARCH=3Dx86_64 CONFIG=3Dsmp -j 6'. =A0This panic is seen on every attempt=
, so
>> I can provide more diagnostics.
>
> Okay, if you did defconfig and just hit enter to all questions, you
> should have SPARSEMEM_EXTREME and NO_BOOTMEM enabled.

Correct.

> This means that the 'mem_section' is an array of pointers and the followi=
ng
> happens in memory_present():
>
> =A0 =A0 =A0 =A0for_one_pfn_in_each_section() {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sparse_index_init(); /* no return value ch=
eck */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ms =3D __nr_to_section();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ms->section_mem_map) /* bang */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0...;
> =A0 =A0 =A0 =A0}
>
> where sparse_index_init(), in the SPARSEMEM_EXTREME case, will allocate
> the mem_section descriptor with bootmem. =A0If this would fail, the box
> would panic immediately earlier, but NO_BOOTMEM does not seem to get it
> right.
>
> Greg, could you retry _with_ my bootmem patch applied, but with setting
> CONFIG_NO_BOOTMEM=3Dn up front?

Note: mmotm has been recently updated to stamp-2010-03-04-18-05.  I
re-tested with 'make defconfig' to confirm the panic with this later
mmotm.

Then, as you suggested, I set CONFIG_NO_BOOTMEM=3Dn.  The system booted
fine (no panic).

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
