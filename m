Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id A14686B0089
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 05:14:19 -0400 (EDT)
Message-ID: <51628A88.2090002@parallels.com>
Date: Mon, 8 Apr 2013 13:14:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 03/28] dcache: convert dentry_stat.nr_unused to per-cpu
 counters
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-4-git-send-email-glommer@parallels.com> <xr93r4ipkcl0.fsf@gthelen.mtv.corp.google.com> <20130405011506.GG12011@dastard>
In-Reply-To: <20130405011506.GG12011@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>

On 04/05/2013 05:15 AM, Dave Chinner wrote:
> On Thu, Apr 04, 2013 at 06:09:31PM -0700, Greg Thelen wrote:
>> On Fri, Mar 29 2013, Glauber Costa wrote:
>>
>>> From: Dave Chinner <dchinner@redhat.com>
>>>
>>> Before we split up the dcache_lru_lock, the unused dentry counter
>>> needs to be made independent of the global dcache_lru_lock. Convert
>>> it to per-cpu counters to do this.
>>>
>>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>>> ---
>>>  fs/dcache.c | 17 ++++++++++++++---
>>>  1 file changed, 14 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/fs/dcache.c b/fs/dcache.c
>>> index fbfae008..f1196f2 100644
>>> --- a/fs/dcache.c
>>> +++ b/fs/dcache.c
>>> @@ -118,6 +118,7 @@ struct dentry_stat_t dentry_stat = {
>>>  };
>>>  
>>>  static DEFINE_PER_CPU(unsigned int, nr_dentry);
>>> +static DEFINE_PER_CPU(unsigned int, nr_dentry_unused);
>>>  
>>>  #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
>>>  static int get_nr_dentry(void)
>>> @@ -129,10 +130,20 @@ static int get_nr_dentry(void)
>>>  	return sum < 0 ? 0 : sum;
>>>  }
>>>  
>>> +static int get_nr_dentry_unused(void)
>>> +{
>>> +	int i;
>>> +	int sum = 0;
>>> +	for_each_possible_cpu(i)
>>> +		sum += per_cpu(nr_dentry_unused, i);
>>> +	return sum < 0 ? 0 : sum;
>>> +}
>>
>> Just checking...  If cpu x is removed, then its per cpu nr_dentry_unused
>> count survives so we don't leak nr_dentry_unused.  Right?  I see code in
>> percpu_counter_sum_positive() to explicitly handle this case and I want
>> to make sure we don't need it here.
> 
> DEFINE_PER_CPU() gives a variable per possible CPU, and we sum for
> all possible CPUs. Therefore online/offline CPUs just don't matter.
> 
> The percpu_counter code uses for_each_online_cpu(), and so it has to
> be aware of hotplug operations so taht it doesn't leak counts.
> 

It is an unsigned quantity, however. Can't we go negative if it becomes
unused in one cpu, but used in another?

Ex:

nr_unused/0: 0
nr_unused/1: 0

dentry goes to the LRU at cpu 1:
nr_unused/0: 0
nr_unused/1: 1

CPU 1 goes down:
nr_unused/0: 0

dentry goes out of the LRU at cpu 0:
nr_unused/0: 1 << 32.

That would easily be fixed by using a normal signed long, and is in fact
what the percpu code does in its internal operations.

Any reason not to do it? Something I am not seeing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
