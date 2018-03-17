Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCD46B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 22:36:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id e205so3570195qkb.8
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 19:36:26 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id w64si6099632qkd.292.2018.03.16.19.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 19:36:25 -0700 (PDT)
Subject: Re: [PATCH 03/14] mm/hmm: HMM should have a callback before MM is
 destroyed v2
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-4-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <7e87c1f9-5c1a-84fd-1f7f-55ffaaed8a66@nvidia.com>
Date: Fri, 16 Mar 2018 19:36:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180316191414.3223-4-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 

<snip>

> +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	struct hmm *hmm = mm->hmm;
> +	struct hmm_mirror *mirror;
> +	struct hmm_mirror *mirror_next;
> +
> +	down_write(&hmm->mirrors_sem);
> +	list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
> +		list_del_init(&mirror->list);
> +		if (mirror->ops->release)
> +			mirror->ops->release(mirror);
> +	}
> +	up_write(&hmm->mirrors_sem);
> +}
> +

OK, as for actual code review:

This part of the locking looks good. However, I think it can race against
hmm_mirror_register(), because hmm_mirror_register() will just add a new 
mirror regardless.

So:

thread 1                                      thread 2
--------------                                -----------------
hmm_release                                   hmm_mirror_register 
    down_write(&hmm->mirrors_sem);                <blocked: waiting for sem>
        // deletes all list items
    up_write
                                                  unblocked: adds new mirror
                                              

...so I think we need a way to back out of any pending hmm_mirror_register()
calls, as part of the .release steps, right? It seems hard for the device driver,
which could be inside of hmm_mirror_register(), to handle that. Especially considering
that right now, hmm_mirror_register() will return success in this case--so
there is no indication that anything is wrong.

Maybe hmm_mirror_register() could return an error (and not add to the mirror list),
in such a situation, how's that sound?

thanks,
-- 
John Hubbard
NVIDIA
