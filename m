Date: Fri, 12 Jan 2001 11:45:26 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <87itnlovej.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.10.10101121138060.2249-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 12 Jan 2001, Zlatko Calusic wrote:
> 
> Performance of 2.4.0-pre2 is terrible as it is now. There is a big
> performance drop from 2.4.0. Simple test (that is not excessively
> swapping, I remind) shows this:
> 
> 2.2.17     -> make -j32  392.49s user 47.87s system 168% cpu 4:21.13 total
> 2.4.0      -> make -j32  389.59s user 31.29s system 182% cpu 3:50.24 total
> 2.4.0-pre2 -> make -j32  393.32s user 138.20s system 129% cpu 6:51.82 total

Marcelo's patch (which is basically the pre2 mm changes - the other was
the syntactic change of making "swap_cnt" be an argument to swap_out_mm()
rather than being a per-mm thing) will improve feel for stuff that doesn't
want to swap out - VM scanning is basically handled exclusively by kswapd,
and it only triggers under low-mem circumstances.

That's an effect of replacing "wakeup_kswapd(1)" with shrinking the inode
and dentry caches and page_launder(), and it is probably the nicest kernel
for stuff that wants to avoid caching stuff excessively. But it does mean
that we don't try to swap stuff out very much, and it also means that we
end up shrinking the directory cache in particular more aggressively than
before. Which is bad.

I really think that that page_launder() should be a "try_to_free_page()"
instead.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
