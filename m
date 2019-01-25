Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8B738E00CD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 04:31:00 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id l73so1900821wmb.1
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 01:31:00 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id k20si87479915wrd.405.2019.01.25.01.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 01:30:59 -0800 (PST)
Date: Fri, 25 Jan 2019 10:30:52 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/17] Fix "x86/alternatives: Lockdep-enforce text_mutex
 in text_poke*()"
Message-ID: <20190125093052.GA27998@zn.tnic>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-2-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190117003259.23141-2-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>

On Wed, Jan 16, 2019 at 04:32:43PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> text_mutex is currently expected to be held before text_poke() is
> called, but we kgdb does not take the mutex, and instead *supposedly*
> ensures the lock is not taken and will not be acquired by any other core
> while text_poke() is running.
> 
> The reason for the "supposedly" comment is that it is not entirely clear
> that this would be the case if gdb_do_roundup is zero.

I guess that variable name is "kgdb_do_roundup" ?

> This patch creates two wrapper functions, text_poke() and

Avoid having "This patch" or "This commit" in the commit message. It is
tautologically useless.

Also, do

$ git grep 'This patch' Documentation/process

for more details.

> text_poke_kgdb() which do or do not run the lockdep assertion
> respectively.
> 
> While we are at it, change the return code of text_poke() to something
> meaningful. One day, callers might actually respect it and the existing
> BUG_ON() when patching fails could be removed. For kgdb, the return
> value can actually be used.
> 
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Fixes: 9222f606506c ("x86/alternatives: Lockdep-enforce text_mutex in text_poke*()")
> Suggested-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/include/asm/text-patching.h |  1 +
>  arch/x86/kernel/alternative.c        | 52 ++++++++++++++++++++--------
>  arch/x86/kernel/kgdb.c               | 11 +++---
>  3 files changed, 45 insertions(+), 19 deletions(-)

...

> +/**
> + * text_poke_kgdb - Update instructions on a live kernel by kgdb
> + * @addr: address to modify
> + * @opcode: source of the copy
> + * @len: length to copy
> + *
> + * Only atomic text poke/set should be allowed when not doing early patching.
> + * It means the size must be writable atomically and the address must be aligned
> + * in a way that permits an atomic write. It also makes sure we fit on a single
> + * page.
> + *
> + * Context: should only be used by kgdb, which ensures no other core is running,
> + *	    despite the fact it does not hold the text_mutex.
> + */
> +void *text_poke_kgdb(void *addr, const void *opcode, size_t len)

text_poke_unlocked() I guess. I don't think kgdb is that special that it
needs its own function flavor.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
