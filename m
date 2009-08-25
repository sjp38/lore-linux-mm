Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4AE356B00B0
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:17:53 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2185694bwz.38
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 13:17:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A93033B.3050606@vflare.org>
References: <200908241007.47910.ngupta@vflare.org>
	 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
	 <4A92EBB4.1070101@vflare.org>
	 <84144f020908241243y11f10e8eudc758b61527e0e9c@mail.gmail.com>
	 <4A93033B.3050606@vflare.org>
Date: Tue, 25 Aug 2009 07:26:53 +0300
Message-ID: <84144f020908242126n5c7d93aah7305f4da64f6965@mail.gmail.com>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org, hugh.dickins@tiscali.co.uk
List-ID: <linux-mm.kvack.org>

Hi Nitin,

On Tue, Aug 25, 2009 at 12:16 AM, Nitin Gupta<ngupta@vflare.org> wrote:
> Now, if code cleanup is the aim rather that reducing the no. of conversions,
> then I think use of PFNs is still preferred due to minor implementation
> details mentioned above.
>
> So, I think the interface should be left in its current state.

I don't agree. For example, grow_pool() does xv_alloc_page() and
immediately passes the PFN to get_ptr_atomic() which does conversion
back to struct page. Passing PFNs around is not a good idea because
it's very non-obvious, potentially broken (the 64-bit issue Hugh
mentioned), and you lose type checking. The whole wrapper thing around
kmap() (which is also duplicated in the actual driver) is a pretty
clear indication that you're doing it the wrong way.

So again, _storing_ PFNs in internal data structures is probably a
reasonable optimization (given the 64-bit issues are sorted out) but
making the APIs work on them is not. It's much cleaner to have few
places that do page_to_pfn() on stores and pass struct pages around.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
