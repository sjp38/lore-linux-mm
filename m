From: Nikita Danilov <Nikita@Clusterfs.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16651.33755.359441.675409@laputa.namesys.com>
Date: Sat, 31 Jul 2004 15:34:51 +0400
Subject: Re: [PATCH] token based thrashing control
In-Reply-To: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
References: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, sjiang@cs.wm.edu
List-ID: <linux-mm.kvack.org>

Rik van Riel writes:
 > 	
 > The following experimental patch implements token based thrashing
 > protection, using the algorithm described in:
 > 
 > 	http://www.cs.wm.edu/~sjiang/token.htm
 > 
 > When there are pageins going on, a task can grab a token, that
 > protects the task from pageout (except by itself) until it is
 > no longer doing heavy pageins, or until the maximum hold time
 > of the token is over.
 > 
 > If the maximum hold time is exceeded, the task isn't eligable
 > to hold the token for a while more, since it wasn't doing it
 > much good anyway.

[...]

 > --- linux-2.6.7/mm/filemap.c.token	2004-07-30 13:22:28.000000000 -0400
 > +++ linux-2.6.7/mm/filemap.c	2004-07-30 13:22:29.000000000 -0400
 > @@ -1195,6 +1195,7 @@
 >  	 * effect.
 >  	 */
 >  	error = page_cache_read(file, pgoff);
 > +	grab_swap_token();

Token functions are declared to be no-ops if !CONFIG_SWAP, but here
token is used for file-system backed page-fault.

 >  

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
