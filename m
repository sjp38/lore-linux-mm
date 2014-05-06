Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0E60F6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 19:28:58 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so180428pde.29
        for <linux-mm@kvack.org>; Tue, 06 May 2014 16:28:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ff3si824773pbb.135.2014.05.06.16.28.57
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 16:28:58 -0700 (PDT)
Date: Tue, 6 May 2014 16:28:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC, PATCH 0/8] remap_file_pages() decommission
Message-Id: <20140506162856.2a94db336b91db5525ed0457@linux-foundation.org>
In-Reply-To: <20140506230323.GA14821@node.dhcp.inet.fi>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140506143542.1d4e5f41be58b3ad3543ffe3@linux-foundation.org>
	<CA+55aFwUO5ubckFFEF+R=yos-Qd3Br4Fy3-LpXL0bDWCmMhb6g@mail.gmail.com>
	<20140506230323.GA14821@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Wed, 7 May 2014 02:03:23 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> remap_file_pages(2) was invented to be able efficiently map parts of
> huge file into limited 32-bit virtual address space such as in database
> workloads.
> 
> Nonlinear mappings are pain to support and it seems there's no
> legitimate use-cases nowadays since 64-bit systems are widely available.
> 
> Let's deprecate remap_file_pages() syscall in hope to get rid of code
> one day.

Before we do this we should ensure that your proposed replacement is viable
and desirable.  If we later decide not to proceed with it, this patch will
sow confusion.

> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -152,6 +152,9 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  	int has_write_lock = 0;
>  	vm_flags_t vm_flags = 0;
>  
> +	printk_once(KERN_WARNING "%s (%d) uses depricated "

pr_warn_once(), "deprecated".

> +			"remap_file_pages(2) syscall.\n",
> +			current->comm, current->pid);
>  	if (prot)
>  		return err;

Can we provide more info than this?  Why is it deprecated, what do we
plan to do with it, what are people's options, etc?  Add "See
Documentation/remap_file_pages.txt", perhaps.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
