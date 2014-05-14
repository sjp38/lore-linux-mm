Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 372706B0037
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:11:44 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id e16so150325lan.14
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:11:43 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id na5si1129589lbb.50.2014.05.14.15.11.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 15:11:42 -0700 (PDT)
Received: by mail-la0-f49.google.com with SMTP id pv20so148372lab.8
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:11:42 -0700 (PDT)
Date: Thu, 15 May 2014 02:11:40 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140514221140.GF28328@moon>
References: <53739201.6080604@oracle.com>
 <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com>
 <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com>
 <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Wed, May 14, 2014 at 02:33:54PM -0700, Andy Lutomirski wrote:
> On Wed, May 14, 2014 at 2:31 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 14 May 2014 17:11:00 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> >
> >> > In my linux-next all that code got deleted by Andy's "x86, vdso:
> >> > Reimplement vdso.so preparation in build-time C" anyway.  What kernel
> >> > were you looking at?
> >>
> >> Deleted? It appears in today's -next. arch/x86/vdso/vma.c:124 .
> >>
> >> I don't see Andy's patch removing that code either.
> >
> > ah, OK, it got moved from arch/x86/vdso/vdso32-setup.c into
> > arch/x86/vdso/vma.c.
> >
> > Maybe you managed to take a fault against the symbol area between the
> > _install_special_mapping() and the remap_pfn_range() call, but mmap_sem
> > should prevent that.
> >
> > Or the remap_pfn_range() call never happened.  Should map_vdso() be
> > running _install_special_mapping() at all if
> > image->sym_vvar_page==NULL?
> 
> I'm confused: are we talking about 3.15-rcsomething or linux-next?
> That code changed.
> 
> Would this all make more sense if there were just a single vma in
> here?  cc: Pavel and Cyrill, who might have to deal with this stuff in
> CRIU

Well, for criu we've not modified any vdso kernel's code (except
setting VM_SOFTDIRTY for this vdso VMA in _install_special_mapping).
And never experienced problems Sasha points. Looks like indeed in
-next code is pretty different from mainline one. To figure out
why I need to fetch -next branch and get some research. I would
try to do that tomorrow (still hoping someone more experienced
in mm system would beat me on that).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
