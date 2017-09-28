Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51D516B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:22:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z46so1715336wrz.2
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 03:22:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor736258edc.21.2017.09.28.03.22.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 03:22:56 -0700 (PDT)
Date: Thu, 28 Sep 2017 13:22:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv7 10/19] x86/mm: Make __PHYSICAL_MASK_SHIFT and
 __VIRTUAL_MASK_SHIFT dynamic
Message-ID: <20170928102254.t34en42ruek6d3lu@node.shutemov.name>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-11-kirill.shutemov@linux.intel.com>
 <20170928082813.lvr45p53niznhycx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928082813.lvr45p53niznhycx@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 28, 2017 at 10:28:13AM +0200, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > --- a/arch/x86/mm/dump_pagetables.c
> > +++ b/arch/x86/mm/dump_pagetables.c
> > @@ -82,8 +82,8 @@ static struct addr_marker address_markers[] = {
> >  	{ 0/* VMALLOC_START */, "vmalloc() Area" },
> >  	{ 0/* VMEMMAP_START */, "Vmemmap" },
> >  #ifdef CONFIG_KASAN
> > -	{ KASAN_SHADOW_START,	"KASAN shadow" },
> > -	{ KASAN_SHADOW_END,	"KASAN shadow end" },
> > +	{ 0/* KASAN_SHADOW_START */,	"KASAN shadow" },
> > +	{ 0/* KASAN_SHADOW_END */,	"KASAN shadow end" },
> 
> What's this? Looks hacky.

KASAN_SHADOW_START and KASAN_SHADOW_END depend on __VIRTUAL_MASK_SHIFT,
which is dynamic for boot-time switching case. It means we cannot
initialize the corresponding address_markers fields compile-time, so we do
it boot-time.

I used the same approach we use to deal with dynamic VMALLOC_START,
VMEMMAP_START and PAGE_OFFSET.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
