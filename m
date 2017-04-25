Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 789476B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 18:05:32 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id g184so130887150oif.6
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:05:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s12si13548507ots.35.2017.04.25.15.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 15:05:31 -0700 (PDT)
Message-ID: <1493157929.3209.113.camel@linux.intel.com>
Subject: Re: [PATCH -mm] mm, swap: Fix swap space leak in error path of
 swap_free_entries()
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 25 Apr 2017 15:05:29 -0700
In-Reply-To: <20170425143718.d05d4f5020b266dfdd61ed9c@linux-foundation.org>
References: <20170421124739.24534-1-ying.huang@intel.com>
	 <20170425143718.d05d4f5020b266dfdd61ed9c@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

On Tue, 2017-04-25 at 14:37 -0700, Andrew Morton wrote:
> On Fri, 21 Apr 2017 20:47:39 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
> 
> > 
> > From: Huang Ying <ying.huang@intel.com>
> > 
> > In swapcache_free_entries(), if swap_info_get_cont() return NULL,
> > something wrong occurs for the swap entry.A A But we should still
> > continue to free the following swap entries in the array instead of
> > skip them to avoid swap space leak.A A This is just problem in error
> > path, where system may be in an inconsistent state, but it is still
> > good to fix it.
> > 
> > ...
> > 
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -1079,8 +1079,6 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
> > A 		p = swap_info_get_cont(entries[i], prev);
> > A 		if (p)
> > A 			swap_entry_free(p, entries[i]);
> > -		else
> > -			break;
> > A 		prev = p;
> So now prev==NULL.A A Will this code get the locking correct in
> swap_info_get_cont()?A A I think so, but please double-check.
> 

There are 4 possible cases, and I checked that the logic
in swap_info_get_cont do the expected:

entries[i]
valid?		prev	A 	Expected swap_info_get_cont behavior
---------------------------------------------------------------------
NO		NULL		Return NULL p, Do nothing on lock/unlock
NO		NON-NULL	Return NULL p, Unlock prevA 
YES		NULL		Return non-NULL p, lock p
YES		NON-NULL	Return non-NULL p, (p != prev) unlock prev and lock pA 
						A  A (p == prev) do nothing on lock/unlock

Thanks.

Tim

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
