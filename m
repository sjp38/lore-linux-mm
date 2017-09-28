Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7976B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:42:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e195so1432012wma.6
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 03:42:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o126sor140639wmd.27.2017.09.28.03.42.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 03:42:46 -0700 (PDT)
Date: Thu, 28 Sep 2017 12:42:43 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 10/19] x86/mm: Make __PHYSICAL_MASK_SHIFT and
 __VIRTUAL_MASK_SHIFT dynamic
Message-ID: <20170928104243.dubif4ayw2spbyfn@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-11-kirill.shutemov@linux.intel.com>
 <20170928082813.lvr45p53niznhycx@gmail.com>
 <20170928102254.t34en42ruek6d3lu@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928102254.t34en42ruek6d3lu@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Sep 28, 2017 at 10:28:13AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > --- a/arch/x86/mm/dump_pagetables.c
> > > +++ b/arch/x86/mm/dump_pagetables.c
> > > @@ -82,8 +82,8 @@ static struct addr_marker address_markers[] = {
> > >  	{ 0/* VMALLOC_START */, "vmalloc() Area" },
> > >  	{ 0/* VMEMMAP_START */, "Vmemmap" },
> > >  #ifdef CONFIG_KASAN
> > > -	{ KASAN_SHADOW_START,	"KASAN shadow" },
> > > -	{ KASAN_SHADOW_END,	"KASAN shadow end" },
> > > +	{ 0/* KASAN_SHADOW_START */,	"KASAN shadow" },
> > > +	{ 0/* KASAN_SHADOW_END */,	"KASAN shadow end" },
> > 
> > What's this? Looks hacky.
> 
> KASAN_SHADOW_START and KASAN_SHADOW_END depend on __VIRTUAL_MASK_SHIFT,
> which is dynamic for boot-time switching case. It means we cannot
> initialize the corresponding address_markers fields compile-time, so we do
> it boot-time.

Yes, so please instead of just commenting out the values, please do something like 
this:

	/*
	 * This field gets initialized with the (dynamic) KASAN_SHADOW_END value
	 * in boot_fn_foo() 
	 */
	{ 0, "KASAN shadow end" },

where boot_fn_foo() is the function where this all gets set up.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
