Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DD63C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:11:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0740021726
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:11:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tbj82VcO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0740021726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B65DA6B027A; Tue, 28 May 2019 13:11:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B157E6B027C; Tue, 28 May 2019 13:11:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2B506B027E; Tue, 28 May 2019 13:11:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 408C06B027A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:11:31 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id n14so3905112ljj.19
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:11:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=A8QVP2Qf5aJcHIy8l49WfRPomDE8uUrBG/3Am/yYNlU=;
        b=TbxSUiEuJL5LkOvrzgUqDDi+Bf0Nf0+8L+tVen9CJAXVb1VgV58CUJ6ulHOKxASEaZ
         /hbQjWioZvv/ZS55ILaey3SqIjdDb3l128t6nYMQbvprMe6t4w3hzOAO1Kgu9LgQaEs6
         A77x3oeonDmtgOfZS8XlgDupSNT1W3iCeElXbjPmhDGI3FmoITatQ9cwl0/BWXLjY5X5
         XGvrNXEcN5WODcq6ezgwgi2VKcvQfd791SVSPCU7vwWzyAI1oIGneNCV/hM0fivcBjCQ
         JfXMRWbAsmoPVIcRcU+8GGZLNxzfW/HtRGe+Bw3R/rJ4aFEff3DDMB26AF2R5farJg9l
         Perg==
X-Gm-Message-State: APjAAAXnrYhRKblak0NiZ/sFkDgLTOm61v2sw5tt6qndzkLA5mXSqlXh
	lDxaJWA00KSUyBBFOo0bE3DMaiCqPPxWEsUvmd8fcjjd7IogxTgjs9om2t9a7HqWF77YWlVcf3S
	UQk1BGpHhfMRQJikoSzeeSiHnsoQQSd89gS2StrAgHJ+7ezK8jrIo71S6WyugcAl+WA==
X-Received: by 2002:ac2:44b1:: with SMTP id c17mr11174125lfm.87.1559063490455;
        Tue, 28 May 2019 10:11:30 -0700 (PDT)
X-Received: by 2002:ac2:44b1:: with SMTP id c17mr11174083lfm.87.1559063489641;
        Tue, 28 May 2019 10:11:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559063489; cv=none;
        d=google.com; s=arc-20160816;
        b=a1styTx+Un6gQcoV+sdy1VLS4jD7FN8T5G5uvXwfOeudWmGT3x+72DZg1e+iWQCvsD
         yZLO56fjwT9OQq+5IRT7fAkNf1bPEExSEiT+qzLeOrlt+zLzc/f+jWEDOempFpvWQM9Q
         9pebTAYab8UlIW4MHbNgbbsAjtw3uDx4ux1c3RAoeivBxn1i5OoKIOk6ctXGVOBDPkIw
         UQNf+RHW4swzGH1jN9idRCqJrWmRA/wo4Tv7IomuatdOF6SL7qguTS1HmXs7FfSedOId
         WO23td0oC4tJgdf2DwEJBtlsmVSFq1zlS3DvfnBWKf34zsXLkz7peuinT2dJSHvHYRAW
         b99w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=A8QVP2Qf5aJcHIy8l49WfRPomDE8uUrBG/3Am/yYNlU=;
        b=k5JrZ4/p37Qu+HcrZWoF52pMaq7Rb0tk/FwHQo+dEpii3Lo7fE++M6iYhfnqiWLB7V
         QSMa8eJ1hC4SddA+d8yL4sZhjBn+819svWhRWUtB89DbN3ymsRcVHoHj+VcvrldkcRNa
         A+KOq1cUS0sNbju4egiuRE+gAgePwU2XNRhp+rfgz0edX4hhdL+6mXpVZZB93z2jSpvw
         YvLH1lCqNkegddyR3IaNNB0u/OrQVTT577hGeQwKfK4eNBRZWVFm4KolJBGQL8dTEKDa
         GxXp0/gzHDgHNNwPDE65lChvcDV4SPKIiYEpc+66whx2MLJgLBIDwFy8NK1ZcxatLYJ4
         NzTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tbj82VcO;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r25sor1339262lfn.60.2019.05.28.10.11.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 10:11:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tbj82VcO;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=A8QVP2Qf5aJcHIy8l49WfRPomDE8uUrBG/3Am/yYNlU=;
        b=tbj82VcOGB/BLqdwN+zId/aL1F3LbvsduOAs5GjftF3C0NFgGGQfU7vrCi+8ZFR4Ew
         uMeDuC9cIWItsZjEU/EYdPtcQbKmV0dwqkHg9AKjbOptmKOd7+DPQ5dAVm05PXKt+oqr
         Td+xYmJbU2LeazwHzmVCPZVcSIPUATTVRVMsqa/4LHzrIbZLk9+XKgatIB2qZQOx+2ZA
         HWq/fedWq82lYNQt9lABwgmMYVhppMEEmA50HzdtSJIgMvQoAuTqzJ3bJoQ5o3mjftyT
         3JTeLVmb57ufyHL1txvLiGXT8sTJqMyPMloJLNcl+S/m1XAOixYz0YB+OWBWw35SNfR1
         S1Yw==
X-Google-Smtp-Source: APXvYqwQOyDJDkoWZFLu1XnDsguS/WvRfLzgNCnt9179uP3/qtkWME3gOICVuCXUEZgQ3/k83zfTpg==
X-Received: by 2002:a05:6512:6c:: with SMTP id i12mr45456509lfo.130.1559063489378;
        Tue, 28 May 2019 10:11:29 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id h22sm3057578ljk.86.2019.05.28.10.11.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 10:11:28 -0700 (PDT)
Date: Tue, 28 May 2019 20:11:26 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 2/7] mm: generalize postponed non-root kmem_cache
 deactivation
Message-ID: <20190528171126.oaneakkydwyzied6@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-3-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:07:30PM -0700, Roman Gushchin wrote:
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 6e00bdf8618d..4e5b4292a763 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -866,11 +859,12 @@ static void flush_memcg_workqueue(struct kmem_cache *s)
>  	mutex_unlock(&slab_mutex);
>  
>  	/*
> -	 * SLUB deactivates the kmem_caches through call_rcu. Make
> +	 * SLAB and SLUB deactivate the kmem_caches through call_rcu. Make
>  	 * sure all registered rcu callbacks have been invoked.
>  	 */
> -	if (IS_ENABLED(CONFIG_SLUB))
> -		rcu_barrier();
> +#ifndef CONFIG_SLOB
> +	rcu_barrier();
> +#endif

Nit: you don't need to check CONFIG_SLOB here as this code is under
CONFIG_MEMCG_KMEM which depends on !SLOB.

Other than that, the patch looks good to me, provided using rcu for slab
deactivation proves to be really necessary, although I'd split it in two
patches - one doing renaming another refactoring - easier to review that
way.

