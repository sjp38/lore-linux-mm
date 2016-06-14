Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59B3C6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:15:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so152204wme.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:15:11 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id c10si8926818wjb.241.2016.06.14.10.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 10:15:10 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id k184so82933wme.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:15:10 -0700 (PDT)
Subject: Re: [RFC 03/18] memcontrol: present maximum used memory also for
 cgroup-v2
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
 <1465847065-3577-4-git-send-email-toiwoton@gmail.com>
 <20160614070130.GB5681@dhcp22.suse.cz>
 <b9d04ccd-28d2-993a-2a40-bbed7b6289d4@gmail.com>
 <20160614160410.GB14279@cmpxchg.org>
From: Topi Miettinen <toiwoton@gmail.com>
Message-ID: <db6a51eb-d1f7-691b-11a6-ef0b7c1c9462@gmail.com>
Date: Tue, 14 Jun 2016 17:15:06 +0000
MIME-Version: 1.0
In-Reply-To: <20160614160410.GB14279@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <cgroups@vger.kernel.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <linux-mm@kvack.org>

On 06/14/16 16:04, Johannes Weiner wrote:
> On Tue, Jun 14, 2016 at 03:47:20PM +0000, Topi Miettinen wrote:
>> On 06/14/16 07:01, Michal Hocko wrote:
>>> On Mon 13-06-16 22:44:10, Topi Miettinen wrote:
>>>> Present maximum used memory in cgroup memory.current_max.
>>>
>>> It would be really much more preferable to present the usecase in the
>>> patch description. It is true that this information is presented in the
>>> v1 API but the current policy is to export new knobs only when there is
>>> a reasonable usecase for it.
>>>
>>
>> This was stated in the cover letter:
>> https://lkml.org/lkml/2016/6/13/857
>>
>> "There are many basic ways to control processes, including capabilities,
>> cgroups and resource limits. However, there are far fewer ways to find out
>> useful values for the limits, except blind trial and error.
>>
>> This patch series attempts to fix that by giving at least a nice starting
>> point from the actual maximum values. I looked where each limit is checked
>> and added a call to limit bump nearby."
>>
>> "Cgroups
>> [RFC 02/18] cgroup_pids: track maximum pids
>> [RFC 03/18] memcontrol: present maximum used memory also for
>> [RFC 04/18] device_cgroup: track and present accessed devices
>>
>> For tasks and memory cgroup limits the situation is somewhat better as the
>> current tasks and memory status can be easily seen with ps(1). However, any
>> transient tasks or temporary higher memory use might slip from the view.
>> Device use may be seen with advanced MAC tools, like TOMOYO, but there is no
>> universal method. Program sources typically give no useful indication about
>> memory use or how many tasks there could be."
>>
>> I can add some of this to the commit message, is that sufficient for you?
> 
> It's useful to have a short summary of the justification in each patch
> as well. Other than that it's fine to be broader and more detailed
> about your motivation in the coverletter.
> 
> I didn't catch the coverletter, though. It makes sense to CC
> recipients of any of those patches on the full series, including the
> cover, since even though we are specialized in certain areas of the
> code, many of us are interested in the whole picture of addressing a
> problem, and not just the few bits in our area without more context.
> 

Thank you for this nice explanation. I suppose "git send-email
--cc-cmd=scripts/get_maintainer.pl" doesn't do this.

> As far as the memcg part of this series goes, one concern is that page
> cache is trimmed back only when there is pressure, so in all but very
> few cases the high watermark you are introducing will be pegged to the
> configured limit. It doesn't give a whole lot of insight.
> 

So using the high watermark would not give a very useful starting point
for the user who wished to configure the memory limit? What else could
be used instead?

> But there are consumers that are less/not compressible than cache,
> such as anonymous memory, unreclaimable slab, maybe socket buffers
> etc. Having spikes in those slip through two sampling points is an
> issue, indeed. Adding consumer-specific watermarks might be useful.
> 
> Thanks
> 

OK, but there's no limiting or tuning mechanism in place for now for
those, or is there? How could the results be used?

-Topi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
