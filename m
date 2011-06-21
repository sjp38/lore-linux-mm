Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5146B0139
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 00:08:23 -0400 (EDT)
Message-ID: <4E00192E.70901@redhat.com>
Date: Tue, 21 Jun 2011 12:08:14 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165844.GA9396@suse.de> <4DFF7E3B.1040404@redhat.com> <4DFF7F0A.8090604@redhat.com> <4DFF8106.8090702@redhat.com> <4DFF8327.1090203@redhat.com> <4DFF84BB.3050209@redhat.com> <4DFF8848.2060802@redhat.com> <20110620182558.GF4749@redhat.com> <20110620192117.GG20843@redhat.com>
In-Reply-To: <20110620192117.GG20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 03:21, Andrea Arcangeli a??e??:
> On Mon, Jun 20, 2011 at 02:25:58PM -0400, Vivek Goyal wrote:
>> So I see some opprotunity there to save memory. But this 10kB
>> definitely sounds trivial amount to me.
>
> Agree with you and Rik. Also I already avoided the big memory waste
> (that for example isn't avoided in the ksmd and could be optimized
> away without decreasing flexibility of KSM, and ksmd surely runs on
> the kdump kernel too...) that is to make khugepaged exit and release
> kernel stack when enabled=never (either done by sysfs or at boot with
> transparent_hugepage=never) and all other structs associated with a
> (temporarily) useless kernel thread.

I agree to disable ksm in kdump kernel, thanks for pointing this out!
I will look into later, and probably send a patch for this too.

>
> The khugepaged_slab_init and mm_slot_hash_init() maybe could be
> deferred to when khugepaged starts, and be released when it shutdown
> but it makes it more tricky/racey. If you really want to optimize
> that, without preventing to ever enable THP again despite all .text
> was compiled in and ready to run. You will likely save more if you
> make ksmd exit when run=0 (which btw is a much more common config than
> enabled=never with THP). And slots hashes are allocated by ksm too so
> you could optimize those too if you want and allocate them only by the
> time ksmd starts.

The thing is that we can save ~10K by adding 3 lines of code as this
patch showed, where else in kernel can you save 10K by 3 lines of code?
(except some kfree() cases, of course) So, again, why not have it? ;)

>
> As long as it'd still possible to enable the feature again as it is
> possible now without noticing an altered behavior from userland, I'm
> not entirely against optimizing for saving ~8k of ram even if it
> increases complexity a bit (more kernel code will increase .text a bit
> though, hopefully not 8k more of .text ;).

Why do we _force_ the feature to be tunable even when user completely
don't want to disable it? Why not provide a way to let the user to decide
which is better for him?

When programming kernel, providing a mechanism rather than a policy is
what I always keep in mind, I don't know why you violate this rule here,
to be honest. :-/

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
