Message-ID: <447CDB99.9080805@yahoo.com.au>
Date: Wed, 31 May 2006 09:56:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH (try #4)] mm: avoid unnecessary OOM kills
References: <200605302235.k4UMZ4ok005150@calaveras.llnl.gov>
In-Reply-To: <200605302235.k4UMZ4ok005150@calaveras.llnl.gov>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, pj@sgi.com, ak@suse.de, linux-mm@kvack.org, garlick@llnl.gov, mgrondona@llnl.gov
List-ID: <linux-mm.kvack.org>

Dave Peterson wrote:
> Below is a 2.6.17-rc4-mm3 patch that fixes a problem where the OOM killer was
> unnecessarily killing system daemons in addition to memory-hogging user
> processes.  The patch fixes things so that the following assertion is
> satisfied:
> 
>     If a failed attempt to allocate memory triggers the OOM killer, then the
>     failed attempt must have occurred _after_ any process previously shot by
>     the OOM killer has cleaned out its mm_struct.
> 
> Thus we avoid situations where concurrent invocations of the OOM killer cause
> more processes to be shot than necessary to resolve the OOM condition.
> 
> Signed-Off-By: David S. Peterson <dsp@llnl.gov>

OK this is looking nice. And I was probably premature in thinking a
single simple call out to the oom code could replace your oom_alloc...
however it _still_ does a little bit too much OOM stuff for my liking.

Can you instead use two calls? oom_kill_prepare() and oom_kill_finish(),
between which you could try the final alloc? (also, declare functions in
.h files rather than .c files).

Lastly: currently, the final alloc only tries to allocate from the high
watermark because it is all racy anyway. If you've eliminated the races,
you might want to start using the low watermark for this.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
