From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Fri, 8 Jan 2016 11:37:33 +0100
Message-ID: <20160108103733.GC12132@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
 <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
 <20160106194222.GC16647@pd.tnic>
 <20160107121131.GB23768@pd.tnic>
 <20160108014526.GA31242@agluck-desk.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160108014526.GA31242@agluck-desk.sc.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Jan 07, 2016 at 05:45:26PM -0800, Luck, Tony wrote:
> On Thu, Jan 07, 2016 at 01:11:31PM +0100, Borislav Petkov wrote:
> > Anyway, here's what I have, it boots fine in a guest.
> > 
> > Btw, it seems I'm coming down with the cold and all that above could be
> > hallucinations so please double-check me.
> 
> Hardly any hallucinations ... here's an update with the changes
> I mentioned in earlier e-mail.  Boots on actual h/w.

Cool, thanks for fixing it up. Looks good to me. Feel free to make it
into a proper patch and add it to your series... unless you want me to
do it.

Just one small question below:

> diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
> index 903ec1e9c326..01098ad010dd 100644
> --- a/arch/x86/mm/extable.c
> +++ b/arch/x86/mm/extable.c
> @@ -3,6 +3,8 @@
>  #include <linux/sort.h>
>  #include <asm/uaccess.h>
>  
> +typedef int (*ex_handler_t)(const struct exception_table_entry *, struct pt_regs *, int);
> +
>  static inline unsigned long
>  ex_insn_addr(const struct exception_table_entry *x)
>  {
> @@ -14,10 +16,39 @@ ex_fixup_addr(const struct exception_table_entry *x)
>  	return (unsigned long)&x->fixup + x->fixup;
>  }
>  
> -int fixup_exception(struct pt_regs *regs)
> +int ex_handler_default(const struct exception_table_entry *fixup,
> +		       struct pt_regs *regs, int trapnr)
>  {
> -	const struct exception_table_entry *fixup;
> -	unsigned long new_ip;
> +	regs->ip = ex_fixup_addr(fixup);
> +	return 1;
> +}
> +EXPORT_SYMBOL(ex_handler_default);

Why not EXPORT_SYMBOL_GPL() ?

We do not care about external modules.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
