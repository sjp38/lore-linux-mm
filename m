From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] rd: Use a private inode for backing storage
Date: Sun, 21 Oct 2007 19:56:50 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710210928.58265.borntraeger@de.ibm.com> <m1zlycc1ut.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1zlycc1ut.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710211956.50624.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 21 October 2007 18:23, Eric W. Biederman wrote:
> Christian Borntraeger <borntraeger@de.ibm.com> writes:

> Let me put it another way.  Looking at /proc/slabinfo I can get
> 37 buffer_heads per page.  I can allocate 10% of memory in
> buffer_heads before we start to reclaim them.  So it requires just
> over 3.7 buffer_heads on very page of low memory to even trigger
> this case.  That is a large 1k filesystem or a weird sized partition,
> that we have written to directly.

On a highmem machine it it could be relatively common.


> > I still dont fully understand what issues you have with my patch.
> > - it obviously fixes the problem
> > - I am not aware of any regression it introduces
> > - its small
>
> My primary issue with your patch is that it continues the saga the
> trying to use buffer cache to store the data which is a serious
> review problem, and clearly not what we want to do long term.

You don't want to change that for a stable patch, however.
It fixes the bug.


> > One concern you had, was the fact that buffer heads are out of sync with
> > struct pages. Testing your first patch revealed that this is actually
> > needed by reiserfs - and maybe others.
> > I can also see, that my patch looks a bit like a bandaid that cobbles the
> > rd pieces together.
> >
> > Is there anything else, that makes my patch unmergeable in your
> > opinion?
>
> For linus's tree the consensus is that to fix rd.c that we
> need to have a backing store that is stored somewhere besides
> in the page cache/buffer cache for /dev/ram0.   Doing that prevents
> all of the weird issues.
>
> Now we have the question of which patch gets us there.  I contend
> I have implemented it with my last little patch that this thread
> is a reply to.  Nick hasn't seen that just yet.

Or ever will. It wasn't that my whole argument against it is
based on that I mistakenly thought your patch served the bdev
inode directly from its backing store.


> So if we have a small patch that can implement the proper long
> term fix I contend we are in better shape.

I just don't think what you have is the proper fix. Calling
into the core vfs and vm because right now it does something
that works for you but is completely unrelated to what you
are conceptually doing is not the right fix.

Also, the patch I posted is big because it did other stuff
with dynamically allocated ramdisks from loop (ie. a modern
rewrite). As it is applied to rd.c and split into chunks, the
actual patch to switch to the new backing store isn't actually
that big. I'll submit it to -mm after things stabilise after
the merge window too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
