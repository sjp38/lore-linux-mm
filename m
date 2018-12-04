Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 819706B6DD8
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:58:54 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 98so15799141qkp.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:58:54 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a19si4697036qta.325.2018.12.04.00.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 00:58:51 -0800 (PST)
Date: Tue, 4 Dec 2018 09:58:35 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 07/13] x86/mm: Add helpers for reference counting
 encrypted VMAs
Message-ID: <20181204085835.GO11614@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <e4407d95c74300c4a6b4c5f9321660e9097fff8f.1543903910.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e4407d95c74300c4a6b4c5f9321660e9097fff8f.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Mon, Dec 03, 2018 at 11:39:54PM -0800, Alison Schofield wrote:

> +void vma_put_encrypt_ref(struct vm_area_struct *vma)
> +{
> +	if (vma_keyid(vma))
> +		if (refcount_dec_and_test(&encrypt_count[vma_keyid(vma)])) {
> +			mktme_map_lock();
> +			mktme_map_free_keyid(vma_keyid(vma));
> +			mktme_map_unlock();
> +		}

This violates CodingStyle

> +}

> +void key_put_encrypt_ref(int keyid)
> +{
> +	if (refcount_dec_and_test(&encrypt_count[keyid])) {
> +		mktme_map_lock();

That smells like it wants to use refcount_dec_and_lock() instead.

> +		mktme_map_free_keyid(keyid);
> +		mktme_map_unlock();
> +	}
> +}

Also, if you write that like:

	if (!refcount_dec_and_lock(&encrypt_count[keyid], &lock))
		return;

you loose an indent level.
