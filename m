Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 1CD506B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 20:22:07 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2078824dak.14
        for <linux-mm@kvack.org>; Sat, 15 Dec 2012 17:22:06 -0800 (PST)
Message-ID: <50CD2232.8020909@gmail.com>
Date: Sun, 16 Dec 2012 09:21:54 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 1/8] mm: memcg: only evict file pages when we have plenty
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-2-git-send-email-hannes@cmpxchg.org> <50C8FCE0.1060408@redhat.com> <20121212222844.GA10257@cmpxchg.org> <20121213145514.GD21644@dhcp22.suse.cz>
In-Reply-To: <20121213145514.GD21644@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/13/2012 10:55 PM, Michal Hocko wrote:
> On Wed 12-12-12 17:28:44, Johannes Weiner wrote:
>> On Wed, Dec 12, 2012 at 04:53:36PM -0500, Rik van Riel wrote:
>>> On 12/12/2012 04:43 PM, Johannes Weiner wrote:
>>>> dc0422c "mm: vmscan: only evict file pages when we have plenty" makes
>>>> a point of not going for anonymous memory while there is still enough
>>>> inactive cache around.
>>>>
>>>> The check was added only for global reclaim, but it is just as useful
>>>> for memory cgroup reclaim.
>>>>
>>>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>>>> ---
>>>>   mm/vmscan.c | 19 ++++++++++---------
>>>>   1 file changed, 10 insertions(+), 9 deletions(-)
>>>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index 157bb11..3874dcb 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -1671,6 +1671,16 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>>>>   		denominator = 1;
>>>>   		goto out;
>>>>   	}
>>>> +	/*
>>>> +	 * There is enough inactive page cache, do not reclaim
>>>> +	 * anything from the anonymous working set right now.
>>>> +	 */
>>>> +	if (!inactive_file_is_low(lruvec)) {
>>>> +		fraction[0] = 0;
>>>> +		fraction[1] = 1;
>>>> +		denominator = 1;
>>>> +		goto out;
>>>> +	}
>>>>
>>>>   	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
>>>>   		get_lru_size(lruvec, LRU_INACTIVE_ANON);
>>>> @@ -1688,15 +1698,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>>>>   			fraction[1] = 0;
>>>>   			denominator = 1;
>>>>   			goto out;
>>>> -		} else if (!inactive_file_is_low_global(zone)) {
>>>> -			/*
>>>> -			 * There is enough inactive page cache, do not
>>>> -			 * reclaim anything from the working set right now.
>>>> -			 */
>>>> -			fraction[0] = 0;
>>>> -			fraction[1] = 1;
>>>> -			denominator = 1;
>>>> -			goto out;
>>>>   		}
>>>>   	}
>>>>
>>>>
>>> I believe the if() block should be moved to AFTER
>>> the check where we make sure we actually have enough
>>> file pages.
>> You are absolutely right, this makes more sense.  Although I'd figure
>> the impact would be small because if there actually is that little
>> file cache, it won't be there for long with force-file scanning... :-)
> Yes, I think that the result would be worse (more swapping) so the
> change can only help.
>
>> I moved the condition, but it throws conflicts in the rest of the
>> series.  Will re-run tests, wait for Michal and Mel, then resend.
> Yes the patch makes sense for memcg as well. I guess you have tested
> this primarily with memcg. Do you have any numbers? Would be nice to put
> them into the changelog if you have (it should help to reduce swapping
> with heavy streaming IO load).
>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Hi Michal,

I still can't understand why "The goto out means that it should be fine 
either way.", could you explain to me, sorry for my stupid. :-)


Regards,
Simon



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
