Message-ID: <3A976CE1.C7493E89@ucla.edu>
Date: Sat, 24 Feb 2001 00:12:17 -0800
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: VM balancing problems under 2.4.2-ac1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
Content-Type: text/plain; charset=big5
Content-Transfer-Encoding: 7bit

Rik van Riel wrote:
> In 2.4.1-pre<something> the kernel swaps out cache 32 times more
> agressively than it scans pages in processes. Until we find a way
> to auto-balance these things, expect them to be wrong for at least
> some workloads ;(

and elsewhere,

> That's because your problem requires a change to the
> balancing between swap_out() and refill_inactive_scan()
> in refill_inactive()...

Rik, can you explain why we still need to "balance" things, instead of
just swapping out the least used pages?  Is this only a problem with the
2.4 implementation (e.g. will refill_inactive_scan eventually do
swap_out in 2.5, or something?), or is it a generic VM issue that has to
be solved?

I'm not quite sure what is going on, but is there perhaps some way that
we can get better information about recent use for pages?  Or do we have
to treat age pages of different type differently based on their usage
pattern, which depends on the type of workload?

Regarding better information on recent page accesses, one thing that
seems strange to me is aging pages down to 0 before making them
inactive.  In order to have the most amount of information in the page
ages, we don't want more than 1/PAGE_AGE_MAX pages to have the same
age.  (Well, there are problems to that view, )  If we only consider
pages with age 0 to be inactive, then if we want a lot of inactive
pages, we make all those pages age zero.  Instead, it seems like a good
thing to do, would be to have a variable "inactive_level", so that a
page is inactive if the age is less than inactive_level.  If we want
more pages to be inactive, we increase inactive_level.  I guess I can
thing of some problems for this approach, but maybe it can be rescued.

In any case, is there a file in /proc/ that displays the number of pages
at each age?  It could be interesting to calculate Shannon Entropy from
this and see how many bits of information we get - a better entropy
could indicate a better aging algorithm.  I guess "6" is the best we
could get right now.

Also, somebody posted a paper reference to linux-mm a few months ago,
about how the optimal page aging strategy aged pages according to how
rapidly referenced bits were being set.  I guess the background page
aging tries to do something like this.  I don't know how well it
succeeds though...

	Thanks for any response/explanation!

-BenRI
-- 
"...assisted of course by pride, for we teach them to describe the
 Creeping Death, as Good Sense, or Maturity, or Experience." 
- "The Screwtape Letters"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
