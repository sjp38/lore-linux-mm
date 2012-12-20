Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 757CD6B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 05:59:45 -0500 (EST)
Message-ID: <50D2EF82.1050808@parallels.com>
Date: Thu, 20 Dec 2012 14:59:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] super: fix calculation of shrinkable objects for
 small numbers
References: <1355906418-3603-1-git-send-email-glommer@parallels.com> <1355906418-3603-2-git-send-email-glommer@parallels.com> <20121220070657.GV15182@dastard>
In-Reply-To: <20121220070657.GV15182@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On 12/20/2012 11:06 AM, Dave Chinner wrote:
> On Wed, Dec 19, 2012 at 12:40:17PM +0400, Glauber Costa wrote:
>> The sysctl knob sysctl_vfs_cache_pressure is used to determine which
>> percentage of the shrinkable objects in our cache we should actively try
>> to shrink.
>>
>> It works great in situations in which we have many objects (at least
>> more than 100), because the aproximation errors will be negligible. But
>> if this is not the case, specially when total_objects < 100, we may end
>> up concluding that we have no objects at all (total / 100 = 0,  if total
>> < 100).
>>
>> This is certainly not the biggest killer in the world, but may matter in
>> very low kernel memory situations.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Dave Chinner <david@fromorbit.com>
>> CC: "Theodore Ts'o" <tytso@mit.edu>
>> CC: Al Viro <viro@zeniv.linux.org.uk>
>> ---
>>  fs/super.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/super.c b/fs/super.c
>> index 12f1237..660552c 100644
>> --- a/fs/super.c
>> +++ b/fs/super.c
>> @@ -104,7 +104,7 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
>>  				sb->s_nr_inodes_unused + fs_objects;
>>  	}
>>  
>> -	total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
>> +	total_objects = mult_frac(total_objects, sysctl_vfs_cache_pressure, 100);
>>  	drop_super(sb);
>>  	return total_objects;
> 
> Hi Glauber,
> 
> sysctl_vfs_cache_pressure all over the place with exactly the same
> calculation. Can you fix all of them in one pass?
> 

affirmative, sir!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
