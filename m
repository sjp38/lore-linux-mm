Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 1E0848D0001
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:43:34 -0500 (EST)
Date: Thu, 6 Dec 2012 16:35:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206163511.GB17258@suse.de>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
 <20121206152234.GA5309@polaris.bitmath.org>
 <CA+55aFwuuAQdoBx_R4CaHJp1ZdRTAwG8n1ZfiKmpZUwwZ9iUkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwuuAQdoBx_R4CaHJp1ZdRTAwG8n1ZfiKmpZUwwZ9iUkw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Henrik Rydberg <rydberg@euromail.se>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 06, 2012 at 08:10:13AM -0800, Linus Torvalds wrote:
> Ok, so it's isolate_freepages_block+0x88, and as Jan Kara already
> guessed from just the offset, that is indeed likely the PageBuddy()
> test.
> 
> On Thu, Dec 6, 2012 at 7:22 AM, Henrik Rydberg <rydberg@euromail.se> wrote:
> >
> >  http://bitmath.org/test/oops-3.7-rc8.jpg
> >
> > ffffffff810a6d6a:       eb 1c                   jmp    ffffffff810a6d88 <isolate_freepages_block+0x88>
> > ffffffff810a6d6c:       0f 1f 40 00             nopl   0x0(%rax)
> 
> On the first entry to the loop, we jump *into* the loop, over the end
> condition (the compiler has basically turned. And we jump directly to
> the faulting instruction. Looking at the register state, though, we're
> not at the first iteration of the loop, so we don't have to worry
> about that case. The loop itself then starts with:
> 
> > ffffffff810a6d70:       48 83 c5 01             add    $0x1,%rbp
> > ffffffff810a6d74:       48 83 c3 40             add    $0x40,%rbx
> 
> The above is the "blockpfn++, cursor++" part of the loop, while the
> test below is the loop condition ("blockpfn < end_pfn"):
> 
> > ffffffff810a6d78:       49 39 ed                cmp    %rbp,%r13
> > ffffffff810a6d7b:       0f 86 cf 00 00 00       jbe    ffffffff810a6e50 <isolate_freepages_block+0x150>
> 
> From your image, %rbp is 0x070000 and %r13 is 0x0702f9.
> 
> The "pfn_valid_within()" test is a no-op because we don't have holes
> in zones on x86, so then we have
> 

That thing is not about holes in zones, it's about holes within a
MAX_ORDER_NR_PAGES block but either way it's a no-op x86 and we're not doing
a pfn_valid check in this loop. I didn't look back in time but I have a
vague recollection that this used to be always start with an aligned PFN
but with large amounts of churn since, it's no longer true.

>                 if (!valid_page)
>                         valid_page = page;
> 
> which generates a test+cmove:
> 
> > ffffffff810a6d81:       4d 85 e4                test   %r12,%r12
> > ffffffff810a6d84:       4c 0f 44 e3             cmove  %rbx,%r12
> 
> (which is how we can tell we're not at the beginning: 'valid_page' is
> 0xffffea0001bfbe40, while the current page is 0xffffea0001c00000).
> 
> .. and finally the oopsing instruction from PageBuddy(), which is the
> read of the 'page->_mapcount'
> 
> > ffffffff810a6d88:       8b 43 18                mov    0x18(%rbx),%eax
> > ffffffff810a6d8b:       83 f8 80                cmp    $0xffffff80,%eax
> > ffffffff810a6d8e:       75 e0                   jne    ffffffff810a6d70 <isolate_freepages_block+0x70>
> 
> So yeah, that loop has apparently wandered into la-la-land. end_pfn
> must be somehow wrong.
> 

I think we wandered into a hole where there is no valid struct page.

> Mel, does any of this ring a bell (Andrew also added to the cc, since
> the patches came through him).
> 

It reminded me of a similar bug in the migration scanner which I mentioned
in the patch elsewhere in the thread but carelessly failed to cc Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
