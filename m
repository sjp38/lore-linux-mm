Received: (3423 bytes) by baldur.fh-brandenburg.de
	via sendmail with P:stdio/R:match-inet-hosts/T:smtp
	(sender: <zippel@fh-brandenburg.de>)
	id <m14TPvZ-000pvxC@baldur.fh-brandenburg.de>
	for <linux-mm@kvack.org>; Thu, 15 Feb 2001 16:02:37 +0100 (MET)
	(Smail-3.2.0.97 1997-Aug-19 #3 built DST-Sep-15)
Date: Thu, 15 Feb 2001 16:02:28 +0100 (MET)
From: Roman Zippel <zippel@fh-brandenburg.de>
Subject: page locking and error handling
Message-ID: <Pine.GSO.4.10.10102151526100.26610-100000@zeus.fh-brandenburg.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm currently trying to exactly understand the current page state handling
and I have a few problems around the generic_file_write function. The
problems I see are:
- the mentioned deadlock in generic_file_write is not really fixed, it's
  just a bit harder to exploit?
- if copy_from_user() fails the page is set as not uptodate. AFAIK this
  assumes that the page->buffers are still uptodate, so previous writes
  are not lost.
- a concurrent read might outrun a write and so possibly get some new data
  of the write and some old data.

Please correct me, if I'm wrong. Anyway, here are some ideas to address
this.
1. We can add a nonblocking version from copy_(from|to)_user, which
   returns EAGAIN if it finds a locked page. Most of the needed code is in
   the slow path, so it doesn't affect performance. Also see
   arch/m68k/mm/fault.c how to pass additional info from the fault
   handler.
2. We should make the state of a page completely independent of the
   underlying mapping mechanism.
   - A page shouldn't get suddenly not uptodate because a read from user
     space fails, so we need to _clearly_ define who sets/clears which
     bit. Especially in error situations ClearPageUptodate() is called,
     but gets the page data really not uptodate?
   - This also includes that the buffer pointer becomes private to the
     mapping mechanism, so it can be used for other caching mechanism
     (e.g. nfs doesn't have to store it separately).
3. During a write we always lock at least one page and we don't release
   the previous page until we got the next. This means:
   - the i_sem is not needed anymore, so multiple writes can access the
     file at the same time.
   - a read can't outrun a write anymore.
   - page locking has to happen completely at the higher layer and keeping
     multiple pages locked would require something like 1).
   - this would allow to pass multiple pages at once to the mapping
     mechanism, as we can easily link several pages together. This
     actually is all what is needed/wanted for streaming and no need for a
     heavyweight kiobuf.

This is probably is a bit sketchy, but the main idea is to further improve
the page state handling and remove dependencies/assumptions to the buffer
handling. This would also allow better error handling, e.g. data for a
removed media could be saved in a temporary file instead of throwing away
the data or one could even keep two medias mounted in the same drive.
Another possibility is to use/test several i/o mechanism at the same time,
or even to make them modular.
Anyway, just some wild ideas :). I'm interested in any comments, whether
above is needed/desired. As it would mean some quite heavy changes, I'd
like to make sure I'm not missing anything before starting hacking on it
(what won't be to soon, as more important things are pending...).

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
