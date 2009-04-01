Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7C36B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:35:47 -0400 (EDT)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id n31MaFQL027406
	for <linux-mm@kvack.org>; Wed, 1 Apr 2009 15:36:17 -0700
Received: from wf-out-1314.google.com (wfc28.prod.google.com [10.142.3.28])
	by spaceape23.eur.corp.google.com with ESMTP id n31MZlZa015586
	for <linux-mm@kvack.org>; Wed, 1 Apr 2009 15:36:13 -0700
Received: by wf-out-1314.google.com with SMTP id 28so268682wfc.32
        for <linux-mm@kvack.org>; Wed, 01 Apr 2009 15:36:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090324173511.GJ23439@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
	 <200903250130.02485.nickpiggin@yahoo.com.au>
	 <20090324144709.GF23439@duck.suse.cz>
	 <200903250203.55520.nickpiggin@yahoo.com.au>
	 <20090324154813.GH23439@duck.suse.cz>
	 <20090324173511.GJ23439@duck.suse.cz>
Date: Wed, 1 Apr 2009 15:36:13 -0700
Message-ID: <604427e00904011536i6332a239pe21786cc4c8b3025@mail.gmail.com>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi Jan:
    I feel that the problem you saw is kind of differnt than mine. As
you mentioned that you saw the PageError() message, which i don't see
it on my system. I tried you patch(based on 2.6.21) on my system and
it runs ok for 2 days, Still, since i don't see the same error message
as you saw, i am not convineced this is the root cause at least for
our problem. I am still looking into it.
    So, are you seeing the PageError() every time the problem happened?

--Ying


On Tue, Mar 24, 2009 at 10:35 AM, Jan Kara <jack@suse.cz> wrote:
> On Tue 24-03-09 16:48:14, Jan Kara wrote:
>> On Wed 25-03-09 02:03:54, Nick Piggin wrote:
>> > On Wednesday 25 March 2009 01:47:09 Jan Kara wrote:
>> > > On Wed 25-03-09 01:30:00, Nick Piggin wrote:
>> >
>> > > > I don't think it is a very good idea for block_write_full_page recovery
>> > > > to do clear_buffer_dirty for !mapped buffers. I think that should rather
>> > > > be a redirty_page_for_writepage in the case that the buffer is dirty.
>> > > >
>> > > > Perhaps not the cleanest way to solve the problem if it is just due to
>> > > > transient shortage of space in ext3, but generic code shouldn't be
>> > > > allowed to throw away dirty data even if it can't be written back due
>> > > > to some software or hardware error.
>> > >
>> > >   Well, that would be one possibility. But then we'd be left with dirty
>> > > pages we cannot ever release since they are constantly dirty (when the
>> > > filesystem really becomes out of space). So what I
>> >
>> > If the filesystem becomes out of space and we have over-committed these
>> > dirty mmapped blocks, then we most definitely want to keep them around.
>> > An error of the system losing a few pages (or if it happens an insanely
>> > large number of times, then slowly dying due to memory leak) is better
>> > than an app suddenly seeing the contents of the page change to nulls
>> > under it when the kernel decides to do some page reclaim.
>>   Hmm, probably you're right. Definitely it would be much easier to track
>> the problem down than it is now... Thinking a bit more... But couldn't a
>> malicious user bring the machine easily to OOM this way? That would be
>> unfortunate.
>  OK, below is the patch which makes things work for me (i.e. no data
> lost). What do you think?
>
>                                                                        Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>
> From f423c2964dd5afbcc40c47731724d48675dd2822 Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Tue, 24 Mar 2009 16:38:22 +0100
> Subject: [PATCH] fs: Don't clear dirty bits in block_write_full_page()
>
> If getblock() fails in block_write_full_page(), we don't want to clear
> dirty bits on buffers. Actually, we even want to redirty the page. This
> way we just won't silently discard users data (written e.g. through mmap)
> in case of ENOSPC, EDQUOT, EIO or other write error. The downside of this
> approach is that if the error is persistent we have this page pinned in
> memory forever and if there are lots of such pages, we can bring the
> machine OOM.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/buffer.c |   10 +++-------
>  1 files changed, 3 insertions(+), 7 deletions(-)
>
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 891e1c7..ae779a0 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -1833,9 +1833,11 @@ recover:
>        /*
>         * ENOSPC, or some other error.  We may already have added some
>         * blocks to the file, so we need to write these out to avoid
> -        * exposing stale data.
> +        * exposing stale data. We redirty the page so that we don't
> +        * loose data we are unable to write.
>         * The page is currently locked and not marked for writeback
>         */
> +       redirty_page_for_writepage(wbc, page);
>        bh = head;
>        /* Recovery: lock and submit the mapped buffers */
>        do {
> @@ -1843,12 +1845,6 @@ recover:
>                    !buffer_delay(bh)) {
>                        lock_buffer(bh);
>                        mark_buffer_async_write(bh);
> -               } else {
> -                       /*
> -                        * The buffer may have been set dirty during
> -                        * attachment to a dirty page.
> -                        */
> -                       clear_buffer_dirty(bh);
>                }
>        } while ((bh = bh->b_this_page) != head);
>        SetPageError(page);
> --
> 1.6.0.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
