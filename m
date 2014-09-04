Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4F08F6B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:42:18 -0400 (EDT)
Received: by mail-oi0-f54.google.com with SMTP id a3so7235140oib.27
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:42:18 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id tb8si171221obc.8.2014.09.04.13.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 13:42:17 -0700 (PDT)
Message-ID: <1409862708.28990.141.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 04 Sep 2014 14:31:48 -0600
In-Reply-To: <20140904201123.GA9116@khazad-dum.debian.net>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
	 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
	 <20140904201123.GA9116@khazad-dum.debian.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com

On Thu, 2014-09-04 at 17:11 -0300, Henrique de Moraes Holschuh wrote:
> On Thu, 04 Sep 2014, Toshi Kani wrote:
> > This patch sets WT to the PA4 slot in the PAT MSR when the processor
> > is not affected by the PAT errata.  The upper 4 slots of the PAT MSR
> > are continued to be unused on the following Intel processors.
> > 
> >   errata           cpuid
> >   --------------------------------------
> >   Pentium 2, A52   family 0x6, model 0x5
> >   Pentium 3, E27   family 0x6, model 0x7
> >   Pentium M, Y26   family 0x6, model 0x9
> >   Pentium 4, N46   family 0xf, model 0x0
> > 
> > For these affected processors, _PAGE_CACHE_MODE_WT is redirected to UC-
> > per the default setup in __cachemode2pte_tbl[].
> 
> There are at least two PAT errata.  The blacklist is in
> arch/x86/kernel/cpu/intel.c:
> 
>         if (c->x86 == 6 && c->x86_model < 15)
>                 clear_cpu_cap(c, X86_FEATURE_PAT);
> 
> It covers model 13, which is not in your blacklist.
> 
> It *is* possible that PAT would work on model 13, as I don't think it has
> any PAT errata listed and it was blacklisted "just in case" (from memory. I
> did not re-check), but this is untested, and unwise to enable on an aging
> platform.
> 
> I am worried of uncharted territory, here.  I'd actually advocate for not
> enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
> is using them as well.  Is this a real concern, or am I being overly
> cautious?

The blacklist you pointed out covers a different PAT errata, and is
still effective after this change.  pat_init() will call pat_disable()
and the PAT will continue to be disabled on these processors.  There is
no change for them.

My blacklist covers the PAT errata that makes the upper four bit
unusable when the PAT is enabled.

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
