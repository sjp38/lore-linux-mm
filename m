Message-ID: <392E7CFD.C9017833@norran.net>
Date: Fri, 26 May 2000 15:32:45 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [patch] page aging and deferred swapping for 2.4.0-test1
References: <Pine.LNX.4.21.0005251936390.7453-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> Hi,
> 
> the attached patch attempts to implement the following two
> things (which we'll probably want in the active/inactive
> design later on):
> - page aging (for active pages)
> - deferred swap IO, with only unmapping in try_to_swap_out()
> 
> The patch still crashes, but maybe one of you has an idea
> on what's wrong and/or even how to fix it ;)
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/
> 


The aging code can not be correct.
		if (PageTestandClearReferenced(page)) {
			page->age += 3;
			if (page->age > 10)
				page->age = 0;
			goto dispose_continue;
		}
		page->age--;

		if (page->age)
			goto dispose_continue;

I would say it should be:

		if (PageTestandClearReferenced(page)) {
			page->age += 3;
			if (page->age > 10)
				page->age = 10;
			goto dispose_continue;
		}

		if (page->age && priority)  // at zero priority ignore age
			goto dispose_continue;

		page->age--;

/RogerL


Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
