Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 367AF6B0133
	for <linux-mm@kvack.org>; Thu,  8 May 2014 20:08:47 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so3486037pab.22
        for <linux-mm@kvack.org>; Thu, 08 May 2014 17:08:46 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id db3si1279135pbc.488.2014.05.08.17.08.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 08 May 2014 17:08:46 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N5A0069L5QKME50@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 09 May 2014 09:08:44 +0900 (KST)
Content-transfer-encoding: 8BIT
Message-id: <1399593989.13268.59.camel@kjgkr>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
From: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Reply-to: jaegeuk.kim@samsung.com
Date: Fri, 09 May 2014 09:06:29 +0900
In-reply-to: <20140508165217.GI17344@arm.com>
References: <20140501184112.GH23420@cmpxchg.org>
 <1399431488.13268.29.camel@kjgkr> <20140507113928.GB17253@arm.com>
 <1399540611.13268.45.camel@kjgkr> <20140508092646.GA17349@arm.com>
 <1399541860.13268.48.camel@kjgkr> <20140508102436.GC17344@arm.com>
 <20140508150026.GA8754@linux.vnet.ibm.com> <20140508152946.GA10470@localhost>
 <20140508155330.GE8754@linux.vnet.ibm.com> <20140508165217.GI17344@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2014-05-08 (ea(C)), 17:52 +0100, Catalin Marinas:
> On Thu, May 08, 2014 at 04:53:30PM +0100, Paul E. McKenney wrote:
> > On Thu, May 08, 2014 at 04:29:48PM +0100, Catalin Marinas wrote:
> > > BTW, is it safe to have a union overlapping node->parent and
> > > node->rcu_head.next? I'm still staring at the radix-tree code but a
> > > scenario I have in mind is that call_rcu() has been raised for a few
> > > nodes, other CPU may have some reference to one of them and set
> > > node->parent to NULL (e.g. concurrent calls to radix_tree_shrink()),
> > > breaking the RCU linking. I can't confirm this theory yet ;)
> > 
> > If this were reproducible, I would suggest retrying with non-overlapping
> > node->parent and node->rcu_head.next, but you knew that already.  ;-)
> 
> Reading the code, I'm less convinced about this scenario (though it's
> worth checking without the union).
> 
> > But the usual practice would be to make node removal exclude shrinking.
> > And the radix-tree code seems to delegate locking to the caller.
> > 
> > So, is the correct locking present in the page cache?  The radix-tree
> > code seems to assume that all update operations for a given tree are
> > protected by a lock global to that tree.
> 
> The calling code in mm/filemap.c holds mapping->tree_lock when deleting
> radix-tree nodes, so no concurrent calls.
> 
> > Another diagnosis approach would be to build with
> > CONFIG_DEBUG_OBJECTS_RCU_HEAD=y, which would complain about double
> > call_rcu() invocations.  Rumor has it that is is necessary to turn off
> > other kmem debugging for this to tell you anything -- I have seen cases
> > where the kmem debugging obscures the debug-objects diagnostics.
> 
> Another test Jaegeuk could run (hopefully he has some time to look into
> this).

Yap, I'll test this too.
Thanks,

> 
> Thanks for suggestions.
> 

-- 
Jaegeuk Kim
Samsung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
