Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 1C3BB6B00F9
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 18:53:35 -0400 (EDT)
Message-ID: <4F91E8CC.5080409@redhat.com>
Date: Fri, 20 Apr 2012 18:53:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
References: <1334356721-9009-1-git-send-email-yinghan@google.com> <20120420151143.433c514e.akpm@linux-foundation.org>
In-Reply-To: <20120420151143.433c514e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>

On 04/20/2012 06:11 PM, Andrew Morton wrote:
> On Fri, 13 Apr 2012 15:38:41 -0700
> Ying Han<yinghan@google.com>  wrote:
>
>> The mmu_shrink() is heavy by itself by iterating all kvms and holding
>> the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
>> don't need to call the shrinker if nothing to shrink.

>> @@ -3900,6 +3905,9 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
>>   	if (nr_to_scan == 0)
>>   		goto out;
>>
>> +	if (!get_kvm_total_used_mmu_pages())
>> +		return 0;
>> +

> Do we actually know that this patch helps anything?  Any measurements? Is
> kvm_total_used_mmu_pages==0 at all common?
>

On re-reading mmu.c, it looks like even with EPT or NPT,
we end up creating mmu pages for the nested page tables.

I have not had the time to look into it more, but it would
be nice to know if the patch has any effect at all.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
