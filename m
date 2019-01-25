Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3FB8E00EE
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 16:20:12 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id d6so4174416wrm.19
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:20:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20sor41015939wml.10.2019.01.25.13.20.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 13:20:11 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231442.EFD29EE0@viggo.jf.intel.com>
 <CAErSpo7kMjfi-1r8ZyGbheWzo+JCFkDZ1zpVhyNV7VVy8NOV7g@mail.gmail.com> <4898e064-5298-6a82-83ea-23d16f3dfb3d@intel.com>
In-Reply-To: <4898e064-5298-6a82-83ea-23d16f3dfb3d@intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 25 Jan 2019 15:19:58 -0600
Message-ID: <CAErSpo5pAQs-SJRKc-ie15zpSqf9FsPWnHeSpggU-EeZDg=AYQ@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/resource: return real error codes from walk failures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>, Jerome Glisse <jglisse@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On Fri, Jan 25, 2019 at 3:10 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/25/19 1:02 PM, Bjorn Helgaas wrote:
> >> @@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
> >>         unsigned long flags;
> >>         struct resource res;
> >>         unsigned long pfn, end_pfn;
> >> -       int ret = -1;
> >> +       int ret = -EINVAL;
> > Can you either make a similar change to the powerpc version of
> > walk_system_ram_range() in arch/powerpc/mm/mem.c or explain why it's
> > not needed?  It *seems* like we'd want both versions of
> > walk_system_ram_range() to behave similarly in this respect.
>
> Sure.  A quick grep shows powerpc being the only other implementation.
> I'll just add this hunk:
>
> > diff -puN arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1 arch/powerpc/mm/mem.c
> > --- a/arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1  2019-01-25 12:57:00.000004446 -0800
> > +++ b/arch/powerpc/mm/mem.c     2019-01-25 12:58:13.215004263 -0800
> > @@ -188,7 +188,7 @@ walk_system_ram_range(unsigned long star
> >         struct memblock_region *reg;
> >         unsigned long end_pfn = start_pfn + nr_pages;
> >         unsigned long tstart, tend;
> > -       int ret = -1;
> > +       int ret = -EINVAL;
>
> I'll also dust off the ol' cross-compiler and make sure I didn't
> fat-finger anything.

Sounds good.  Then add my

Reviewed-by: Bjorn Helgaas <bhelgaas@google.com>
