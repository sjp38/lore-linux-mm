Date: Thu, 15 Mar 2007 14:13:05 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] splice: dont steal
Message-ID: <20070315131305.GF8321@wotan.suse.de>
References: <20070314121440.GA926@wotan.suse.de> <20070315115237.GM15400@kernel.dk> <20070315122207.GA8321@wotan.suse.de> <20070315122723.GQ15400@kernel.dk> <20070315124531.GD8321@wotan.suse.de> <20070315125432.GT15400@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070315125432.GT15400@kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 01:54:32PM +0100, Jens Axboe wrote:
> On Thu, Mar 15 2007, Nick Piggin wrote:
> > On Thu, Mar 15, 2007 at 01:27:23PM +0100, Jens Axboe wrote:
> > > On Thu, Mar 15 2007, Nick Piggin wrote:
> > > > 
> > > > We should be able to allow for it with the new a_ops API I'm working
> > > > on.
> > > 
> > > "Should be" and in progress stuff, is it guarenteed to get there?
> > 
> > Well considering that it is needed in order to solve 3 different deadlock
> > scenarios in the core write(2) path without taking a big performance hit,
> > I'd hope so ;)
> > 
> > It isn't guaranteed, but I have only had positive feedback so far. Would
> > take a while to actually get merged, though.
> 
> It's not that I don't believe you, I'm just a little reluctant to rip
> stuff out with a promise to fix it later when foo and bar are merged,
> since things like that have a tendency not to get done because they are
> forgotten :-)

Fair enough. The API side is trivial, all I need to do is set a single
flag and make splice pass down the page, and set that flag when stealing.
Filesystems might vary from trivial to impossible, but I think most should
be OK. If the flag is there then they at least have the option.


> Do you have a test case for stealing failures? What I'm really asking is
> how critical is this?

I guess you could fill a filesystem completely, and have a sparse file
in it. Then steal a page and splice it in. The prepare_write should fail,
but the page will still be in pagecache, until it gets reclaimed, then
it will go back to zeroes.

(no I don't have a test case ;)).

You could do something like remove the page if prepare_write fails, but
there is still a window where a read can see it. Basically I can't see
a way that it can possibly work within our current prepare_write API,
and it is a data corruption bug, so in my opinion it is a candidate for
2.6.21 + stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
