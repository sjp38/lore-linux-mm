Date: Wed, 17 May 2000 09:08:39 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Best way to extend try_to_free_pages()?
Message-ID: <20000517090839.F30758@redhat.com>
References: <852568E2.000A17E8.00@D51MTA03.pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <852568E2.000A17E8.00@D51MTA03.pok.ibm.com>; from frankeh@us.ibm.com on Tue, May 16, 2000 at 09:51:17PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: Rik van Riel <riel@conectiva.com.br>, Andreas Bombe <andreas.bombe@munich.netsurf.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, May 16, 2000 at 09:51:17PM -0400, frankeh@us.ibm.com wrote:

> I assume everything could register as a first class citizen, including file
> cache, etc.....
> Some thoughts along the line.
> Would it make sense to priorities such <kernel-memory-clients>.
> Wouldn't it make sense to specify the number of pages as part of the
> interface?
> Do you assume fairness among memory clients based on the cyclic queue if
> priorities is not desirable.

Chris Mason and I have already been looking at doing something
similar, but on a per-page basis, to allow advanced filesystems to
release memory in a controlled manner.  This is particularly
necessary for journaled filesystems, in which releasing certain 
data may require a transaction commit --- until the commit, there
is just no way shrink_mmap() will be able to free those pages, so
there has to be a way for shrink_mmap() to let the filesystem know
that it wants some memory back.

The route we'll probably go for this is through address_space_operations
callbacks from shrink_mmap.  That allows proper fairness --- all fses
can share the same lru that way.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
