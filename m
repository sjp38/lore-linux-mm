Date: Mon, 10 May 1999 17:01:50 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [PATCH] dirty pages in memory & co.
In-Reply-To: <14135.13698.659905.454361@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990510164506.10344A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 May 1999, Stephen C. Tweedie wrote:

> On 07 May 1999 09:56:00 -0500, ebiederm+eric@ccr.net (Eric W. Biederman)
> said:
> 
> >        It looks like I need 2 variations on generic_file_write at the
> >        moment. 
> >        1) for network filesystems that can get away without filling
> >           the page on a partial write.
> >        2) for block based filesystems that must fill the page on a
> >           partial write because they can't write arbitrary chunks of
> >           data.
> 
> I'd be very worried by (1): sounds like a partial write followed by a
> read of the full page could show up garbage in the page cache if you do
> this.  If NFS skips the page clearing for partial writes, how does it
> avoid returning garbage later?

Hmmm, it shouldn't be a problem if the write blocks the reading of the
page and PG_uptodate isn't set.  This conflicts with the current
assumption in generic_file_read that a locked page becoming unlocked
without PG_uptodate being set indicates an error -- the best thing here
is probably to add a PG_error flag and do away with the overloading.
Everything else should be checking PG_uptodate, right?

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
