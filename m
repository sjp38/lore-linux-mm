Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id DFB516B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 08:51:04 -0400 (EDT)
Message-ID: <51B085E5.9070103@parallels.com>
Date: Thu, 6 Jun 2013 16:51:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 04/35] dentry: move to per-sb LRU locks
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-5-git-send-email-glommer@openvz.org> <20130605160738.fe46654369044b6d94eadd1b@linux-foundation.org> <51B0424A.3090208@parallels.com>
In-Reply-To: <51B0424A.3090208@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On 06/06/2013 12:03 PM, Glauber Costa wrote:
> On 06/06/2013 03:07 AM, Andrew Morton wrote:
>> On Mon,  3 Jun 2013 23:29:33 +0400 Glauber Costa <glommer@openvz.org> wrote:
>>
>>> From: Dave Chinner <dchinner@redhat.com>
>>>
>>> With the dentry LRUs being per-sb structures, there is no real need
>>> for a global dentry_lru_lock. The locking can be made more
>>> fine-grained by moving to a per-sb LRU lock, isolating the LRU
>>> operations of different filesytsems completely from each other.
>>
>> What's the point to this patch?  Is it to enable some additional
>> development, or is it a standalone performance tweak?
>>
>> If the latter then the patch obviously makes this dentry code bloatier
>> and straight-line slower.  So we're assuming that the multiprocessor
>> contention-avoidance benefits will outweigh that cost.  Got any proof
>> of this?
>>
>>
> This is preparation for the whole point of this series, which is to
> abstract the lru manipulation into a list_lru. It is hard to do that
> when the dcache has a single lock for all manipulations, and multiple
> lists under its umbrella.
> 
> 

I have updated the Changelog, that now reads:

With the dentry LRUs being per-sb structures, there is no real need for
a global dentry_lru_lock. The locking can be made more fine-grained by
moving to a per-sb LRU lock, isolating the LRU operations of different
filesytsems completely from each other. The need for this is independent
of any performance consideration that may arise: in the interest of
abstracting the lru operations away, it is mandatory that each lru works
around its own lock instead of a global lock for all of them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
