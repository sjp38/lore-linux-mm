Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA796B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:19:20 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id wy7so59644585lbb.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 12:19:20 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id bm7si36524606wjc.230.2016.06.14.12.19.18
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 12:19:18 -0700 (PDT)
Date: Tue, 14 Jun 2016 21:19:16 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Message-ID: <20160614191916.GI30015@pd.tnic>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <57603DC0.9070607@linux.intel.com>
 <20160614193407.1470d998@lxorguk.ukuu.org.uk>
 <576052E0.3050408@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <576052E0.3050408@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com

On Tue, Jun 14, 2016 at 11:54:24AM -0700, Dave Hansen wrote:
> Lukasz, Borislav suggested using static_cpu_has_bug(), which will do the
> alternatives patching.  It's definitely the right thing to use here.

Yeah, either that or do an

alternative_call(null_func, fix_pte_peak, X86_BUG_PTE_LEAK, ...)

or so and you'll need a dummy function to call on !X86_BUG_PTE_LEAK
CPUs.

The static_cpu_has_bug() thing should be most likely a penalty
of a single JMP (I have to look at the asm) but then since the
callers are inlined, you'll have to patch all those places where
*ptep_get_and_clear() get inlined.

Shouldn't be a big deal still but...

"debug-alternative" and a kvm guest should help you there to get a quick
idea.

HTH.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
