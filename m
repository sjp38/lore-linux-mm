Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0843D6B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 01:17:57 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAI6Ht4Q005871
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Nov 2009 15:17:56 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 838B445DE3E
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:17:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F31B45DE52
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:17:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 332D71DB803C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:17:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D2EDC1DB803F
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:17:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] dm: use __GFP_HIGH instead PF_MEMALLOC
In-Reply-To: <20091117131527.GB6644@agk-dp.fab.redhat.com>
References: <20091117161616.3DD7.A69D9226@jp.fujitsu.com> <20091117131527.GB6644@agk-dp.fab.redhat.com>
Message-Id: <20091118145621.3E1A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 18 Nov 2009 15:17:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, dm-devel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

Thank you for give me comment.

> On Tue, Nov 17, 2009 at 04:17:07PM +0900, KOSAKI Motohiro wrote:
> > Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> > memory, anyone must not prevent it. Otherwise the system cause
> > mysterious hang-up and/or OOM Killer invokation.
>  
> This code is also on the critical path, for example, if you are swapping
> onto a dm device.  (There are ways we could reduce its use further as
> not every dm ioctl needs to be on the critical path and the buffer size
> could be limited for the ioctls that do.)

May I ask one additional question?
Original code is here.

	-------------------------------------------------------
        /*
         * Trying to avoid low memory issues when a device is
         * suspended.
         */
        current->flags |= PF_MEMALLOC;

        /*
         * Copy the parameters into kernel space.
         */
        r = copy_params(user, &param);

        current->flags &= ~PF_MEMALLOC;
	-------------------------------------------------------

but PF_MEMALLOC doesn't gurantee allocation successfull. In your case,
mempoll seems better to me. copy_params seems enough small function 
and we can rewrite it. Why didn't you use mempool?

Am I missing something?


> But what situations have been causing you trouble?  The OOM killer must
> generally avoid killing userspace processes that suspend & resume dm
> devices, and there are tight restrictions on what those processes
> can do safely between suspending and resuming.

No. This is theorical issue. but I really want to avoid stress weakness
kernel.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
