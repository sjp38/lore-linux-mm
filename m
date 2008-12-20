Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B97586B0044
	for <linux-mm@kvack.org>; Sat, 20 Dec 2008 10:53:18 -0500 (EST)
Date: Sat, 20 Dec 2008 16:55:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-ID: <20081220155536.GD6383@random.random>
References: <491DAF8E.4080506@quantum.com> <200811191526.00036.nickpiggin@yahoo.com.au> <20081119165819.GE19209@random.random> <20081218152952.GW24856@random.random> <20081219161911.dcf15331.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081219161911.dcf15331.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 19, 2008 at 04:19:11PM +0900, KAMEZAWA Hiroyuki wrote:
> Result of cost-of-fork() on ia64.
> ==
>   size of memory  before  after
>   Anon=1M   	, 0.07ms, 0.08ms
>   Anon=10M  	, 0.17ms, 0.22ms
>   Anon=100M 	, 1.15ms, 1.64ms
>   Anon=1000M	, 11.5ms, 15.821ms
> ==
> 
> fork() cost is 135% when the process has 1G of Anon.

Not sure where the 135% number comes from. The above number shows a
performance decrease of 27% or a time increase of 37% which I hope is
inline with the overhead introduced by the TestSetPageLocked in the
fast path (which I didn't expect to be so bad), but that it's almost
trivial to eliminate with a smb_wmb in add_to_swap_cache and a smb_rmb
in fork. So we'll need to repeat this measurement after replacing the
TestSetPageLocked with smb_rmb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
