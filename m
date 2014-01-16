Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id B7AE46B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 17:10:54 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id 6so1369197bkj.8
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 14:10:54 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id at9si2297882bkc.56.2014.01.16.14.10.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 14:10:53 -0800 (PST)
Date: Thu, 16 Jan 2014 17:09:51 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140116220951.GO6963@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <52D622B5.6070203@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D622B5.6070203@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jan 15, 2014 at 01:55:01PM +0800, Bob Liu wrote:
> Hi Johannes,
> 
> On 01/11/2014 02:10 AM, Johannes Weiner wrote:
> > Previously, page cache radix tree nodes were freed after reclaim
> > emptied out their page pointers.  But now reclaim stores shadow
> > entries in their place, which are only reclaimed when the inodes
> > themselves are reclaimed.  This is problematic for bigger files that
> > are still in use after they have a significant amount of their cache
> > reclaimed, without any of those pages actually refaulting.  The shadow
> > entries will just sit there and waste memory.  In the worst case, the
> > shadow entries will accumulate until the machine runs out of memory.
> > 
> 
> I have one more question. It seems that other algorithm only remember
> history information of a limit number of evicted pages where the number
> is usually the same as the total cache or memory size.
> But in your patch, I didn't see a preferred value that how many evicted
> pages' history information should be recorded. It all depends on the
> workingset_shadow_shrinker?

That "same as total cache" number is a fairly arbitrary cut-off that
defines how far we record eviction history.  For this patch set, we
technically do not need more shadow entries than active pages, but
strict enforcement would be very expensive.  So we leave it mostly to
refaults and inode reclaim to keep the number of shadow entries low,
with the shadow shrinker as an emergency backup.  Keep in mind that
the shadow entries represent that part of the working set that exceeds
available memory.  So the only way the number of shadow entries
exceeds the number of RAM pages in the system is if your workingset is
more than twice that of memory, otherwise the shadow entries refault
before they can accumulate.  And because of inode reclaim, that huge
working set would have to be backed by a very small number of files,
otherwise the shadow entries are reclaimed along with the inodes.  But
this theoretical workload would be entirely IO bound and a few extra
MB wasted on shadow entries should make no difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
