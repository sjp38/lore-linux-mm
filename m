Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 000806B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 04:27:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k12so8675492lfb.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:27:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gv3si23330475wjb.110.2016.09.20.01.27.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 01:27:32 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: warn about empty nodemask
References: <1473044391.4250.19.camel@TP420>
 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
 <B1E0D42A-2F9D-4511-927B-962BC2FD13B3@linux.vnet.ibm.com>
 <3a661375-95d9-d1ff-c799-a0c5d9cec5e3@suse.cz>
 <1473208886.12692.2.camel@TP420>
 <20160908162621.51ff52413559a7a6bb5a7df5@linux-foundation.org>
 <D1029A5D-C180-440C-8B14-A6C9E17CDB06@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dbdc5abe-3dcd-2b93-32be-0d6da69458fd@suse.cz>
Date: Tue, 20 Sep 2016 10:27:27 +0200
MIME-Version: 1.0
In-Reply-To: <D1029A5D-C180-440C-8B14-A6C9E17CDB06@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, John Allen <jallen@linux.vnet.ibm.com>, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 09/09/2016 06:03 AM, Li Zhong wrote:
>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index a2214c6..d624ff3 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -3448,6 +3448,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>> 	if (page)
>>> 		goto got_pg;
>>>
>>> +	if (ac->nodemask && nodes_empty(*ac->nodemask)) {
>>> +		pr_warn("nodemask is empty\n");
>>> +		gfp_mask &= ~__GFP_NOWARN;
>>> +		goto nopage;
>>> +	}
>>> +
>>
>> Wouldn't it be better to do
>>
>> 	if (WARN_ON(ac->nodemask && nodes_empty(*ac->nodemask)) {
>> 		...
>>
>> so we can identify the misbehaving call site?
>
> I think with __GFP_NOWARN cleared, we could know the call site from warn_alloc_failed().
> And the message a??nodemask is emptya?? makes the error obvious without going to the source.

Yes, that was my suggestion. It uses the generic warn_alloc_failed() this way. 
With a WARN_ON we would either have to "return NULL" (and get only the WARN_ON 
without the extra warn_alloc_failed() stuff) or "goto nopage" and thus get two 
backtraces. But this should be really rare occurence, so I don't have a 
particularly strong preference.

Anyway, since I suggested it in the first place:
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Thanks, Zhong
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
