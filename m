Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AC2CF6B0062
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 16:04:56 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0CBE382C3F9
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 16:11:39 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8FZ-MA951f5R for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 16:11:38 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 15CB382C415
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 16:11:24 -0500 (EST)
Date: Thu, 5 Nov 2009 16:03:39 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter
 instead
In-Reply-To: <87r5sc7kst.fsf@basil.nowhere.org>
Message-ID: <alpine.DEB.1.10.0911051558220.7668@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> <87r5sc7kst.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009, Andi Kleen wrote:

> I'm not sure making all writers more expensive is really a good idea.

The scaling problems that I have seen (like simple concurrent page faults)
are due to lock contention on mmap_sem and due to counter updates in
mm_struct.

> For example it will definitely impact the AIM7 multi brk() issue
> or the mysql allocation case, which are all writer intensive. I assume
> doing a lot of mmaps/brks in parallel is not that uncommon.

No its not that common. Page faults are much more common. The AIM7 seems
to be an artificial case? What does mysql do for allocation? If its brk()
related then simply going to larger increases may fix the issue??

> My thinking was more that we simply need per VMA locking or
> some other per larger address range locking. Unfortunately that
> needs changes in a lot of users that mess with the VMA lists
> (perhaps really needs some better abstractions for VMA list management
> first)

We have range locking through the distribution of the ptl for systems with
more than 4 processors. One can use that today to lock ranges of the
address space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
