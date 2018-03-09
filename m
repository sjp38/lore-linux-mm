Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA2786B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 06:10:59 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id w1so1454990vke.23
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 03:10:59 -0800 (PST)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id z3si202010uah.178.2018.03.09.03.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 03:10:58 -0800 (PST)
Subject: Re: [PATCH] mm/mempolicy: Avoid use uninitialized preferred_node
References: <CAG_fn=VW5tfzT6cHJd+jF=t3WO6XS3HqSF_TYnKdycX_M_48vw@mail.gmail.com>
 <4ebee1c2-57f6-bcb8-0e2d-1833d1ee0bb7@huawei.com>
 <CAG_fn=XP6X5rqRVBameyU-F2UOc4hpbowUBNxZENf2ZHpMSmfQ@mail.gmail.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <a4efd431-39c3-8ede-9fa1-e69924263ce0@huawei.com>
Date: Fri, 9 Mar 2018 19:10:43 +0800
MIME-Version: 1.0
In-Reply-To: <CAG_fn=XP6X5rqRVBameyU-F2UOc4hpbowUBNxZENf2ZHpMSmfQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Dmitriy Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, "mhocko@suse.com" <mhocko@suse.com>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>

Hi Alexander ,

On 2018/3/9 18:49, Alexander Potapenko wrote:
> On Fri, Mar 9, 2018 at 6:21 AM, Yisheng Xie <xieyisheng1@huawei.com> wrote:
>> Alexander reported an use of uninitialized memory in __mpol_equal(),
>> which is caused by incorrect use of preferred_node.
>>
>> When mempolicy in mode MPOL_PREFERRED with flags MPOL_F_LOCAL, it use
>> numa_node_id() instead of preferred_node, however, __mpol_equeue() use
>> preferred_node without check whether it is MPOL_F_LOCAL or not.
>>
>> Reported-by: Alexander Potapenko <glider@google.com>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Tested-by: Alexander Potapenko <glider@google.com>

Thanks,
> 
> I confirm that the patch fixes the problem. Thanks for the quick turnaround!
> Any idea which commit had introduced the bug in the first place?

IIUC, It is introduce by:
Fixes: fc36b8d3d819 (mempolicy: use MPOL_F_LOCAL to Indicate Preferred Local Policy)

Thanks
Yisheng
>> ---
>>  mm/mempolicy.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index d879f1d..641545e 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2124,6 +2124,9 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
>>         case MPOL_INTERLEAVE:
>>                 return !!nodes_equal(a->v.nodes, b->v.nodes);
>>         case MPOL_PREFERRED:
>> +               /* a's flags is the same as b's */
>> +               if (a->flags & MPOL_F_LOCAL)
>> +                       return true;
>>                 return a->v.preferred_node == b->v.preferred_node;
>>         default:
>>                 BUG();
>> --
>> 1.8.3.1
>>
> 
> 
> 
