Message-ID: <464B014B.20109@yahoo.com.au>
Date: Wed, 16 May 2007 23:04:11 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
References: <20070318233008.GA32597093@melbourne.sgi.com> <18993.1179310769@redhat.com> <1179317360.2859.225.camel@shinybook.infradead.org> <20070516125341.GS26766@think.oraclecorp.com>
In-Reply-To: <20070516125341.GS26766@think.oraclecorp.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> On Wed, May 16, 2007 at 08:09:19PM +0800, David Woodhouse wrote:
> 
>>On Wed, 2007-05-16 at 11:19 +0100, David Howells wrote:
>>
>>>The start and end points passed to block_prepare_write() delimit the region of
>>>the page that is going to be modified.  This means that prepare_write()
>>>doesn't need to fill it in if the page is not up to date. 
>>
>>Really? Is it _really_ going to be modified? Even if the pointer
>>userspace gave to write() is bogus, and is going to fault half-way
>>through the copy_from_user()?
> 
> 
> This is why there are so many variations on copy_from_user that zero on
> faults.  One way or another, the prepare_write/commit_write pair are
> responsible for filling it in.

I'll add to David's question about David's comment on David's patch, yes
it will be modified but in that case it would be zero-filled as Chris
says. However I believe this is incorrect behaviour.

It is possible to easily fix that so it would only happen via a tiny race
window (where the source memory gets unmapped at just the right time)
however nobody seemed to interested (just by checking the return value of
fault_in_pages_readable).

The buffered write patches I'm working on fix that (among other things) of
course. But they do away with prepare_write and introduce new aops, and
they indeed must not expect the full range to have been written to.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
