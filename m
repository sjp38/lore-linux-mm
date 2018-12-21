Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3FE8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 20:37:40 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 41so3942321qto.17
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 17:37:40 -0800 (PST)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id f10si2166720qvm.149.2018.12.20.17.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 17:37:39 -0800 (PST)
Date: Fri, 21 Dec 2018 01:37:38 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slub: improve performance by skipping checked node
 in get_any_partial()
In-Reply-To: <20181220144107.9376344c2be687615ea9aa69@linux-foundation.org>
Message-ID: <01000167ce692d0d-ef68fdc8-4c30-40a4-8ca5-afbc3773c075-000000@email.amazonses.com>
References: <20181108011204.9491-1-richard.weiyang@gmail.com> <20181120033119.30013-1-richard.weiyang@gmail.com> <20181220144107.9376344c2be687615ea9aa69@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, penberg@kernel.org, mhocko@kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Thu, 20 Dec 2018, Andrew Morton wrote:

>   The result of (get_partial_count / get_partial_try_count):
>
>    +----------+----------------+------------+-------------+
>    |          |       Base     |    Patched |  Improvement|
>    +----------+----------------+------------+-------------+
>    |One Node  |       1:3      |    1:0     |      - 100% |

If you have one node then you already searched all your slabs. So we could
completely skip the get_any_partial() functionality in the non NUMA case
(if nr_node_ids == 1)


>    +----------+----------------+------------+-------------+
>    |Four Nodes|       1:5.8    |    1:2.5   |      -  56% |
>    +----------+----------------+------------+-------------+

Hmm.... Ok but that is the extreme slowpath.

>    Each version/system configuration combination has four round kernel
>    build tests. Take the average result of real to compare.
>
>    +----------+----------------+------------+-------------+
>    |          |       Base     |   Patched  |  Improvement|
>    +----------+----------------+------------+-------------+
>    |One Node  |      4m41s     |   4m32s    |     - 4.47% |
>    +----------+----------------+------------+-------------+
>    |Four Nodes|      4m45s     |   4m39s    |     - 2.92% |
>    +----------+----------------+------------+-------------+

3% on the four node case? That means that the slowpath is taken
frequently. Wonder why?

Can we also see the variability? Since this is a NUMA system there is
bound to be some indeterminism in those numbers.
