Date: Fri, 24 Aug 2001 12:19:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: SWAP_MAP_MAX: How?
Message-ID: <20010824121951.A4389@redhat.com>
References: <Pine.LNX.4.21.0108241158230.979-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0108241158230.979-100000@localhost.localdomain>; from hugh@veritas.com on Fri, Aug 24, 2001 at 12:16:12PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Aug 24, 2001 at 12:16:12PM +0100, Hugh Dickins wrote:
> The SWAP_MAP_MAX case imposes a severe constraint on how swapoff
> may be implemented correctly.  I am still struggling to understand
> how a swap count might reach SWAP_MAP_MAX 0x7fff on 2.4.  Please,
> can someone enlighten me?

The swap count is incremented for every separate mm which references a
page.  That basically means that demand-zero (heap and anon mmap)
pages which get created by a parent process and then shared by a
forked child process will get the swap count bumped on that page
whenever it gets swapped.  The raised count only survives as long as
neither parent nor child modifies the page --- as soon as
copy-on-write occurs, the process which modified the page gets a new
copy and the reference count on the original page gets decremented.

Of course, any one process can fork as many times as it likes, leading
to multiply-raised swap counts.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
