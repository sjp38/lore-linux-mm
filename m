Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
References: <20000607144102.F30951@redhat.com>
	<Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva>
	<20000607154620.O30951@redhat.com>
From: "Quintela Carreira Juan J." <quintela@fi.udc.es>
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 15:46:20 +0100"
Date: 07 Jun 2000 17:20:41 +0200
Message-ID: <yttog5decvq.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

>>>>> "stephen" == Stephen C Tweedie <sct@redhat.com> writes:

Hi

stephen> It doesn't matter.  *If* the filesystem knows better than the 
stephen> page cleaner what progress can be made, then let the filesystem
stephen> make progress where it can.  There are likely to be transaction
stephen> dependencies which mean we have to clean some pages in a specific
stephen> order.  As soon as the page cleaner starts exerting back pressure
stephen> on the filesystem, the filesystem needs to start clearing stuff,
stephen> and if that means we have to start cleaning things that shrink_
stephen> mmap didn't expect us to, then that's fine.

I don't like that, if you put some page in the LRU cache, that means
that you think that _this_ page is freeable.  Yes some times that can
fail, but in the _normal_ case things just work that way.  It doesn't
make sense to have pages in the LRU cache that are unfreeable and each
time that we ask the filesystem code to free them it tolds us: 
     - Well that page is actually busy, but I have that other free
       instead. 
If we really need a notify to the relevant fs that tells it: We are
short of memory, please free as much memory as possible.  Where as
much as possible is an ammount related to the priority number (or any
other number).

I like the idea of having pages of Journaled FS in the cache if I can
ask the FS:  free this page, and the fs will write/free that page and
*possible* more pages, but I am not *interested* in that detail.

If you need pages in the LRU cache only for getting notifications,
then change the system to send notifications each time that we are
short of memory.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
