Date: Thu, 8 Feb 2007 16:22:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Drop PageReclaim()
In-Reply-To: <20070208151341.7e27ca59.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702081613300.15669@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
 <20070208140338.971b3f53.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
 <20070208142431.eb81ae70.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702081425000.14424@schroedinger.engr.sgi.com>
 <20070208143746.79c000f5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702081438510.15063@schroedinger.engr.sgi.com>
 <20070208151341.7e27ca59.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007, Andrew Morton wrote:

> I expect that'll be OK for pages which were written back by the vm scanner.
>  But it also means that pages which were written back by
> pdflush/balance_dirty_pages/fsync/etc will now all also be eligible for
> rotation.  ie: the vast majority of written-back pages.
> 
> Whether that will make much difference to page aging I don't know.  But it
> will cause more lru->lock traffic.

I'd rather avoid more lru lock traffic. Could we simply drop the rotation?
Writeback is typically a relatively long process. The page should 
have made some progress through the inactive list by the time the 
write is complete.

One additional issue that is raised by the writeback pages remaining on 
the LRU lists is that we can get into the same livelock situation as with 
mlocked pages if we keep on skipping over writeback pages. However, the 
system is already slow due to us waiting for I/O. I guess we just do not 
notice.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
