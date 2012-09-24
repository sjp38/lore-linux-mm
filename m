Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 06C8A6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:12:57 -0400 (EDT)
Message-ID: <50602343.6040806@parallels.com>
Date: Mon, 24 Sep 2012 13:09:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/16] memcg: skip memcg kmem allocations in specified
 code regions
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-8-git-send-email-glommer@parallels.com> <20120921195929.GL7264@google.com>
In-Reply-To: <20120921195929.GL7264@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 09/21/2012 11:59 PM, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 18, 2012 at 06:12:01PM +0400, Glauber Costa wrote:
>> +static void memcg_stop_kmem_account(void)
>> +{
>> +	if (!current->mm)
>> +		return;
>> +
>> +	current->memcg_kmem_skip_account++;
>> +}
>> +
>> +static void memcg_resume_kmem_account(void)
>> +{
>> +	if (!current->mm)
>> +		return;
>> +
>> +	current->memcg_kmem_skip_account--;
>> +}
> 
> I can't say I'm a big fan of this approach.  If there are enough
> users, maybe but can't we just annotate the affected allocations
> explicitly?  Is this gonna have many more users?
> 

What exactly do you mean by annotating the affected allocations?

There are currently two users of this. In both places, we are interested
in disallowing recursion, because cache creation will trigger new cache
allocations that will bring us back here.

We can't rely on unsetting the GFP flag we're using for this, because
that affects only the page allocation, not the metadata allocation for
the cache.


> Also, in general, can we please add some comments?  I know memcg code
> is dearth of comments but let's please not keep it that way.
> 
All right here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
