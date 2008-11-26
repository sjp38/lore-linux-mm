Date: Wed, 26 Nov 2008 06:02:46 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 6/9] swapfile: swapon use discard (trim)
In-Reply-To: <20081125171748.57450cb5.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0811260530570.26081@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
 <Pine.LNX.4.64.0811252140230.17555@blonde.site> <20081125171748.57450cb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dwmw2@infradead.org, jens.axboe@oracle.com, matthew@wil.cx, joern@logfs.org, James.Bottomley@HansenPartnership.com, djshin90@gmail.com, teheo@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008, Andrew Morton wrote:
> On Tue, 25 Nov 2008 21:44:34 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > When adding swap, all the old data on swap can be forgotten: sys_swapon()
> > discard all but the header page of the swap partition (or every extent
> > but the header of the swap file), to give a solidstate swap device the
> > opportunity to optimize its wear-levelling.
> > 
> > If that succeeds, note SWP_DISCARDABLE for later use, and report it
> > with a "D" at the right end of the kernel's "Adding ... swap" message.
> > Perhaps something should be shown in /proc/swaps (swapon -s), but we
> > have to be more cautious before making any addition to that format.
> 
> When reading the above text it's a bit hard to tell whether it's
> talking about "this is how things are at present" or "this is how
> things are after the patch".  This is fairly common with Hugh
> changelogs.

;)  Sorry about that - yes, that's often true.  In this case, it's
all talking about how things are after the patch.  I think it's that
first sentence which bothers you - "all the old data on swap can be
forgotten".  In this case, I'm meaning "it's a good idea to let the
device know that it can forget about all the old data"; but it's easy
to imagine another patch coming from me in which the same sentence
would mean "we've got a terrible data-loss bug, such that all the
data already written to swap gets erased".  Let's hope I didn't
implement the latter.

> > +static int discard_swap(struct swap_info_struct *si)
> > +{
> > +	struct swap_extent *se;
> > +	int err = 0;
> > +
> > +	list_for_each_entry(se, &si->extent_list, list) {
> > +		sector_t start_block = se->start_block << (PAGE_SHIFT - 9);
> > +		pgoff_t nr_blocks = se->nr_pages << (PAGE_SHIFT - 9);
> 
> I trust we don't have any shift overflows here.
> 
> It's a bit dissonant to see a pgoff_t with "blocks" in its name.  But
> swap is like that..

In fact we don't have a shift overflow there, but you've such a good eye.

I noticed that "pgoff_t nr_blocks" line just as I was about to send off
the patches, and had a little worry about it.  By that time I was at
the stage that if I went into the patch and changed a few pgoff_ts
to sector_ts at the last minute, likelihood was I'd screw something
up badly, in one CONFIG combination or another, and if I delayed
it'd be tomorrow.

It would be good to make that change when built and tested,
just for reassurance.  There isn't a shift overflow as it stands,
but the reasons are too contingent for my liking: on 64-bit there
isn't an issue because pgoff_t is as big as sector_t; on 32-bit,
it's because a swp_entry_t is an unsigned long, and it has to
contain five bits for the "type" (which of the 30 or 32 swapfiles
is addressed), and the pages-to-sectors shift is less than 5 on
all 32-bit machines for the foreseeable future.  Oh, and it also
relies on the fact that by the time we're setting up swap extents,
we've already curtailed the size to what's usable by a swp_entry_t,
if that's less than the size given in the swap header.

So, not actually a bug there, but certainly a source of anxiety,
better eliminated.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
