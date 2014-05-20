Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id ACA0B6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:39:11 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id p9so718492lbv.25
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:39:10 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id c3si17972509lae.9.2014.05.20.11.39.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 11:39:09 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so720619lbi.23
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:39:09 -0700 (PDT)
Date: Tue, 20 May 2014 22:39:07 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix x86
 vdso naming
Message-ID: <20140520183907.GM2185@moon>
References: <cover.1400538962.git.luto@amacapital.net>
 <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
 <20140520172134.GJ2185@moon>
 <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com>
 <20140520174759.GK2185@moon>
 <CALCETrUARCP0eNj5e3Kh81KDXg5AFLnoNoDHeoZcBXi9z-5F3w@mail.gmail.com>
 <20140520180104.GL2185@moon>
 <537B9C6D.7010705@zytor.com>
 <CALCETrWmKvox1poGK5fBw2OBip7zMpjb-bpYrzd4EGHPDvZEHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWmKvox1poGK5fBw2OBip7zMpjb-bpYrzd4EGHPDvZEHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, May 20, 2014 at 11:24:56AM -0700, Andy Lutomirski wrote:
> On Tue, May 20, 2014 at 11:18 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> > On 05/20/2014 11:01 AM, Cyrill Gorcunov wrote:
> >>>
> >>> This patch should fix this issue, at least.  If there's still a way to
> >>> get a native vdso that doesn't say "[vdso]", please let me know/
> >>
> >> Yes, having a native procfs way to detect vdso is much preferred!
> >>
> >
> > Is there any path by which we can end up with [vdso] without a leading
> > slash in /proc/self/maps?  Otherwise, why is that not "native"?
> 
> Dunno.  But before this patch the reverse was possible: we can end up
> with a vdso that doesn't say [vdso].

I fear I don't understand the phrase "leading slash in /proc/self/maps".
Peter could you rephrase please?

> >>>>   The situation get worse when task was dumped on one kernel and
> >>>> then restored on another kernel where vdso content is different
> >>>> from one save in image -- is such case as I mentioned we need
> >>>> that named vdso proxy which redirect calls to vdso of the system
> >>>> where task is restoring. And when such "restored" task get checkpointed
> >>>> second time we don't dump new living vdso but save only old vdso
> >>>> proxy on disk (detecting it is a different story, in short we
> >>>> inject a unique mark into elf header).
> >>>
> >>> Yuck.  But I don't know whether the kernel can help much here.
> >>
> >> Some prctl which would tell kernel to put vdso at specifed address.
> >> We can live without it for now so not a big deal (yet ;)
> >
> > mremap() will do this for you.
> 
> Except that it's buggy: it doesn't change mm->context.vdso.  For
> 64-bit tasks, the only consumer outside exec was arch_vma_name, and
> this patch removes even that.  For 32-bit tasks, though, it's needed
> for signal delivery.

yes, fwiw we can deal with it currently but i'm not sure yet about
compat case simply because didn't look presicely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
