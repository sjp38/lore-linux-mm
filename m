Date: Fri, 24 Aug 2001 13:42:59 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: SWAP_MAP_MAX: How?
In-Reply-To: <20010824121951.A4389@redhat.com>
Message-ID: <Pine.LNX.4.21.0108241323280.1044-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2001, Stephen C. Tweedie wrote:
> On Fri, Aug 24, 2001 at 12:16:12PM +0100, Hugh Dickins wrote:
> > The SWAP_MAP_MAX case imposes a severe constraint on how swapoff
> > may be implemented correctly.  I am still struggling to understand
> > how a swap count might reach SWAP_MAP_MAX 0x7fff on 2.4.  Please,
> > can someone enlighten me?
> 
> The swap count is incremented for every separate mm which references a
> page.  That basically means that demand-zero (heap and anon mmap)
> pages which get created by a parent process and then shared by a
> forked child process will get the swap count bumped on that page
> whenever it gets swapped.  The raised count only survives as long as
> neither parent nor child modifies the page --- as soon as
> copy-on-write occurs, the process which modified the page gets a new
> copy and the reference count on the original page gets decremented.
> 
> Of course, any one process can fork as many times as it likes, leading
> to multiply-raised swap counts.

Many thanks for the reply.  That much I understand, but with PID_MAX
0x8000 (and CLONE_PID disallowed on user processes), I don't see how
any one swap entry could reach a count of 0x7fff - each fork raises
the count, but each exit lowers it.

I can imagine approaching 0x7fff with an anonymous page somehow mapped
into every user process, and temporary incrementations, e.g. from
valid_swaphandles(), perhaps taking it over the edge; but if that's
what it's about, well, it's easier to avoid such cases than to handle
SWAP_MAP_MAX in swapoff (the temporary incrementations are all about
trying to avoid a worrying message which simply should not be shown).

Doesn't it need an anonymous page mapped multiple (e.g. 256) times
into multiple (e.g. 256) mms to reach the limit?  And there's an obvious
way that can happen, by multiply attaching a piece of IPC Shared Memory,
and multiply forking.  But in that case it's the shared memory object
which gets the large number of references, and the swap counts stay 1.

So: I still don't get it.
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
