Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5D8666B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:00:29 -0400 (EDT)
Message-ID: <515E84BD.2080404@parallels.com>
Date: Fri, 5 Apr 2013 12:01:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/28] list: add a new LRU list type
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-9-git-send-email-glommer@parallels.com> <xr93ehepkcje.fsf@gthelen.mtv.corp.google.com> <20130405012048.GH12011@dastard>
In-Reply-To: <20130405012048.GH12011@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>

On 04/05/2013 05:20 AM, Dave Chinner wrote:
> On Thu, Apr 04, 2013 at 02:53:49PM -0700, Greg Thelen wrote:
>> On Fri, Mar 29 2013, Glauber Costa wrote:
>>> From: Dave Chinner <dchinner@redhat.com>
>>> +long
>>> +list_lru_walk(
>>> +	struct list_lru *lru,
>>> +	list_lru_walk_cb isolate,
>>> +	void		*cb_arg,
>>> +	long		nr_to_walk)
>>> +{
>>> +	struct list_head *item, *n;
>>> +	long removed = 0;
>>> +restart:
>>> +	spin_lock(&lru->lock);
>>> +	list_for_each_safe(item, n, &lru->list) {
>>> +		int ret;
>>> +
>>> +		if (nr_to_walk-- < 0)
>>> +			break;
>>> +
>>> +		ret = isolate(item, &lru->lock, cb_arg);
>>> +		switch (ret) {
>>> +		case 0:	/* item removed from list */
>>> +			lru->nr_items--;
>>> +			removed++;
>>> +			break;
>>> +		case 1: /* item referenced, give another pass */
>>> +			list_move_tail(item, &lru->list);
>>> +			break;
>>> +		case 2: /* item cannot be locked, skip */
>>> +			break;
>>> +		case 3: /* item not freeable, lock dropped */
>>> +			goto restart;
>>
>> These four magic return values might benefit from an enum (or #define)
>> for clarity.
> 
> Obviously, and it was stated that this needed to be done by miself
> when I last posted the patch set many months ago. I've been rather
> busy since then, and so haven't had time to do anything with it.
> 
>> Maybe the names would be LRU_OK, LRU_REMOVED, LRU_ROTATE, LRU_RETRY.
> 
> Something like that...
> 
I can handle that and fold it with credits as usual if you don't mind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
