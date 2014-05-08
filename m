Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 94EEF6B0106
	for <linux-mm@kvack.org>; Thu,  8 May 2014 12:53:01 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id vb8so3423699obc.28
        for <linux-mm@kvack.org>; Thu, 08 May 2014 09:53:01 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id fm5si778036pbc.507.2014.05.08.09.53.00
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 09:53:01 -0700 (PDT)
Date: Thu, 8 May 2014 17:52:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Message-ID: <20140508165217.GI17344@arm.com>
References: <20140501184112.GH23420@cmpxchg.org>
 <1399431488.13268.29.camel@kjgkr>
 <20140507113928.GB17253@arm.com>
 <1399540611.13268.45.camel@kjgkr>
 <20140508092646.GA17349@arm.com>
 <1399541860.13268.48.camel@kjgkr>
 <20140508102436.GC17344@arm.com>
 <20140508150026.GA8754@linux.vnet.ibm.com>
 <20140508152946.GA10470@localhost>
 <20140508155330.GE8754@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140508155330.GE8754@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jaegeuk Kim <jaegeuk.kim@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 08, 2014 at 04:53:30PM +0100, Paul E. McKenney wrote:
> On Thu, May 08, 2014 at 04:29:48PM +0100, Catalin Marinas wrote:
> > BTW, is it safe to have a union overlapping node->parent and
> > node->rcu_head.next? I'm still staring at the radix-tree code but a
> > scenario I have in mind is that call_rcu() has been raised for a few
> > nodes, other CPU may have some reference to one of them and set
> > node->parent to NULL (e.g. concurrent calls to radix_tree_shrink()),
> > breaking the RCU linking. I can't confirm this theory yet ;)
> 
> If this were reproducible, I would suggest retrying with non-overlapping
> node->parent and node->rcu_head.next, but you knew that already.  ;-)

Reading the code, I'm less convinced about this scenario (though it's
worth checking without the union).

> But the usual practice would be to make node removal exclude shrinking.
> And the radix-tree code seems to delegate locking to the caller.
> 
> So, is the correct locking present in the page cache?  The radix-tree
> code seems to assume that all update operations for a given tree are
> protected by a lock global to that tree.

The calling code in mm/filemap.c holds mapping->tree_lock when deleting
radix-tree nodes, so no concurrent calls.

> Another diagnosis approach would be to build with
> CONFIG_DEBUG_OBJECTS_RCU_HEAD=y, which would complain about double
> call_rcu() invocations.  Rumor has it that is is necessary to turn off
> other kmem debugging for this to tell you anything -- I have seen cases
> where the kmem debugging obscures the debug-objects diagnostics.

Another test Jaegeuk could run (hopefully he has some time to look into
this).

Thanks for suggestions.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
