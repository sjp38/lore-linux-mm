Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4229C8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 04:28:41 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 42so38072146qtr.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 01:28:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s16si2648224qtk.382.2019.01.02.01.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 01:28:40 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x029NRb3036655
	for <linux-mm@kvack.org>; Wed, 2 Jan 2019 04:28:39 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2prtc5grda-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 Jan 2019 04:28:39 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 2 Jan 2019 09:28:28 -0000
Date: Wed, 2 Jan 2019 11:28:17 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCHv3 2/2] x86/kdump: bugfix, make the behavior of
 crashkernel=X consistent with kaslr
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-3-git-send-email-kernelfans@gmail.com>
 <20181231084608.GB28478@rapoport-lnx>
 <CAFgQCTs2A-_ZzLAz=wZng=2e3+VURd97wJxLv5UesVUTMaw0hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTs2A-_ZzLAz=wZng=2e3+VURd97wJxLv5UesVUTMaw0hg@mail.gmail.com>
Message-Id: <20190102092817.GB22664@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On Wed, Jan 02, 2019 at 02:47:54PM +0800, Pingfan Liu wrote:
> On Mon, Dec 31, 2018 at 4:46 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > On Fri, Dec 28, 2018 at 11:00:02AM +0800, Pingfan Liu wrote:
> > > Customer reported a bug on a high end server with many pcie devices, where
> > > kernel bootup with crashkernel=384M, and kaslr is enabled. Even
> > > though we still see much memory under 896 MB, the finding still failed
> > > intermittently. Because currently we can only find region under 896 MB,
> > > if w/0 ',high' specified. Then KASLR breaks 896 MB into several parts
> > > randomly, and crashkernel reservation need be aligned to 128 MB, that's
> > > why failure is found. It raises confusion to the end user that sometimes
> > > crashkernel=X works while sometimes fails.
> > > If want to make it succeed, customer can change kernel option to
> > > "crashkernel=384M, high". Just this give "crashkernel=xx@yy" a very
> > > limited space to behave even though its grammer looks more generic.
> > > And we can't answer questions raised from customer that confidently:
> > > 1) why it doesn't succeed to reserve 896 MB;
> > > 2) what's wrong with memory region under 4G;
> > > 3) why I have to add ',high', I only require 384 MB, not 3840 MB.
> > >
> > > This patch simplifies the method suggested in the mail [1]. It just goes
> > > bottom-up to find a candidate region for crashkernel. The bottom-up may be
> > > better compatible with the old reservation style, i.e. still want to get
> > > memory region from 896 MB firstly, then [896 MB, 4G], finally above 4G.
> > >
> > > There is one trivial thing about the compatibility with old kexec-tools:
> > > if the reserved region is above 896M, then old tool will fail to load
> > > bzImage. But without this patch, the old tool also fail since there is no
> > > memory below 896M can be reserved for crashkernel.
> > >
> > > [1]: http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
> > > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > > Cc: Tang Chen <tangchen@cn.fujitsu.com>
> > > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > > Cc: Len Brown <lenb@kernel.org>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Jonathan Corbet <corbet@lwn.net>
> > > Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> > > Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> > > Cc: Nicholas Piggin <npiggin@gmail.com>
> > > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: Daniel Vacek <neelx@redhat.com>
> > > Cc: Mathieu Malaterre <malat@debian.org>
> > > Cc: Stefan Agner <stefan@agner.ch>
> > > Cc: Dave Young <dyoung@redhat.com>
> > > Cc: Baoquan He <bhe@redhat.com>
> > > Cc: yinghai@kernel.org,
> > > Cc: vgoyal@redhat.com
> > > Cc: linux-kernel@vger.kernel.org
> > > ---
> > >  arch/x86/kernel/setup.c | 9 ++++++---
> > >  1 file changed, 6 insertions(+), 3 deletions(-)
> > >
> > > diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> > > index d494b9b..165f9c3 100644
> > > --- a/arch/x86/kernel/setup.c
> > > +++ b/arch/x86/kernel/setup.c
> > > @@ -541,15 +541,18 @@ static void __init reserve_crashkernel(void)
> > >
> > >       /* 0 means: find the address automatically */
> > >       if (crash_base <= 0) {
> > > +             bool bottom_up = memblock_bottom_up();
> > > +
> > > +             memblock_set_bottom_up(true);
> > >
> > >               /*
> > >                * Set CRASH_ADDR_LOW_MAX upper bound for crash memory,
> > >                * as old kexec-tools loads bzImage below that, unless
> > >                * "crashkernel=size[KMG],high" is specified.
> > >                */
> > >               crash_base = memblock_find_in_range(CRASH_ALIGN,
> > > -                                                 high ? CRASH_ADDR_HIGH_MAX
> > > -                                                      : CRASH_ADDR_LOW_MAX,
> > > -                                                 crash_size, CRASH_ALIGN);
> > > +                     (max_pfn * PAGE_SIZE), crash_size, CRASH_ALIGN);
> > > +             memblock_set_bottom_up(bottom_up);
> >
> > Using bottom-up does not guarantee that the allocation won't fall into a
> > removable memory, it only makes it highly probable.
> >
> > I think that the 'max_pfn * PAGE_SIZE' limit should be replaced with the
> > end of the non-removable memory node.
> >
> Since passing MEMBLOCK_NONE, memblock_find_in_range() ->...->
> __next_mem_range(), there is a logic to guarantee hotmovable memory
> will not be stamped over.
> if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
> continue;

Thanks for the clarification, I've missed that.
 
> Thanks,
> Pingfan
> 
> > > +
> > >               if (!crash_base) {
> > >                       pr_info("crashkernel reservation failed - No suitable area found.\n");
> > >                       return;
> > > --
> > > 2.7.4
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 

-- 
Sincerely yours,
Mike.
