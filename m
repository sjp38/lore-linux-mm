Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BF18C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:15:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 358FD208CA
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:15:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ah/LPaiX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 358FD208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84C5B6B0003; Tue, 25 Jun 2019 20:15:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D7838E0003; Tue, 25 Jun 2019 20:15:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6772E8E0002; Tue, 25 Jun 2019 20:15:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 407526B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:15:25 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b188so1180745ywb.10
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KKVa5Ei85vO/xl8eKxbG6qTUC2Z/5faLfHmHsNuzkTM=;
        b=euzZmp8cmAHps004RZzw2I9RCpio1XeZVvVYt2rQvtqQ56g8Gxmqo+QzeTnAa8mdHN
         8+H/fgAAys6xHBWFMerZbQRv59QHMVPBewzavQ1pvkrAWYbn1Pyfqu60kRzAW4LSr9SF
         0xd/kGesYOXpl8wpZtH7dw1v6Zz4JW2B0Z0StBgB+yn/tVl7LtJGoE71xI3FTs8NbaPy
         QXWVigriGYlpTC/j6UnYN7O/Qgf8Kv6CZpnpCy/auNSK7JIho/cov7sPqSm5gWDl64Hg
         jARQB/kfZCbbCzhTc/2i8ARf67y7/xHdNPLxNktFfA6mBDOv0t7qNsmE6SJE5kO+h+hl
         jMUg==
X-Gm-Message-State: APjAAAWjiVgDaYu0zo8ipTposs7lw5tWs/cgQF9OHORF/jxae4kSDsgK
	IQvKkUeewq+jPTuYzQLEXTI6XtLfZHk/HQpCpI8H6jYSRuiMZiMKaoPOXAv9d3KJH4zv7c7VkK+
	fNS41QC21J360Wrz3t1wcIjT/jdwkXfcyHOURRnEg/+mZShjZgdj8mm1xyfUTozCK/w==
X-Received: by 2002:a25:1f82:: with SMTP id f124mr817343ybf.228.1561508125053;
        Tue, 25 Jun 2019 17:15:25 -0700 (PDT)
X-Received: by 2002:a25:1f82:: with SMTP id f124mr817312ybf.228.1561508124406;
        Tue, 25 Jun 2019 17:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561508124; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+Tzg8j5uDrfvnWScuJiKuk5PzIMMrQGnBbBmrKV0RNcaiGUdD+YMT3Qq6Wuf/LGvD
         7tnK1CxsgC8uYOAo/36TSAOIZJ010YWrEzWPCETSZOteAibYLoQgo0KGc102a2fHApaL
         9v9R6JZYSZ3g6L5KhycHf0U6rSqbVXKnC/ZiGEEt8b+adgKE9FX+AdgUlWeFY3DFSvx2
         zXabXgQaavHRxoJOJ98ysF83j21Zo8mffZ/BBAxqOW/dIdMsENs3w5B79PRnkDPcbvtt
         2oinElG8j8sfZUTzVKoQYugk1W+z3bt7/i5eoCgX9bvqJdR728oiWpRgmmPwf6f10bv3
         Oopg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KKVa5Ei85vO/xl8eKxbG6qTUC2Z/5faLfHmHsNuzkTM=;
        b=lU/pePGobHS3Bvu4DC6EV2rcB+VAMur+XtVC+Pd6kUsKF5FgyVNWnwzH8CyGwtu1ui
         0KdYX5zCtMQgabbDclplJGwjcRCFgCPY1U599kLOOLF1QByoRyaYy3QFA0Mu1oOqDTNS
         qUqb3buaptMV2Vsu7Sn7amGlsXVBDRcAOsePOZ/fB6NrSzfiGJQVvK6MjwomwU13sU0v
         sS0hj9oLPHo+hBggvT5b6qsBzIPpc13nwkReREehOZUNjUiZVUBwa27BOkTDZLGkOehX
         qak/4SClWKIV+umVnC9zOwv0X8ill4UhAWHeWSJjrDEdkzS5yUIo9GBng9xRhVEyYTOG
         a9KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Ah/LPaiX";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k144sor8781648ywa.71.2019.06.25.17.15.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 17:15:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Ah/LPaiX";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KKVa5Ei85vO/xl8eKxbG6qTUC2Z/5faLfHmHsNuzkTM=;
        b=Ah/LPaiXFjkiiPD77qZcdlWGO13E2LGO4ZIJGolulIyLP4ucxhY+XFE2dcLhlYzbB3
         6BqGf1qlPAtAc4t51PD4a5o866Hrmru/gdSHFEzovDQZawzBoAmkSZ8fFpw548ilFx/U
         hnfAWZHGRpPl++/3NbDHb7UL2MqkpXcoHip/NaD4nWPEpNVYFxN+5K5gOJhjm4n4pJwF
         z5BEw8DVUKjWxZ31//Fk0/K3hkUP81CYNDfewsLGwCbrHqwf9U2z6ZddYpT9BiQxdPcu
         1La96rfXWbZp9VkK4Sf3sAbCvIrp9EIT93lB0PPTIR47atoSKU+g8l6XtC4AZgsbqRmz
         qSFw==
X-Google-Smtp-Source: APXvYqynzG0duVfTH8jitCp8dKbdD8azxAbifWP6sAGnrQlrTRm3+PLFaapULGqEPf0anL+TKNdFDILsHzx56cfQMVA=
X-Received: by 2002:a81:4c44:: with SMTP id z65mr1001089ywa.4.1561508123747;
 Tue, 25 Jun 2019 17:15:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190611231813.3148843-1-guro@fb.com> <20190611231813.3148843-11-guro@fb.com>
In-Reply-To: <20190611231813.3148843-11-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 25 Jun 2019 17:15:12 -0700
Message-ID: <CALvZod7AuMLQP32P=aRJqwLMeGVUx3G86ANoM_f1Eii9f6EqbQ@mail.gmail.com>
Subject: Re: [PATCH v7 10/10] mm: reparent memcg kmem_caches on cgroup removal
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:18 PM Roman Gushchin <guro@fb.com> wrote:
>
> Let's reparent non-root kmem_caches on memcg offlining. This allows us
> to release the memory cgroup without waiting for the last outstanding
> kernel object (e.g. dentry used by another application).
>
> Since the parent cgroup is already charged, everything we need to do
> is to splice the list of kmem_caches to the parent's kmem_caches list,
> swap the memcg pointer, drop the css refcounter for each kmem_cache
> and adjust the parent's css refcounter.
>
> Please, note that kmem_cache->memcg_params.memcg isn't a stable
> pointer anymore. It's safe to read it under rcu_read_lock(),
> cgroup_mutex held, or any other way that protects the memory cgroup
> from being released.
>
> We can race with the slab allocation and deallocation paths. It's not
> a big problem: parent's charge and slab global stats are always
> correct, and we don't care anymore about the child usage and global
> stats. The child cgroup is already offline, so we don't use or show it
> anywhere.
>
> Local slab stats (NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE)
> aren't used anywhere except count_shadow_nodes(). But even there it
> won't break anything: after reparenting "nodes" will be 0 on child
> level (because we're already reparenting shrinker lists), and on
> parent level page stats always were 0, and this patch won't change
> anything.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

The reparenting of top level memcg and "return true" is fixed in the
later patch.

Reviewed-by: Shakeel Butt <shakeelb@google.com>

