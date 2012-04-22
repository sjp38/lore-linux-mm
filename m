Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 956816B004D
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 02:30:31 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so12035998obb.14
        for <linux-mm@kvack.org>; Sat, 21 Apr 2012 23:30:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=oWtpgRfqaZ1YDXgZoQHcFY0=DYVcwXYbFtZt2v+K532w@mail.gmail.com>
References: <1334863211-19504-1-git-send-email-tytso@mit.edu>
	<4F912880.70708@panasas.com>
	<alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com>
	<1334919662.5879.23.camel@dabdike>
	<alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
	<1334932928.13001.11.camel@dabdike>
	<20120420145856.GC24486@thunk.org>
	<CAHGf_=oWtpgRfqaZ1YDXgZoQHcFY0=DYVcwXYbFtZt2v+K532w@mail.gmail.com>
Date: Sun, 22 Apr 2012 16:30:30 +1000
Message-ID: <CAPa8GCDkP_53VGAeQPeYgf3GW3KZ09BvnqduArQE7svf2mMj4A@mail.gmail.com>
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Ted Ts'o <tytso@mit.edu>, James Bottomley <James.Bottomley@hansenpartnership.com>, Lukas Czerner <lczerner@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

On 22 April 2012 09:56, KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:
> On Fri, Apr 20, 2012 at 10:58 AM, Ted Ts'o <tytso@mit.edu> wrote:
>> On Fri, Apr 20, 2012 at 06:42:08PM +0400, James Bottomley wrote:
>>>
>>> I'm not at all wedded to O_HOT and O_COLD; I think if we establish a
>>> hint hierarchy file->page cache->device then we should, of course,
>>> choose the best API and naming scheme for file->page cache. =A0The only
>>> real point I was making is that we should tie in the page cache, and
>>> currently it only knows about "hot" and "cold" pages.
>>
>> The problem is that "hot" and "cold" will have different meanings from
>> the perspective of the file system versus the page cache. =A0The file
>> system may consider a file "hot" if it is accessed frequently ---
>> compared to the other 2 TB of data on that HDD. =A0The memory subsystem
>> will consider a page "hot" compared to what has been recently accessed
>> in the 8GB of memory that you might have your system. =A0Now consider
>> that you might have a dozen or so 2TB disks that each have their "hot"
>> areas, and it's not at all obvious that just because a file, or even
>> part of a file is marked "hot", that it deserves to be in memory at
>> any particular point in time.
>
> So, this have intentionally different meanings I have no seen a reason wh=
y
> fs uses hot/cold words. It seems to bring a confusion.

Right. It has nothing to do with hot/cold usage in the page allocator,
which is about how many lines of that page are in CPU cache.

However it could be propagated up to page reclaim level, at least.
Perhaps readahead/writeback too. But IMO it would be better to nail down
the semantics for block and filesystem before getting worried about that.


>
> But I don't know full story of this feature and I might be overlooking
> something.

Also, "hot" and "cold" (as others have noted) is a big hammer that perhaps
catches a tiny subset of useful work (probably more likely: benchmarks).

Is it read often? Written often? Both? Are reads and writes random or linea=
r?
Is it latency bound, or throughput bound? (i.e., are queue depths high or
low?)

A filesystem and storage device might care about all of these things.
Particularly if you have something more advanced than a single disk.
Caches, tiers of storage, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
