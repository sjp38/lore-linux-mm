From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch][rfc] rewrite ramdisk
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m1abqjirmd.fsf@ebiederm.dsl.xmission.com>
	<200710161808.06405.nickpiggin@yahoo.com.au>
	<200710161747.12968.nickpiggin@yahoo.com.au>
Date: Wed, 17 Oct 2007 04:30:39 -0600
In-Reply-To: <200710161747.12968.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Tue, 16 Oct 2007 17:47:12 +1000")
Message-ID: <m16416f2y8.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Tuesday 16 October 2007 18:08, Nick Piggin wrote:
>> On Tuesday 16 October 2007 14:57, Eric W. Biederman wrote:
>
>> > > What magic restrictions on page allocations? Actually we have
>> > > fewer restrictions on page allocations because we can use
>> > > highmem!
>> >
>> > With the proposed rewrite yes.
>
> Here's a quick first hack...
>
> Comments?

I have beaten my version of this into working shape, and things
seem ok.

However I'm beginning to think that the real solution is to remove
the dependence on buffer heads for caching the disk mapping for
data pages, and move the metadata buffer heads off of the block
device page cache pages.  Although I am just a touch concerned
there may be an issue with using filesystem tools while the
filesystem is mounted if I move the metadata buffer heads.

If we were to move the metadata buffer heads (assuming I haven't
missed some weird dependency) then I think there a bunch of
weird corner cases that would be simplified.

I guess that is where I look next.

Oh for what it is worth I took a quick look at fsblock and I don't think
struct fsblock makes much sense as a block mapping translation layer for
the data path where the current page caches works well.  For less
then the cost of 1 fsblock I can cache all of the translations for a
1K filesystem on a 4K page.

I haven't looked to see if fsblock makes sense to use as a buffer head
replacement yet.

Anyway off to bed with me.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
