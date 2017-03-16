Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1AD56B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:45:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g2so106188959pge.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:45:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s1si6101162plj.295.2017.03.16.11.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 11:45:30 -0700 (PDT)
Date: Thu, 16 Mar 2017 11:45:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm] "x86/atomic: move __arch_atomic_add_unless out of line"
 build error
Message-Id: <20170316114529.b94234511ed04faf3605a364@linux-foundation.org>
In-Reply-To: <20170316164110.GK32070@tassilo.jf.intel.com>
References: <20170316044704.GA729@jagdpanzerIV.localdomain>
	<CACT4Y+asa7rDwjQi_09cYGsgqy0LFRRiCHq3=3t6__VUMLzmXg@mail.gmail.com>
	<20170316164110.GK32070@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, 20170315021431.13107-3-andi@firstfloor.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 16 Mar 2017 09:41:10 -0700 Andi Kleen <ak@linux.intel.com> wrote:

> > Andi, why did you completely remove __arch_atomic_add_unless() from
> > the header? Don't we need at least a declaration there?
> 
> Actually it's there in my git version:
> 
> I wonder where it disappeared.
> 
> -/**
> - * __atomic_add_unless - add unless the number is already a given value
> - * @v: pointer of type atomic_t
> - * @a: the amount to add to v...
> - * @u: ...unless v is equal to u.
> - *
> - * Atomically adds @a to @v, so long as @v was not already @u.
> - * Returns the old value of @v.
> - */
> -static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
> -{
> -       int c, old;
> -       c = atomic_read(v);
> -       for (;;) {
> -               if (unlikely(c == (u)))
> -                       break;
> -               old = atomic_cmpxchg((v), c, c + (a));
> -               if (likely(old == c))
> -                       break;
> -               c = old;
> -       }
> -       return c;
> -}
> +int __atomic_add_unless(atomic_t *v, int a, int u);

That was me fixing rejects (from
asm-generic-x86-wrap-atomic-operations.patch), incompletely.

--- a/arch/x86/include/asm/atomic.h~x86-atomic-move-__atomic_add_unless-out-of-line-fix
+++ a/arch/x86/include/asm/atomic.h
@@ -235,6 +235,8 @@ ATOMIC_OPS(xor, ^)
 #undef ATOMIC_FETCH_OP
 #undef ATOMIC_OP
 
+int __arch_atomic_add_unless(atomic_t *v, int a, int u);
+
 /**
  * arch_atomic_inc_short - increment of a short integer
  * @v: pointer to type int

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
