Date: Tue, 26 Jun 2007 11:52:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 12/26] SLUB: Slab defragmentation core
In-Reply-To: <20070626113823.d78d8c0c.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706261140410.19696@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095916.297690463@sgi.com>
 <20070626011831.181d7a6a.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706261114320.18010@schroedinger.engr.sgi.com>
 <20070626113823.d78d8c0c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Andrew Morton wrote:

> Damned if I know.  Perhaps by reading slob.c instead of slub.c.  When can
> we start deleting some slab implementations?

Probably after we switch to SLUB in 2.6.23 and then address all the 
eventual complaints and issues that come up.

> > See http://marc.info/?l=linux-mm&m=118125373320855&w=2
> 
> hm, OK, thin.
> 
> I think we'll need to come up with a better-than-usual test plan for this
> change.  One starting point might be to ask what in-the-field problem
> you're trying to address here, and what the results were.

The typical scenario is the unmounting of a volume with a large number of 
entries. Anything that uses a large number of inodes and then shifts the
load so that the memory needs to be used for a different purpose. 
Currently those cases lead to trapping a lot of memory in dentry / inode 
caches.

Note that the approach may  also supports memory compaction by Mel.
It may allow us to get rid of the RECLAIMABLE category and thus simplify
his code.

> Also, what are the risks of meltdowns in this code?  For example, it
> reaches the magical 30% ratio, tries to do defrag, but the defrag is for
> some reason unsuccessful and it then tries to run defrag again, etc.

That could occur if something keeps holding extra references to 
dentries and inodes for a long time. Same issue as with page migration. 
Migrates again and again.

The issue is to some extend avoided by putting slabs that we were not able
to handle at the to of the partial list. Meaning these slabs will soon be
grabbed and used for allocations. So they will fill up and protected from
new attempts until they first have been filled up and then aged on the 
partial list.

Another measure to avoid that issue is that we abandon attempts at the
first sign of trouble. That limits the overhead. If we get into some
strange scenario where the slabs are unreclaimable then we will not retry.

Yet another measure is to not attempt anything if the number of
partial slabs is below a certain mininum. We will never attempt to
handle all partial slabs, some problem slabs may stick around without
causing additional reclaim.

> And that was "for example"!  Are there other such potential problems in
> there?  There usually are, with memory reclaim.

Its difficult to foresee all these issues. I have tried to cover what I 
could imagine.
 
> (Should slab_defrag_ratio be per-slab rather than global?)

I do not have seen scenarios that would justify that change. inode / 
dentry are very related and its easier to simply have to manage one
global number.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
