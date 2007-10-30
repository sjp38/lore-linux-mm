Received: by nz-out-0506.google.com with SMTP id s1so1501079nze
        for <linux-mm@kvack.org>; Tue, 30 Oct 2007 06:16:41 -0700 (PDT)
Message-ID: <45a44e480710300616p34b0a159m87de78d0a4d43028@mail.gmail.com>
Date: Tue, 30 Oct 2007 09:16:40 -0400
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
In-Reply-To: <1193738177.27652.69.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
	 <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
	 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
	 <1193738177.27652.69.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On 10/30/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> So page->index does what you want it to, identify which part of the
> framebuffer this particular page belongs to.

Ok. I'm attempting to walk the code sequence. Here's what I think:

- driver loads
- driver vmalloc()s its fb
- this creates the necessary pte entries
then...
- app mmap(/dev/fb0)
- vma is created
- defio mmap adds this vma to private list (equivalent of
address_space or anon_vma)
- app touches base + pixel(128,128) = base + 16k
- page fault
- defio nopage gets called
- defio nopage does vmalloc_to_page(base+16k)
- that finds the correct struct page corresponding to that vaddr.
page->index has not been set by anyone so far, right?
* ah... i see, you are suggesting that this is where I could set the
index since i know the offset i want it to represent. right?
- defio mkwrite get called. defio adds page to its list. schedules delayed work
- app keeps writing the page
- delayed work occurs
- foreach vma { foreach page { page_mkclean_one(page, vma) }
- cycle repeats...

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
