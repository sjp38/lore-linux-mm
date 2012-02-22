Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 079736B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:02:07 -0500 (EST)
Message-ID: <4F44F4E0.7060003@parallels.com>
Date: Wed, 22 Feb 2012 18:00:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] shrink support for memcg kmem controller
References: <1329824079-14449-1-git-send-email-glommer@parallels.com> <1329824079-14449-6-git-send-email-glommer@parallels.com> <CABCjUKCcGWsSqUnN-9g77bTLQdZ0HF3ryLz+2PyLK1VucqPjSg@mail.gmail.com>
In-Reply-To: <CABCjUKCcGWsSqUnN-9g77bTLQdZ0HF3ryLz+2PyLK1VucqPjSg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Paul
 Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Pekka
 Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On 02/22/2012 03:35 AM, Suleiman Souhlal wrote:
> On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa<glommer@parallels.com>  wrote:
>
>> @@ -5055,8 +5117,21 @@ int memcg_kmem_newpage(struct mem_cgroup *memcg, struct page *page, unsigned lon
>>   {
>>         unsigned long size = pages<<  PAGE_SHIFT;
>>         struct res_counter *fail;
>> +       int ret;
>> +       bool do_softlimit;
>> +
>> +       ret = res_counter_charge(memcg_kmem(memcg), size,&fail);
>> +       if (unlikely(mem_cgroup_event_ratelimit(memcg,
>> +                                               MEM_CGROUP_TARGET_THRESH))) {
>> +
>> +               do_softlimit = mem_cgroup_event_ratelimit(memcg,
>> +                                               MEM_CGROUP_TARGET_SOFTLIMIT);
>> +               mem_cgroup_threshold(memcg);
>> +               if (unlikely(do_softlimit))
>> +                       mem_cgroup_update_tree(memcg, page);
>> +       }
>>
>> -       return res_counter_charge(memcg_kmem(memcg), size,&fail);
>> +       return ret;
>>   }
>
> It seems like this might cause a lot of kernel memory allocations to
> fail whenever we are at the limit, even if we have a lot of
> reclaimable memory, when we don't have independent accounting.
>
> Would it be better to use __mem_cgroup_try_charge() here, when we
> don't have independent accounting, in order to deal with this
> situation?
>

Yes, it would.
I'll work on that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
