Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5B90B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:01:26 -0500 (EST)
Received: by paceu11 with SMTP id eu11so14783600pac.1
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 17:01:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id li11si3099633pab.42.2015.03.03.17.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 17:01:25 -0800 (PST)
Date: Tue, 3 Mar 2015 17:00:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 6/6] x86, mm: Support huge KVA mappings on x86
Message-Id: <20150303170035.85e94c87.akpm@linux-foundation.org>
In-Reply-To: <1425424472.17007.191.camel@misato.fc.hp.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
	<1425404664-19675-7-git-send-email-toshi.kani@hp.com>
	<20150303144414.9f97ef25ad8aed7d112896bf@linux-foundation.org>
	<1425424472.17007.191.camel@misato.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com

On Tue, 03 Mar 2015 16:14:32 -0700 Toshi Kani <toshi.kani@hp.com> wrote:

> On Tue, 2015-03-03 at 14:44 -0800, Andrew Morton wrote:
> > On Tue,  3 Mar 2015 10:44:24 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
>  :
> > > +
> > > +#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> > > +int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
> > > +{
> > > +	u8 mtrr;
> > > +
> > > +	/*
> > > +	 * Do not use a huge page when the range is covered by non-WB type
> > > +	 * of MTRRs.
> > > +	 */
> > > +	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
> > > +	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
> > > +		return 0;
> > 
> > It would be good to notify the operator in some way when this happens. 
> > Otherwise the kernel will run more slowly and there's no way of knowing
> > why.  I guess slap a pr_info() in there.  Or maybe pr_warn()?
> 
> We only use 4KB mappings today, so this case will not make it run
> slowly, i.e. it will be the same as today.

Yes, but it would be slower than it would be if the operator fixed the
mtrr settings!  How do we let the operator know this?

>  Also, adding a message here
> can generate a lot of messages when MTRRs cover a large area.

Really?  This is only going to happen when a device driver requests a
huge io mapping, isn't it?  That's rare.  We could emit a warning,
return an error code and fall all the way back to the top-level ioremap
code which can then retry with 4k mappings.  Or something similar -
somehow record the fact that this warning has been emitted or use
printk ratelimiting (bad option).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
