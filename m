Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 2C6B06B0005
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 23:56:16 -0500 (EST)
Received: by mail-da0-f49.google.com with SMTP id v40so2459783dad.22
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 20:56:15 -0800 (PST)
Date: Sun, 3 Feb 2013 20:56:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
In-Reply-To: <20130127141853.GB27019@kernel.org>
Message-ID: <alpine.LNX.2.00.1302032039540.4662@eggly.anvils>
References: <20130122065341.GA1850@kernel.org> <20130123075808.GH2723@blaptop> <1359018598.2866.5.camel@kernel> <CAH9JG2UpVtxeLB21kx5-_pokK8p_uVZ-2o41Ep--oOyKStBZFQ@mail.gmail.com> <20130127141853.GB27019@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Minchan Kim <minchan@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Simon Jeons <simon.jeons@gmail.com>

On Sun, 27 Jan 2013, Shaohua Li wrote:
> On Sat, Jan 26, 2013 at 01:40:55PM +0900, Kyungmin Park wrote:
> > 5. SSD related optimization, mainly discard support.
> > 
> > Now swap codes are based on each swap slots. it means it can't
> > optimize discard feature since getting meaningful performance gain, it
> > requires 2 pages at least. Of course it's based on eMMC. In case of
> > SSD. it requires more pages to support discard.
> > 
> > To address issue. I consider the batched discard approach used at filesystem.
> > *Sometime* scan all empty slot and it issues discard continuous swap
> > slots as many as possible.
> 
> I posted a patch to make discard async before, which is almost good to me,
> though we still discard a cluster. 
> http://marc.info/?l=linux-mm&m=135087309208120&w=2

Any reason why you point to 2012/10/22 patch rather than the 2012/11/19?

Seeing this reminded me to take your 1/2 and 2/2 (of 11/19) out again and
give them a fresh run - though they were easier to apply to 3.8-rc rather
than mmotm with your locking changes, so it was 3.8-rc6 I tried.

As I reported in private mail last year, I wish you'd remove the "buddy"
from description of your 1/2 allocator, that just misled me; but I've not
experienced any problem with the allocator, and I still like the direction
you take with improving swap discard in 2/2.

This time around I've not yet seen any "swap_free: Unused swap offset entry"
messages (despite forgetting to include your later SWAP_MAP_BAD addition to
__swap_duplicate() - I still haven't thought that through to be honest),
but did again get the VM_BUG_ON(error == -EEXIST) in __add_to_swap_cache()
called from add_to_swap() from shrink_page_list().

Since it came after 1.5 hours of load, I didn't give it much thought,
and just went on to test other things, thinking I could easily reproduce
it later; but have failed to do so in many hours since.  Still trying.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
