Date: Thu, 15 Mar 2007 13:38:29 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch 2/2] splice: dont readpage
Message-ID: <20070315123829.GR15400@kernel.dk>
References: <20070314121440.GA926@wotan.suse.de> <20070314121543.GB926@wotan.suse.de> <20070315115454.GN15400@kernel.dk> <20070315122736.GB8321@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070315122736.GB8321@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15 2007, Nick Piggin wrote:
> On Thu, Mar 15, 2007 at 12:54:54PM +0100, Jens Axboe wrote:
> > On Wed, Mar 14 2007, Nick Piggin wrote:
> > > 
> > > Splice does not need to readpage to bring the page uptodate before writing
> > > to it, because prepare_write will take care of that for us.
> > 
> > Ah great, always good to get rid of some code.
> 
> Yeah, it should especially make block (but not page) sized and aligned
> writes into uncached files work much better, AFAIKS (won't require the
> synchronous read).

Yep, it's a nice improvement! Plus a cleanup.

> > > Splice is also wrong to SetPageUptodate before the page is actually uptodate.
> > > This results in the old uninitialised memory leak. This gets fixed as a
> > > matter of course when removing the readpage logic.
> > 
> > Leak, how? The page should still be locked all through to the copy.
> > Anyway, doesn't matter since you've killed it anyway. I have applied
> > this patch.
> 
> The read side doesn't need to lock the page if it is uptodate, and doesn't.

Oh, then there's definitely an issue.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
