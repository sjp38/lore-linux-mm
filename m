Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CE8208D003B
	for <linux-mm@kvack.org>; Sat, 23 Apr 2011 09:08:26 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1364965bwz.14
        for <linux-mm@kvack.org>; Sat, 23 Apr 2011 06:08:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTim_A-r4Khdx20tLKFU8ybtB+=wcyg@mail.gmail.com>
References: <BANLkTi=6T8SxqnsXTY5ceyikg2NTKLVSKw@mail.gmail.com>
	<BANLkTimN4vbAPJVKgH8iTZy7B5Fr8B+ibA@mail.gmail.com>
	<BANLkTikSRStQO6cyE+L2vHHe0TnkoBe8=A@mail.gmail.com>
	<BANLkTim_A-r4Khdx20tLKFU8ybtB+=wcyg@mail.gmail.com>
Date: Sat, 23 Apr 2011 15:08:23 +0200
Message-ID: <BANLkTin4=QFyQUT95d7eoXXrdkNJc=T9Tw@mail.gmail.com>
Subject: Re: Fix for SLUB? (was: Fwd: [PATCH v3] mm: make expand_downwards
 symmetrical to expand_upwards)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Schmitz <schmitzmic@googlemail.com>
Cc: Thorsten Glaser <tg@mirbsd.de>, Linux/m68k <linux-m68k@vger.kernel.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

[Added some CCs]

On Sat, Apr 23, 2011 at 05:47, Michael Schmitz
<schmitzmic@googlemail.com> wrote:
> Hi,
>
> node_present_pages(node) returns false:
>
> m68k_setup_node: node 0 addr 0 size 14680064
> m68k_setup_node: node 0 not present!
> m68k_setup_node: node 1 addr 16777216 size 268435456
> m68k_setup_node: node 1 not present!
>
> Changing the patch to
>
> diff --git a/arch/m68k/mm/init_mm.c b/arch/m68k/mm/init_mm.c
> --- a/arch/m68k/mm/init_mm.c
> +++ b/arch/m68k/mm/init_mm.c
> @@ -59,6 +59,7 @@ void __init m68k_setup_node(int node)
> =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0#endif
> =C2=A0 =C2=A0 =C2=A0 pg_data_map[node].bdata =3D bootmem_node_data + node=
;
> + =C2=A0 =C2=A0 =C2=A0 node_set_state(node, N_NORMAL_MEMORY);
> =C2=A0 =C2=A0 =C2=A0 node_set_online(node);
> =C2=A0}
>
> i.e. ignoring the node_present_pages return value does result in a
> booting kernel even with the problematic commit included.
>
> I'll leave it to the mm experts to explain why node_present_pages
> returns zero here.
>
> Cheers,
>
> =C2=A0Michael
>
>
>
> On Sat, Apr 23, 2011 at 2:14 PM, Michael Schmitz
> <schmitzmic@googlemail.com> wrote:
>> Looks like that wasn't helping after all. I still need to revert said
>> commit. Guess I'll have to check what node_present_pages(node) returns
>> in each case ...
>>
>> Cheers,
>>
>> =C2=A0MIchael
>>
>>
>> On Sat, Apr 23, 2011 at 1:31 PM, Michael Schmitz
>> <schmitzmic@googlemail.com> wrote:
>>> I'll check this out - might well be the correct fix for our problems.
>>>
>>> Cheers,
>>>
>>> =C2=A0Michael
>>>
>>>
>>> On Thu, Apr 21, 2011 at 8:19 PM, Geert Uytterhoeven
>>> <geert@linux-m68k.org> wrote:
>>>> ---------- Forwarded message ----------
>>>> From: David Rientjes <rientjes@google.com>
>>>> Date: Thu, Apr 21, 2011 at 01:12
>>>> Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expan=
d_upwards
>>>> To: James Bottomley <James.Bottomley@hansenpartnership.com>
>>>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg
>>>> <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko
>>>> <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh
>>>> Dickins <hughd@google.com>, linux-mm@kvack.org, LKML
>>>> <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo
>>>> Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>
>>>>
>>>>
>>>> On Wed, 20 Apr 2011, James Bottomley wrote:
>>>>
>>>>> > This is probably because the parisc's DISCONTIGMEM memory ranges do=
n't
>>>>> > have bits set in N_NORMAL_MEMORY.
>>>>> >
>>>>> > diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
>>>>> > --- a/arch/parisc/mm/init.c
>>>>> > +++ b/arch/parisc/mm/init.c
>>>>> > @@ -266,8 +266,10 @@ static void __init setup_bootmem(void)
>>>>> > =C2=A0 =C2=A0 }
>>>>> > =C2=A0 =C2=A0 memset(pfnnid_map, 0xff, sizeof(pfnnid_map));
>>>>> >
>>>>> > - =C2=A0 for (i =3D 0; i < npmem_ranges; i++)
>>>>> > + =C2=A0 for (i =3D 0; i < npmem_ranges; i++) {
>>>>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 node_set_state(i, N_NORMAL_MEM=
ORY);
>>>>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 node_set_online(i);
>>>>> > + =C2=A0 }
>>>>> > =C2=A0#endif
>>>>>
>>>>> Yes, this seems to be the missing piece that gets it to boot. =C2=A0W=
e really
>>>>> need this in generic code, unless someone wants to run through all th=
e
>>>>> other arch's doing it ...
>>>>>
>>>>
>>>> Looking at all other architectures that allow ARCH_DISCONTIGMEM_ENABLE=
, we
>>>> already know x86 is fine, avr32 disables ARCH_DISCONTIGMEM_ENABLE enti=
rely
>>>> because its code only brings online node 0, and tile already sets the =
bit
>>>> in N_NORMAL_MEMORY correctly when bringing a node online, probably bec=
ause
>>>> it was introduced after the various node state masks were added in
>>>> 7ea1530ab3fd back in October 2007.
>>>>
>>>> So we're really only talking about alpha, ia64, m32r, m68k, and mips a=
nd
>>>> it only seems to matter when using CONFIG_SLUB, which isn't surprising
>>>> when greping for it:
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0$ grep -r N_NORMAL_MEMORY mm/*
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/memcontrol.c: =C2=A0 =C2=A0 =C2=A0 =C2=
=A0if (!node_state(node, N_NORMAL_MEMORY))
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/memcontrol.c: =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!node_state(node, N_NORMAL_MEMORY))
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/page_alloc.c: =C2=A0 =C2=A0 =C2=A0 =C2=
=A0[N_NORMAL_MEMORY] =3D { { [0] =3D 1UL } },
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/page_alloc.c:
>>>> node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0for_each_node_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0for_each_node_state(node, N_NORMAL_MEMORY) {
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm/slub.c: =C2=A0 =C2=A0 =C2=A0for_each_nod=
e_state(node, N_NORMAL_MEMORY)
>>>>
>>>> Those memory controller occurrences only result in it passing a node i=
d of
>>>> -1 to kmalloc_node() which means no specific node target, and that's f=
ine
>>>> for DISCONTIGMEM since we don't care about any proximity between memor=
y
>>>> ranges.
>>>>
>>>> This should fix the remaining architectures so they can use CONFIG_SLU=
B,
>>>> but I hope it can be tested by the individual arch maintainers like yo=
u
>>>> did for parisc.
>>>>
>>>> diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
>>>> --- a/arch/alpha/mm/numa.c
>>>> +++ b/arch/alpha/mm/numa.c
>>>> @@ -245,6 +245,7 @@ setup_memory_node(int nid, void *kernel_end)
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0bootmap_size, BOOTMEM_DEFAULT);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(" reserving pages %ld:%ld\n", bootma=
p_start,
>>>> bootmap_start+PFN_UP(bootmap_size));
>>>>
>>>> + =C2=A0 =C2=A0 =C2=A0 node_set_state(nid, N_NORMAL_MEMORY);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0node_set_online(nid);
>>>> =C2=A0}
>>>>
>>>> diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
>>>> --- a/arch/ia64/mm/discontig.c
>>>> +++ b/arch/ia64/mm/discontig.c
>>>> @@ -573,6 +573,8 @@ void __init find_memory(void)
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0map>>PAGE_SHIFT,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bdp->node_min_pfn,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bdp->node_low_pfn);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (node_present_pa=
ges(node))
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 node_set_state(node, N_NORMAL_MEMORY);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0efi_memmap_walk(filter_rsvd_memory, free_no=
de_bootmem);
>>>> diff --git a/arch/m32r/kernel/setup.c b/arch/m32r/kernel/setup.c
>>>> --- a/arch/m32r/kernel/setup.c
>>>> +++ b/arch/m32r/kernel/setup.c
>>>> @@ -247,7 +247,9 @@ void __init setup_arch(char **cmdline_p)
>>>>
>>>> =C2=A0#ifdef CONFIG_DISCONTIGMEM
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nodes_clear(node_online_map);
>>>> + =C2=A0 =C2=A0 =C2=A0 node_set_state(0, N_NORMAL_MEMORY); =C2=A0 =C2=
=A0 /* always has memory */
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0node_set_online(0);
>>>> + =C2=A0 =C2=A0 =C2=A0 node_set_state(1, N_NORMAL_MEMORY); =C2=A0 =C2=
=A0 /* always has memory */
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0node_set_online(1);
>>>> =C2=A0#endif /* CONFIG_DISCONTIGMEM */
>>>>
>>>> diff --git a/arch/m68k/mm/init_mm.c b/arch/m68k/mm/init_mm.c
>>>> --- a/arch/m68k/mm/init_mm.c
>>>> +++ b/arch/m68k/mm/init_mm.c
>>>> @@ -59,6 +59,8 @@ void __init m68k_setup_node(int node)
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>>> =C2=A0#endif
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0pg_data_map[node].bdata =3D bootmem_node_da=
ta + node;
>>>> + =C2=A0 =C2=A0 =C2=A0 if (node_present_pages(node))
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 node_set_state(node=
, N_NORMAL_MEMORY);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0node_set_online(node);
>>>> =C2=A0}
>>>>
>>>> diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip2=
7-memory.c
>>>> --- a/arch/mips/sgi-ip27/ip27-memory.c
>>>> +++ b/arch/mips/sgi-ip27/ip27-memory.c
>>>> @@ -471,6 +471,8 @@ void __init paging_init(void)
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (end_pfn > m=
ax_low_pfn)
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0max_low_pfn =3D end_pfn;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (end_pfn > start=
_pfn)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 node_set_state(node, N_NORMAL_MEMORY);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0zones_size[ZONE_NORMAL] =3D max_low_pfn;
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_area_init_nodes(zones_size);

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
