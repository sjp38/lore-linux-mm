Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id E83E56B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:48:08 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so695806lab.16
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:48:08 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id o7si17800070lao.96.2014.05.20.10.48.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 10:48:07 -0700 (PDT)
Received: by mail-lb0-f177.google.com with SMTP id s7so676178lbd.36
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:48:06 -0700 (PDT)
Date: Tue, 20 May 2014 21:47:59 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix x86
 vdso naming
Message-ID: <20140520174759.GK2185@moon>
References: <cover.1400538962.git.luto@amacapital.net>
 <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
 <20140520172134.GJ2185@moon>
 <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, May 20, 2014 at 10:24:49AM -0700, Andy Lutomirski wrote:
> On Tue, May 20, 2014 at 10:21 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > On Mon, May 19, 2014 at 03:58:33PM -0700, Andy Lutomirski wrote:
> >> Using arch_vma_name to give special mappings a name is awkward.  x86
> >> currently implements it by comparing the start address of the vma to
> >> the expected address of the vdso.  This requires tracking the start
> >> address of special mappings and is probably buggy if a special vma
> >> is split or moved.
> >>
> >> Improve _install_special_mapping to just name the vma directly.  Use
> >> it to give the x86 vvar area a name, which should make CRIU's life
> >> easier.
> >>
> >> As a side effect, the vvar area will show up in core dumps.  This
> >> could be considered weird and is fixable.  Thoughts?
> >>
> >> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> >> Cc: Pavel Emelyanov <xemul@parallels.com>
> >> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> >
> > Hi Andy, thanks a lot for this! I must confess I don't yet know how
> > would we deal with compat tasks but this is 'must have' mark which
> > allow us to detect vvar area!
> 
> Out of curiosity, how does CRIU currently handle checkpointing a
> restored task?  In current kernels, the "[vdso]" name in maps goes
> away after mremapping the vdso.

  We use not only [vdso] mark to detect vdso area but also page frame
number of the living vdso. If mark is not present in procfs output
we examinate executable areas and check if pfn == vdso_pfn, it's
a slow path because there migh be a bunch of executable areas and
touching every of it is not that fast thing, but we simply have no
choise.

  The situation get worse when task was dumped on one kernel and
then restored on another kernel where vdso content is different
from one save in image -- is such case as I mentioned we need
that named vdso proxy which redirect calls to vdso of the system
where task is restoring. And when such "restored" task get checkpointed
second time we don't dump new living vdso but save only old vdso
proxy on disk (detecting it is a different story, in short we
inject a unique mark into elf header).

> 
> I suspect that you'll need kernel changes for compat tasks, since I
> think that mremapping the vdso on any reasonably modern hardware in a
> 32-bit task will cause sigreturn to blow up.  This could be fixed by
> making mremap magical, although adding a new prctl or arch_prctl to
> reliably move the vdso might be a better bet.

Well, as far as I understand compat code uses abs addressing for
vvar data and if vvar data position doesn't change we're safe,
but same time because vvar addresses are not abi I fear one day
we indeed hit the problems and the only solution would be
to use kernel's help. But again, Andy, I didn't think much
about implementing compat mode in criu yet so i might be
missing some details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
