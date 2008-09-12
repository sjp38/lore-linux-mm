Subject: Re: [RFC PATCH] discarding swap
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0809121154430.12812@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
	 <20080910173518.GD20055@kernel.dk>
	 <Pine.LNX.4.64.0809102015230.16131@blonde.site>
	 <1221082117.13621.25.camel@macbook.infradead.org>
	 <Pine.LNX.4.64.0809121154430.12812@blonde.site>
Content-Type: text/plain
Date: Fri, 12 Sep 2008 07:09:27 -0700
Message-Id: <1221228567.3919.35.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-09-12 at 13:10 +0100, Hugh Dickins wrote:
> So long as the I/O schedulers guarantee that a WRITE bio submitted
> to an area already covered by a DISCARD_NOBARRIER bio cannot pass that
> DISCARD_NOBARRIER - ...

> That seems a reasonable guarantee to me, and perhaps it's trivially
> obvious to those who know their I/O schedulers; but I don't, so I'd
> like to hear such assurance given.

No, that's the point. the I/O schedulers _don't_ give you that guarantee
at all. They can treat DISCARD_NOBARRIER just like a write. That's all
it is, really -- a special kind of WRITE request without any data.

But -- and this came as a bit of a shock to me -- they don't guarantee
that writes don't cross writes on their queue. If you issue two WRITE
requests to the same sector, you have to make sure for _yourself_ that
there is some kind of barrier between them to keep them in the right
order.

Does swap do that, when a page on the disk is deallocated and then used
for something else?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
