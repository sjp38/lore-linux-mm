Subject: Re: page locking and error handling
References: <Pine.GSO.4.10.10102151526100.26610-100000@zeus.fh-brandenburg.de>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 15 Feb 2001 08:33:07 -0700
In-Reply-To: Roman Zippel's message of "Thu, 15 Feb 2001 16:02:28 +0100 (MET)"
Message-ID: <m1snlg6jws.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@fh-brandenburg.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Roman Zippel <zippel@fh-brandenburg.de> writes:

> Hi,
> 
> I'm currently trying to exactly understand the current page state handling
> and I have a few problems around the generic_file_write function. The
> problems I see are:
> - the mentioned deadlock in generic_file_write is not really fixed, it's
>   just a bit harder to exploit?

I don't know I haven't traced that path.

> - if copy_from_user() fails the page is set as not uptodate. AFAIK this
>   assumes that the page->buffers are still uptodate, so previous writes
>   are not lost.
If copy_from_user fails that invokes undefined behavior, and you just lost
your previous writes because you ``overwrote'' them.

> - a concurrent read might outrun a write and so possibly get some new data
>   of the write and some old data.

Read/write are not atomic so no problem.
> 

> Please correct me, if I'm wrong. Anyway, here are some ideas to address
> this.
> 1. We can add a nonblocking version from copy_(from|to)_user, which
>    returns EAGAIN if it finds a locked page. Most of the needed code is in
>    the slow path, so it doesn't affect performance. Also see
>    arch/m68k/mm/fault.c how to pass additional info from the fault
>    handler.
> 2. We should make the state of a page completely independent of the
>    underlying mapping mechanism.
>    - A page shouldn't get suddenly not uptodate because a read from user
>      space fails, so we need to _clearly_ define who sets/clears which
>      bit. Especially in error situations ClearPageUptodate() is called,
>      but gets the page data really not uptodate?

Some kind of ``correct'' handling for this should happen so that if
the page is mapped we don't break invariants, (like a mapped page
should always be uptodate.  But other than that we are fine.

>    - This also includes that the buffer pointer becomes private to the
>      mapping mechanism, so it can be used for other caching mechanism
>      (e.g. nfs doesn't have to store it separately).

Possibly.  This is a bit of a corner case.  It looks good on paper
certainly.

> 3. During a write we always lock at least one page and we don't release
>    the previous page until we got the next. This means:
>    - the i_sem is not needed anymore, so multiple writes can access the
>      file at the same time.

i_sem I believe is to protect the file length, and avoid weird
truncation races.  As well allowing things like O_APPEND work.
I don't see how page level locking helps with file size changes.

>    - a read can't outrun a write anymore.

That isn't a problem.  You have to do locking in user space to avoid
that if you want it.

>    - page locking has to happen completely at the higher layer and keeping
>      multiple pages locked would require something like 1).
?
>    - this would allow to pass multiple pages at once to the mapping
>      mechanism, as we can easily link several pages together. This
>      actually is all what is needed/wanted for streaming and no need for a
>      heavyweight kiobuf.

Hmm.  For what you are suggesting kiobufs aren't that bad.  Not that
I'm supporting them, but since you are aiming at the cases they handle
just fine I won't criticize them either.

> 
> This is probably is a bit sketchy, but the main idea is to further improve
> the page state handling and remove dependencies/assumptions to the buffer
> handling. This would also allow better error handling, e.g. data for a
> removed media could be saved in a temporary file instead of throwing away
> the data or one could even keep two medias mounted in the same
> drive.

Create a pseudo block device if you want these kinds of semantics they
should not be handled directly by the filesystem layer.  At least not
unless so one comes up with a design where it just happens to fall out
naturally. (Unlikely).

> Another possibility is to use/test several i/o mechanism at the same time,
> or even to make them modular.
> Anyway, just some wild ideas :). I'm interested in any comments, whether
> above is needed/desired. As it would mean some quite heavy changes, I'd
> like to make sure I'm not missing anything before starting hacking on it
> (what won't be to soon, as more important things are pending...).

Have fun reading the code and kibitzing.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
