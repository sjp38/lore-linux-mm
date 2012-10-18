Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2E0C06B0062
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 05:37:55 -0400 (EDT)
Message-ID: <507FCDE3.1050408@parallels.com>
Date: Thu, 18 Oct 2012 13:37:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 13/14] protect architectures where THREAD_SIZE >= PAGE_SIZE
 against fork bombs
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-14-git-send-email-glommer@parallels.com> <20121017151245.f11c4d18.akpm@linux-foundation.org>
In-Reply-To: <20121017151245.f11c4d18.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 10/18/2012 02:12 AM, Andrew Morton wrote:
> On Tue, 16 Oct 2012 14:16:50 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> @@ -146,7 +146,7 @@ void __weak arch_release_thread_info(struct thread_info *ti)
>>  static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
>>  						  int node)
>>  {
>> -	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
>> +	struct page *page = alloc_pages_node(node, THREADINFO_GFP_ACCOUNTED,
>>  					     THREAD_SIZE_ORDER);
> 
> yay, we actually used all this code for something ;)
> 
Happy to be of use, sir!

> I don't think we really saw a comprehensive list of what else the kmem
> controller will be used for, but I believe that all other envisaged
> applications will require slab accounting, yes?
> 
> 
> So it appears that all we have at present is a
> yet-another-fork-bomb-preventer, but one which requires that the
> culprit be in a container?  That's reasonable, given your
> hosted-environment scenario.  It's unclear (to me) that we should merge
> all this code for only this feature.  Again, it would be good to have a
> clear listing of and plan for other applications of this code.
> 

I agree. This doesn't buy me much without slab accounting. But
reiterating what I've just said in another e-mail, slab accounting is
not really in plan stage, but had also been through extensive development.

As a matter of fact, it used to be only "slab accounting" in the
beginning, without this. I've split it more recently because I believe
it would allow people to do a more focused review, leading to better code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
