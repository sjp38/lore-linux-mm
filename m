Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id DFA7C6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 03:20:14 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q59so2961874wes.21
        for <linux-mm@kvack.org>; Thu, 22 May 2014 00:20:14 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id fc6si3102126wib.73.2014.05.22.00.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 May 2014 00:20:09 -0700 (PDT)
Date: Thu, 22 May 2014 09:20:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140522072001.GP30445@twins.programming.kicks-ass.net>
References: <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
 <20140521213354.GL2485@laptop.programming.kicks-ass.net>
 <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
 <20140522000715.GA23991@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Gi2vSq8QtPYbuTNa"
Content-Disposition: inline
In-Reply-To: <20140522000715.GA23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>


--Gi2vSq8QtPYbuTNa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 22, 2014 at 01:07:15AM +0100, Mel Gorman wrote:

> +PAGEFLAG(Waiters, waiters) __CLEARPAGEFLAG(Waiters, waiters)
> +	TESTCLEARFLAG(Waiters, waiters)
> +#define __PG_WAITERS		(1 << PG_waiters)
> +#else
> +/* Always fallback to slow path on 32-bit */
> +static inline bool PageWaiters(struct page *page)
> +{
> +	return true;
> +}
> +static inline void __ClearPageWaiters(struct page *page) {}
> +static inline void ClearPageWaiters(struct page *page) {}
> +static inline void SetPageWaiters(struct page *page) {}
> +#define __PG_WAITERS		0


> +void __wake_up_page_bit(wait_queue_head_t *wqh, struct page *page, void *word, int bit)
> +{
> +	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
> +	unsigned long flags;
> +
> +	/*
> +	 * Unlike __wake_up_bit it is necessary to check waitqueue_active to be
> +	 * checked under the wqh->lock to avoid races with parallel additions
> +	 * to the waitqueue. Otherwise races could result in lost wakeups
> +	 */

Well, you could do something like:

	if (!__PG_WAITERS && !waitqueue_active(wqh))
		return;

Which at least for 32bit restores some of the performance loss of this
patch (did you have 32bit numbers in that massive changelog?, I totally
tl;dr it).

> +	spin_lock_irqsave(&wqh->lock, flags);
> +	if (waitqueue_active(wqh))
> +		__wake_up_common(wqh, TASK_NORMAL, 1, 0, &key);
> +	else
> +		ClearPageWaiters(page);
> +	spin_unlock_irqrestore(&wqh->lock, flags);
> +}

--Gi2vSq8QtPYbuTNa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTfaUhAAoJEHZH4aRLwOS6+pUP/RIBpDxISiW0cjgaSqTKzi6B
CXgpKBFSLjmaR/Q0/aAWu9TZ05uvbVTR4z0UeevPKEIrngipussAwEr1PzeaE5LI
HGtCwZ3K8nlo5HH0LEFv7uTqgNZil/FaJWXvFqr1niRxE7DY95KYN+paAlbPEMPG
FE0JlwuWh0oDyxH06u5CD/3BzZl3atecaRERxhYXmhi1Trk4Tw8YxUDTqcuFZwtW
4gZ7WnEKIxhs/tsJ6Ki1GeWZeRbXNbMzuclZUP+9otH14S3/bZTklfU6jcImTQmL
TGLVOms0YW4I0a59iMoYlejdPsha0BoNcDyaV1AeHzmmAjbRYbvu6iSI9vREiJKq
e+Z1ATagg41+KM67nGjs2yE+2CC4vnckHtsHVudBhplTx7L8DtOdK/lb86/Peeci
97Vns4MTtP09YWYkioCDEsn5fA6outwERPUnwOVPukcIQxnNcrSc3lBp4Is+N1I5
ZilBIQ5v3fEPNfU5YG4MFo6UZsatCBq6LI4feDI8whAF3TdPo2Ae+sMyH4lSOdBT
roBdCqWXWqcIik+V0JXOv2R9ONTEYbu89AX2utGWc9kFog0UgcXnwPKjyPnX0JqG
8yIjHQrAP9JQP6QNfd3E6Z9w6T2Klo7qt4QwoexGJbmuHEQksOgtIGbAxLvqvq/9
/UeLqRC7IQvmVd6SdkFM
=TNvM
-----END PGP SIGNATURE-----

--Gi2vSq8QtPYbuTNa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
