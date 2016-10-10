Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A474C6B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 02:44:35 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x79so32426824lff.2
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 23:44:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wt3si16863094wjb.9.2016.10.09.23.44.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 09 Oct 2016 23:44:34 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
References: <20161004081215.5563-1-mhocko@kernel.org>
 <e7dc1e23-10fe-99de-e9c8-581857e3ab9d@suse.cz>
 <20161007065019.GA18439@dhcp22.suse.cz>
 <b32db10d-3a89-b60e-ac2c-238484610d8c@suse.cz>
 <20161007092107.GJ18439@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <84149b25-95f3-2ddc-8e67-c3b2114922cd@suse.cz>
Date: Mon, 10 Oct 2016 08:44:33 +0200
MIME-Version: 1.0
In-Reply-To: <20161007092107.GJ18439@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/07/2016 11:21 AM, Michal Hocko wrote:
> On Fri 07-10-16 10:15:07, Vlastimil Babka wrote:
>> On 10/07/2016 08:50 AM, Michal Hocko wrote:
>>> On Fri 07-10-16 07:27:37, Vlastimil Babka wrote:
> [...]
>>>> But make sure you don't break kcompactd and manual compaction from /proc, as
>>>> they don't currently set cc->gfp_mask. Looks like until now it was only used
>>>> to determine direct compactor's migratetype which is irrelevant in those
>>>> contexts.
>>>
>>> OK, I see. This is really subtle. One way to go would be to provide a
>>> fake gfp_mask for them. How does the following look to you?
>>
>> Looks OK. I'll have to think about the kcompactd case, as gfp mask implying
>> unmovable migratetype might restrict it without good reason. But that would
>> be separate patch anyway, yours doesn't change that (empty gfp_mask also
>> means unmovable migratetype) and that's good.
>
> OK, I see. A follow up patch would be really trivial AFAICS. Just add
> __GFP_MOVABLE to the mask. But I am not familiar with all these details
> enough to propose a patch with full description.

Hm, actually the migratetype only matters for async compaction, and 
kcompactd uses sync_light, so __GFP_MOVABLE will have no effect right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
