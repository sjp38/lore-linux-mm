Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 565B66B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 14:51:30 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id t10so905321eei.34
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:51:28 -0700 (PDT)
Date: Thu, 11 Apr 2013 14:48:06 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
Message-ID: <20130411184806.GB6696@gmail.com>
References: <5114DF05.7070702@mellanox.com>
 <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com>
 <CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com>
 <5164C6EE.7020502@gmail.com>
 <20130410205557.GB3958@gmail.com>
 <51662FFF.10103@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51662FFF.10103@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

On Thu, Apr 11, 2013 at 11:37:35AM +0800, Simon Jeons wrote:
> Hi Jerome,
> On 04/11/2013 04:55 AM, Jerome Glisse wrote:
> >On Wed, Apr 10, 2013 at 09:57:02AM +0800, Simon Jeons wrote:
> >>Hi Jerome,
> >>On 02/10/2013 12:29 AM, Jerome Glisse wrote:
> >>>On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse <walken@google.com> wrote:
> >>>>On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel <raindel@mellanox.com> wrote:
> >>>>>Hi,
> >>>>>
> >>>>>We would like to present a reference implementation for safely sharing
> >>>>>memory pages from user space with the hardware, without pinning.
> >>>>>
> >>>>>We will be happy to hear the community feedback on our prototype
> >>>>>implementation, and suggestions for future improvements.
> >>>>>
> >>>>>We would also like to discuss adding features to the core MM subsystem to
> >>>>>assist hardware access to user memory without pinning.
> >>>>This sounds kinda scary TBH; however I do understand the need for such
> >>>>technology.
> >>>>
> >>>>I think one issue is that many MM developers are insufficiently aware
> >>>>of such developments; having a technology presentation would probably
> >>>>help there; but traditionally LSF/MM sessions are more interactive
> >>>>between developers who are already quite familiar with the technology.
> >>>>I think it would help if you could send in advance a detailed
> >>>>presentation of the problem and the proposed solutions (and then what
> >>>>they require of the MM layer) so people can be better prepared.
> >>>>
> >>>>And first I'd like to ask, aren't IOMMUs supposed to already largely
> >>>>solve this problem ? (probably a dumb question, but that just tells
> >>>>you how much you need to explain :)
> >>>For GPU the motivation is three fold. With the advance of GPU compute
> >>>and also with newer graphic program we see a massive increase in GPU
> >>>memory consumption. We easily can reach buffer that are bigger than
> >>>1gbytes. So the first motivation is to directly use the memory the
> >>>user allocated through malloc in the GPU this avoid copying 1gbytes of
> >>>data with the cpu to the gpu buffer. The second and mostly important
> >>>to GPU compute is the use of GPU seamlessly with the CPU, in order to
> >>>achieve this you want the programmer to have a single address space on
> >>>the CPU and GPU. So that the same address point to the same object on
> >>>GPU as on the CPU. This would also be a tremendous cleaner design from
> >>>driver point of view toward memory management.
> >>When GPU will comsume memory?
> >>
> >>The userspace process like mplayer will have video datas and GPU
> >>will play this datas and use memory of mplayer since these video
> >>datas load in mplayer process's address space? So GPU codes will
> >>call gup to take a reference of memory? Please correct me if my
> >>understanding is wrong. ;-)
> >First target is not thing such as video decompression, however they could
> >too benefit from it given updated driver kernel API. In case of using
> >iommu hardware page fault we don't call get_user_pages (gup) those we
> >don't take a reference on the page. That's the whole point of the hardware
> >pagefault, not taking reference on the page.
> 
> mplayer process is running on normal CPU or GPU?
> chipset_integrated graphics will use normal memory and discrete
> graphics will use its own memory, correct? So the memory used by
> discrete graphics won't need gup, correct?

mplayer can decode video in software an only use the cpu. It can also use
one of the accleration API such as VDPAU. In any case mplayer is still opening
the video file allocating some memory with malloc, reading from file into
this memory eventually do some preprocessing on that memory and then
memcpy from this memory to memory allocated by the gpu driver.

No imagine a world where you don't have to memcpy so that the gpu can access
it. Even if it's doable today it's really not something you want todo, ie
gup on page and not releasing page for minutes.

There is two kind of integrated GPU, on x86 integrated GPU should be considered
as discrete GPU because BIOS steal a chunk of system ram and transform it in
fake vram. This stolen chunk is never ever under the control of the linux kernel
(from mm pov the gpu kernel driver is in charge of it).

In any case both discrete GPU and integrated GPU have their own page table or
memory controller and they map system memory in it or video memory, sometime
interleaving (at address 0x100000 64k is in vram but at address 0x10000+64k it's
system memory pointing to some pages).

So right now any time we map a normal system ram page we take a reference on it
so it does not goes away. We decided to not use gup because it will break several
kernel assumption on anonymous memory in case of GPU. But we could use gup for
short lived memory transaction like memcpy from system ram to vram (no matter if
it's fake vram or real vram).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
