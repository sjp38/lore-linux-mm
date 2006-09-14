Date: Thu, 14 Sep 2006 16:23:04 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] Don't set/test/wait-for radix tree tags if no capability
In-Reply-To: <1158185559.5328.82.camel@localhost>
Message-ID: <Pine.LNX.4.64.0609141559300.3122@blonde.wat.veritas.com>
References: <1158176114.5328.52.camel@localhost>
 <Pine.LNX.4.64.0609131350030.19101@schroedinger.engr.sgi.com>
 <1158185559.5328.82.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Lee Schermerhorn wrote:
> On Wed, 2006-09-13 at 13:51 -0700, Christoph Lameter wrote:
> > On Wed, 13 Sep 2006, Lee Schermerhorn wrote:
> > 
> > > While debugging a problem [in the out-of-tree migration cache], I
> > > noticed a lot of radix-tree tag activity for address spaces that have
> > > the BDI_CAP_NO_{ACCT_DIRTY|WRITEBACK} capability flags set--effectively
> > > disabling these capabilities--in their backing device.  Altho'
> > > functionally benign, I believe that this unnecessary overhead.  Seeking
> > > contrary opinions.
> > 
> > I do not think that not wanting accounting for dirty pages means that we 
> > should not mark those dirty. If we do this then filesystems will 
> > not be able to find the dirty pags for writeout.
> 
> That's why I asked, and why I noted that maybe setting the dirty tags
> should be gated by the 'No writeback' capability, rather than the "No
> dirty accounting" capability.  But then, maybe "no writeback" doesn't
> really mean that the address space/backing device doesn't do
> writeback.  
> 
> The 'no writeback' capability is set for things like:  configfs,
> hugetlbfs, dlmfs, ramfs, cpuset, sysfs, shmem segs, swap, ...  And, as I
> mentioned, the 'no dirty accounting' capability happens to be set for
> all file systems that set 'no writeback'.  However, I agree that we
> shouldn't count on this.  

I agree you do need to check it out carefully, but it sounds very
reasonable to me to avoid that radix tree tag overhead on the whole
class of storageless filesystems (and swap plays by those same rules,
despite that it does have backing storage).

If it checks out right at present, I think you can "count on this",
just so long as you insert a suitable BUG_ON somewhere to alert us
if some later mod unconsciously changes the situation (e.g. we find
we do need more dirty page tracking on those currently exempt).

A related saving you can make there, I believe, is to add another
.set_page_dirty variant which does nothing(?) more than SetPageDirty -
swap and tmpfs and probably all those you mentioned above don't really
want to do any more than that there - or didn't two or three years ago,
when I had a patch for that but got diverted - the situation may have
changed significantly since, and no longer be an option.

> 
> So, do the file systems need to writeout dirty pages for these file
> systems using the radix tree tags?  Just looking where the tags are
> queried [radix_tree_gang_lookup_tag()], it appears that tags are only
> used by "real" file systems, despite a call from pagevec_lookup_tag()
> that resides in mm/swap.c.  And, it appears that the 'no writeback'
> capability flag will prevent writeback in some cases.  Not sure if it
> catches all.

You are shamelessly parading your naivete, expecting mm/swap.c to
have something to do with swap.  Perhaps it did once upon a time
(ooh, swap_setup does have something to do with swap), and it still
has a lot to do with the page LRU lists (which are pointless unless
you're swapping in the wider sense); but really it's just mm/misc.c.

Hugh

> 
> If we can't gate setting the flags based on the existing capabilities,
> maybe we want to define a new cap flag--e.g., BDI_CAP_NO_TAGS--for use
> by file systems that don't need the tags set?  Not sure it's worth it,
> but could eliminate some cache pollution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
