Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 437F76B006E
	for <linux-mm@kvack.org>; Tue, 13 May 2014 06:33:31 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so248834eek.31
        for <linux-mm@kvack.org>; Tue, 13 May 2014 03:33:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si12767699eef.202.2014.05.13.03.33.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 03:33:30 -0700 (PDT)
Date: Tue, 13 May 2014 11:33:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv2 3/4] plist: add plist_requeue
Message-ID: <20140513103323.GN23991@suse.de>
References: <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
 <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
 <1399912700-30100-4-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1399912700-30100-4-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, May 12, 2014 at 12:38:19PM -0400, Dan Streetman wrote:
> Add plist_requeue(), which moves the specified plist_node after
> all other same-priority plist_nodes in the list.  This is
> essentially an optimized plist_del() followed by plist_add().
> 
> This is needed by swap, which (with the next patch in this set)
> uses a plist of available swap devices.  When a swap device
> (either a swap partition or swap file) are added to the system
> with swapon(), the device is added to a plist, ordered by
> the swap device's priority.  When swap needs to allocate a page
> from one of the swap devices, it takes the page from the first swap
> device on the plist, which is the highest priority swap device.
> The swap device is left in the plist until all its pages are
> used, and then removed from the plist when it becomes full.
> 
> However, as described in man 2 swapon, swap must allocate pages
> from swap devices with the same priority in round-robin order;
> to do this, on each swap page allocation, swap uses a page from
> the first swap device in the plist, and then calls plist_requeue()
> to move that swap device entry to after any other same-priority
> swap devices.  The next swap page allocation will again use a
> page from the first swap device in the plist and requeue it,
> and so on, resulting in round-robin usage of equal-priority
> swap devices.
> 
> Also add plist_test_requeue() test function, for use by plist_test()
> to test plist_requeue() function.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> 

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
