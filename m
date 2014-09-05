Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 374A26B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 06:23:54 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id t60so11451888wes.24
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 03:23:53 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id m1si1316049wje.125.2014.09.05.03.23.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 03:23:52 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so2707552wib.4
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 03:23:51 -0700 (PDT)
Date: Fri, 5 Sep 2014 12:23:47 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Message-ID: <20140905102347.GA30096@gmail.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
 <20140904201123.GA9116@khazad-dum.debian.net>
 <1409862708.28990.141.camel@misato.fc.hp.com>
 <1409873255.28990.158.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409873255.28990.158.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> On Thu, 2014-09-04 at 14:31 -0600, Toshi Kani wrote:
> > On Thu, 2014-09-04 at 17:11 -0300, Henrique de Moraes Holschuh wrote:
> > > On Thu, 04 Sep 2014, Toshi Kani wrote:
> > > > This patch sets WT to the PA4 slot in the PAT MSR when the processor
> > > > is not affected by the PAT errata.  The upper 4 slots of the PAT MSR
> > > > are continued to be unused on the following Intel processors.
> > > > 
> > > >   errata           cpuid
> > > >   --------------------------------------
> > > >   Pentium 2, A52   family 0x6, model 0x5
> > > >   Pentium 3, E27   family 0x6, model 0x7
> > > >   Pentium M, Y26   family 0x6, model 0x9
> > > >   Pentium 4, N46   family 0xf, model 0x0
> > > > 
> > > > For these affected processors, _PAGE_CACHE_MODE_WT is redirected to UC-
> > > > per the default setup in __cachemode2pte_tbl[].
> > > 
> > > There are at least two PAT errata.  The blacklist is in
> > > arch/x86/kernel/cpu/intel.c:
> > > 
> > >         if (c->x86 == 6 && c->x86_model < 15)
> > >                 clear_cpu_cap(c, X86_FEATURE_PAT);
> > > 
> > > It covers model 13, which is not in your blacklist.
> > > 
> > > It *is* possible that PAT would work on model 13, as I don't think it has
> > > any PAT errata listed and it was blacklisted "just in case" (from memory. I
> > > did not re-check), but this is untested, and unwise to enable on an aging
> > > platform.
> > > 
> > > I am worried of uncharted territory, here.  I'd actually advocate for not
> > > enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
> > > is using them as well.  Is this a real concern, or am I being overly
> > > cautious?
> > 
> > The blacklist you pointed out covers a different PAT errata, and is
> > still effective after this change.  pat_init() will call pat_disable()
> > and the PAT will continue to be disabled on these processors.  There is
> > no change for them.
> > 
> > My blacklist covers the PAT errata that makes the upper four bit
> > unusable when the PAT is enabled.
> 
> I checked more carefully, and it turns out that the processors 
> that have the WC bug with PAT/MTRR also have the upper four bit 
> bug in PAT as well.  The updated blacklist is:
> 
>    errata               cpuid
>    --------------------------------------
>    Pentium 2, A52       family 0x6, model 0x5
>    Pentium 3, E27       family 0x6, model 0x7, 0x8
>    Pentium 3 Xeon, G26  family 0x6, model 0x7, 0x8, 0xa
>    Pentium M, Y26       family 0x6, model 0x9
>    Pentium M 90nm, X9   family 0x6, model 0xd
>    Pentium 4, N46       family 0xf, model 0x0
>                 
> So, the check can be the same as cpu/intel.c, except that early 
> Pentium 4 steppings also have the upper four bit bug.  I will 
> update the check. In any case, this check is only meaningful 
> for P4 since the PAT is disabled for P2/3/M.

Any reason why we have to create such a sharp boundary, instead 
of simply saying: 'disable PAT on all x86 CPU families that have 
at least one buggy model'?

That would nicely sort out all the broken CPUs, and would make it 
highly unlikely that we'd accidentally forget about a model or 
two.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
