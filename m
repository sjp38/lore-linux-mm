Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBA66B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 15:56:29 -0500 (EST)
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091117172802.3DF4.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.0911170004380.1564@chino.kir.corp.google.com>
	 <20091117172802.3DF4.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Nov 2009 21:56:19 +0100
Message-ID: <1258491379.3918.48.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-17 at 17:33 +0900, KOSAKI Motohiro wrote:
> 
> if there is so such reason. we might need to implement another MM trick.
> but keeping this strage usage is not a option. All memory freeing activity
> (e.g. page out, task killing) need some memory. we need to protect its
> emergency memory. otherwise linux reliability decrease dramatically when
> the system face to memory stress. 

In general PF_MEMALLOC is a particularly bad idea, even for the VM when
not coupled with limiting the consumption. That is one should make an
upper-bound estimation of the memory needed for a writeout-path per
page, and reserve a small multiple thereof, and limit the number of
pages written out so as to never exceed this estimate.

If the current mempool interface isn't sufficient (not hard to imagine),
look at the swap over NFS patch-set, that includes a much more able
reservation scheme, and accounting framework.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
