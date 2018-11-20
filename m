Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4926B1D9F
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:07:39 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s27so543578pgm.4
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 21:07:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n87sor8066276pfh.64.2018.11.19.21.07.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 21:07:38 -0800 (PST)
Date: Mon, 19 Nov 2018 21:07:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] mm: fix swap offset when replacing shmem page
In-Reply-To: <20181120012950.GA94981@google.com>
Message-ID: <alpine.LSU.2.11.1811192057490.2185@eggly.anvils>
References: <20181119004719.156411-1-yuzhao@google.com> <20181119010924.177177-1-yuzhao@google.com> <alpine.LSU.2.11.1811191343280.17359@eggly.anvils> <20181120012950.GA94981@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 19 Nov 2018, Yu Zhao wrote:
> On Mon, Nov 19, 2018 at 02:11:27PM -0800, Hugh Dickins wrote:
> > On Sun, 18 Nov 2018, Yu Zhao wrote:
> > 
> > > We used to have a single swap address space with swp_entry_t.val
> > > as its radix tree index. This is not the case anymore. Now Each
> > > swp_type() has its own address space and should use swp_offset()
> > > as radix tree index.
> > > 
> > > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > 
> > This fix is a great find, thank you! But completely mis-described!
> 
> Yes, now I remember making swap offset as key was done long after per
> swap device radix tree.
> 
> > And could you do a smaller patch, keeping swap_index, that can go to
> > stable without getting into trouble with the recent xarrifications?
> > 
> > Fixes: bde05d1ccd51 ("shmem: replace page if mapping excludes its zone")
> > Cc: stable@vger.kernel.org # 3.5+
> > 
> > Seems shmem_replace_page() has been wrong since the day I wrote it:
> > good enough to work on swap "type" 0, which is all most people ever use
> > (especially those few who need shmem_replace_page() at all), but broken
> > once there are any non-0 swp_type bits set in the higher order bits.
> 
> But you did get it right when you wrote the function, which was before
> the per swap device radix tree. so
> Fixes: f6ab1f7f6b2d ("mm, swap: use offset of swap entry as key of swap cache")
> looks good?

Oh, you're right, thank you. Yes, the fix is to that one, in 4.9 onwards.

I don't much like my original use of the name "swap_index", when it was
not the index in a swapfile (though it was the index in the radix tree);
but it will become a correct name with your patch.

Though Matthew Wilcox seems to want us to avoid saying "radix tree"...

Hugh
