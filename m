From: David Howells <dhowells@redhat.com>
In-Reply-To: <464AF224.30105@yahoo.com.au>
References: <464AF224.30105@yahoo.com.au> <20070318233008.GA32597093@melbourne.sgi.com> <18993.1179310769@redhat.com>
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Date: Wed, 16 May 2007 14:20:47 +0100
Message-ID: <17244.1179321647@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Dave is using prepare_write here to ensure blocks are allocated in the
> given range. The filesystem's ->nopage function must ensure it is uptodate
> before allowing it to be mapped.

Which is fine... assuming it's called.  For blockdev-based filesystems, this
is probably true.  But I'm not sure you can guarantee it.

I've seen Ext3, for example, unlocking a page that isn't yet uptodate.
nopage() won't get called on it again, but prepare_write() might.  I don't
know why this happens, but it's something I've fallen over in doing
CacheFiles.  When reading, readpage() is just called on it again and again
until it is up to date.  When writing, prepare_write() is called correctly.

> Consider that the code currently works OK today _without_ page_mkwrite.
> page_mkwrite is being added to do block allocation / reservation.

Which doesn't prove anything.  All it means is that PG_uptodate being unset is
handled elsewhere.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
