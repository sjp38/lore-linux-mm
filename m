Subject: Re: [RFC] Don't set/test/wait-for radix tree tags if no capability
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0609131350030.19101@schroedinger.engr.sgi.com>
References: <1158176114.5328.52.camel@localhost>
	 <Pine.LNX.4.64.0609131350030.19101@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 13 Sep 2006 18:12:39 -0400
Message-Id: <1158185559.5328.82.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-13 at 13:51 -0700, Christoph Lameter wrote:
> On Wed, 13 Sep 2006, Lee Schermerhorn wrote:
> 
> > While debugging a problem [in the out-of-tree migration cache], I
> > noticed a lot of radix-tree tag activity for address spaces that have
> > the BDI_CAP_NO_{ACCT_DIRTY|WRITEBACK} capability flags set--effectively
> > disabling these capabilities--in their backing device.  Altho'
> > functionally benign, I believe that this unnecessary overhead.  Seeking
> > contrary opinions.
> 
> I do not think that not wanting accounting for dirty pages means that we 
> should not mark those dirty. If we do this then filesystems will 
> not be able to find the dirty pags for writeout.

That's why I asked, and why I noted that maybe setting the dirty tags
should be gated by the 'No writeback' capability, rather than the "No
dirty accounting" capability.  But then, maybe "no writeback" doesn't
really mean that the address space/backing device doesn't do
writeback.  

The 'no writeback' capability is set for things like:  configfs,
hugetlbfs, dlmfs, ramfs, cpuset, sysfs, shmem segs, swap, ...  And, as I
mentioned, the 'no dirty accounting' capability happens to be set for
all file systems that set 'no writeback'.  However, I agree that we
shouldn't count on this.  

So, do the file systems need to writeout dirty pages for these file
systems using the radix tree tags?  Just looking where the tags are
queried [radix_tree_gang_lookup_tag()], it appears that tags are only
used by "real" file systems, despite a call from pagevec_lookup_tag()
that resides in mm/swap.c.  And, it appears that the 'no writeback'
capability flag will prevent writeback in some cases.  Not sure if it
catches all.

If we can't gate setting the flags based on the existing capabilities,
maybe we want to define a new cap flag--e.g., BDI_CAP_NO_TAGS--for use
by file systems that don't need the tags set?  Not sure it's worth it,
but could eliminate some cache pollution.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
