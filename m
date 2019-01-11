Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA4318E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:38:01 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id i12so144098ita.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:38:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor241556jal.5.2019.01.10.18.38.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:38:00 -0800 (PST)
MIME-Version: 1.0
References: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
 <20190108080538.GB4396@rapoport-lnx> <20190108090138.GB18718@MiWiFi-R3L-srv>
 <20190108154852.GC14063@rapoport-lnx> <CAFgQCTtVjwJ_Rfp8DcmzPx6uYPnOx7E_x=YjC+MQ=mx7W38HEw@mail.gmail.com>
 <20190110075652.GB32036@rapoport-lnx>
In-Reply-To: <20190110075652.GB32036@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 11 Jan 2019 10:37:49 +0800
Message-ID: <CAFgQCTtXp3gOhfzfQPnBP7wU7ABCJcyTTki689iqkVEr_A21AQ@mail.gmail.com>
Subject: Re: [PATCHv5] x86/kdump: bugfix, make the behavior of crashkernel=X
 consistent with kaslr
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On Thu, Jan 10, 2019 at 3:57 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi Pingfan,
>
> On Wed, Jan 09, 2019 at 09:02:41PM +0800, Pingfan Liu wrote:
> > On Tue, Jan 8, 2019 at 11:49 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > >
> > > On Tue, Jan 08, 2019 at 05:01:38PM +0800, Baoquan He wrote:
> > > > Hi Mike,
> > > >
> > > > On 01/08/19 at 10:05am, Mike Rapoport wrote:
> > > > > I'm not thrilled by duplicating this code (yet again).
> > > > > I liked the v3 of this patch [1] more, assuming we allow bottom-up mode to
> > > > > allocate [0, kernel_start) unconditionally.
> > > > > I'd just replace you first patch in v3 [2] with something like:
> > > >
> > > > In initmem_init(), we will restore the top-down allocation style anyway.
> > > > While reserve_crashkernel() is called after initmem_init(), it's not
> > > > appropriate to adjust memblock_find_in_range_node(), and we really want
> > > > to find region bottom up for crashkernel reservation, no matter where
> > > > kernel is loaded, better call __memblock_find_range_bottom_up().
> > > >
> > > > Create a wrapper to do the necessary handling, then call
> > > > __memblock_find_range_bottom_up() directly, looks better.
> > >
> > > What bothers me is 'the necessary handling' which is already done in
> > > several places in memblock in a similar, but yet slightly different way.
> > >
> > > memblock_find_in_range() and memblock_phys_alloc_nid() retry with different
> > > MEMBLOCK_MIRROR, but memblock_phys_alloc_try_nid() does that only when
> > > allocating from the specified node and does not retry when it falls back to
> > > any node. And memblock_alloc_internal() has yet another set of fallbacks.
> > >
> > > So what should be the necessary handling in the wrapper for
> > > __memblock_find_range_bottom_up() ?
> > >
> > Well, it is a hard choice.
> > > BTW, even without any memblock modifications, retrying allocation in
> > > reserve_crashkerenel() for different ranges, like the proposal at [1] would
> > > also work, wouldn't it?
> > >
> > Yes, it can work. Then is it worth to expose the bottom-up allocation
> > style beside for hotmovable purpose?
>
> Some architectures use bottom-up as a "compatability" mode with bootmem.
> And, I believe, powerpc and s390 use bottom-up to make some of the
> allocations close to the kernel.
>
Ok, got it. Thanks.

Best regards,
Pingfan

> > Thanks,
> > Pingfan
> > > [1] http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
> > >
> > > > Thanks
> > > > Baoquan
> > > >
> > > > >
> > > > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > > > index 7df468c..d1b30b9 100644
> > > > > --- a/mm/memblock.c
> > > > > +++ b/mm/memblock.c
> > > > > @@ -274,24 +274,14 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> > > > >      * try bottom-up allocation only when bottom-up mode
> > > > >      * is set and @end is above the kernel image.
> > > > >      */
> > > > > -   if (memblock_bottom_up() && end > kernel_end) {
> > > > > -           phys_addr_t bottom_up_start;
> > > > > -
> > > > > -           /* make sure we will allocate above the kernel */
> > > > > -           bottom_up_start = max(start, kernel_end);
> > > > > -
> > > > > +   if (memblock_bottom_up()) {
> > > > >             /* ok, try bottom-up allocation first */
> > > > > -           ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> > > > > +           ret = __memblock_find_range_bottom_up(start, end,
> > > > >                                                   size, align, nid, flags);
> > > > >             if (ret)
> > > > >                     return ret;
> > > > >
> > > > >             /*
> > > > > -            * we always limit bottom-up allocation above the kernel,
> > > > > -            * but top-down allocation doesn't have the limit, so
> > > > > -            * retrying top-down allocation may succeed when bottom-up
> > > > > -            * allocation failed.
> > > > > -            *
> > > > >              * bottom-up allocation is expected to be fail very rarely,
> > > > >              * so we use WARN_ONCE() here to see the stack trace if
> > > > >              * fail happens.
> > > > >
> > > > > [1] https://lore.kernel.org/lkml/1545966002-3075-3-git-send-email-kernelfans@gmail.com/
> > > > > [2] https://lore.kernel.org/lkml/1545966002-3075-2-git-send-email-kernelfans@gmail.com/
> > > > >
> > > > > > +
> > > > > > + return ret;
> > > > > > +}
> > > > > > +
> > > > > >  /**
> > > > > >   * __memblock_find_range_top_down - find free area utility, in top-down
> > > > > >   * @start: start of candidate range
> > > > > > --
> > > > > > 2.7.4
> > > > > >
> > > > >
> > > > > --
> > > > > Sincerely yours,
> > > > > Mike.
> > > > >
> > > >
> > >
> > > --
> > > Sincerely yours,
> > > Mike.
> > >
> >
>
> --
> Sincerely yours,
> Mike.
>
