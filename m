Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAL5lHZI005776
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:47:17 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAL5mb0D072816
	for <linux-mm@kvack.org>; Sun, 20 Nov 2005 22:48:37 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAL5lHYp019906
	for <linux-mm@kvack.org>; Sun, 20 Nov 2005 22:47:17 -0700
Message-ID: <43815F64.4070502@us.ibm.com>
Date: Sun, 20 Nov 2005 21:47:16 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
References: <437E2C69.4000708@us.ibm.com> <20051118195657.GI7991@shell0.pdx.osdl.net>
In-Reply-To: <20051118195657.GI7991@shell0.pdx.osdl.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@osdl.org>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Chris Wright wrote:
> * Matthew Dobson (colpatch@us.ibm.com) wrote:
> 
>>/proc/sys/vm/critical_pages: write the number of pages you want to reserve
>>for the critical pool into this file
> 
> 
> How do you size this pool?

Trial and error.  If you want networking to survive with no memory other
than the critical pool for 2 minutes, for example, you pick a random value,
block all other allocations (I have a test patch to do this), and send a
boatload of packets at the box.  If it OOMs, you need a bigger pool.
Lather, rinse, repeat.


> Allocations are interrupt driven, so how to you
> ensure you're allocating for the cluster network traffic you care about?

On the receive side, you can't. :(  You *have* to allocate an skbuff for
the packet, and only a couple levels up the networking 7-layer burrito can
you tell if you can toss the packet as non-critical or keep it.  On the
send side, you can create a simple socket flag that tags all that socket's
SEND requests as critical.


>>/proc/sys/vm/in_emergency: write a non-zero value to tell the kernel that
>>the system is in an emergency state and authorize the kernel to dip into
>>the critical pool to satisfy critical allocations.
> 
> 
> Seems odd to me.  Why make this another knob?  How did you run to set this
> flag if you're in emergency and kswapd is going nuts?

We did this because we didn't want __GFP_CRITICAL allocations  dipping into
the pool in the case of a transient low mem situation.  In those cases we
want to force the task to do writeback to get a page (as usual), so that
the critical pool will be full when the system REALLY goes critical.  We
also open the in_emergency file when the app starts so that we can just
write to it and don't need to try to open it when kswapd is going nuts.

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
