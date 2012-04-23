Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 30ACF6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 07:47:51 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so13689850obb.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 04:47:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335169383.4191.9.camel@dabdike.lan>
References: <1334863211-19504-1-git-send-email-tytso@mit.edu>
	<4F912880.70708@panasas.com>
	<alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com>
	<1334919662.5879.23.camel@dabdike>
	<alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
	<1334932928.13001.11.camel@dabdike>
	<20120420145856.GC24486@thunk.org>
	<CAHGf_=oWtpgRfqaZ1YDXgZoQHcFY0=DYVcwXYbFtZt2v+K532w@mail.gmail.com>
	<CAPa8GCDkP_53VGAeQPeYgf3GW3KZ09BvnqduArQE7svf2mMj4A@mail.gmail.com>
	<1335169383.4191.9.camel@dabdike.lan>
Date: Mon, 23 Apr 2012 21:47:50 +1000
Message-ID: <CAPa8GCCE7x=ox0K=QoFR8+bTNrUqfFO+ooRKDLNROnd7xsF4Pw@mail.gmail.com>
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Ted Ts'o <tytso@mit.edu>, Lukas Czerner <lczerner@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

On 23 April 2012 18:23, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Sun, 2012-04-22 at 16:30 +1000, Nick Piggin wrote:
>> On 22 April 2012 09:56, KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrot=
e:
>> > On Fri, Apr 20, 2012 at 10:58 AM, Ted Ts'o <tytso@mit.edu> wrote:
>> >> On Fri, Apr 20, 2012 at 06:42:08PM +0400, James Bottomley wrote:
>> >>>
>> >>> I'm not at all wedded to O_HOT and O_COLD; I think if we establish a
>> >>> hint hierarchy file->page cache->device then we should, of course,
>> >>> choose the best API and naming scheme for file->page cache. =A0The o=
nly
>> >>> real point I was making is that we should tie in the page cache, and
>> >>> currently it only knows about "hot" and "cold" pages.
>> >>
>> >> The problem is that "hot" and "cold" will have different meanings fro=
m
>> >> the perspective of the file system versus the page cache. =A0The file
>> >> system may consider a file "hot" if it is accessed frequently ---
>> >> compared to the other 2 TB of data on that HDD. =A0The memory subsyst=
em
>> >> will consider a page "hot" compared to what has been recently accesse=
d
>> >> in the 8GB of memory that you might have your system. =A0Now consider
>> >> that you might have a dozen or so 2TB disks that each have their "hot=
"
>> >> areas, and it's not at all obvious that just because a file, or even
>> >> part of a file is marked "hot", that it deserves to be in memory at
>> >> any particular point in time.
>> >
>> > So, this have intentionally different meanings I have no seen a reason=
 why
>> > fs uses hot/cold words. It seems to bring a confusion.
>>
>> Right. It has nothing to do with hot/cold usage in the page allocator,
>> which is about how many lines of that page are in CPU cache.
>
> Well, no it's a similar concept: =A0we have no idea whether the page is
> cached or not.
>
> =A0What we do is estimate that by elapsed time since we
> last touched the page. =A0In some sense, this is similar to the fs
> definition: a hot page hint would mean we expect to touch the page
> frequently and a cold page means we wouldn't. =A0i.e. for a hot page, the
> elapsed time between touches would be short and for a cold page it would
> be long. =A0Now I still think there's a mismatch in the time scales: a
> long elapsed time for mm making the page cold isn't necessarily the same
> long elapsed time for the file, because the mm idea is conditioned by
> local events (like memory pressure).

I suspect the mismatch would make it have virtually no correlation.
Experiments could surely be made, though.


>> However it could be propagated up to page reclaim level, at least.
>> Perhaps readahead/writeback too. But IMO it would be better to nail down
>> the semantics for block and filesystem before getting worried about that=
.
>
> Sure ... I just forwarded the email in case mm people had an interest.
> If you want FS and storage to develop the hints first and then figure
> out if we can involve the page cache, that's more or less what was
> happening anyway.

OK, good. mm layers can always look up any such flags quite easily, so
I think there is no problem of mechanism, only policy.


>> > But I don't know full story of this feature and I might be overlooking
>> > something.
>>
>> Also, "hot" and "cold" (as others have noted) is a big hammer that perha=
ps
>> catches a tiny subset of useful work (probably more likely: benchmarks).
>>
>> Is it read often? Written often? Both? Are reads and writes random or li=
near?
>> Is it latency bound, or throughput bound? (i.e., are queue depths high o=
r
>> low?)
>>
>> A filesystem and storage device might care about all of these things.
>> Particularly if you have something more advanced than a single disk.
>> Caches, tiers of storage, etc.
>
> Experience has taught me to be wary of fine grained hints: they tend to
> be more trouble than they're worth (the definitions are either
> inaccurate or so tediously precise that no-one can be bothered to read
> them). =A0A small set of broad hints is usually more useable than a huge
> set of fine grained ones, so from that point of view, I like the
> O_HOT/O_COLD ones.

So long as the implementations can be sufficiently general that large major=
ity
of "reasonable" application of the flags does not result in a slowdown, per=
haps.

But while defining the API, you have to think about these things and not
just dismiss them completely.

Read vs write can be very important for caches and tiers, same for
random/linear,
latency constraints, etc. These things aren't exactly a huge unwieldy matri=
x. We
already have similar concepts in fadvise and such.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
