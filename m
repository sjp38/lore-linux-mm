Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 63B086B00E8
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 00:53:23 -0400 (EDT)
Date: Wed, 13 Oct 2010 12:53:19 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [RFC]vmscan: doing page_referenced() in batch way
Message-ID: <20101013045319.GA11115@sli10-conroe.sh.intel.com>
References: <1285729053.27440.13.camel@sli10-conroe.sh.intel.com>
 <20101006131052.e3ae026f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101006131052.e3ae026f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, "hughd@google.com" <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 04:10:52AM +0800, Andrew Morton wrote:
> On Wed, 29 Sep 2010 10:57:33 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > when memory pressure is high, page_referenced() causes a lot of lock contention
> > for anon_vma->lock or mapping->i_mmap_lock. Considering pages from one file
> > usually live side by side in LRU list, we can lock several pages in
> > shrink_page_list() and do batch page_referenced() to avoid some lock/unlock,
> > which should reduce lock contention a lot. The locking rule documented in
> > rmap.c is:
> > page_lock
> > 	mapping->i_mmap_lock
> > 		anon_vma->lock
> > For a batch of pages, we do page lock for all of them first and check their
> > reference, and then release their i_mmap_lock or anon_vma lock. This seems not
> > break the rule to me.
> > Before I further polish the patch, I'd like to know if there is anything
> > preventing us to do such batch here.
Thanks for your time.

> The patch adds quite a bit of complexity, so we'd need to see benchmark
> testing results which justify it, please.
My test only shows around 10% improvements, which is below my expections.
try_to_unmap() causes quite a lot of lock contention for such locks, and makes
the page_referenced() batch not quite helpful. Looks we can do batch try_to_unmap()
too. I'll report back later when I have data with try_to_unmap() batched.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
