Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83CE26B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:01:33 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n8so1910558wmg.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:01:33 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u18si1415351wrc.235.2017.11.01.14.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 14:01:32 -0700 (PDT)
Date: Wed, 1 Nov 2017 22:01:28 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 01/23] x86, kaiser: prepare assembly for entry/exit CR3
 switching
In-Reply-To: <20171031223148.5334003A@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711012155000.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223148.5334003A@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Tue, 31 Oct 2017, Dave Hansen wrote:
>  
> +	pushq	%rdi
> +	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
> +	popq	%rdi

Can you please have a macro variant which does:

    SWITCH_TO_KERNEL_CR3_PUSH reg=%rdi

So the pushq/popq is inside the macro. This has two reasons:

   1) If KAISER=n the pointless pushq/popq go away

   2) We need a boottime switch for that stuff, so we better have all
      related code in the various macros in order to patch it in/out.

Also, please wrap these macros in #ifdef KAISER right away and provide the
stubs as well. It does not make sense to have them in patch 7 when patch 1
introduces them.

Aside of Boris comments this looks about right.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
