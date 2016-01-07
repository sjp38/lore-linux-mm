Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9453828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 13:22:48 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id cy9so264588399pac.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 10:22:48 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rw4si10392364pac.72.2016.01.07.10.22.47
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 10:22:47 -0800 (PST)
Date: Thu, 7 Jan 2016 10:22:46 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Message-ID: <20160107182246.GA21892@agluck-desk.sc.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
 <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
 <20160106194222.GC16647@pd.tnic>
 <20160107121131.GB23768@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107121131.GB23768@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Thu, Jan 07, 2016 at 01:11:31PM +0100, Borislav Petkov wrote:
>  #ifdef __ASSEMBLY__
>  # define _ASM_EXTABLE(from,to)					\
>  	.pushsection "__ex_table","a" ;				\
> -	.balign 8 ;						\
> +	.balign 4 ;						\
>  	.long (from) - . ;					\
>  	.long (to) - . ;					\
> +	.long 0;						\

Why not
	.long ex_handler_default - . ;

Then you wouldn't have to special case the zero in the lookup
(and in the sort, which you don't do now, but should)

> @@ -33,42 +67,36 @@ int fixup_exception(struct pt_regs *regs)
>  	}
>  #endif
>  
> -	fixup = search_exception_tables(regs->ip);
> -	if (fixup) {
> -		new_ip = ex_fixup_addr(fixup);
> -
> -		if (fixup->fixup - fixup->insn >= 0x7ffffff0 - 4) {
> -			/* Special hack for uaccess_err */
> -			current_thread_info()->uaccess_err = 1;
> -			new_ip -= 0x7ffffff0;
> -		}
> -		regs->ip = new_ip;
> -		return 1;
> -	}
> +	e = search_exception_tables(regs->ip);
> +	if (!e)
> +		return 0;
>  
> -	return 0;
> +	new_ip  = ex_fixup_addr(e);

Assigned, but not used - delete the declaration above too.

> +static void x86_sort_relative_table(char *extab_image, int image_size)
> +{
> +	int i;
> +
> +	i = 0;
> +	while (i < image_size) {
> +		uint32_t *loc = (uint32_t *)(extab_image + i);
> +
> +		w(r(loc) + i, loc);
> +		w(r(loc + 1) + i + 4, loc + 1);
Need to twiddle the 'handler' field too (unless it is 0). If you
give up on the magic zero and fill in the offset to ex_handler_default
then I *think* you need:
		w(r(loc + 2) + i + 8, loc + 2);
the special case *might* be:
		if (r(loc + 2))
			w(r(loc + 2) + i + 8, loc + 2);
> +
> +		i += sizeof(uint32_t) * 3;
> +	}
> +
> +	qsort(extab_image, image_size / 12, 12, compare_relative_table);
> +
> +	i = 0;
> +	while (i < image_size) {
> +		uint32_t *loc = (uint32_t *)(extab_image + i);
> +
> +		w(r(loc) - i, loc);
> +		w(r(loc + 1) - (i + 4), loc + 1);
ditto, untwiddle the handler (unless it was zero)
		w(r(loc + 2) - (i + 8), loc + 2);

There is also arch/x86/mm/extable.c:sort_extable() which will
be used on the main kernel exception table if for some reason
the build skipped using scripts/sortextable ... and is always
used for exception tables in modules.  It also needs to know
about the new field (and would be another place to special case
the zero fields for the default handler).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
