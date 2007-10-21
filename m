From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] block: Isolate the buffer cache in it's own mappings.
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710211424.46650.nickpiggin@yahoo.com.au>
	<m16411dq6b.fsf@ebiederm.dsl.xmission.com>
	<200710211536.24722.nickpiggin@yahoo.com.au>
Date: Sun, 21 Oct 2007 01:09:36 -0600
In-Reply-To: <200710211536.24722.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Sun, 21 Oct 2007 15:36:24 +1000")
Message-ID: <m18x5xc5an.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Sunday 21 October 2007 14:53, Eric W. Biederman wrote:
>> Nick Piggin <nickpiggin@yahoo.com.au> writes:
>> > On Saturday 20 October 2007 07:27, Eric W. Biederman wrote:
>> >> Andrew Morton <akpm@linux-foundation.org> writes:
>> >> > I don't think we little angels want to tread here.  There are so many
>> >> > weirdo things out there which will break if we bust the coherence
>> >> > between the fs and /dev/hda1.
>> >>
>> >> We broke coherence between the fs and /dev/hda1 when we introduced
>> >> the page cache years ago,
>> >
>> > Not for metadata. And I wouldn't expect many filesystem analysis
>> > tools to care about data.
>>
>> Well tools like dump certainly weren't happy when we made the change.
>
> Doesn't that give you any suspicion that other tools mightn't
> be happy if we make this change, then?

I read a representative sample of the relevant tools before replying
to Andrew.

>> >> and weird hacky cases like
>> >> unmap_underlying_metadata don't change that.
>> >
>> > unmap_underlying_metadata isn't about raw block device access at
>> > all, though (if you write to the filesystem via the blockdevice
>> > when it isn't expecting it, it's going to blow up regardless).
>>
>> Well my goal with separating things is so that we could decouple two
>> pieces of code that have different usage scenarios, and where
>> supporting both scenarios simultaneously appears to me to needlessly
>> complicate the code.
>>
>> Added to that we could then tune the two pieces of code for their
>> different users.
>
> I don't see too much complication from it. If we can actually
> simplify things or make useful tuning, maybe it will be worth
> doing.

That was my feeling that we could simplify things.  The block layer
page cache operations certainly.

I know in the filesystems that use the buffer cache like reiser and
JBD they could stop worrying about the buffers becoming mysteriously
dirty.  Beyond that I think there is a lot of opportunity I just
haven't looked much yet.

>> >> Currently only
>> >> metadata is more or less in sync with the contents of /dev/hda1.
>> >
>> > It either is or it isn't, right? And it is, isn't it? (at least
>> > for the common filesystems).
>>
>> ext2 doesn't store directories in the buffer cache.
>  
> Oh that's what you mean. OK, agreed there. But for the filesystems
> and types of metadata that can now expect to have coherency, doing
> this will break that expectation.
>
> Again, I have no opinions either way on whether we should do that
> in the long run. But doing it as a kneejerk response to braindead
> rd.c code is wrong because of what *might* go wrong and we don't
> know about.

The rd.c code is perfectly valid if someone wasn't forcing buffer
heads on it's pages.  It is a conflict of expectations.

Regardless I didn't do it as a kneejerk and I don't think that
patch should be merged at this time.  I proposed it because as I
see it that starts untangling the mess that is the buffer cache.
rd.c was just my entry point into understanding how all of those
pieces work.   I was doing my best to completely explore my options
and what the code was doing before settling on the fix for rd.c

>> Journaling filesystems and filesystems that do ordered writes
>> game the buffer cache.  Putting in data that should not yet
>> be written to disk.  That gaming is where reiserfs goes BUG
>> and where JBD moves the dirty bit to a different dirty bit.
>
> Filesystems really want better control of writeback, I think.
> This isn't really a consequence of the unified blockdev pagecache
> / metadata buffer cache, it is just that most of the important
> things they do are with metadata.

Yes.

> If they have their own metadata inode, then they'll need to game
> the cache for it, or the writeback code for that inode somehow
> too.

Yes.  Although they will at least get the guarantee that no one
else is dirtying their pages at strange times. 


>> So as far as I can tell what is in the buffer cache is not really
>> in sync with what should be on disk at any given movement except
>> when everything is clean.
>
> Naturally. It is a writeback cache.

Not that so much as the order in which things go into the cache
does not match the order the blocks go to disk.

>> My suspicion is that actually reading from disk is likely to
>> give a more coherent view of things.  Because there at least
>> we have the writes as they are expected to be seen by fsck
>> to recover the data, and a snapshot there should at least
>> be recoverable.  Whereas a snapshot provides not such guarantees.
>
> ext3 fsck I don't think is supposed to be run under a read/write
> filesystem, so it's going to explode if you do that regardless.

Yes.  I was thinking of dump or something like that here.  Where
we simply read out the data and try to make some coherent sense
of it.  If we see a version of the metadata that points to things
that have not been finished yet or is in the process of being
written to that could be a problem.

When going through the buffer cache as far as I can tell people
don't use little things like page lock when writing data so
the page cache reads can potentially race with what should
be atomic writes.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
