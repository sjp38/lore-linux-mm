Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id E22F56B0007
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 05:41:43 -0500 (EST)
Message-ID: <511E10FA.2040708@parallels.com>
Date: Fri, 15 Feb 2013 14:42:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] memcg targeted shrinking
References: <1360328857-28070-1-git-send-email-glommer@parallels.com> <xr93ip5unz52.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93ip5unz52.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org

On 02/15/2013 05:28 AM, Greg Thelen wrote:
> On Fri, Feb 08 2013, Glauber Costa wrote:
> 
>> This patchset implements targeted shrinking for memcg when kmem limits are
>> present. So far, we've been accounting kernel objects but failing allocations
>> when short of memory. This is because our only option would be to call the
>> global shrinker, depleting objects from all caches and breaking isolation.
>>
>> This patchset builds upon the recent work from David Chinner
>> (http://oss.sgi.com/archives/xfs/2012-11/msg00643.html) to implement NUMA
>> aware per-node LRUs. I build heavily on its API, and its presence is implied.
>>
>> The main idea is to associate per-memcg lists with each of the LRUs. The main
>> LRU still provides a single entry point and when adding or removing an element
>> from the LRU, we use the page information to figure out which memcg it belongs
>> to and relay it to the right list.
>>
>> This patchset is still not perfect, and some uses cases still need to be
>> dealt with. But I wanted to get this out in the open sooner rather than
>> later. In particular, I have the following (noncomprehensive) todo list:
>>
>> TODO:
>> * shrink dead memcgs when global pressure kicks in.
>> * balance global reclaim among memcgs.
>> * improve testing and reliability (I am still seeing some stalls in some cases)
> 
> Do you have a git tree with these changes so I can see Dave's numa LRUs
> plus these changes?
> 
I've just uploaded the exact same thing I have sent here to:

  git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git

The branch is kmemcg-lru-shrinker. Note that there is also another
branch kmemcg-shrinker that contains some other simple patches that were
not yet taken and are more stable. I eventually have to merge the two.

I also still need to incorporate the feedback from you and Kame into
that. I will be traveling until next Wednesday, so expect changes in
there around Thursday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
