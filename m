Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8C758E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 17:03:25 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so15611938edm.18
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 14:03:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25-v6sor8357208eja.49.2018.12.24.14.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 14:03:24 -0800 (PST)
Date: Mon, 24 Dec 2018 22:03:22 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked node
 in get_any_partial()
Message-ID: <20181224220322.5z3oyqzrvptttamp@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com>
 <20181120033119.30013-1-richard.weiyang@gmail.com>
 <20181220144107.9376344c2be687615ea9aa69@linux-foundation.org>
 <01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wei Yang <richard.weiyang@gmail.com>, penberg@kernel.org, mhocko@kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Fri, Dec 21, 2018 at 01:37:38AM +0000, Christopher Lameter wrote:
>On Thu, 20 Dec 2018, Andrew Morton wrote:
>
>>   The result of (get_partial_count / get_partial_try_count):
>>
>>    +----------+----------------+------------+-------------+
>>    |          |       Base     |    Patched |  Improvement|
>>    +----------+----------------+------------+-------------+
>>    |One Node  |       1:3      |    1:0     |      - 100% |
>
>If you have one node then you already searched all your slabs. So we could
>completely skip the get_any_partial() functionality in the non NUMA case
>(if nr_node_ids == 1)
>
>
>>    +----------+----------------+------------+-------------+
>>    |Four Nodes|       1:5.8    |    1:2.5   |      -  56% |
>>    +----------+----------------+------------+-------------+
>
>Hmm.... Ok but that is the extreme slowpath.
>
>>    Each version/system configuration combination has four round kernel
>>    build tests. Take the average result of real to compare.
>>
>>    +----------+----------------+------------+-------------+
>>    |          |       Base     |   Patched  |  Improvement|
>>    +----------+----------------+------------+-------------+
>>    |One Node  |      4m41s     |   4m32s    |     - 4.47% |
>>    +----------+----------------+------------+-------------+
>>    |Four Nodes|      4m45s     |   4m39s    |     - 2.92% |
>>    +----------+----------------+------------+-------------+
>
>3% on the four node case? That means that the slowpath is taken
>frequently. Wonder why?
>
>Can we also see the variability? Since this is a NUMA system there is
>bound to be some indeterminism in those numbers.

Hmm... I rebuilt the kernel and try the experiment again, but found I
can't reproduce this statistics. The data show it is worse than base
line and shakes heavily...

Base                    Patched 
                        
real    5m49.652s       real    8m9.515s
user    19m0.581s       user    17m30.296s
sys     2m31.906s       sys     2m21.445s
                        
real    5m47.145s       real    6m47.437s
user    19m17.445s      user    18m33.461s
sys     2m41.931s       sys     2m43.249s
                        
real    7m2.043s        real    5m38.539s
user    18m11.723s      user    19m40.552s
sys     2m46.443s       sys     2m43.771s
                        
real    5m31.797s       real    12m59.936s
user    19m13.984s      user    15m47.602s
sys     2m34.727s       sys     2m20.385s



















-- 
Wei Yang
Help you, Help me
