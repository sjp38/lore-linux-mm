Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0D9CC6B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 03:05:18 -0400 (EDT)
Received: by qyk12 with SMTP id 12so4024314qyk.14
        for <linux-mm@kvack.org>; Fri, 09 Jul 2010 00:05:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTim9d3x8oMLxRLyb2EeKCAxFgsOgw2ip87LUOn7z@mail.gmail.com>
References: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
	<AANLkTik9TlLYbG4GE6TV1wF7SOXz7v7gQ1BR531HGyNx@mail.gmail.com>
	<AANLkTin8JIdtSFR-E1J8FwVR2WTivShmZrEoeJWjCd1j@mail.gmail.com>
	<AANLkTim9d3x8oMLxRLyb2EeKCAxFgsOgw2ip87LUOn7z@mail.gmail.com>
Date: Fri, 9 Jul 2010 12:35:17 +0530
Message-ID: <AANLkTil7X11whzqzsTudHQNCuFJKprTsStHVQNRgbYZD@mail.gmail.com>
Subject: Re: Need some help in understanding sparsemem.
From: naren.mehra@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks to you guys, I am now getting a grip on the sparsemem code.
While going through the code, I came across several instances of the follow=
ing:
#ifndef CONFIG_NEED_MULTIPLE_NODES
.
<some code>
.
#endif

Now, it seems like this configuration option is used in case there are
multiple nodes in a system.
But its linked/depends on NUMA/discontigmem.

It could be possible that we have multiple nodes in a UMA system.
How can sparsemem handle such cases ??


Regards,
Naren


On Wed, Jul 7, 2010 at 9:19 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Tue, Jul 6, 2010 at 7:48 PM, =A0<naren.mehra@gmail.com> wrote:
>> Thanks Kame for your elaborate response, I got a lot of pointers on
>> where to look for in the code.
>> Kim, thanks for pointing out memmap_init_zone.
>> So basically those sections which contains holes in them, the mem_map
>> in those sections skip the entry for the invalid pages (holes).
>> This happens in memmap_init_zone().
>> 1) So it means that all the sections get the initial allocation of
>> mem_map and in memmap_init_zone we decide whether or not it requires
>
> Yes. kernel allocates memmap for non-empty sections.
> Even kernel allocates memmap for section which has mixed with valid
> and invalid(ex, hole) pages. For example, bank supports 64M but system
> have 16M. Let's assume section size is 64M. In this case, section has
> hole of 48M.
>
>> any mem_map entry. Correct ??
>
> No. memmap_init_zone doesn't care about it.
> Regardless of hole, it initializes page descriptors(include struct
> page which on hole).
> But page descriptors on holes are _Reserved_ then doesn't go to the
> buddy allocator as free page. For it, free_bootmem_node marks 0x0 on
> bitmap about only _valid_ pages by bank. Afterwards,
> free_all_bootmem_core doesn't insert pages on hole into buddy by using
> bitmap. Even memmap on hole would be free on ARM by
> free_unused_memmap_node.
>
>>
>> 2) Both of you mentioned that
>>> "If a section contains both of valid pages and
>>> holes, the section itself is marked as SECTION_MARKED_PRESENT."
>>> "It just mark _bank_ which has memory with SECTION_MARKED_PRESENT.
>>> Otherwise, Hole."
>>
>> which happens in memory_present(). In memory_present() code, I am not
>> able to find anything where we are doing this classification of valid
>> section/bank ? To me it looks that memory_present marks, all the
>> sections as present and doesnt verify whether any section contains any
>> valid pages or not. Correct ??
>
> memory_present is just called on banks.
> So some sections which consists of hole don't marked "SECTION_MARKED_PRES=
ENT".
>
> I hope this help you.
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
