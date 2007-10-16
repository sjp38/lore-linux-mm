From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710160006.19735.nickpiggin@yahoo.com.au>
	<20071015021624.7d5233bd.akpm@linux-foundation.org>
	<200710160123.32434.nickpiggin@yahoo.com.au>
Date: Mon, 15 Oct 2007 21:14:39 -0600
In-Reply-To: <200710160123.32434.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Tue, 16 Oct 2007 01:23:32 +1000")
Message-ID: <m1zlyjiwdc.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Monday 15 October 2007 19:16, Andrew Morton wrote:
>> On Tue, 16 Oct 2007 00:06:19 +1000 Nick Piggin <nickpiggin@yahoo.com.au> 
> wrote:
>> > On Monday 15 October 2007 18:28, Christian Borntraeger wrote:
>> > > Andrew, this is a resend of a bugfix patch. Ramdisk seems a bit
>> > > unmaintained, so decided to sent the patch to you :-).
>> > > I have CCed Ted, who did work on the code in the 90s. I found no
>> > > current email address of Chad Page.
>> >
>> > This really needs to be fixed...
>>
>> rd.c is fairly mind-boggling vfs abuse.
>
> Why do you say that? I guess it is _different_, by necessity(?)
> Is there anything that is really bad?

make_page_uptodate() is most hideous part I have run into.
It has to know details about other layers to now what not
to stomp.  I think my incorrect simplification of this is what messed
things up, last round.

> I guess it's not nice
> for operating on the pagecache from its request_fn, but the
> alternative is to duplicate pages for backing store and buffer
> cache (actually that might not be a bad alternative really).

Cool. Triple buffering :)  Although I guess that would only
apply to metadata these days.   Having a separate store would
solve some of the problems, and probably remove the need
for carefully specifying the ramdisk block size.  We would
still need the magic restictions on page allocations though
and it we would use them more often as the initial write to the
ramdisk would not populate the pages we need.

A very ugly bit seems to be the fact that we assume we can
dereference bh->b_data without any special magic which
means the ramdisk must live in low memory on 32bit machines.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
