Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 05F096B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:20:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2670295dak.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 01:20:49 -0700 (PDT)
Date: Thu, 14 Jun 2012 01:20:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] shmem: replace_page must flush_dcache and others
In-Reply-To: <20120608084033.GA21818@schnuecks.de>
Message-ID: <alpine.LSU.2.00.1206140049350.5499@eggly.anvils>
References: <alpine.LSU.2.00.1205311524160.4512@eggly.anvils> <20120608084033.GA21818@schnuecks.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Baatz <gmbnomis@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Rob Clark <rob.clark@linaro.org>, Cong Wang <xiyou.wangcong@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-fsdevel@kernel.org, linux-kernel@vger.kernel.org

On Fri, 8 Jun 2012, Simon Baatz wrote:
> On Thu, May 31, 2012 at 03:31:27PM -0700, Hugh Dickins wrote:
> > * shmem_replace_page must flush_dcache_page after copy_highpage [akpm]
> 
> >  
> > -	*pagep = newpage;
> >  	page_cache_get(newpage);
> >  	copy_highpage(newpage, oldpage);
> > +	flush_dcache_page(newpage);
> >  
> 
> Couldn't we use the lighter flush_kernel_dcache_page() here (like in
> fs/exec.c copy_strings())?  If I got this correctly, the page is
> copied via the kernel mapping and thus, only the kernel mapping needs
> to be flushed.

Sorry for being so slow to respond, I had to focus on something else.

That's an interesting question you raise: I think you are almost right.

You are correct that it's copied via kernel mapping; and this page
cannot yet be visible to userspace.

But I have to say that you're "almost" right, because when I look up
flush_kernel_dcache_page(), I notice that it's supposed to be called
while the page is still kmapped (if kmap() or kmap_atomic() were
necessary).  So I would have to pull apart copy_highpage() and
do it inside there.

There are four uses of flush_dcache_page() in mm/shmem.c.  One of
those (in do_shmem_file_read()) should certainly not be converted
to flush_kernel_dcache_page(), but the rest could be.

However, I'm reluctant to do so myself, since I don't test on any
architecture which has a non-default flush_kernel_dcache_page(),
and I'm not at all familiar with it either.

fs/exec.c is rather an exception to be using it.  I believe it was
introduced to solve a coherency issue at the block or driver level,
and generally nothing in fs or mm has been using it.

You may well be right that savings (on arm, mips, parisc) could be
made in various places by using it in place of flush_dcache_page().
But I'd rather leave that exercise to someone who understands better
what they're doing, and can see the results if they get it wrong.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
