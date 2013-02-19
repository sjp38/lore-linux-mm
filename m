Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 3E6BB6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 14:42:41 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so2437833pbc.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 11:42:40 -0800 (PST)
Date: Tue, 19 Feb 2013 11:41:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
In-Reply-To: <20130219061512.GA14921@kernel.org>
Message-ID: <alpine.LNX.2.00.1302191120540.2406@eggly.anvils>
References: <20130122065341.GA1850@kernel.org> <20130123075808.GH2723@blaptop> <1359018598.2866.5.camel@kernel> <CAH9JG2UpVtxeLB21kx5-_pokK8p_uVZ-2o41Ep--oOyKStBZFQ@mail.gmail.com> <20130127141853.GB27019@kernel.org> <alpine.LNX.2.00.1302032039540.4662@eggly.anvils>
 <20130219061512.GA14921@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Minchan Kim <minchan@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Simon Jeons <simon.jeons@gmail.com>

On Tue, 19 Feb 2013, Shaohua Li wrote:
> On Sun, Feb 03, 2013 at 08:56:15PM -0800, Hugh Dickins wrote:
> > 
> > Seeing this reminded me to take your 1/2 and 2/2 (of 11/19) out again and
> > give them a fresh run - though they were easier to apply to 3.8-rc rather
> > than mmotm with your locking changes, so it was 3.8-rc6 I tried.
> > 
> > As I reported in private mail last year, I wish you'd remove the "buddy"
> > from description of your 1/2 allocator, that just misled me; but I've not
> > experienced any problem with the allocator, and I still like the direction
> > you take with improving swap discard in 2/2.
> > 
> > This time around I've not yet seen any "swap_free: Unused swap offset entry"
> > messages (despite forgetting to include your later SWAP_MAP_BAD addition to
> > __swap_duplicate() - I still haven't thought that through to be honest),
> > but did again get the VM_BUG_ON(error == -EEXIST) in __add_to_swap_cache()
> > called from add_to_swap() from shrink_page_list().
> > 
> > Since it came after 1.5 hours of load, I didn't give it much thought,
> > and just went on to test other things, thinking I could easily reproduce
> > it later; but have failed to do so in many hours since.  Still trying.
> 
> Missed this mail, sorry. I'm planing to repost the patches against linux-next (because
> of the locking changes) and will include the SWAP_MAP_BAD change. I did see
> problems without the SWAP_MAP_BAD change.

Good, I'll take a look at them then.

I did manage to hit the VM_BUG_ON(error == -EEXIST) in __add_to_swap_cache()
again with those patches, and verified that there really was another page
sitting in its radix_tree slot.

Although I've never succeeded in reproducing this without your patches,
I'm pretty sure they're not to blame, that they just perhaps alter the
timing in some way as to make this more likely to happen.

I believe (without actual evidence) that it's a race with swapin_readahead():
its read_swap_cache_async() coming in and reading into its own page, in
between the swap slot being allocated from the swap_map with SWAP_HAS_CACHE
and add_to_swap()'s page actually being inserted into the swap cache.

I've not prepared a fix for it yet, but it shouldn't be a worry.

Something I learnt in looking through the radix_tree to find the
right slot, a benefit of your your per-device swapper_spaces that
we had not anticipated: once you have multiple swap areas (because
the swp_entry_t is arranged with the "type" at the top to get the
offsets contiguous), the single-swapper_space radix_tree becomes
very sparse, with matching high height and lots of silly levels
of radix_tree_nodes - I had to go down 10 levels, despite having
only two 1.5GB swap areas.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
