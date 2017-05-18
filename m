Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E16B9831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:13:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k57so10575553wrk.6
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:13:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n41si6871553edn.180.2017.05.18.10.13.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 10:13:33 -0700 (PDT)
Date: Thu, 18 May 2017 19:13:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv5, REBASED 9/9] x86/mm: Allow to have userspace mappings
 above 47-bits
Message-ID: <20170518171330.GA30148@dhcp22.suse.cz>
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
 <20170515121218.27610-10-kirill.shutemov@linux.intel.com>
 <20170518114359.GB25471@dhcp22.suse.cz>
 <20170518151952.jzvz6aeelgx7ifmm@node.shutemov.name>
 <20170518152736.GA18333@dhcp22.suse.cz>
 <20170518154135.zekuqls6almevrjt@node.shutemov.name>
 <20170518155003.GB18333@dhcp22.suse.cz>
 <20170518155914.GC18333@dhcp22.suse.cz>
 <20170518162255.l55tm5qbmnvvsgba@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518162255.l55tm5qbmnvvsgba@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu 18-05-17 19:22:55, Kirill A. Shutemov wrote:
> On Thu, May 18, 2017 at 05:59:14PM +0200, Michal Hocko wrote:
[...]
> > I basically mean something like the following
> > ---
> > diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
> > index 74d1587b181d..d6f66ff02d0a 100644
> > --- a/arch/x86/kernel/sys_x86_64.c
> > +++ b/arch/x86/kernel/sys_x86_64.c
> > @@ -195,7 +195,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> >  		goto bottomup;
> >  
> >  	/* requesting a specific address */
> > -	if (addr) {
> > +	if (addr && addr <= DEFAULT_MAP_WINDOW) {
> >  		addr = PAGE_ALIGN(addr);
> >  		vma = find_vma(mm, addr);
> >  		if (TASK_SIZE - len >= addr &&
> > @@ -215,7 +215,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> >  	 * !in_compat_syscall() check to avoid high addresses for x32.
> >  	 */
> >  	if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> > -		info.high_limit += TASK_SIZE_MAX - DEFAULT_MAP_WINDOW;
> > +		info.high_limit += min(TASK_SIZE_MAX, address) - DEFAULT_MAP_WINDOW;
> >  
> >  	info.align_mask = 0;
> >  	info.align_offset = pgoff << PAGE_SHIFT;
> 
> You try to stretch the interface too far. With the patch you propose we
> have totally different behaviour wrt hint address if it below and above
> 47-bits:
> 
>  * <= 47-bits: allocate VM [addr; addr + len - 1], if free;

unless I am missing something fundamental here this is not how it works.
We just map a different range if the requested one is not free (in
absence of MAP_FIXED). And we do that in top->down direction so this is
already how it works. And you _do_ rely on the same thing when allowing
larger than 47b except you start from the top of the supported address
space. So how exactly is your new behavior any different and more clear?

Say you would do
	mmap(1<<48, ...) # you will get 1<<48
	mmap(1<<48, ...) # you will get something below TASK_SIZE_MAX

>  * > 47-bits: allocate VM anywhere under addr;
> 
> Sorry, no. That's ugly.
> 
> If you feel that we need to guarantee that bits above certain limit are
> unused, introduce new interface. We have enough logic encoded in hint
> address already.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
