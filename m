Subject: [PATCH] Re: latancy test of -ac22-riel
References: <Pine.LNX.4.21.0006192052001.7938-100000@duckman.distro.conectiva> <394F0B6C.3925591B@norran.net> <m2u2eoxwzx.fsf@boreas.southchinaseas> <394FB013.3B21EA28@norran.net>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 22 Jun 2000 20:11:29 +0100
Message-ID: <m2ya3xsf8e.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Roger Larsson <roger.larsson@norran.net> writes:

[...]

> I retried running with normal prio - then I get stalls
> of > 350ms...

I think some stalls are most probably due to try_to_free_pages below

page_alloc.c::__alloc_pages
	/*
	 * Uhhuh. All the zones have been critical, which means that
	 * we'd better do some synchronous swap-out. kswapd has not
	 * been able to cope..
	 */
	if (!(current->flags & PF_MEMALLOC)) {
		if (!try_to_free_pages(gfp_mask)) {
			if (!(gfp_mask & __GFP_HIGH))
				goto fail;
		}
		goto fail;
	}

That is, it happens in times of high memory stress and when I comment
it out the pauses go away but I'm not sure that this is a good
long-term solution ;-) though IMHO the behaviour without it (VM
killing process) is better than the behaviour with it (paging until
power is cycled).

[...]

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
