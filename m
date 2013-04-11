Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 9457D6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 14:42:09 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e50so898982eek.30
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:42:08 -0700 (PDT)
Date: Thu, 11 Apr 2013 14:38:29 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
Message-ID: <20130411183828.GA6696@gmail.com>
References: <5114DF05.7070702@mellanox.com>
 <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com>
 <CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com>
 <5163D119.80603@gmail.com>
 <20130409142156.GA1909@gmail.com>
 <5164C365.70302@gmail.com>
 <20130410204507.GA3958@gmail.com>
 <5166310D.4020100@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5166310D.4020100@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

On Thu, Apr 11, 2013 at 11:42:05AM +0800, Simon Jeons wrote:
> Hi Jerome,
> On 04/11/2013 04:45 AM, Jerome Glisse wrote:
> >On Wed, Apr 10, 2013 at 09:41:57AM +0800, Simon Jeons wrote:
> >>Hi Jerome,
> >>On 04/09/2013 10:21 PM, Jerome Glisse wrote:
> >>>On Tue, Apr 09, 2013 at 04:28:09PM +0800, Simon Jeons wrote:
> >>>>Hi Jerome,
> >>>>On 02/10/2013 12:29 AM, Jerome Glisse wrote:
> >>>>>On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse <walken@google.com> wrote:
> >>>>>>On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel <raindel@mellanox.com> wrote:
> >>>>>>>Hi,
> >>>>>>>
> >>>>>>>We would like to present a reference implementation for safely sharing
> >>>>>>>memory pages from user space with the hardware, without pinning.
> >>>>>>>
> >>>>>>>We will be happy to hear the community feedback on our prototype
> >>>>>>>implementation, and suggestions for future improvements.
> >>>>>>>
> >>>>>>>We would also like to discuss adding features to the core MM subsystem to
> >>>>>>>assist hardware access to user memory without pinning.
> >>>>>>This sounds kinda scary TBH; however I do understand the need for such
> >>>>>>technology.
> >>>>>>
> >>>>>>I think one issue is that many MM developers are insufficiently aware
> >>>>>>of such developments; having a technology presentation would probably
> >>>>>>help there; but traditionally LSF/MM sessions are more interactive
> >>>>>>between developers who are already quite familiar with the technology.
> >>>>>>I think it would help if you could send in advance a detailed
> >>>>>>presentation of the problem and the proposed solutions (and then what
> >>>>>>they require of the MM layer) so people can be better prepared.
> >>>>>>
> >>>>>>And first I'd like to ask, aren't IOMMUs supposed to already largely
> >>>>>>solve this problem ? (probably a dumb question, but that just tells
> >>>>>>you how much you need to explain :)
> >>>>>For GPU the motivation is three fold. With the advance of GPU compute
> >>>>>and also with newer graphic program we see a massive increase in GPU
> >>>>>memory consumption. We easily can reach buffer that are bigger than
> >>>>>1gbytes. So the first motivation is to directly use the memory the
> >>>>>user allocated through malloc in the GPU this avoid copying 1gbytes of
> >>>>>data with the cpu to the gpu buffer. The second and mostly important
> >>>>>to GPU compute is the use of GPU seamlessly with the CPU, in order to
> >>>>>achieve this you want the programmer to have a single address space on
> >>>>>the CPU and GPU. So that the same address point to the same object on
> >>>>>GPU as on the CPU. This would also be a tremendous cleaner design from
> >>>>>driver point of view toward memory management.
> >>>>>
> >>>>>And last, the most important, with such big buffer (>1gbytes) the
> >>>>>memory pinning is becoming way to expensive and also drastically
> >>>>>reduce the freedom of the mm to free page for other process. Most of
> >>>>>the time a small window (every thing is relative the window can be >
> >>>>>100mbytes not so small :)) of the object will be in use by the
> >>>>>hardware. The hardware pagefault support would avoid the necessity to
> >>>>What's the meaning of hardware pagefault?
> >>>It's a PCIE extension (well it's a combination of extension that allow
> >>>that see http://www.pcisig.com/specifications/iov/ats/). Idea is that the
> >>>iommu can trigger a regular pagefault inside a process address space on
> >>>behalf of the hardware. The only iommu supporting that right now is the
> >>>AMD iommu v2 that you find on recent AMD platform.
> >>Why need hardware page fault? regular page fault is trigger by cpu
> >>mmu, correct?
> >Well here i abuse regular page fault term. Idea is that with hardware page
> >fault you don't need to pin memory or take reference on page for hardware to
> >use it. So that kernel can free as usual page that would otherwise have been
> 
> For the case when GPU need to pin memory, why GPU need grap the
> memory of normal process instead of allocating for itself?

Pin memory is today world where gpu allocate its own memory (GB of memory)
that disappear from kernel control ie kernel can no longer reclaim this
memory it's lost memory (i had complain about that already from user than
saw GB of memory vanish and couldn't understand why the GPU was using so
much).

Tomorrow world we want gpu to be able to access memory that the application
allocated through a simple malloc and we want the kernel to be able to
recycly any page at any time because of memory pressure or because kernel
decide to do so.

That's just what we want to do. To achieve so we are getting hw that can do
pagefault. No change to kernel core mm code (some improvement might be made).

> 
> >pinned. If GPU is really using them it will trigger a fault through the iommu
> >driver that call get_user_pages (which can end up calling handle_mm_fault like
> >a regular page fault that happened on the CPU).
> 
> This time normal process can't use this page, correct? So GPU and
> normal process both have their own pages?

No, tomorrow world, gpu and cpu both using same page in same address space at
the same time. Just like two cpu core each running a different thread of
the same process would. Just consider the gpu as a new cpu core working in same
address space using the same memory all at the same time as cpu.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
