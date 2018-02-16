Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7756B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:00:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x77so1040496wmd.0
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:00:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15sor4263963edd.35.2018.02.16.07.00.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 07:00:17 -0800 (PST)
Date: Fri, 16 Feb 2018 18:00:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] x86/xen: Allow XEN_PV and XEN_PVH to be enabled with
 X86_5LEVEL
Message-ID: <20180216150013.twajic7ewrbacx7m@node.shutemov.name>
References: <20180216114948.68868-1-kirill.shutemov@linux.intel.com>
 <20180216114948.68868-2-kirill.shutemov@linux.intel.com>
 <20180216141110.GA10501@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180216141110.GA10501@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 16, 2018 at 06:11:10AM -0800, Matthew Wilcox wrote:
> On Fri, Feb 16, 2018 at 02:49:46PM +0300, Kirill A. Shutemov wrote:
> > @@ -38,12 +38,12 @@
> >   *
> >   */
> >  
> > +#define l4_index(x)	(((x) >> 39) & 511)
> >  #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
> 
> Shouldn't that be
> +#define p4d_index(x)	(((x) >> P4D_SHIFT) & (PTRS_PER_P4D-1))

With CONFIG_X86_5LEVEL=y, PTRS_PER_P4D is a varaible, so it won't compile.
With CONFIG_X86_5LEVEL=n, PTRS_PER_P4D is 1, so it's broken.

And I didn't want to mixin p4d here: it's actually top-level page table
in 4-level paging mode.

I guess we can do something like:

#define l4_index(x)	(((x) >> P4D_SIFT) & (PTRS_PER_PGD-1))

But to me it's more confusing than couple numbers.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
