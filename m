Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 682506B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:11:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z96so1869721wrb.21
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:11:42 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 18si1329417wry.218.2017.11.01.14.11.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 14:11:41 -0700 (PDT)
Date: Wed, 1 Nov 2017 22:11:37 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <20171031223150.AB41C68F@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711012206050.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Tue, 31 Oct 2017, Dave Hansen wrote:

> 
> init_mm is for kernel-exclusive use.  If someone is allocating page
> tables in it, do not set _PAGE_USER on them.  This ensures that
> we do *not* set NX on these page tables in the KAISER code.

This changelog is confusing at best.

Why is this a kaiser issue? Nothing should ever create _PAGE_USER entries
in init_mm, right?

So this is a general improvement and creating a _PAGE_USER entry in init_mm
should be considered a bug in the first place.

> +/*
> + * _KERNPG_TABLE has _PAGE_USER clear which tells the KAISER code
> + * that this mapping is for kernel use only.  That makes sure that
> + * we leave the mapping usable by the kernel and do not try to
> + * sabotage it by doing stuff like setting _PAGE_NX on it.

So this comment should not mention KAISER at all. As I explained above
there are no user mappings in init_mm and this should be expressed here.

The fact that KAISER can make use of this information is a different story.

Other than that:

      Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
