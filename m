Date: Sat, 17 Jun 2000 20:12:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: PATCH: Improvements in shrink_mmap and kswapd
In-Reply-To: <ytt3dmcyli7.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0006172002370.31955-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 18 Jun 2000, Juan J. Quintela wrote:

> Reports of success/failure are welcome.  Comments are also welcome.

I have a few comments on the patch. They have mostly to do
with the maxlaunder logic.

A few days ago I sent you the buffer.c patch where
try_to_free_buffers was modified so that it would never try
to do IO on pages if the 'wait' argument has a value of -1.

This can be combined with maxlaunder in a nice way. Firstly
we need to wakeup_bdflush() if we queued some buffers or swap
pages for IO, that way bdflush will flush dirty and IO queued
pages to disk.

Secondly we need to try try_to_free_buffers(page, -1) first,
currently you count freeing buffers without doing IO as an
IO operation (and also, you're starting IO operations when
__GFP_IO isn't set). If that fails and maxlaunder isn't reached
yet, we can try to start asynchronous IO on the page.

When we reach the end of shrink_mmap, we can do something like
this:

wait = 0;
if (nr_writes && (gfp_mask & __GFP_IO))
	wait = 1;
wake_up_bdflush(wait);
if (wait && !ret) {
	goto again;  /* bdflush just made pages available, roll again */
}

This will give us something like write throttling where apps
will be waiting for bdflush to have done IO on pages so we'll
have freeable pages around. If __GFP_IO isn't set we'll still
fail, of course, but this will at least keep applications from
failing needlessly.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
