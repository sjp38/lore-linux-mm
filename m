Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
References: <393E8AEF.7A782FE4@reiser.to>
	<Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva>
	<20000607205819.E30951@redhat.com> <ytt1z29dxce.fsf@serpe.mitica>
	<20000607222421.H30951@redhat.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 22:24:21 +0100"
Date: 07 Jun 2000 23:40:47 +0200
Message-ID: <yttvgzlcgps.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

>>>>> "stephen" == Stephen C Tweedie <sct@redhat.com> writes:

Hi

stephen> All transactional filesystems will have ordering constraints which
stephen> the core VM cannot know about.  In that case, the filesystem may
stephen> simply have no choice about cleaning and unpinning pages in a given
stephen> order.  For actually removing a page from memory, evicting precisely
stephen> the right page is far more important, but for writeback, it's
stephen> controlling the amount of dirty/pinned data from the various different
stephen> sources which counts.

Fair enough, don't put pinned pages in the LRU, *why* do you want put
pages in the LRU if you can't freed it when the LRU told it: free that
page?  Ok. New example.  You have the 10 (put here any number) older
pages in the LRU.  That pages are pinned in memory, i.e. you can't
remove them.  You will call the ->flush() function in each of them
(put it any name for the method).  Now, the same fs has a lot of new
pages in the LRU that are being used actively, but are not pinned in
this precise instant.  Each time that we call the flush method, we
will free some dirty pages, not the pinned ones, evidently. We will
call that flush function 10 times consecutively.  Posibly we will
flush all the pages from the cache for that fs, and for not good
reason.  The only reason was that it was the 10 oldest pages in the
LRU, nothing else.  Yes, I know that this is a pathological case, but
I think that we should work ok in that case also.

I will be also very happy with only one place where doing the aging,
cleaning, ... of _all_ the pages, but for that place we need a policy,
and that policy _must_ be honored (almost) always or it doesn't make
sense and we will arrive to unstable/unfair situations.

I am working just now in a patch that will allow pages to be defered
the write of mmaped pages from the swap_out function to shrink_mmap
time.  The same that we do with swap pages actually, but for fs pages
mmaped in processes.  That would help that.  But note that in this
case, I put in the LRU pages that can be freed.  I can't understand
putting pages that are not freeable.  I told that to show that I am
supportive of the idea of only one LRU queue (or multiqueue, that is
the same).

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
