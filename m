Received: from mail.ccr.net (ccr@alogconduit1ah.ccr.net [208.130.159.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA15064
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 14:25:42 -0500
Subject: Re: Linux-2.1.129..
References: <19981119223434.00625@boole.suse.de> 	<Pine.LNX.3.95.981119143242.13021A-100000@penguin.transmeta.com> <199811231713.RAA17361@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 Nov 1998 13:46:16 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 23 Nov 1998 17:13:34 GMT"
Message-ID: <m1n25idwfr.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> I'm going to check this out: I'll post preliminary benchmarks and a
ST> patch for other people to test tomorrow.  Getting the balancing right
ST> will then just be a matter of making sure that try_to_swap_out gets
ST> called often enough under normal running conditions.  I'm open to
ST> suggestions about that: we've never tried that sort of behaviour in the
ST> vm to my knowledge.

I just said the buffer cache is very similiar and it is.

The trick part with balancing is there is an tradition in linux of
using very little swap space.  And the linux kernel not using swap
space unless it needs it.

The simplest model (and what we use for disk writes) is after
something becomes dirty to wait a little bit (in case of more writes,
(so we don't flood the disk)) and write the data to disk.

Ideally/Theoretically I think that is what we should be doing for swap
as well, as it would spread out the swap writes across evenly across
time.  And should leave most of our pages clean.

To implement that model we would need some different swap statistics,
so our users wouldn't panic.  (i.e. swap used but in swap cache ...)

But that is obviously going a little far for 2.2.  We already have our
model of only try to clean pages when we need memory (ouch!)  Which
we must balance with an amount of reaping by shrink_mmap.  This I
agree is unprecedented.

The correct ratio (of pages to free from each source) (compuated
dynamically) would be:
(# of process pages)/(# of pages)

Basically for every page kswapd frees shrink_mmap must also free one
page.  Plus however many pages shrink_mmap used to return.

So I in practicall terms this would either be a call of shrink_mmap
for every call to swap_out.  Or we would need an extra case added to
the extra shrink_mmap call at the start of do_try_to_free_page.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
