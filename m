Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF2DB6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 15:29:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u98so11779169wrb.4
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 12:29:55 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e7si8270569wma.119.2017.11.14.12.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 12:29:54 -0800 (PST)
Date: Tue, 14 Nov 2017 21:29:41 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171114192113.t7pq5p2n5emmiw2n@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1711142128170.2221@nanos>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1711141630210.2044@nanos> <20171114192113.t7pq5p2n5emmiw2n@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Nov 2017, Kirill A. Shutemov wrote:
> On Tue, Nov 14, 2017 at 05:01:50PM +0100, Thomas Gleixner wrote:
> > +bool mmap_address_hint_valid(unsigned long addr, unsigned long len)
> > +{
> > +	if (TASK_SIZE - len < addr)
> > +		return false;
> > +#if CONFIG_PGTABLE_LEVELS >= 5
> > +	return (addr > DEFAULT_MAP_WINDOW) == (addr + len > DEFAULT_MAP_WINDOW);
> 
> Is it micro optimization? I don't feel it necessary. It's not that hot
> codepath to care about few cycles. (And one more place to care about for
> boot-time switching.)
> 
> If you think it's needed, maybe IS_ENABLED() instead?

You're right. It's can be unconditional, For page table levels < 5 its just
redundant as its covered by the TASK_SIZE check already.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
