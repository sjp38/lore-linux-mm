Date: Wed, 15 Aug 2001 19:15:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0108151908330.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Linus Torvalds wrote:

> diff -u --recursive --new-file pre4/linux/mm/page_alloc.c linux/mm/page_alloc.c
> --- pre4/linux/mm/page_alloc.c	Wed Aug 15 02:39:44 2001
> +++ linux/mm/page_alloc.c	Wed Aug 15 13:35:02 2001
> @@ -450,7 +450,7 @@
>  		if (gfp_mask & __GFP_WAIT) {
>  			if (!order || free_shortage()) {
>  				int progress = try_to_free_pages(gfp_mask);
> -				if (progress || (gfp_mask & __GFP_FS))
> +				if (progress || (gfp_mask & __GFP_IO))
>  					goto try_again;
>  				/*
>  				 * Fail in case no progress was made and the

Hmmm, thinking about it a bit more I'm not sure about
this part. It could lead to us looping infinitely while
not being able to free pages because we'd need __GFP_FS
in order to call the various ->writepage() functions.

In case a GFP_BUFFER (or similar) allocation really cannot
make any progress here, we need to exit instead of looping
forever, so my intuition is that trying to let the allocation
loop forever can cause system hangs whereas failing the
allocation would the code path in buffer.c or one of the
filesystems to bail out in another way...

regards,

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
