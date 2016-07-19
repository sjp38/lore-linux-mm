Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8729E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 00:24:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so14804671pfa.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 21:24:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id er10si8148548pac.38.2016.07.18.21.24.08
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 21:24:09 -0700 (PDT)
Date: Mon, 18 Jul 2016 22:11:23 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] radix-tree: fix radix_tree_iter_retry() for tagged
 iterators.
Message-ID: <20160719041123.GB2779@linux.intel.com>
References: <CACT4Y+a99OW7TYeLsuEic19uY2j45DGXL=LowUMq3TywWS3f2Q@mail.gmail.com>
 <1468495196-10604-1-git-send-email-aryabinin@virtuozzo.com>
 <20160714222527.GA26136@linux.intel.com>
 <5788A46A.70106@virtuozzo.com>
 <20160715190040.GA7195@linux.intel.com>
 <CALYGNiOAKHtU0U6YSg39ByGsBYxrtuWEx270zC3=dtEijDHBaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiOAKHtU0U6YSg39ByGsBYxrtuWEx270zC3=dtEijDHBaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Stable <stable@vger.kernel.org>

On Sat, Jul 16, 2016 at 04:45:31PM +0300, Konstantin Khlebnikov wrote:
> On Fri, Jul 15, 2016 at 10:00 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
<>
> > 3) radix_tree_iter_next() via via a non-tagged iteration like
> > radix_tree_for_each_slot().  This currently happens in shmem_tag_pins()
> > and shmem_partial_swap_usage().
> >
> > I think that this case is currently unhandled.  Unlike with
> > radix_tree_iter_retry() case (#1 above) we can't rely on 'count' in the else
> > case of radix_tree_next_slot() to be zero, so I think it's possible we'll end
> > up executing code in the while() loop in radix_tree_next_slot() that assumes
> > 'slot' is valid.
> >
> > I haven't actually seen this crash on a test setup, but I don't think the
> > current code is safe.
> 
> This is becase distance between ->index and ->next_index now could be
> more that one?
>
> We could fix that by adding "iter->index = iter->next_index - 1;" into
> radix_tree_iter_next()
> right after updating next_index and tweak multi-order itreration logic
> if it depends on that.
> 
> I'd like to keep radix_tree_next_slot() as small as possible because
> this is supposed to be a fast-path.

I think it'll be exactly one?

	iter->next_index = __radix_tree_iter_add(iter, 1);

So iter->index will be X, iter->next_index will be X+1, accounting for the
iterator's shift.  So, basically, whatever your height is, you'll be set up to
process one more entry, I think.

This means that radix_tree_chunk_size() will return 1.  I guess with the
current logic this is safe:

static __always_inline void **
radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
{
...
	} else {
		long count = radix_tree_chunk_size(iter);
		void *canon = slot;

		while (--count > 0) {
			/* code that assumes 'slot' is non-NULL */

So 'count' will be 1, the prefix decrement will make it 0, so we won't execute
the code in the while() loop.  So maybe all the cases are covered after all.

It seems like we need some unit tests in tools/testing/radix-tree around this
- I'll try and find time to add them this week.

I just feel like this isn't very organized.  We have a lot of code in
radix_tree_next_slot() that assumes that 'slot' is non-NULL, but we don't
check it anywhere.  We know it *can* be NULL, but we just happen to have
things set up so that none of the code that uses 'slot' is executed.

I personally feel like a quick check for slot==NULL at the beginning of the
function is the simplest way to keep ourselves safe, and it doesn't seem like
we'd be adding that much overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
