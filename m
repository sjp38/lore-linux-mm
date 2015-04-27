Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF1A6B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:41:21 -0400 (EDT)
Received: by wizk4 with SMTP id k4so106976585wiz.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:41:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id wr1si34061112wjb.25.2015.04.27.09.41.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 09:41:19 -0700 (PDT)
Date: Mon, 27 Apr 2015 18:40:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
Message-ID: <20150427164050.GA24035@redhat.com>
References: <20150418205656.GA7972@pd.tnic>
 <CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
 <20150418215656.GA13928@node.dhcp.inet.fi>
 <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
 <20150418220803.GB7972@pd.tnic>
 <20150422131219.GD6897@pd.tnic>
 <20150422183309.GA4351@node.dhcp.inet.fi>
 <CA+55aFx5NXDUsyd2qjQ+Uu3mt9Fw4HrsonzREs9V0PhHwWmGPQ@mail.gmail.com>
 <20150423162311.GB19709@redhat.com>
 <20150424214225.GA18804@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150424214225.GA18804@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

Hello,

On Sat, Apr 25, 2015 at 12:42:25AM +0300, Kirill A. Shutemov wrote:
> On Thu, Apr 23, 2015 at 06:23:11PM +0200, Andrea Arcangeli wrote:
> > On Wed, Apr 22, 2015 at 12:26:55PM -0700, Linus Torvalds wrote:
> > > On Wed, Apr 22, 2015 at 11:33 AM, Kirill A. Shutemov
> > > <kirill@shutemov.name> wrote:
> > > >
> > > > Could you try patch below instead? This can give a clue what's going on.
> > > 
> > > Just FYI, I've done the revert in my tree.
> > > 
> > > Trying to figure out what is going on despite that is obviously a good
> > > idea, but I'm hoping that my merge window is winding down, so I am
> > > trying to make sure it's all "good to go"..
> > 
> > Sounds safer to defer it, agreed.
> > 
> > Unfortunately I also can only reproduce it only on a workstation where
> > it wasn't very handy to debug it as it'd disrupt my workflow and it
> > isn't equipped with reliable logging either (and the KMS mode didn't
> > switch to console to show me the oops either). It just got it logged
> > once in syslog before freezing.
> > 
> > The problem has to be that there's some get_page/put_page activity
> > before and after a PageAnon transition and it looks like a tail page
> > got mapped by hand in userland by some driver using 4k ptes which
> > isn't normal
> 
> Compound pages mapped with PTEs predates THP. See f3d48f0373c1.

Yes, I intended "normal" as a feeling about it considering it's your
new patchset that tries to introduce that behavior for regular anon
pages, I didn't imply it was not ok for driver-owned pages, sorry for
the confusion.

> I looked into code a bit more. And the VM_BUG_ON_PAGE() is bogus. See
> explanation in commit message below.
> 
> Tail page refcounting is mess. Please consider reviewing my patchset which
> drops it [1]. ;)
> 
> Linus, how should we proceed with reverted patch? Should I re-submit it to
> Andrew? Or you'll re-revert it?

You could resubmit the old patch together with this patch, so they go
together.

In retrospect it may have been cleaner to pick another field than
mapcount for the tail page refcounting, then the VM_BUG_ON could have
been retained.

mapcount was picked as candidate of tail page refcounting, because it
already implemented a "count" too so it was simpler to use than
another random 32bit word and didn't require further unions into the
page struct.

page_count cannot be used for refcounting tail pages of THP or
speculative pagecache lookups race against
split_huge_page_refcount. For non-THP it doesn't matter, even
page_count could have been used or even better no tail refcounting at
all like with your patch.

With your patch you're basically disabling the tail page refcounting
for those usages so it probably doesn't matter anymore to move away
from mapcount and removing the VM_BUG_ON doesn't concern me by now (it
never actually triggered before).

Even for those usages doubling up the refcounting in mapcount, the
refcounting of 4.0 was safe. The false positive VM_BUG_ON could only
happen only after the change.

> [1] lkml.kernel.org/g/1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com
> 
> From 854cdc961b7f83f04a83144ab4f7459ae46b0f3d Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Fri, 24 Apr 2015 23:49:04 +0300
> Subject: [PATCH] mm: drop bogus VM_BUG_ON_PAGE assert in put_page() codepath
> 
> My patch 8d63d99a5dfb which was merged during 4.1 merge window caused
> regression:
> 
>   page:ffffea0010a15040 count:0 mapcount:1 mapping:          (null) index:0x0
>   flags: 0x8000000000008014(referenced|dirty|tail)
>   page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
>   ------------[ cut here ]------------
>   kernel BUG at mm/swap.c:134!
> 
> The problem can be reproduced by playing *two* audio files at the same
> time and then stopping one of players. I used two mplayers to trigger
> this.
> 
> The VM_BUG_ON_PAGE() which triggers the bug is bogus:
> 
> Sound subsystem uses compound pages for its buffers, but unlike most
> __GFP_COMP users sound maps compound pages to userspace with PTEs.
> 
> In our case with two players map the buffer twice and therefore elevates

I didn't think at the case of mapping the same compound page twice in
userland, this clearly explains the crash. I thought it had to be the
PageAnon flipping somehow but I couldn't explain where... and in fact
it was something else.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Borislav Petkov <bp@alien8.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/swap.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index a7251a8ed532..a3a0a2f1f7c3 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -131,7 +131,6 @@ void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
>  		 * here, see the comment above this function.
>  		 */
>  		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
> -		VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
>  		if (put_page_testzero(page_head)) {
>  			/*
>  			 * If this is the tail of a slab THP page,

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

If you resend a consolidated commit with the two changes in the same
commit, feel free to retain the Reviewed-by for both.

Optionally you could turn it into a VM_BUG_ON_PAGE(page_mapcount(page)
< 0, page) but it's up to you.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
