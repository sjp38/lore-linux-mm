Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA20713
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 10:38:55 -0500
Date: Tue, 24 Nov 1998 15:38:47 GMT
Message-Id: <199811241538.PAA00984@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Linux-2.1.129..
In-Reply-To: <m1n25idwfr.fsf@flinx.ccr.net>
References: <19981119223434.00625@boole.suse.de>
	<Pine.LNX.3.95.981119143242.13021A-100000@penguin.transmeta.com>
	<199811231713.RAA17361@dax.scot.redhat.com>
	<m1n25idwfr.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Nov 1998 13:46:16 -0600, ebiederm+eric@ccr.net (Eric
W. Biederman) said:

> The simplest model (and what we use for disk writes) is after
> something becomes dirty to wait a little bit (in case of more writes,
> (so we don't flood the disk)) and write the data to disk.

The disk write model is not a good comparison, since (a) our current
write model is badly broken anyway (the only way to throttle writes is
to run out of memory), and (b) there are all sorts of fairness issues
involving the IO queues too in the write case.  But they have
similarities.

> Ideally/Theoretically I think that is what we should be doing for swap
> as well, as it would spread out the swap writes across evenly across
> time.  And should leave most of our pages clean.

Batching the writes improves our swap throughput enormously.  This is
well proven.  Sometimes we don't want to be too even. :)

> So I in practicall terms this would either be a call of shrink_mmap
> for every call to swap_out.  Or we would need an extra case added to
> the extra shrink_mmap call at the start of do_try_to_free_page.

The patch I just sent out essentially does this.  By making swap_out
unlikely to free real memory (it just unlinks things from ptes while
leaving them in the page cache), it batches out our swap writes and
causes regular aging of swap pages when memory gets short, but still
leaves all of the work of balancing the vm to shrink_mmap() where
those unlinked pages can be reused at will.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
