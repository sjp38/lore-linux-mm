Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18F576B0274
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:18:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b189so751349wmd.5
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:18:11 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k129si2603551wmf.199.2017.11.15.06.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 06:18:09 -0800 (PST)
Date: Wed, 15 Nov 2017 15:18:02 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
In-Reply-To: <20171115121042.dt2us5fsuqmepx4i@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1711151509060.1805@nanos>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1711141630210.2044@nanos> <20171114202102.crpgiwgv2lu5aboq@node.shutemov.name> <alpine.DEB.2.20.1711142131010.2221@nanos> <20171114222718.76w4lmclf6wasbl3@node.shutemov.name>
 <alpine.DEB.2.20.1711142354520.2221@nanos> <20171115112702.e2m66wons37imtcj@node.shutemov.name> <alpine.DEB.2.20.1711151238500.1805@nanos> <20171115121042.dt2us5fsuqmepx4i@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 15 Nov 2017, Kirill A. Shutemov wrote:
> On Wed, Nov 15, 2017 at 12:39:40PM +0100, Thomas Gleixner wrote:
> > > I *think* we should be fine with checking unaligned 'addr'.
> > 
> > I think we should keep it consistent for the normal and the huge case and
> > just check aligned and be done with it.
> 
> Aligned 'addr'? Or 'len'? Both?
> 
> We would have problem with checking aligned addr. I steped it in hugetlb
> case:
> 
>   - User asks for mmap((1UL << 47) - PAGE_SIZE, 2 << 20, MAP_HUGETLB);
> 
>   - On 4-level paging machine this gives us invalid hint address as
>     'TASK_SIZE - len' is more than 'addr'. Goto get_unmapped_area.
> 
>   - On 5-level paging machine hint address gets rounded up to next 2MB
>     boundary that is exactly 1UL << 47 and we happily allocate from full
>     address space which may lead to trouble.

Ah, right because that ALIGN is using huge_page_size(h) and not PAGE_SIZE.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
