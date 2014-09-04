Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7326B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:11:43 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so2067663pde.3
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:11:43 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id ao2si15248pad.52.2014.09.04.13.11.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Sep 2014 13:11:40 -0700 (PDT)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 9B73720C5A
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:11:35 -0400 (EDT)
Date: Thu, 4 Sep 2014 17:11:23 -0300
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Message-ID: <20140904201123.GA9116@khazad-dum.debian.net>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com

On Thu, 04 Sep 2014, Toshi Kani wrote:
> This patch sets WT to the PA4 slot in the PAT MSR when the processor
> is not affected by the PAT errata.  The upper 4 slots of the PAT MSR
> are continued to be unused on the following Intel processors.
> 
>   errata           cpuid
>   --------------------------------------
>   Pentium 2, A52   family 0x6, model 0x5
>   Pentium 3, E27   family 0x6, model 0x7
>   Pentium M, Y26   family 0x6, model 0x9
>   Pentium 4, N46   family 0xf, model 0x0
> 
> For these affected processors, _PAGE_CACHE_MODE_WT is redirected to UC-
> per the default setup in __cachemode2pte_tbl[].

There are at least two PAT errata.  The blacklist is in
arch/x86/kernel/cpu/intel.c:

        if (c->x86 == 6 && c->x86_model < 15)
                clear_cpu_cap(c, X86_FEATURE_PAT);

It covers model 13, which is not in your blacklist.

It *is* possible that PAT would work on model 13, as I don't think it has
any PAT errata listed and it was blacklisted "just in case" (from memory. I
did not re-check), but this is untested, and unwise to enable on an aging
platform.

I am worried of uncharted territory, here.  I'd actually advocate for not
enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
is using them as well.  Is this a real concern, or am I being overly
cautious?

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
