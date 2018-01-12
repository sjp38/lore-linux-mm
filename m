Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2CD6B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 19:56:05 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 23so2487781otv.0
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 16:56:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q186si5335757oif.514.2018.01.11.16.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 16:56:04 -0800 (PST)
Date: Fri, 12 Jan 2018 08:55:49 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180112005549.GA2265@dhcp-128-65.nay.redhat.com>
References: <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <20180109010927.GA2082@dhcp-128-65.nay.redhat.com>
 <20180109054131.GB1935@localhost.localdomain>
 <20180109072440.GA6521@dhcp-128-65.nay.redhat.com>
 <20180109090552.45ddfk2y25lf4uyn@node.shutemov.name>
 <20180110030804.GB1744@dhcp-128-110.nay.redhat.com>
 <20180110111603.56disgew7ipusgjy@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110111603.56disgew7ipusgjy@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Baoquan He <bhe@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org

On 01/10/18 at 02:16pm, Kirill A. Shutemov wrote:
> On Wed, Jan 10, 2018 at 03:08:04AM +0000, Dave Young wrote:
> > On Tue, Jan 09, 2018 at 12:05:52PM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Jan 09, 2018 at 03:24:40PM +0800, Dave Young wrote:
> > > > On 01/09/18 at 01:41pm, Baoquan He wrote:
> > > > > On 01/09/18 at 09:09am, Dave Young wrote:
> > > > > 
> > > > > > As for the macro name, VMCOREINFO_SYMBOL_ARRAY sounds better.
> > > 
> > > Yep, that's better.
> > > 
> > > > > I still think using vmcoreinfo_append_str is better. Unless we replace
> > > > > all array variables with the newly added macro.
> > > > > 
> > > > > vmcoreinfo_append_str("SYMBOL(mem_section)=%lx\n",
> > > > >                                 (unsigned long)mem_section);
> > > > 
> > > > I have no strong opinion, either change all array uses or just introduce
> > > > the macro and start to use it from now on if we have similar array
> > > > symbols.
> > > 
> > > Do you need some action on my side or will you folks take care about this?
> > 
> > I think Baoquan was suggesting to update all array users in current
> > code, if you can check every VMCOREINFO_SYMBOL and update all the arrays
> > he will be happy. But if can not do it easily I'm fine with a
> > VMCOREINFO_SYMBOL_ARRAY changes only now, we kdump people can do it
> > later as well. 
> 
> It seems it's the only array we have there. swapper_pg_dir is a potential
> candidate, but it's 'unsigned long' on arm.
> 
> Below it patch with corrected macro name.
> 
> Please, consider applying.
> 
> From 70f3a84b97f2de98d1364f7b10b7a42a1d8e9968 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 9 Jan 2018 02:55:47 +0300
> Subject: [PATCH] kdump: Write a correct address of mem_section into vmcoreinfo
> 
> Depending on configuration mem_section can now be an array or a pointer
> to an array allocated dynamically. In most cases, we can continue to refer
> to it as 'mem_section' regardless of what it is.
> 
> But there's one exception: '&mem_section' means "address of the array" if
> mem_section is an array, but if mem_section is a pointer, it would mean
> "address of the pointer".
> 
> We've stepped onto this in kdump code. VMCOREINFO_SYMBOL(mem_section)
> writes down address of pointer into vmcoreinfo, not array as we wanted.
> 
> Let's introduce VMCOREINFO_SYMBOL_ARRAY() that would handle the
> situation correctly for both cases.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
> ---
>  include/linux/crash_core.h | 2 ++
>  kernel/crash_core.c        | 2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
> index 06097ef30449..b511f6d24b42 100644
> --- a/include/linux/crash_core.h
> +++ b/include/linux/crash_core.h
> @@ -42,6 +42,8 @@ phys_addr_t paddr_vmcoreinfo_note(void);
>  	vmcoreinfo_append_str("PAGESIZE=%ld\n", value)
>  #define VMCOREINFO_SYMBOL(name) \
>  	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)&name)
> +#define VMCOREINFO_SYMBOL_ARRAY(name) \
> +	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)name)
>  #define VMCOREINFO_SIZE(name) \
>  	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
>  			      (unsigned long)sizeof(name))
> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> index b3663896278e..4f63597c824d 100644
> --- a/kernel/crash_core.c
> +++ b/kernel/crash_core.c
> @@ -410,7 +410,7 @@ static int __init crash_save_vmcoreinfo_init(void)
>  	VMCOREINFO_SYMBOL(contig_page_data);
>  #endif
>  #ifdef CONFIG_SPARSEMEM
> -	VMCOREINFO_SYMBOL(mem_section);
> +	VMCOREINFO_SYMBOL_ARRAY(mem_section);
>  	VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
>  	VMCOREINFO_STRUCT_SIZE(mem_section);
>  	VMCOREINFO_OFFSET(mem_section, section_mem_map);
> -- 
>  Kirill A. Shutemov


Acked-by: Dave Young <dyoung@redhat.com>

If stable kernel took the mem section commits, then should also cc
stable.  Andrew, can you help to make this in 4.15?

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
