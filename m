Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD49F8E00C2
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:09:20 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f22so13579933qkm.11
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:09:20 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
	<x49va46e1p0.fsf@segfault.boston.devel.redhat.com>
	<x49pnuee1gm.fsf@segfault.boston.devel.redhat.com>
	<x49mupcm11r.fsf@segfault.boston.devel.redhat.com>
	<20181211175156.GF6830@bombadil.infradead.org>
	<x495zw0lz68.fsf@segfault.boston.devel.redhat.com>
	<0f77a532-0d88-78bc-b9cc-06bb203a0405@kernel.dk>
Date: Tue, 11 Dec 2018 13:09:17 -0500
In-Reply-To: <0f77a532-0d88-78bc-b9cc-06bb203a0405@kernel.dk> (Jens Axboe's
	message of "Tue, 11 Dec 2018 11:05:12 -0700")
Message-ID: <x49y38wkkaa.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Matthew Wilcox <willy@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, kent.overstreet@gmail.com

Jens Axboe <axboe@kernel.dk> writes:

> On 12/11/18 11:02 AM, Jeff Moyer wrote:
>> Matthew Wilcox <willy@infradead.org> writes:
>> 
>>> On Tue, Dec 11, 2018 at 12:21:52PM -0500, Jeff Moyer wrote:
>>>> I'm going to submit this version formally.  If you're interested in
>>>> converting the ioctx_table to xarray, you can do that separately from a
>>>> security fix.  I would include a performance analysis with that patch,
>>>> though.  The idea of using a radix tree for the ioctx table was
>>>> discarded due to performance reasons--see commit db446a08c23d5 ("aio:
>>>> convert the ioctx list to table lookup v3").  I suspect using the xarray
>>>> will perform similarly.
>>>
>>> There's a big difference between Octavian's patch and mine.  That patch
>>> indexed into the radix tree by 'ctx_id' directly, which was pretty
>>> much guaranteed to exhibit some close-to-worst-case behaviour from the
>>> radix tree due to IDs being sparsely assigned.  My patch uses the ring
>>> ID which _we_ assigned, and so is nicely behaved, being usually a very
>>> small integer.
>> 
>> OK, good to know.  I obviously didn't look too closely at the two.
>> 
>>> What performance analysis would you find compelling?  Octavian's original
>>> fio script:
>>>
>>>> rw=randrw; size=256k ;directory=/mnt/fio; ioengine=libaio; iodepth=1
>>>> blocksize=1024; numjobs=512; thread; loops=100
>>>>
>>>> on an EXT2 filesystem mounted on top of a ramdisk
>>>
>>> or something else?
>> 
>> I think the most common use case is a small number of ioctx-s, so I'd
>> like to see that use case not regress (that should be easy, right?).

Bah, I meant a small number of threads doing submit/getevents.

>> Kent, what were the tests you were using when doing this work?  Jens,
>> since you're doing performance work in this area now, are there any
>> particular test cases you care about?
>
> I can give it a spin, ioctx lookup is in the fast path, and for "classic"
> aio we do it twice for each IO...

Thanks!

-Jeff
