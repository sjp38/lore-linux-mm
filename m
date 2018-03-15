Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9431A6B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 18:48:32 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 60-v6so3996472plf.19
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 15:48:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y4si4077813pgr.152.2018.03.15.15.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 15:48:31 -0700 (PDT)
Date: Thu, 15 Mar 2018 15:48:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm/hmm: HMM should have a callback before MM is
 destroyed
Message-Id: <20180315154829.89054bfd579d03097b0f6457@linux-foundation.org>
In-Reply-To: <20180315183700.3843-4-jglisse@redhat.com>
References: <20180315183700.3843-1-jglisse@redhat.com>
	<20180315183700.3843-4-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Thu, 15 Mar 2018 14:36:59 -0400 jglisse@redhat.com wrote:

> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> The hmm_mirror_register() function registers a callback for when
> the CPU pagetable is modified. Normally, the device driver will
> call hmm_mirror_unregister() when the process using the device is
> finished. However, if the process exits uncleanly, the struct_mm
> can be destroyed with no warning to the device driver.

The changelog doesn't tell us what the runtime effects of the bug are. 
This makes it hard for me to answer the "did Jerome consider doing
cc:stable" question.

> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -160,6 +160,23 @@ static void hmm_invalidate_range(struct hmm *hmm,
>  	up_read(&hmm->mirrors_sem);
>  }
>  
> +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	struct hmm *hmm = mm->hmm;
> +	struct hmm_mirror *mirror;
> +	struct hmm_mirror *mirror_next;
> +
> +	VM_BUG_ON(!hmm);

This doesn't add much value.  We'll reliably oops on the next statement
anyway, which will provide the same info.  And Linus gets all upset at
new BUG_ON() instances.

> +	down_write(&hmm->mirrors_sem);
> +	list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
> +		list_del_init(&mirror->list);
> +		if (mirror->ops->release)
> +			mirror->ops->release(mirror);
> +	}
> +	up_write(&hmm->mirrors_sem);
> +}
> +
