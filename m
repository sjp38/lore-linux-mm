From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14452.55013.418893.168846@dukat.scot.redhat.com>
Date: Thu, 6 Jan 2000 17:54:45 +0000 (GMT)
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <386153A8.C8366F70@starnet.gov.sg>
References: <Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
	<Pine.LNX.3.96.991221200955.16115B-100000@kanga.kvack.org>
	<14433.20097.10335.102803@dukat.scot.redhat.com>
	<386153A8.C8366F70@starnet.gov.sg>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tan Pong Heng <pongheng@starnet.gov.sg>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Andrea Arcangeli <andrea@suse.de>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 23 Dec 1999 06:41:44 +0800, Tan Pong Heng
<pongheng@starnet.gov.sg> said:

> I was thinking that, unless you want to have FS specific buffer/page
> cache, there is alway a gain for a unified cache for all fs. I think
> the one piece of functionality missing from the 2.3 implementation
> is the dependency between the various pages. If you could specify a
> tree relations between the various subset of the buffer/page and the
> reclaim machanism honor that everything should be fine. For FS that
> does not care about ordering, they could simply ignore this
> capability and the machanism could assume that everything is in one
> big set and could be reclaimed in any order.

That just doesn't give you enough power.  The trouble is that there
are IO dependencies which you don't know about until after the first
IO has completed.  For example, in journaling you may be allocating
journal blocks on demand, and you don't know where the journal commit
block will be until you have written most of the rest of the
transaction out.  If you are doing deferred allocation of disk blocks,
then you can't even _start_ the dependent IO trail until you
explicitly tell the filesystem that the flush-to-disk is beginning.

You need a way to let the filesystem know that you want something in
the cache to be written to disk.  You don't want to presume that one
general-purpose ordering mechanism will work.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
