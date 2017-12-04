Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E723A6B0253
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 13:50:30 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a141so4508475wma.8
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 10:50:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor7331103edm.44.2017.12.04.10.50.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 10:50:29 -0800 (PST)
Date: Mon, 4 Dec 2017 21:50:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: Rewrite sme_populate_pgd() in a more sensible way
Message-ID: <20171204185027.gn6gu3b5vdq7lxx3@node.shutemov.name>
References: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
 <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
 <20171204145755.6xu2w6a6og56rq5v@node.shutemov.name>
 <d9701b1c-1abf-5fc1-80b0-47ab4e517681@amd.com>
 <20171204163445.qt5dqcrrkilnhowz@black.fi.intel.com>
 <d73f4ce1-b959-f54c-c30b-ed2c4dc8b67e@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d73f4ce1-b959-f54c-c30b-ed2c4dc8b67e@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 04, 2017 at 12:33:01PM -0600, Tom Lendacky wrote:
> On 12/4/2017 10:34 AM, Kirill A. Shutemov wrote:
> > On Mon, Dec 04, 2017 at 04:00:26PM +0000, Tom Lendacky wrote:
> > > On 12/4/2017 8:57 AM, Kirill A. Shutemov wrote:
> > > > On Mon, Dec 04, 2017 at 08:19:11AM -0600, Tom Lendacky wrote:
> > > > > On 12/4/2017 5:23 AM, Kirill A. Shutemov wrote:
> > > > > > sme_populate_pgd() open-codes a lot of things that are not needed to be
> > > > > > open-coded.
> > > > > > 
> > > > > > Let's rewrite it in a more stream-lined way.
> > > > > > 
> > > > > > This would also buy us boot-time switching between support between
> > > > > > paging modes, when rest of the pieces will be upstream.
> > > > > 
> > > > > Hi Kirill,
> > > > > 
> > > > > Unfortunately, some of these can't be changed.  The use of p4d_offset(),
> > > > > pud_offset(), etc., use non-identity mapped virtual addresses which cause
> > > > > failures at this point of the boot process.
> > > > 
> > > > Wat? Virtual address is virtual address. p?d_offset() doesn't care about
> > > > what mapping you're using.
> > > 
> > > Yes it does.  For example, pmd_offset() issues a pud_page_addr() call,
> > > which does a __va() returning a non-identity mapped address (0xffff88...).
> > > Only identity mapped virtual addresses have been setup at this point, so
> > > the use of that virtual address panics the kernel.
> > 
> > Stupid me. You are right.
> > 
> > What about something like this:
> > 
> > diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> > index d9a9e9fc75dd..65e0d68f863f 100644
> > --- a/arch/x86/mm/mem_encrypt.c
> > +++ b/arch/x86/mm/mem_encrypt.c
> > @@ -12,6 +12,23 @@
> >   #define DISABLE_BRANCH_PROFILING
> > +/*
> > + * Since we're dealing with identity mappings, physical and virtual
> > + * addresses are the same, so override these defines which are ultimately
> > + * used by the headers in misc.h.
> > + */
> > +#define __pa(x)  ((unsigned long)(x))
> > +#define __va(x)  ((void *)((unsigned long)(x)))
> 
> No, you can't do this.  There are routines in this file that are called
> after the kernel has switched to its standard virtual address map where
> this definition of __va() will likely cause a failure.

Let's than split it up into separate compilation unit.

> > +/*
> > + * Special hack: we have to be careful, because no indirections are
> > + * allowed here, and paravirt_ops is a kind of one. As it will only run in
> > + * baremetal anyway, we just keep it from happening. (This list needs to
> > + * be extended when new paravirt and debugging variants are added.)
> > + */
> > +#undef CONFIG_PARAVIRT
> > +#undef CONFIG_PARAVIRT_SPINLOCKS
> 
> I'd really, really like to avoid doing something like this.

Any other proposals?

Current code is way too hairy and hard to modify.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
