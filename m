Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 059256B013E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 15:21:22 -0400 (EDT)
Date: Mon, 20 Jun 2011 21:21:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm: completely disable THP by
 transparent_hugepage=never
Message-ID: <20110620192117.GG20843@redhat.com>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <20110620165844.GA9396@suse.de>
 <4DFF7E3B.1040404@redhat.com>
 <4DFF7F0A.8090604@redhat.com>
 <4DFF8106.8090702@redhat.com>
 <4DFF8327.1090203@redhat.com>
 <4DFF84BB.3050209@redhat.com>
 <4DFF8848.2060802@redhat.com>
 <20110620182558.GF4749@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110620182558.GF4749@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Cong Wang <amwang@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, Jun 20, 2011 at 02:25:58PM -0400, Vivek Goyal wrote:
> So I see some opprotunity there to save memory. But this 10kB
> definitely sounds trivial amount to me.

Agree with you and Rik. Also I already avoided the big memory waste
(that for example isn't avoided in the ksmd and could be optimized
away without decreasing flexibility of KSM, and ksmd surely runs on
the kdump kernel too...) that is to make khugepaged exit and release
kernel stack when enabled=never (either done by sysfs or at boot with
transparent_hugepage=never) and all other structs associated with a
(temporarily) useless kernel thread.

The khugepaged_slab_init and mm_slot_hash_init() maybe could be
deferred to when khugepaged starts, and be released when it shutdown
but it makes it more tricky/racey. If you really want to optimize
that, without preventing to ever enable THP again despite all .text
was compiled in and ready to run. You will likely save more if you
make ksmd exit when run=0 (which btw is a much more common config than
enabled=never with THP). And slots hashes are allocated by ksm too so
you could optimize those too if you want and allocate them only by the
time ksmd starts.

As long as it'd still possible to enable the feature again as it is
possible now without noticing an altered behavior from userland, I'm
not entirely against optimizing for saving ~8k of ram even if it
increases complexity a bit (more kernel code will increase .text a bit
though, hopefully not 8k more of .text ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
