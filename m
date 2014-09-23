Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4EECD6B0037
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 03:49:10 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so728886wgg.7
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 00:49:09 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id ej7si1325557wib.61.2014.09.23.00.49.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 00:49:09 -0700 (PDT)
Received: by mail-wg0-f43.google.com with SMTP id y10so4272333wgg.14
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 00:49:08 -0700 (PDT)
Message-ID: <542125F1.3080607@redhat.com>
Date: Tue, 23 Sep 2014 09:49:05 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] kvm: Fix page ageing bugs
References: <1411410865-3603-1-git-send-email-andreslc@google.com> <1411422882-16245-1-git-send-email-andreslc@google.com>
In-Reply-To: <1411422882-16245-1-git-send-email-andreslc@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andres Lagar-Cavilla <andreslc@gooogle.com>

Il 22/09/2014 23:54, Andres Lagar-Cavilla ha scritto:
> @@ -1406,32 +1406,24 @@ static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp,
>  	struct rmap_iterator uninitialized_var(iter);
>  	int young = 0;
>  
> -	/*
> -	 * In case of absence of EPT Access and Dirty Bits supports,
> -	 * emulate the accessed bit for EPT, by checking if this page has
> -	 * an EPT mapping, and clearing it if it does. On the next access,
> -	 * a new EPT mapping will be established.
> -	 * This has some overhead, but not as much as the cost of swapping
> -	 * out actively used pages or breaking up actively used hugepages.
> -	 */
> -	if (!shadow_accessed_mask) {
> -		young = kvm_unmap_rmapp(kvm, rmapp, slot, data);
> -		goto out;
> -	}
> +	BUG_ON(!shadow_accessed_mask);
>  
>  	for (sptep = rmap_get_first(*rmapp, &iter); sptep;
>  	     sptep = rmap_get_next(&iter)) {
> +		struct kvm_mmu_page *sp;
> +		gfn_t gfn;
>  		BUG_ON(!is_shadow_present_pte(*sptep));
> +		/* From spte to gfn. */
> +		sp = page_header(__pa(sptep));
> +		gfn = kvm_mmu_page_get_gfn(sp, sptep - sp->spt);
>  
>  		if (*sptep & shadow_accessed_mask) {
>  			young = 1;
>  			clear_bit((ffs(shadow_accessed_mask) - 1),
>  				 (unsigned long *)sptep);
>  		}
> +		trace_kvm_age_page(gfn, slot, young);

Yesterday I couldn't think of a way to avoid the
page_header/kvm_mmu_page_get_gfn on every iteration, but it's actually
not hard.  Instead of passing hva as datum, you can pass (unsigned long)
&start.  Then you can add PAGE_SIZE to it at the end of every call to
kvm_age_rmapp, and keep the old tracing logic.


Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
