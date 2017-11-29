Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE636B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 03:53:01 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i7so1754082pgq.7
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 00:53:01 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id ay5si928003plb.457.2017.11.29.00.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 Nov 2017 00:53:00 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] vfs: Add PERM_* symbolic helpers for common file mode/permissions
In-Reply-To: <20171128111214.42esi4igzgnldsx5@gmail.com>
References: <20171126231403.657575796@linutronix.de> <20171126232414.563046145@linutronix.de> <20171127094156.rbq7i7it7ojsblfj@hirez.programming.kicks-ass.net> <20171127100635.kfw2nspspqbrf2qm@gmail.com> <CA+55aFyLC9+S=MZueRXMmwwnx47bhovXr1YhRg+FAPFfQZXoYA@mail.gmail.com> <20171128111214.42esi4igzgnldsx5@gmail.com>
Date: Wed, 29 Nov 2017 19:52:56 +1100
Message-ID: <87tvxda2l3.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, linux-mm <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

Ingo Molnar <mingo@kernel.org> writes:
...
> Index: tip/include/linux/stat.h
> ===================================================================
> --- tip.orig/include/linux/stat.h
> +++ tip/include/linux/stat.h
> @@ -6,6 +6,34 @@
>  #include <asm/stat.h>
>  #include <uapi/linux/stat.h>
>  
> +/*
> + * Human readable symbolic definitions for common
> + * file permissions:
> + */
> +#define PERM_r________	0400
> +#define PERM_r__r_____	0440
> +#define PERM_r__r__r__	0444
> +
> +#define PERM_rw_______	0600
> +#define PERM_rw_r_____	0640
> +#define PERM_rw_r__r__	0644
> +#define PERM_rw_rw_r__	0664
> +#define PERM_rw_rw_rw_	0666
> +
> +#define PERM__w_______	0200
> +#define PERM__w__w____	0220
> +#define PERM__w__w__w_	0222
> +
> +#define PERM_r_x______	0500
> +#define PERM_r_xr_x___	0550
> +#define PERM_r_xr_xr_x	0555
> +
> +#define PERM_rwx______	0700
> +#define PERM_rwxr_x___	0750
> +#define PERM_rwxr_xr_x	0755
> +#define PERM_rwxrwxr_x	0775
> +#define PERM_rwxrwxrwx	0777

I see what you're trying to do with all the explicit underscores, but it
does make them look kinda ugly.

What if you just used underscores to separate the user/group/other, and
the unset permission bits are just omitted.

Then the two most common cases would be:

  PERM_rw_r_r
  PERM_r_r_r

Both of those read nicely I think. ie. the first is "perm read write,
read, read".

Full set would be:

#define PERM_r			0400
#define PERM_r_r		0440
#define PERM_r_r_r		0444

#define PERM_rw			0600
#define PERM_rw_r		0640
#define PERM_rw_r_r		0644
#define PERM_rw_rw_r		0664
#define PERM_rw_rw_rw		0666

#define PERM_w			0200
#define PERM_w_w		0220
#define PERM_w_w_w		0222

#define PERM_rx			0500
#define PERM_rx_rx		0550
#define PERM_rx_rx_rx		0555

#define PERM_rwx		0700
#define PERM_rwx_rx		0750
#define PERM_rwx_rx_rx		0755
#define PERM_rwx_rwx_rx		0775
#define PERM_rwx_rwx_rwx	0777


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
