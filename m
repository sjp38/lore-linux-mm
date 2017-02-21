Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5B96B0387
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 15:46:58 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id s41so96055064ioi.5
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 12:46:58 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 14si15055430pfs.255.2017.02.21.12.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 12:46:57 -0800 (PST)
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and
 PR_GET_MAX_VADDR
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
 <20170218092133.GA17471@node.shutemov.name>
 <20170220131515.GA9502@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0d05ac45-a139-6f8e-f98b-71876fbb509d@intel.com>
Date: Tue, 21 Feb 2017 12:46:55 -0800
MIME-Version: 1.0
In-Reply-To: <20170220131515.GA9502@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

Let me make sure I'm grokking what you're trying to do here.

On 02/20/2017 05:15 AM, Kirill A. Shutemov wrote:
> +/* MPX cannot handle addresses above 47-bits yet. */
> +unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
> +		unsigned long flags)
> +{
> +	if (!kernel_managing_mpx_tables(current->mm))
> +		return addr;
> +	if (addr + len <= DEFAULT_MAP_WINDOW)
> +		return addr;

At this point, we know MPX management is on and the hint is for memory
above DEFAULT_MAP_WINDOW?

> +	if (flags & MAP_FIXED)
> +		return -ENOMEM;

... and if it's a MAP_FIXED request, fail it.

> +	if (len > DEFAULT_MAP_WINDOW)
> +		return -ENOMEM;

What is this case for?  If addr+len wraps?

> +	/* Look for unmap area within DEFAULT_MAP_WINDOW */
> +	return 0;
> +}

Otherwise, blow away the hint, which we know is high and needs to
be discarded?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
