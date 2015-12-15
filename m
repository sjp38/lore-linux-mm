Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6DB6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 20:01:01 -0500 (EST)
Received: by pff63 with SMTP id 63so20494775pff.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 17:01:00 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id n1si12408577pap.152.2015.12.14.17.01.00
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 17:01:00 -0800 (PST)
Date: Mon, 14 Dec 2015 17:00:59 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Message-ID: <20151215010059.GA17353@agluck-desk.sc.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
 <20151212101142.GA3867@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151212101142.GA3867@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Sat, Dec 12, 2015 at 11:11:42AM +0100, Borislav Petkov wrote:
> > +config MCE_KERNEL_RECOVERY
> > +	depends on X86_MCE && X86_64
> > +	def_bool y
> 
> Shouldn't that depend on NVDIMM or whatnot? Looks too generic now.

Not sure what the "whatnot" would be though.  Making it depend on
X86_MCE should keep it out of the tiny configurations. By the time
you have MCE support, this seems like a pretty small incremental
change.

> > +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> > +int fixup_mcexception(struct pt_regs *regs, u64 addr)
> > +{
> 
> If you move the #ifdef here, you can save yourself the ifdeffery in the
> header above.

I realized I didn't need the inline stub function in the header.

> > diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
> > index 1781e54ea6d3..21bb20d1172a 100644
> > --- a/include/asm-generic/vmlinux.lds.h
> > +++ b/include/asm-generic/vmlinux.lds.h
> > @@ -473,6 +473,12 @@
> >  		VMLINUX_SYMBOL(__start___ex_table) = .;			\
> >  		*(__ex_table)						\
> >  		VMLINUX_SYMBOL(__stop___ex_table) = .;			\
> > +	}								\
> > +	. = ALIGN(align);						\
> > +	__mcex_table : AT(ADDR(__mcex_table) - LOAD_OFFSET) {		\
> > +		VMLINUX_SYMBOL(__start___mcex_table) = .;		\
> > +		*(__mcex_table)						\
> > +		VMLINUX_SYMBOL(__stop___mcex_table) = .;		\
> 
> Of all the places, this one is missing #ifdef CONFIG_MCE_KERNEL_RECOVERY.

Is there some cpp magic to use an #ifdef inside a multi-line macro like this?
Impact of not having the #ifdef is two extra symbols (the start/stop ones)
in the symbol table of the final binary. If that's unacceptable I can fall
back to an earlier unpublished version that had separate EXCEPTION_TABLE and
MCEXCEPTION_TABLE macros with both invoked in the x86 vmlinux.lds.S file.

> You can make this one a bit more readable by doing:
> 
> /* Given an address, look for it in the machine check exception tables. */
> const struct exception_table_entry *
> search_mcexception_tables(unsigned long addr)
> {
> #ifdef CONFIG_MCE_KERNEL_RECOVERY
>         return search_extable(__start___mcex_table,
>                                __stop___mcex_table - 1, addr);
> #endif
> }

I got rid of the local variable and the return ... but left the
#ifdef/#endif around the whole function.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
