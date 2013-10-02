Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 562966B0062
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 18:53:16 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so1677185pab.39
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 15:53:16 -0700 (PDT)
Date: Wed, 2 Oct 2013 18:53:10 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: readahead man page incorrectly says it blocks
Message-ID: <20131002225310.GA12225@thunk.org>
References: <524C54B8.2060107@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524C54B8.2060107@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-mm@kvack.org

On Wed, Oct 02, 2013 at 01:15:36PM -0400, Phillip Susi wrote:
> 
> The man page for readahead(2) incorrectly claims that it blocks until
> all of the requested data has been read.  I filed a bug a few months
> ago to have this corrected, but I think it is being ignored now
> because they don't believe me that it isn't supposed to block.  Could
> someone help back me up and get this fixed?
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=54271

We do need to make sure that users of readahead(2) understand that:

(a) readahead(2) *can* block (either to read metadata blocks, or
    perhaps due to a memory allocation from a kmalloc or get_free_page
    requiring pages to be cleaned and evicted)

(b) readhead(2) does *not* guaranteee that once it returns, that a
    subsequent read or access to a mmap'ed page will not block.  That
    is, readhead(2) does not block until the page becomes available in
    the page cache.

BTW, Caveat (a) is also basically how AIO works --- io_submit(2) can
block, which means that if thread was using AIO because it didn't want
to lose control of the CPU, it can get quite disappointed.  (With ext4
we have a way to preread and the file metadata and try very hard to
keep it from getting ejected from memory to minimize this from
happening, precisely because I had some users for which having
io_submit(2) block was highly undesirable.)

So you're right, but we do need to make sure that the resulting change
doesn't cause the reader of the man page causes them to think that
readhead(2) is guaranteeed not to block.

Cheers,

						- Ted




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
