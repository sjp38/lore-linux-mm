Date: Wed, 24 May 2000 20:32:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2.3/4 VM queues idea
In-Reply-To: <ytt66s3muva.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0005242010080.24993-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>, "Stephen C. Tweedie" <sct@redhat.com>, Arnaldo Carvalho de Melo <acme@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On 25 May 2000, Juan J. Quintela wrote:

> we need to be able to write pages syncronously to disk if they are
> dirty, there are no free pages around, and we can sleep.

Indeed. Luckily this is covered in my design ;)

> Other question, who do you write the pages from the laundry disk to
> disk if they are dirty pages, not dirty buffers.  You need to look at
> the ptes to be able to do a swap_entry.  Or I am loosing something
> evident here?

The swap entry is allocated at swap_out (page unmapping) time and
put in the page struct.

> I continue with my problem, how do you write one page for the dirty
> page that has not a swap_entry defined.

The solution is to not have such pages around. Allocating a swap
entry when we unmap the page is easy...

> I think that the desing is quite right, but I have that problem
> just now with the current design, we jump over dirty pages in
> shrink_mmap due to the fact that we don't know what to do with
> them, I see the same problem here.

No we don't. We will move pages from the active list to the
inactive list regardless of whether they're clean or dirty.
And pages will stay on the inactive list either until they're
referenced by something or until they're reclaimed for something
else.

Once we end up with an inactive queue full of dirty pages,
we'll be syncing stuff to disk instead of putting memory pressure
on the active pages.

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
