Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9092C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:12:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49FC821871
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:12:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49FC821871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D256B0003; Tue, 16 Jul 2019 20:12:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACDFA6B0005; Tue, 16 Jul 2019 20:12:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BD938E0001; Tue, 16 Jul 2019 20:12:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6110E6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 20:12:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so13342500pfv.18
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:12:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=p5UqyDYyuR/rMPWUNdnmfibXY+FneEs1hMXmIvV8vCA=;
        b=CRRs14CC4piy8T/xdVLNdHvSYa0X0Lqy/eSx2J+Tx78xIjMVGVXgBssaRqrgjFOkU3
         qN09AZBgVTyD9l0TJGoUGZzthdkHHUuOHIFKqXq8lt2NEEirO9qvYDQSFljuJ/8XTl19
         slSqFdm1+zOLlN2ryPwrItDfmpc/aMm0w1K5tDRo7VwsfUXjCh8D2fd/cy2o9JbayTAg
         ckrpwSpuBPAF3g883H8/6BiYlMhJ66skClRL7mo7Kc/tasW+f1up5xxJvxbTrxH97rEz
         nCjFK3CrPoF4QQpo6oOcSrfApckNVV6QzByCsSbHovSFRO+i06FqvIq+ZnnzpX9gPnRT
         k8Bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXxPOKxAjV6Q2VJKomAOBizZwon7+Chvw8nObpHy+e0W67cEhZX
	x1rRuU3U2AUfFZnAfq8ti5af8tXX2onhNVgNPxTzXvMYrINWoYIRVev1+p89Gm517i35BCGOTLi
	kgwwHqiSvCTs7d8Ghzk24bgCy3mBK42DiB7aoa9O5sqBttdt2QGWaFyi7dZb/csmP0w==
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr39949289plb.237.1563322372987;
        Tue, 16 Jul 2019 17:12:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbs9P/vbKvNkOaAZVv5V/6wu5a5Q90rQUscB3XiR8O1D1nb1Kxv+OEKBnSwfDFnVBa6+sN
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr39949231plb.237.1563322372101;
        Tue, 16 Jul 2019 17:12:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563322372; cv=none;
        d=google.com; s=arc-20160816;
        b=xz1l3OReHZaCmcG2rjD6daw+Ccy3eX1PKeEOpdIzQwcCPqJ+HKy64GTWe0cOg9Sl84
         z7wJP0jFOeYUO3pRQLGz2mpzx06mgEjsPiB+6KA4aH+m/El+2tloWLe7+iIN/P9zOx0S
         uzGxu87EFq0T68JAne0GVJnQeRwgN2TtHsVrxQSSal98kYKM4i58RnmjmrrggC94vTPr
         DZtm8XycbdHpljPMX1VnmSiwTvwfsU9a6pd9JQwXiXtBNk9L2K1zW9Qqo6dJadpKlpcb
         BYe5Qwq6vKjUX25l2MbJfWi0BLmKZV0zD6DcqgnoTEqibsX+V/6/eMC1gsYaagxnRfP1
         P2xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=p5UqyDYyuR/rMPWUNdnmfibXY+FneEs1hMXmIvV8vCA=;
        b=MLKjXpxF2XW66yVqDtCMqJPwrwAXDtTushVqGywIOyKegc7yNhDSV5sg5KkZ3wt1uT
         p7Wlr6tjyYLt8zP1cjq6q+F5ptBg+GW59xJt0Fn7E6RmrYXpaC+zkCXFKFMhtzBbR1Ad
         hW+SONerrBrY+zWMlO7m8cAC8X5zHHdqm3iEsgO/kJXyXsFFkJalQhvZD3nbN0mrck4A
         VYBaXl3EOqDmPx3fgjlaG/TBfAFoD1mK9xl9Gc/PMCK7GztKUOattPN5PVT7AUCpGjJp
         FxShDJbSKUhxVEwut09KWfnQT3B+Zeal9LCeC/ysNLFtSdluUFQFNJu2HkC4ntsNuSyP
         G/ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id cp10si13907975plb.301.2019.07.16.17.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 17:12:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TX5-mrd_1563322365;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX5-mrd_1563322365)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Jul 2019 08:12:49 +0800
Subject: Re: list corruption in deferred_split_scan()
To: Shakeel Butt <shakeelb@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Hugh Dickins <hughd@google.com>,
 Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Roman Gushchin <guro@fb.com>
Cc: Qian Cai <cai@lca.pw>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>
References: <1562795006.8510.19.camel@lca.pw>
 <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
 <1562879229.8510.24.camel@lca.pw>
 <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
 <1563225798.4610.5.camel@lca.pw>
 <5c853e6e-6367-d83c-bb97-97cd67320126@linux.alibaba.com>
 <8A64D551-FF5B-4068-853E-9E31AF323517@lca.pw>
 <e5aa1f5b-b955-5b8e-f502-7ac5deb141a7@linux.alibaba.com>
 <CALvZod7+ComCUROSBaj==r0VmCczs=npP4u6C9LuJWNWdfB0Pg@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <50f57bf8-a71a-c61f-74f7-31fb7bfe3253@linux.alibaba.com>
Date: Tue, 16 Jul 2019 17:12:45 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <CALvZod7+ComCUROSBaj==r0VmCczs=npP4u6C9LuJWNWdfB0Pg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/16/19 4:36 PM, Shakeel Butt wrote:
> Adding related people.
>
> The thread starts at:
> http://lkml.kernel.org/r/1562795006.8510.19.camel@lca.pw
>
> On Mon, Jul 15, 2019 at 8:01 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>
>>
>> On 7/15/19 6:36 PM, Qian Cai wrote:
>>>> On Jul 15, 2019, at 8:22 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>>>
>>>>
>>>>
>>>> On 7/15/19 2:23 PM, Qian Cai wrote:
>>>>> On Fri, 2019-07-12 at 12:12 -0700, Yang Shi wrote:
>>>>>>> Another possible lead is that without reverting the those commits below,
>>>>>>> kdump
>>>>>>> kernel would always also crash in shrink_slab_memcg() at this line,
>>>>>>>
>>>>>>> map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map, true);
>>>>>> This looks a little bit weird. It seems nodeinfo[nid] is NULL? I didn't
>>>>>> think of where nodeinfo was freed but memcg was still online. Maybe a
>>>>>> check is needed:
>>>>> Actually, "memcg" is NULL.
>>>> It sounds weird. shrink_slab() is called in mem_cgroup_iter which does pin the memcg. So, the memcg should not go away.
>>> Well, the commit “mm: shrinker: make shrinker not depend on memcg kmem” changed this line in shrink_slab_memcg(),
>>>
>>> -     if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
>>> +     if (!mem_cgroup_online(memcg))
>>>                return 0;
>>>
>>> Since the kdump kernel has the parameter “cgroup_disable=memory”, shrink_slab_memcg() will no longer be able to handle NULL memcg from mem_cgroup_iter() as,
>>>
>>> if (mem_cgroup_disabled())
>>>        return NULL;
>> Aha, yes. memcg_kmem_enabled() implicitly checks !mem_cgroup_disabled().
>> Thanks for figuring this out. I think we need add mem_cgroup_dsiabled()
>> check before calling shrink_slab_memcg() as below:
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index a0301ed..2f03c61 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -701,7 +701,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int
>> nid,
>>           unsigned long ret, freed = 0;
>>           struct shrinker *shrinker;
>>
>> -       if (!mem_cgroup_is_root(memcg))
>> +       if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
>>                   return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>>
>>           if (!down_read_trylock(&shrinker_rwsem))
>>
> We were seeing unneeded oom-kills on kernels with
> "cgroup_disabled=memory" and Yang's patch series basically expose the
> bug to crash. I think the commit aeed1d325d42 ("mm/vmscan.c:
> generalize shrink_slab() calls in shrink_node()") missed the case for
> "cgroup_disabled=memory". However I am surprised that root_mem_cgroup
> is allocated even for "cgroup_disabled=memory" and it seems like
> css_alloc() is called even before checking if the corresponding
> controller is disabled.

I'm surprised too. A quick test with drgn shows root memcg is definitely 
allocated:

 >>> prog['root_mem_cgroup']
*(struct mem_cgroup *)0xffff8902cf058000 = {
[snip]

But, isn't this a bug?

Thanks,
Yang

>
> Yang, can you please send the above change with signed-off and CC to
> stable as well?
>
> thanks,
> Shakeel

