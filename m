Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 796136B002D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 19:14:50 -0400 (EDT)
Received: by gyg8 with SMTP id 8so2064748gyg.14
        for <linux-mm@kvack.org>; Mon, 31 Oct 2011 16:14:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111031231031.GD10107@quack.suse.cz>
References: <CALCETrXbPWsgaZmsvHZGEX-CxB579tG+zusXiYhR-13RcEnGvQ@mail.gmail.com>
	<ACE78D84-0E94-4E7A-99BF-C20583018697@dilger.ca>
	<CALCETrU23vyCXPG6mJU9qaPeAGOWDQtur5C+LRT154V5FM=Ajg@mail.gmail.com>
	<CALCETrX=-CnNQ9+4tRbqMG4mfuy2FBPXXoJeBVDVPnEiRJYRFQ@mail.gmail.com>
	<CALCETrUcOKQAJTTmCSD3Q3wYS-zLqv6tBa4AdkK50bNobRhDUQ@mail.gmail.com>
	<20111025122618.GA8072@quack.suse.cz>
	<CALCETrWoZeFpznU5Nv=+PvL9QRkTnS4atiGXx0jqZP_E3TJPqw@mail.gmail.com>
	<20111031231031.GD10107@quack.suse.cz>
Date: Mon, 31 Oct 2011 16:14:47 -0700
Message-ID: <CALCETrViG6t1forOFtO-R=bGABvtLcECxJ8m8Tenv6rwxLg_ew@mail.gmail.com>
Subject: Re: Latency writing to an mlocked ext4 mapping
From: Andy Lutomirski <luto@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andreas Dilger <adilger@dilger.ca>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Mon, Oct 31, 2011 at 4:10 PM, Jan Kara <jack@suse.cz> wrote:
> On Fri 28-10-11 16:37:03, Andy Lutomirski wrote:
>> On Tue, Oct 25, 2011 at 5:26 AM, Jan Kara <jack@suse.cz> wrote:
>> >> =A0- Why are we calling file_update_time at all? =A0Presumably we als=
o
>> >> update the time when the page is written back (if not, that sounds
>> >> like a bug, since the contents may be changed after something saw the
>> >> mtime update), and, if so, why bother updating it on the first write?
>> >> Anything that relies on this behavior is, I think, unreliable, becaus=
e
>> >> the page could be made writable arbitrarily early by another program
>> >> that changes nothing.
>> > =A0We don't update timestamp when the page is written back. I believe =
this
>> > is mostly because we don't know whether the data has been changed by a
>> > write syscall, which already updated the timestamp, or by mmap. That i=
s
>> > also the reason why we update the timestamp at page fault time.
>> >
>> > =A0The reason why file_update_time() blocks for you is probably that i=
t
>> > needs to get access to buffer where inode is stored on disk and becaus=
e a
>> > transaction including this buffer is committing at the moment, your th=
read
>> > has to wait until the transaction commit finishes. This is mostly a pr=
oblem
>> > specific to how ext4 works so e.g. xfs shouldn't have it.
>> >
>> > =A0Generally I believe the attempts to achieve any RT-like latencies w=
hen
>> > writing to a filesystem are rather hopeless. How much hopeless depends=
 on
>> > the load of the filesystem (e.g., in your case of mostly idle filesyst=
em I
>> > can imagine some tweaks could reduce your latencies to an acceptable l=
evel
>> > but once the disk gets loaded you'll be screwed). So I'd suggest that
>> > having RT thread just store log in memory (or write to a pipe) and hav=
e
>> > another non-RT thread write the data to disk would be a much more robu=
st
>> > design.
>>
>> Windows seems to do pretty well at this, and I think it should be fixabl=
e on
>> Linux too. =A0"All" that needs to be done is to remove the pte_wrprotect=
 from
>> page_mkclean_one. =A0The fallout from that might be unpleasant, though, =
but
>> it would probably speed up a number of workloads.
> =A0Well, but Linux's mm pretty much depends the pte_wrprotect() so that's
> unlikely to go away in a forseeable future. The reason is that we need to
> reliably account the number of dirty pages so that we can throttle
> processes that dirty too much of memory and also protect agaist system
> going into out-of-memory problems when too many pages would be dirty (and
> thus hard to reclaim). Thus we create clean pages as write-protected, whe=
n
> they are first written to, we account them as dirtied and unprotect them.
> When pages are cleaned by writeback, we decrement number of dirty pages
> accordingly and write-protect them again.

What about skipping pte_wrprotect for mlocked pages and continuing to
account them dirty even if they're actually clean?  This should be a
straightforward patch except for the effect on stable pages for
writeback.  (It would also have unfortunate side effects on
ctime/mtime without my other patch to rearrange that code.)

>
>> Adding a whole separate process just to copy data from memory to disk so=
unds
>> a bit like a hack -- that's what mmap + mlock would do if it worked bett=
er.
> =A0Well, always only guarantees you cannot hit major fault when accessing
> the page. And we keep that promise - we only hit a minor fault. But I agr=
ee
> that for your usecase this is impractical.

Not really true.  We never fault in the page, but make_write can wait
for I/O (for hundreds of ms) which is just as bad.

>
> I can see as theoretically feasible for writeback to skip mlocked pages
> which would help your case. But practically, I do not see how to implemen=
t
> that efficiently (just skipping a dirty page when we find it's mlocked
> seems like a way to waste CPU needlessly).
>
>> Incidentally, pipes are no good. =A0I haven't root-caused it yet, but bo=
th
>> reading to and writing from pipes, even if O_NONBLOCK, can block. =A0I
>> haven't root-caused it yet.
> =A0Interesting. I imagine they could block on memory allocation but I gue=
ss
> you don't put that much pressure on your system. So it might be interesti=
ng
> to know where else they block...

I'll figure it out in a couple of days, I imagine.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
