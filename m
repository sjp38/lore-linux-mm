Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4C19F6B0070
	for <linux-mm@kvack.org>; Tue, 13 May 2014 06:34:52 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so254235eek.21
        for <linux-mm@kvack.org>; Tue, 13 May 2014 03:34:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h41si47538eeo.58.2014.05.13.03.34.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 03:34:51 -0700 (PDT)
Date: Tue, 13 May 2014 11:34:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv2 4/4] swap: change swap_list_head to plist, add
 swap_avail_head
Message-ID: <20140513103446.GO23991@suse.de>
References: <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
 <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
 <1399912700-30100-5-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1399912700-30100-5-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

On Mon, May 12, 2014 at 12:38:20PM -0400, Dan Streetman wrote:
> Originally get_swap_page() started iterating through the singly-linked
> list of swap_info_structs using swap_list.next or highest_priority_index,
> which both were intended to point to the highest priority active swap
> target that was not full.  The first patch in this series changed the
> singly-linked list to a doubly-linked list, and removed the logic to start
> at the highest priority non-full entry; it starts scanning at the highest
> priority entry each time, even if the entry is full.
> 
> Replace the manually ordered swap_list_head with a plist, swap_active_head.
> Add a new plist, swap_avail_head.  The original swap_active_head plist
> contains all active swap_info_structs, as before, while the new
> swap_avail_head plist contains only swap_info_structs that are active and
> available, i.e. not full.  Add a new spinlock, swap_avail_lock, to protect
> the swap_avail_head list.
> 
> Mel Gorman suggested using plists since they internally handle ordering
> the list entries based on priority, which is exactly what swap was doing
> manually.  All the ordering code is now removed, and swap_info_struct
> entries and simply added to their corresponding plist and automatically
> ordered correctly.
> 
> Using a new plist for available swap_info_structs simplifies and
> optimizes get_swap_page(), which no longer has to iterate over full
> swap_info_structs.  Using a new spinlock for swap_avail_head plist
> allows each swap_info_struct to add or remove themselves from the
> plist when they become full or not-full; previously they could not
> do so because the swap_info_struct->lock is held when they change
> from full<->not-full, and the swap_lock protecting the main
> swap_active_head must be ordered before any swap_info_struct->lock.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Shaohua Li <shli@fusionio.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
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
