Date: Fri, 26 May 2000 10:41:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] page aging and deferred swapping for 2.4.0-test1
In-Reply-To: <392E7CFD.C9017833@norran.net>
Message-ID: <Pine.LNX.4.21.0005261038340.26570-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 May 2000, Roger Larsson wrote:
> Rik van Riel wrote:

> > the attached patch attempts to implement the following two
> > things (which we'll probably want in the active/inactive
> > design later on):
> > - page aging (for active pages)
> > - deferred swap IO, with only unmapping in try_to_swap_out()

> The aging code can not be correct.
> 		if (PageTestandClearReferenced(page)) {
> 			page->age += 3;
> 			if (page->age > 10)
> 				page->age = 0;
> 			goto dispose_continue;
> 		}
> 		page->age--;
> 
> 		if (page->age)
> 			goto dispose_continue;

True, there is one obvious error here...

> I would say it should be:
> 
> 		if (PageTestandClearReferenced(page)) {
> 			page->age += 3;
> 			if (page->age > 10)
> 				page->age = 10;
> 			goto dispose_continue;
> 		}
> 
> 		if (page->age && priority)  // at zero priority ignore age
> 			goto dispose_continue;
> 
> 		page->age--;

This is wrong too. It would mean that we'd never decrease the
page age unless priority == 0 ;)

The fix is this:

}
-	page->age--;
+	if (page->age)
+		page->age--;


(so we cannot get into a near-infinite loop when we decrease
the unsigned age when it's zero and have it wrap to infinite)

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
