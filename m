Received: (3074 bytes) by baldur.fh-brandenburg.de
	via sendmail with P:stdio/R:match-inet-hosts/T:smtp
	(sender: <zippel@fh-brandenburg.de>)
	id <m14TTU2-000pwIC@baldur.fh-brandenburg.de>
	for <linux-mm@kvack.org>; Thu, 15 Feb 2001 19:50:26 +0100 (MET)
	(Smail-3.2.0.97 1997-Aug-19 #3 built DST-Sep-15)
Date: Thu, 15 Feb 2001 19:50:09 +0100 (MET)
From: Roman Zippel <zippel@fh-brandenburg.de>
Subject: Re: page locking and error handling
In-Reply-To: <m1snlg6jws.fsf@frodo.biederman.org>
Message-ID: <Pine.GSO.4.10.10102151835020.2986-100000@zeus.fh-brandenburg.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 15 Feb 2001, Eric W. Biederman wrote:

> > - if copy_from_user() fails the page is set as not uptodate. AFAIK this
> >   assumes that the page->buffers are still uptodate, so previous writes
> >   are not lost.
> If copy_from_user fails that invokes undefined behavior, and you just lost
> your previous writes because you ``overwrote'' them.

What about partial writes?

> > 3. During a write we always lock at least one page and we don't release
> >    the previous page until we got the next. This means:
> >    - the i_sem is not needed anymore, so multiple writes can access the
> >      file at the same time.
> 
> i_sem I believe is to protect the file length, and avoid weird
> truncation races.  As well allowing things like O_APPEND work.
> I don't see how page level locking helps with file size changes.

Of course locking of i_size is still needed, but i_sem is not needed for
the writing itself.

> >    - this would allow to pass multiple pages at once to the mapping
> >      mechanism, as we can easily link several pages together. This
> >      actually is all what is needed/wanted for streaming and no need for a
> >      heavyweight kiobuf.
> 
> Hmm.  For what you are suggesting kiobufs aren't that bad.  Not that
> I'm supporting them, but since you are aiming at the cases they handle
> just fine I won't criticize them either.

A list of pages is more flexible and can be used in more situations than
a kiobuf, a lower layer can of course still use whatever it wants.

> > This is probably is a bit sketchy, but the main idea is to further improve
> > the page state handling and remove dependencies/assumptions to the buffer
> > handling. This would also allow better error handling, e.g. data for a
> > removed media could be saved in a temporary file instead of throwing away
> > the data or one could even keep two medias mounted in the same
> > drive.
> 
> Create a pseudo block device if you want these kinds of semantics they
> should not be handled directly by the filesystem layer.  At least not
> unless so one comes up with a design where it just happens to fall out
> naturally. (Unlikely).

A pseudo block device is probably needed, but it needs a few hooks to
switch to it, but most of them are in the slow path. It also needs some
userspace support. Anyway, it doesn't need that much design changes,
mostly you only need to change the ClearPageUptodate() calls.

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
