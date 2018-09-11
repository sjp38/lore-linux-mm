Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6B448E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:03:19 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k21-v6so25670788qtj.23
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:03:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f12-v6si9809335qvh.45.2018.09.11.15.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 15:03:19 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com>
References: <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com> <cover.1536356108.git.alison.schofield@intel.com>
Subject: Re: [RFC 11/12] keys/mktme: Add a new key service type for memory encryption keys
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <27767.1536703394.1@warthog.procyon.org.uk>
Date: Tue, 11 Sep 2018 23:03:15 +0100
Message-ID: <27768.1536703395@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Alison Schofield <alison.schofield@intel.com> wrote:

> +/* Key Service Command: Creates a software key and programs hardware */
> +int mktme_instantiate(struct key *key, struct key_preparsed_payload *prep)
> +{
> +	struct mktme_key_program *kprog = NULL;
> +	size_t datalen = prep->datalen;
> +	char *options;
> +	int ret = 0;
> +
> +	if (!capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
> +		return -EACCES;
> +
> +	if (datalen <= 0 || datalen > 1024 || !prep->data)
> +		return -EINVAL;
> +
> +	options = kmemdup(prep->data, datalen + 1, GFP_KERNEL);
> +	if (!options)
> +		return -ENOMEM;
> +
> +	options[datalen] = '\0';
> +
> +	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_KERNEL);
> +	if (!kprog) {
> +		kzfree(options);
> +		return -ENOMEM;
> +	}
> +	ret = mktme_get_options(options, kprog);
> +	if (ret < 0)
> +		goto out;

Everything prior to here looks like it should be in the ->preparse() routine.
I really should get round to making that mandatory.

> +
> +	mktme_map_lock();
> +	ret = mktme_program_key(key->serial, kprog);
> +	mktme_map_unlock();
> +out:
> +	kzfree(options);
> +	kmem_cache_free(mktme_prog_cache, kprog);
> +	return ret;
> +}

David
