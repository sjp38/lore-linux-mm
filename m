Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 866AC6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 11:04:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g15so17409773wmc.8
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:04:55 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id r188si3095182wmf.131.2017.06.02.08.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 08:04:54 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id k15so19470201wmh.3
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:04:53 -0700 (PDT)
Date: Fri, 2 Jun 2017 18:04:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 06/10] x86/mm: Add sync_global_pgds() for configuration
 with 5-level paging
Message-ID: <20170602150451.nspo54dzp7y54wdk@node.shutemov.name>
References: <20170524095419.14281-1-kirill.shutemov@linux.intel.com>
 <20170524095419.14281-7-kirill.shutemov@linux.intel.com>
 <86bddb33-4f07-2949-256b-caf931df98d8@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86bddb33-4f07-2949-256b-caf931df98d8@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 02, 2017 at 05:50:34PM +0300, Andrey Ryabinin wrote:
> On 05/24/2017 12:54 PM, Kirill A. Shutemov wrote:
> > This basically restores slightly modified version of original
> > sync_global_pgds() which we had before folded p4d was introduced.
> > 
> > The only modification is protection against 'addr' overflow.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/mm/init_64.c | 39 +++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 39 insertions(+)
> > 
> > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> > index 95651dc58e09..ce410c05d68d 100644
> > --- a/arch/x86/mm/init_64.c
> > +++ b/arch/x86/mm/init_64.c
> > @@ -92,6 +92,44 @@ __setup("noexec32=", nonx32_setup);
> >   * When memory was added make sure all the processes MM have
> >   * suitable PGD entries in the local PGD level page.
> >   */
> > +#ifdef CONFIG_X86_5LEVEL
> > +void sync_global_pgds(unsigned long start, unsigned long end)
> > +{
> > +	unsigned long addr;
> > +
> > +	for (addr = start; addr <= end; addr += ALIGN(addr + 1, PGDIR_SIZE)) {
> 
>                                         addr = ALIGN(addr + 1, PGDIR_SIZE)

Ouch. Thanks for noticing this.

Strange that it haven't crashed anywhere in my tests.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
