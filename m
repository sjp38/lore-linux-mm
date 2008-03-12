From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/7] [rfc] VM_MIXEDMAP, pte_special, xip work
Date: Wed, 12 Mar 2008 16:33:34 +1100
References: <20080311104653.995564000@nick.local0.net> <20080311213525.a5994894.akpm@linux-foundation.org>
In-Reply-To: <20080311213525.a5994894.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200803121633.34539.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@nick.local0.net, Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 12 March 2008 15:35, Andrew Morton wrote:
> On Tue, 11 Mar 2008 21:46:53 +1100 npiggin@nick.local0.net wrote:
> > --
> >
> > (doh, please ignore the previous "x/6" patches, they're old. The
> > new ones are these x/7 set)
> >
> > Hi,
> >
> > I'm sorry for neglecting these patches for a few weeks :(
> >
> > I'd like to still get them into -mm and aim for the next merge window --
> > they've been gradually getting a pretty reasonable amount of review and
> > testing. I think the implementation of the pte_special path in
> > vm_normal_page and vm_insert_mixed was the only point left unresolved
> > since last time.
> >
> > I've included the dual kaddr/pfn API that we worked out with Jared, but
> > he hasn't yet tested my patch rollup... so this is an RFC only. If we all
> > agree on it, then I'll rebase to -mm and submit.
>
> umm, could we have some executive summary about what this is all supposed
> to achieve?  I can see what each patch does, but what's the overall result?

The overall result is that:
1. We now support XIP backed filesystems using memory that have no
   struct page allocated to them. And patches 6 and 7 actually implement
   this for s390.

   This is pretty important in a number of cases. As far as I understand,
   in the case of virtualisation (eg. s390), each guest may mount a
   readonly copy of the same filesystem (eg. the distro). Currently,
   guests need to allocate struct pages for this image. So if you have
   100 guests, you already need to allocate more memory for the struct
   pages than the size of the image. I think. (Carsten?)

   For other (eg. embedded) systems, you may have a very large non-
   volatile filesystem. If you have to have struct pages for this, then
   your RAM consumption will go up proportionally to fs size. Even
   though it is just a small proportion, RAM can be much more costly
   eg in terms of power.

2. VM_MIXEDMAP allows us to support mappings where you actually do want
   to refcount _some_ pages in the mapping, but not others. I haven't
   actually seen his code, but I understand Jared requires this for his
   filesystem that can migrate pages between RAM and XIP/NVRAM
   transparently. Obviously the filesystem isn't finished yet, but
   Jared is relying on these changes for it to work.

3. pte_special also has a peripheral usage that I need for my lockless
   get_user_pages patch. That was shown to speed up "oltp" on db2 by
   10% on a 2 socket system, which is kind of significant because they
   scrounge for months to try to find 0.1% improvement on these
   workloads. I'm hoping we might finally be faster than AIX on
   pSeries with that patch. This is not meant to justify the whole
   patchset of course, but just to show that pte_special is not some
   s390 specific thing that should be hidden in arch code or xip code:
   I want to use it on x86 and powerpc as well, and in that case I
   need to use it for VM_PFNMAP not only VM_MIXEDMAP.


> [1/7] says:
> > VM_MIXEDMAP achieves this by refcounting all pfn_valid pages, and not
> > refcounting !pfn_valid pages (which is not an option for VM_PFNMAP,
> > because it needs to avoid refcounting pfn_valid pages eg. for /dev/mem
> > mappings).
>
> I have this vague feeling that pfn_valid() isn't reliable - it can
> sometimes lie, and that making it truthful was considered too expensive.
>
> But maybe I'm thinking of something else?

As far as I'm aware, if pfn_valid is true, then we can refcount the page.
This is the condition used by the page allocator to initialize the page
arrays, and should be the case if we're using one of the standard memory
models.

s390 is slightly different because it doesn't use a standard memory model
but something more dynamic. It doesn't quite do the right thing here, so
it uses pte_special. It could possibly tighten up pfn_valid, however I
think there are various reasons why they don't want to (one is that they
need to take a global lock in order to search their list of extents;
which will suck for VM_MIXEDMAP performance).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
