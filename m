Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 63F0D6B0134
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 05:26:25 -0400 (EDT)
Message-ID: <4FE97F9C.5030907@parallels.com>
Date: Tue, 26 Jun 2012 13:23:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] memcg: Reclaim when more than one page needed.
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-3-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252106430.26640@chino.kir.corp.google.com> <4FE960D6.4040409@parallels.com> <alpine.DEB.2.00.1206260146010.16020@chino.kir.corp.google.com> <4FE97C20.8010500@parallels.com> <alpine.DEB.2.00.1206260214310.16020@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206260214310.16020@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic
 Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal
 Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph
 Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Suleiman Souhlal <suleiman@google.com>

On 06/26/2012 01:17 PM, David Rientjes wrote:
> On Tue, 26 Jun 2012, Glauber Costa wrote:
>
>>> Nope, have you checked the output of /sys/kernel/slab/.../order when
>>> running slub?  On my workstation 127 out of 316 caches have order-2 or
>>> higher by default.
>>>
>>
>> Well, this is still on the side of my argument, since this is still a majority
>> of them being low ordered.
>
> Ok, so what happens if I pass slub_min_order=2 on the command line?  We
> never retry?

Well, indeed. The function has many other RETRY points, but I believe 
we'd reach none of them without triggering oom first.

>> The code here does not necessarily have to retry -
>> if I understand it correctly - we just retry for very small allocations
>> because that is where our likelihood of succeeding is.
>>
>
> Well, the comment for NR_PAGES_TO_RETRY says
>
> 	/*
> 	 * We need a number that is small enough to be likely to have been
> 	 * reclaimed even under pressure, but not too big to trigger unnecessary
> 	 * retries
> 	 */
>
> and mmzone.h says
>
> 	/*
> 	 * PAGE_ALLOC_COSTLY_ORDER is the order at which allocations are deemed
> 	 * costly to service.  That is between allocation orders which should
> 	 * coalesce naturally under reasonable reclaim pressure and those which
> 	 * will not.
> 	 */
> 	#define PAGE_ALLOC_COSTLY_ORDER 3
>
> so I'm trying to reconcile which one is correct.
>

I am not myself against reverting back to costly order. The check we 
have here, of course, is stricter than costly order, so there is nothing 
to reconcile. Now if we really need a stricter check or not, is the 
subject of discussion.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
