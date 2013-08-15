Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 8FF7F6B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 11:03:27 -0400 (EDT)
Date: Thu, 15 Aug 2013 10:03:25 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130815150325.GA4729@medulla.variantweb.net>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <CAA25o9Q1KVHEzdeXJFe9A8K9MULysq_ShWrUBZM4-h=5vmaQ8w@mail.gmail.com>
 <20130814161753.GB2706@gmail.com>
 <CAA_GA1da3jkOO9Y3+L6_DMmiH8wsbJJ-xcUxUK_Gh2SYPPbjoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1da3jkOO9Y3+L6_DMmiH8wsbJJ-xcUxUK_Gh2SYPPbjoA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

On Thu, Aug 15, 2013 at 08:18:46AM +0800, Bob Liu wrote:
> On Thu, Aug 15, 2013 at 12:17 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Hi Luigi,
> >
> > On Wed, Aug 14, 2013 at 08:53:31AM -0700, Luigi Semenzato wrote:
> >> During earlier discussions of zswap there was a plan to make it work
> >> with zsmalloc as an option instead of zbud. Does zbud work for
> >
> > AFAIR, it was not an optoin but zsmalloc was must but there were
> > several objections because zswap's notable feature is to dump
> > compressed object to real swap storage. For that, zswap needs to
> > store bounded objects in a zpage so that dumping could be bounded, too.
> > Otherwise, it could encounter OOM easily.
> >
> 
> AFAIR, the next step of zswap should be have a modular allocation layer so that
> users can choose zsmalloc or zbud to use.
> 
> Seth?

Yes, that should be doable without too much effort, at least if you
disregard writeback.  I believe I wrote the code so that you can make
the registration of the eviction handler for the allocator NULL, in
which case, zswap can just fail the store and fall back to swap. That
reintroduces the inverse LRU issue when the pool is full, but in the
meantime you potentially get much better effective compression.  Then
tackle zsmalloc writeback separately.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
