Date: Thu, 25 May 2000 11:52:02 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000525115202.A19969@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200005242057.NAA77059@apollo.backplane.com>; from dillon@apollo.backplane.com on Wed, May 24, 2000 at 01:57:19PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Dillon wrote:
>     Virtual
>     page scanning has severe scaleability problems over physical page
>     scanning.  For example, what happens when you have an oracle database
>     running with a hundred independant (non-threaded) processes mapping
>     300MB+ of shared memory?

Actually you can make this scalable quite easily.   I think it's
asymptotically equivalent to physical page scanning.

First, ensure the async. unmapper can limit the number of mapped
ptes.  Method: whenever the number of established ptes increases
above a high water mark (e.g. due to a page fault), invoke the unmapper
synchronously to push the number below a low water mark.  (Both marks
can be the same).

Second, make the scanner scale independently of the virtual addresses
used.  Method: store boundary tags in the /unused/ ptes so that
scanning skips unused ptes.  Ok, this can have fiddly interactions with
not-present swap entries.

In this way, the work required to scan _all_ mapped pages can be
strictly bounded.

cheers,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
