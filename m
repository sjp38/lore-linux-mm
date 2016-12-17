Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE646B0253
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 02:45:16 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id t196so13243422lff.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 23:45:16 -0800 (PST)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id h99si5815549lfi.54.2016.12.16.23.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 23:45:14 -0800 (PST)
Date: Sat, 17 Dec 2016 08:45:12 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context register 1
Message-ID: <20161217074512.GC23567@ravnborg.org>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Mike

> diff --git a/arch/sparc/kernel/fpu_traps.S b/arch/sparc/kernel/fpu_traps.S
> index 336d275..f85a034 100644
> --- a/arch/sparc/kernel/fpu_traps.S
> +++ b/arch/sparc/kernel/fpu_traps.S
> @@ -73,6 +73,16 @@ do_fpdis:
>  	ldxa		[%g3] ASI_MMU, %g5
>  	.previous
>  
> +661:	nop
> +	nop
> +	.section	.sun4v_2insn_patch, "ax"
> +	.word		661b
> +	mov		SECONDARY_CONTEXT_R1, %g3
> +	ldxa		[%g3] ASI_MMU, %g4
> +	.previous
> +	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
> +	mov		SECONDARY_CONTEXT, %g3
> +
>  	sethi		%hi(sparc64_kern_sec_context), %g2

You missed the second instruction to patch with here.
This bug repeats itself further down.

Just noted while briefly reading the code - did not really follow the code.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
