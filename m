Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DE0A86B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 17:49:27 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id x125so643467pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 14:49:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id by6si3627703pad.69.2016.01.26.14.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 14:49:27 -0800 (PST)
Date: Tue, 26 Jan 2016 14:49:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: warn about VmData over RLIMIT_DATA
Message-Id: <20160126144926.21d854fe53b76bd03e34b0d1@linux-foundation.org>
In-Reply-To: <145358234948.18573.2681359119037889087.stgit@zurg>
References: <145358234948.18573.2681359119037889087.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

On Sat, 23 Jan 2016 23:52:29 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> This patch fixes 84638335900f ("mm: rework virtual memory accounting")

uh, I think I'll rewrite this to

: This patch provides a way of working around a slight regression introduced
: by 84638335900f ("mm: rework virtual memory accounting").

> Before that commit RLIMIT_DATA have control only over size of the brk region.
> But that change have caused problems with all existing versions of valgrind,
> because it set RLIMIT_DATA to zero.
> 
> This patch fixes rlimit check (limit actually in bytes, not pages)
> and by default turns it into warning which prints at first VmData misuse:
> "mmap: top (795): VmData 516096 exceed data ulimit 512000. Will be forbidden soon."
> 
> Behavior is controlled by boot param ignore_rlimit_data=y/n and by sysfs
> /sys/module/kernel/parameters/ignore_rlimit_data. For now it set to "y".
> 
> 
> ...
>
> +static inline bool is_data_mapping(vm_flags_t flags)
> +{
> +	return (flags & ((VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)) |
> +					VM_WRITE | VM_SHARED)) == VM_WRITE;
> +}

This (copied from existing code) hurts my brain.  We're saying "if it
isn't stack and it's unshared and writable, it's data", yes?

hm.  I guess that's because with a shared mapping we don't know who to
blame for the memory consumption so we blame nobody.  But what about
non-shared read-only mappings?

Can we please have a comment here fully explaining the thinking?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
