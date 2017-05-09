Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF8A3280757
	for <linux-mm@kvack.org>; Tue,  9 May 2017 16:41:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w50so3051342wrc.4
        for <linux-mm@kvack.org>; Tue, 09 May 2017 13:41:41 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q11si1021509wra.35.2017.05.09.13.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 13:41:40 -0700 (PDT)
Date: Tue, 9 May 2017 22:41:27 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded
 mm
In-Reply-To: <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
Message-ID: <alpine.DEB.2.20.1705092236290.2295@nanos>
References: <cover.1494160201.git.luto@kernel.org> <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Sun, 7 May 2017, Andy Lutomirski wrote:
>  /* context.lock is held for us, so we don't need any locking. */
>  static void flush_ldt(void *current_mm)
>  {
> +	struct mm_struct *mm = current_mm;
>  	mm_context_t *pc;
>  
> -	if (current->active_mm != current_mm)
> +	if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)

While functional correct, this really should compare against 'mm'.

>  		return;
>  
> -	pc = &current->active_mm->context;
> +	pc = &mm->context;

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
