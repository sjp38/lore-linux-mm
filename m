Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 791FB6B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 23:52:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O3qBlE027539
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 24 Sep 2009 12:52:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A169445DE7E
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:52:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61D6645DE70
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:52:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F5B3E18006
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:52:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E9C21DB8045
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:52:09 +0900 (JST)
Date: Thu, 24 Sep 2009 12:50:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC 1/2] Add notifiers for various swap events
Message-Id: <20090924125000.d734a7b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ABAE340.7010403@vflare.org>
References: <1253540040-24860-1-git-send-email-ngupta@vflare.org>
	<20090924104708.4f54ce4e.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABAE340.7010403@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 08:40:56 +0530
Nitin Gupta <ngupta@vflare.org> wrote:

> On 09/24/2009 07:17 AM, KAMEZAWA Hiroyuki wrote:
> > On Mon, 21 Sep 2009 19:03:59 +0530
> > Nitin Gupta <ngupta@vflare.org> wrote:
> > 
> >> Add notifiers for following swap events:
> >>  - Swapon
> >>  - Swapoff
> >>  - When a swap slot is freed
> >>
> >> This is required for ramzswap module which implements RAM based block
> >> devices to be used as swap disks. These devices require a notification
> >> on these events to function properly (as shown in patch 2/2).
> >>
> >> Currently, I'm not sure if any of these event notifiers have any other
> >> users. However, adding ramzswap specific hooks instead of this generic
> >> approach resulted in a bad/hacky code.
> >>
> > Hmm ? if it's not necessary to make ramzswap as module, for-ramzswap-only
> > code is much easier to read..
> >
> 
> The patches posted earlier (v3 patches) inserts special hooks for swap slot
> free event only. In this version, the callback is set when we get first R/W request.
> Actually ramzswap needs callback for swapon/swapoff too but I just didn't do it.
> 
> Then Pekka posted test patch that allows setting this callback during swapon
> itself. Looking that all these patches, I realized its already too messy even
> if we just make everything ramzswap specific.
> Just FYI, Pekka's test patch:
> http://patchwork.kernel.org/patch/48472/
> 
> Then I added this generic notifier interface which, compared to earlier version,
> looks much cleaner. The code to add these notifiers is also very small.
>  
ya, yes. the patch itsels seems clean.

> > 
> > 
> >> For SWAP_EVENT_SLOT_FREE, callbacks are made under swap_lock. Currently, this
> >> is not a problem since ramzswap is the only user and the callback it registers
> >> can be safely made under this lock. However, if this event finds more users,
> >> we might have to work on reducing contention on this lock.
> >>
> >> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> >>
> > 
> > In general, notifier chain codes allowed to return NOTIFY_BAD.
> > But this patch just assumes all chains should return NOTIFY_OK or
> > just ignore return code.
> > 
> > That's not good as generic interface, I think.
> 
> 
> What action we can take here if the notifier_call_chain() returns an error (apart
> from maybe printing an error)? Perhaps we can add a warning in case of swapon/off
> events but not in case of swap slot free event which is called under swap_lock.
> 
If return code is ignored, please add commentary at least.

I wonder I may able to move memcg's swap_cgroup code for swapon/swapoff onto this
notifier. (swap_cgroup_swapon/swap_cgroup_swapoff) But it seems not.
sorry for bothering you.

Thanks,
-Kame


> 
> 
> Thanks,
> Nitin
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
