Message-ID: <464B0A1B.4000209@yahoo.com.au>
Date: Wed, 16 May 2007 23:41:47 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
References: <464AF224.30105@yahoo.com.au> <20070318233008.GA32597093@melbourne.sgi.com> <18993.1179310769@redhat.com> <17244.1179321647@redhat.com>
In-Reply-To: <17244.1179321647@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

David Howells wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>Dave is using prepare_write here to ensure blocks are allocated in the
>>given range. The filesystem's ->nopage function must ensure it is uptodate
>>before allowing it to be mapped.
> 
> 
> Which is fine... assuming it's called.  For blockdev-based filesystems, this
> is probably true.  But I'm not sure you can guarantee it.
> 
> I've seen Ext3, for example, unlocking a page that isn't yet uptodate.
> nopage() won't get called on it again, but prepare_write() might.  I don't
> know why this happens, but it's something I've fallen over in doing
> CacheFiles.  When reading, readpage() is just called on it again and again
> until it is up to date.  When writing, prepare_write() is called correctly.

There are bugs in the core VM and block filesystem code where !uptodate pages
are left in pagetables. Some of these are fixed in -mm.

But they aren't a good reason to invent completely different ways to do things.


>>Consider that the code currently works OK today _without_ page_mkwrite.
>>page_mkwrite is being added to do block allocation / reservation.
> 
> 
> Which doesn't prove anything.  All it means is that PG_uptodate being unset is
> handled elsewhere.

It means that Dave's page_mkwrite function will do the block allocation
and everything else continues as it is. Your suggested change to pass in
offset == to is just completely wrong for this.

PG_uptodate being unset should be done via pagecache invalidation or truncation
APIs, which (sometimes... modulo bugs) tear down pagetables first.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
