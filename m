Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13A476B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 05:44:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k10so240672wrk.4
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 02:44:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k72sor418467wrc.27.2017.09.28.02.44.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 02:44:26 -0700 (PDT)
Date: Thu, 28 Sep 2017 11:44:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 02/19] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Message-ID: <20170928094423.c75fatvl6rnqzt5n@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-3-kirill.shutemov@linux.intel.com>
 <20170928081034.g3k3sz7pue7jnzvi@gmail.com>
 <20170928091954.t74i542dlnejbzty@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928091954.t74i542dlnejbzty@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Sep 28, 2017 at 10:10:34AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > With boot-time switching between paging mode we will have variable
> > > MAX_PHYSMEM_BITS.
> > > 
> > > Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
> > > configuration to define zsmalloc data structures.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Nitin Gupta <ngupta@vflare.org>
> > > Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> > > ---
> > >  mm/zsmalloc.c | 6 ++++++
> > >  1 file changed, 6 insertions(+)
> > > 
> > > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > > index 7c38e850a8fc..fe22661f2fe5 100644
> > > --- a/mm/zsmalloc.c
> > > +++ b/mm/zsmalloc.c
> > > @@ -93,7 +93,13 @@
> > >  #define MAX_PHYSMEM_BITS BITS_PER_LONG
> > >  #endif
> > >  #endif
> > > +
> > > +#ifdef CONFIG_X86_5LEVEL
> > > +/* MAX_PHYSMEM_BITS is variable, use maximum value here */
> > > +#define _PFN_BITS		(52 - PAGE_SHIFT)
> > > +#else
> > >  #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
> > > +#endif
> > 
> > This is a totally ugly hack, polluting generic MM code with an x86-ism and an 
> > arbitrary hard-coded constant that would silently lose validity when x86 paging 
> > gets extended again ...
> 
> Well, yes it's ugly. And I would be glad to find better solution. But I
> don't see one.
> 
> And it won't break silently on x86 paging expanding as it won't use
> CONFIG_X86_5LEVEL, so we would fallback to MAX_PHYSMEM_BITS - PAGE_SHIFT.
>
> I worth noting that the code already has x86 hack. See PAE special case
> for MAX_PHYSMEM_BITS.

Old mistakes don't justify new ones.

It's possible to do better: for example if we provide a MAX_POSSIBLE_PHYSMEM_BITS 
define that is the higher value then code which needs this for sizing can use it?

That could eliminate the PAE dependency as well perhaps.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
