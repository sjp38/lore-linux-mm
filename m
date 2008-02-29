Received: by wr-out-0506.google.com with SMTP id 60so5589308wri.8
        for <linux-mm@kvack.org>; Fri, 29 Feb 2008 03:58:53 -0800 (PST)
Message-ID: <84144f020802290358t2774f7bwd87efe79e7bd4235@mail.gmail.com>
Date: Fri, 29 Feb 2008 13:58:52 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: <1204285912.6243.93.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
	 <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
	 <1204285912.6243.93.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Fri, Feb 29, 2008 at 1:51 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>  I made page->reserve into PG_emergency and made that bit stick for the
>  lifetime of that page allocation. I then made kmem_is_emergency() look
>  up the head page backing that allocation's slab and return
>  PageEmergency().

[snip]

On Fri, Feb 29, 2008 at 1:51 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>  This is a stricter model than I had before, and has one ramification I'm
>  not entirely sure I like.
>
>  It means the page remains a reserve page throughout its lifetime, which
>  means the slab remains a reserve slab throughout its lifetime. Therefore
>  it may never be used for !reserve allocations. Which in turn generates
>  complexities for the partial list.

Hmm, so why don't we then clear the PG_emergency flag then and
allocate a new fresh page to the reserves?

On Fri, Feb 29, 2008 at 1:51 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>  Does this sound like something I should pursuit? I feel it might
>  complicate the slab allocators too much..

I can't answer that question until I see the code ;-). But overall, I
think it's better to put that code in SLUB rather than trying to work
around it elsewhere. The fact is, as soon as you have some sort of
reservation for _objects_, you need help from the SLUB allocator.

                           Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
