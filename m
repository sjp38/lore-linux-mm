Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CBE4C282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 04:35:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1987B20717
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 04:35:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="l6etWU3h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1987B20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3AB86B000E; Wed,  5 Jun 2019 00:35:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EAE16B0010; Wed,  5 Jun 2019 00:35:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88A8F6B0266; Wed,  5 Jun 2019 00:35:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 695806B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 00:35:15 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id d6so18970585ybj.16
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 21:35:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EiZjBZHC5Luc27kYIuZtZXOYiqvfneCugvkG3Zxzj+0=;
        b=dEJ1YX1OK/SHK5Gl63qmX00k2Lwut+0ONOe/pX9g5f0ndSbDU/tNPBKI5S6ZGtRrHN
         aLQ3bkHQhdD+mj1viURqoQlPH5hgByaUqOQC52oAhTrcLNyXNRRLZikBxcc1ROn0PcTw
         Rx2QPPZQibHwHQ3oITtTn6kuFsEzjvHZL+Zh52hEHeDYuqkpGQW4e9+zDpOjiHtP4KYE
         bhNiWzFvPEANoOF9p3RADsdNXT9Cn62kn/eStfNEVF3CnM06Z8bLL8AMOG74McpzZ86z
         v+VSOqprKmu3rzh2Aiuq2/6CwuyDBHGga1ZhwjbgqHn/NtOB78sd8zeVkbZN3ZkS/1sK
         kFqQ==
X-Gm-Message-State: APjAAAVSjSr8r5pro0b/sBKbj+ORJ6uD3wPfd6ih1nt5+U+X+oyqeEqY
	HpX205hWfPJKAZEUqFmk5zDx0rrdpqQzPveoHKh3YHn04VV4KKfcHR2i0m/ZCYiQk2+62W7+9tM
	RwNerLlN7605UfBOFpecvpGB7qi2FdhEmNAoKUThKlEuAcSio/EWsvK/HH1J5KlwRuQ==
X-Received: by 2002:a0d:d8d6:: with SMTP id a205mr19914091ywe.211.1559709315120;
        Tue, 04 Jun 2019 21:35:15 -0700 (PDT)
X-Received: by 2002:a0d:d8d6:: with SMTP id a205mr19914057ywe.211.1559709314435;
        Tue, 04 Jun 2019 21:35:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559709314; cv=none;
        d=google.com; s=arc-20160816;
        b=rh2Fp1RC/HXQaEIceMrENf7INEF+ZNK1/EbFeNtIVW9UKx5TJpHfkOUME2oYKV+Jn4
         tRWlge3kuggRKksDynhMVpBcxLimzXG9wSoiUvM+nfjg4aq1hv6pBepfGHH0kFT/6b5Y
         5of/qH52eJS+qJj66YgS8CnUzGUbLTK/xgKH4utTU/BA9Yy7X/mSmasT1AJq57FDkn/m
         O/lyk7x1UEkkJAdfAInoMK/gLfkGp8oJIoL9RMy3rf19h469wiIAK9ayWhnyYsGpB/Q1
         NMMjm3KsDNTEL50oiKSvcfQgVpLjj/ihbIcK6LAmq9kEcVL8VNAt7MkV4rNs2UloegeO
         E/sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EiZjBZHC5Luc27kYIuZtZXOYiqvfneCugvkG3Zxzj+0=;
        b=l9WROXVNr+xRsz/VTrVvBLX5eRE0DwmgevvVUn91lqEyYXzyn6ve1c75oD5ozNQJmf
         7JCOv+Vqva2EmbG5yCnEKB5luSE5ZwlKPsu8sMpgXdOBXwR/nSOsXGtL69DolnhN88TG
         Pyn1fdOaZAsqs11HOfUuI0xk1F+3WzFcjO+JDkKNKZjZ8K1hX7ZcxC/i13wIaMqzw1t/
         kQyohYOkaiDy9YS2r+Rpz/HXIBmd/ceP3nUVoy0BqxvhowpGS2xXVrL/KOm8SS1D9/WF
         84noWyc74PSNsDJfcWBt7G5A2Vs4I9rIxwO+5uUYUNyiN7/vVv0Rzr2X/h5P0N1Qr6M5
         PWQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l6etWU3h;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8sor9416829ybc.119.2019.06.04.21.35.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 21:35:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=l6etWU3h;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EiZjBZHC5Luc27kYIuZtZXOYiqvfneCugvkG3Zxzj+0=;
        b=l6etWU3hoAIzk502NCLzqzCwueHjUuAnf/eR/wuiZbG2FPIk0eHDh2w2W5nSiNQHEq
         yUf6WkAw/xmU45plNLxfP6qOhMt0ugZl9MoJ8xIDlaCWNsHoct8OGKM/PKs61uNe3pPZ
         aIscz2/I4HZncJ6NXVBtM0ugZJlklYIwDqHhbISCJNKhl0MNuXwsRXEQbntjyqDTFqd0
         Lk8t0r90YIAdrU2QKZzfq0ofEgZnHL22HS/F2/jiThl65tNXqWA69ZpWgKUW+PUUDna2
         ExMgFaz75HDTB0wHox6aUC5wAp8HAFCKs/DTCOZRynpNNf6VylThXCEwBBXdNvFIgtgZ
         QkHQ==
X-Google-Smtp-Source: APXvYqwYEsTxKXLhDDZZLM7bg5/6GEAiuuqGq8PUklt7d0KxCckL9NGG4Q/b5VxneyZkVXRh6FDzTj9EDbju++v3JZk=
X-Received: by 2002:a25:943:: with SMTP id u3mr17294262ybm.293.1559709313724;
 Tue, 04 Jun 2019 21:35:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190605024454.1393507-1-guro@fb.com> <20190605024454.1393507-2-guro@fb.com>
In-Reply-To: <20190605024454.1393507-2-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 4 Jun 2019 21:35:02 -0700
Message-ID: <CALvZod4F4FqO27Y+msXrxT9yaDLLN7njmBsRoTkmQSPE_7=FtQ@mail.gmail.com>
Subject: Re: [PATCH v6 01/10] mm: add missing smp read barrier on getting
 memcg kmem_cache pointer
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 7:45 PM Roman Gushchin <guro@fb.com> wrote:
>
> Johannes noticed that reading the memcg kmem_cache pointer in
> cache_from_memcg_idx() is performed using READ_ONCE() macro,
> which doesn't implement a SMP barrier, which is required
> by the logic.
>
> Add a proper smp_rmb() to be paired with smp_wmb() in
> memcg_create_kmem_cache().
>
> The same applies to memcg_create_kmem_cache() itself,
> which reads the same value without barriers and READ_ONCE().
>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

This seems like independent to the series. Shouldn't this be Cc'ed stable?

> ---
>  mm/slab.h        | 1 +
>  mm/slab_common.c | 3 ++-
>  2 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slab.h b/mm/slab.h
> index 739099af6cbb..1176b61bb8fc 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -260,6 +260,7 @@ cache_from_memcg_idx(struct kmem_cache *s, int idx)
>          * memcg_caches issues a write barrier to match this (see
>          * memcg_create_kmem_cache()).
>          */
> +       smp_rmb();
>         cachep = READ_ONCE(arr->entries[idx]);
>         rcu_read_unlock();
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 58251ba63e4a..8092bdfc05d5 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -652,7 +652,8 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
>          * allocation (see memcg_kmem_get_cache()), several threads can try to
>          * create the same cache, but only one of them may succeed.
>          */
> -       if (arr->entries[idx])
> +       smp_rmb();
> +       if (READ_ONCE(arr->entries[idx]))
>                 goto out_unlock;
>
>         cgroup_name(css->cgroup, memcg_name_buf, sizeof(memcg_name_buf));
> --
> 2.20.1
>

