Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4D66B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:01:07 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id e16so707719lan.14
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:01:06 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id bq4si9759158lbb.85.2014.05.20.11.01.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 11:01:06 -0700 (PDT)
Received: by mail-la0-f51.google.com with SMTP id gf5so697309lab.38
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:01:05 -0700 (PDT)
Date: Tue, 20 May 2014 22:01:04 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix x86
 vdso naming
Message-ID: <20140520180104.GL2185@moon>
References: <cover.1400538962.git.luto@amacapital.net>
 <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
 <20140520172134.GJ2185@moon>
 <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com>
 <20140520174759.GK2185@moon>
 <CALCETrUARCP0eNj5e3Kh81KDXg5AFLnoNoDHeoZcBXi9z-5F3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUARCP0eNj5e3Kh81KDXg5AFLnoNoDHeoZcBXi9z-5F3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, May 20, 2014 at 10:52:51AM -0700, Andy Lutomirski wrote:
> >
> >   We use not only [vdso] mark to detect vdso area but also page frame
> > number of the living vdso. If mark is not present in procfs output
> > we examinate executable areas and check if pfn == vdso_pfn, it's
> > a slow path because there migh be a bunch of executable areas and
> > touching every of it is not that fast thing, but we simply have no
> > choise.
> 
> This patch should fix this issue, at least.  If there's still a way to
> get a native vdso that doesn't say "[vdso]", please let me know/

Yes, having a native procfs way to detect vdso is much preferred!

> >   The situation get worse when task was dumped on one kernel and
> > then restored on another kernel where vdso content is different
> > from one save in image -- is such case as I mentioned we need
> > that named vdso proxy which redirect calls to vdso of the system
> > where task is restoring. And when such "restored" task get checkpointed
> > second time we don't dump new living vdso but save only old vdso
> > proxy on disk (detecting it is a different story, in short we
> > inject a unique mark into elf header).
> 
> Yuck.  But I don't know whether the kernel can help much here.

Some prctl which would tell kernel to put vdso at specifed address.
We can live without it for now so not a big deal (yet ;)

> >> I suspect that you'll need kernel changes for compat tasks, since I
> >> think that mremapping the vdso on any reasonably modern hardware in a
> >> 32-bit task will cause sigreturn to blow up.  This could be fixed by
> >> making mremap magical, although adding a new prctl or arch_prctl to
> >> reliably move the vdso might be a better bet.
> >
> > Well, as far as I understand compat code uses abs addressing for
> > vvar data and if vvar data position doesn't change we're safe,
> > but same time because vvar addresses are not abi I fear one day
> > we indeed hit the problems and the only solution would be
> > to use kernel's help. But again, Andy, I didn't think much
> > about implementing compat mode in criu yet so i might be
> > missing some details.
> 
> Prior to 3.15, the compat code didn't have vvar data at all.  In 3.15
> and up, the vvar data is accessed using PC-relative addressing, even
> in compat mode (using the usual call; mov trick to read EIP).

i see. I'll ping you for help once I start implementing compat mode ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
