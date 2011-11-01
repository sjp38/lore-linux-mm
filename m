Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 964D56B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 19:10:54 -0400 (EDT)
Received: by ggnh4 with SMTP id h4so9885242ggn.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 16:10:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111101230320.GH18701@quack.suse.cz>
References: <CALCETrXbPWsgaZmsvHZGEX-CxB579tG+zusXiYhR-13RcEnGvQ@mail.gmail.com>
 <ACE78D84-0E94-4E7A-99BF-C20583018697@dilger.ca> <CALCETrU23vyCXPG6mJU9qaPeAGOWDQtur5C+LRT154V5FM=Ajg@mail.gmail.com>
 <CALCETrX=-CnNQ9+4tRbqMG4mfuy2FBPXXoJeBVDVPnEiRJYRFQ@mail.gmail.com>
 <CALCETrUcOKQAJTTmCSD3Q3wYS-zLqv6tBa4AdkK50bNobRhDUQ@mail.gmail.com>
 <20111025122618.GA8072@quack.suse.cz> <CALCETrWoZeFpznU5Nv=+PvL9QRkTnS4atiGXx0jqZP_E3TJPqw@mail.gmail.com>
 <20111031231031.GD10107@quack.suse.cz> <CALCETrViG6t1forOFtO-R=bGABvtLcECxJ8m8Tenv6rwxLg_ew@mail.gmail.com>
 <20111101230320.GH18701@quack.suse.cz>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 1 Nov 2011 16:10:31 -0700
Message-ID: <CALCETrVKHyRtizmTs=4hZzOs+7JLnvv0WtkSLYLDmM0fs2ce-w@mail.gmail.com>
Subject: Re: Latency writing to an mlocked ext4 mapping
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andreas Dilger <adilger@dilger.ca>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Tue, Nov 1, 2011 at 4:03 PM, Jan Kara <jack@suse.cz> wrote:
> On Mon 31-10-11 16:14:47, Andy Lutomirski wrote:
>> On Mon, Oct 31, 2011 at 4:10 PM, Jan Kara <jack@suse.cz> wrote:
>> > On Fri 28-10-11 16:37:03, Andy Lutomirski wrote:
>> >> On Tue, Oct 25, 2011 at 5:26 AM, Jan Kara <jack@suse.cz> wrote:
>> >> >> =A0- Why are we calling file_update_time at all? =A0Presumably we =
also
>> >> >> update the time when the page is written back (if not, that sounds
>> >> >> like a bug, since the contents may be changed after something saw =
the
>> >> >> mtime update), and, if so, why bother updating it on the first wri=
te?
>> >> >> Anything that relies on this behavior is, I think, unreliable, bec=
ause
>> >> >> the page could be made writable arbitrarily early by another progr=
am
>> >> >> that changes nothing.
>> >> > =A0We don't update timestamp when the page is written back. I belie=
ve this
>> >> > is mostly because we don't know whether the data has been changed b=
y a
>> >> > write syscall, which already updated the timestamp, or by mmap. Tha=
t is
>> >> > also the reason why we update the timestamp at page fault time.
>> >> >
>> >> > =A0The reason why file_update_time() blocks for you is probably tha=
t it
>> >> > needs to get access to buffer where inode is stored on disk and bec=
ause a
>> >> > transaction including this buffer is committing at the moment, your=
 thread
>> >> > has to wait until the transaction commit finishes. This is mostly a=
 problem
>> >> > specific to how ext4 works so e.g. xfs shouldn't have it.
>> >> >
>> >> > =A0Generally I believe the attempts to achieve any RT-like latencie=
s when
>> >> > writing to a filesystem are rather hopeless. How much hopeless depe=
nds on
>> >> > the load of the filesystem (e.g., in your case of mostly idle files=
ystem I
>> >> > can imagine some tweaks could reduce your latencies to an acceptabl=
e level
>> >> > but once the disk gets loaded you'll be screwed). So I'd suggest th=
at
>> >> > having RT thread just store log in memory (or write to a pipe) and =
have
>> >> > another non-RT thread write the data to disk would be a much more r=
obust
>> >> > design.
>> >>
>> >> Windows seems to do pretty well at this, and I think it should be fix=
able on
>> >> Linux too. =A0"All" that needs to be done is to remove the pte_wrprot=
ect from
>> >> page_mkclean_one. =A0The fallout from that might be unpleasant, thoug=
h, but
>> >> it would probably speed up a number of workloads.
>> > =A0Well, but Linux's mm pretty much depends the pte_wrprotect() so tha=
t's
>> > unlikely to go away in a forseeable future. The reason is that we need=
 to
>> > reliably account the number of dirty pages so that we can throttle
>> > processes that dirty too much of memory and also protect agaist system
>> > going into out-of-memory problems when too many pages would be dirty (=
and
>> > thus hard to reclaim). Thus we create clean pages as write-protected, =
when
>> > they are first written to, we account them as dirtied and unprotect th=
em.
>> > When pages are cleaned by writeback, we decrement number of dirty page=
s
>> > accordingly and write-protect them again.
>>
>> What about skipping pte_wrprotect for mlocked pages and continuing to
>> account them dirty even if they're actually clean? =A0This should be a
>> straightforward patch except for the effect on stable pages for
>> writeback. =A0(It would also have unfortunate side effects on
>> ctime/mtime without my other patch to rearrange that code.)
> =A0Well, doing proper dirty accounting would be a mess (you'd have to
> unaccount dirty pages during munlock etc.) and I'm not sure what all woul=
d
> break when page writes would not be coupled with page faults. So I don't
> think it's really worth it.

I'll add it to my back burner.  I haven't figured out all (any?) of
the accounting yet.

>
> Avoiding IO during a minor fault would be a decent thing which might be
> worth pursuing. As you properly noted "stable pages during writeback"
> requirement is one obstacle which won't be that trivial to avoid though..=
.

There's an easy solution that would be good enough for me: add a mount
option to turn off stable pages.

Is the other problem just a race, perhaps?  __block_page_mkwrite calls
__block_write_begin (which calls get_block, which I think is where the
latency comes from) *before* wait_on_page_writeback, which means that
there might not be any space allocated yet.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
