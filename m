Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB7C6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 14:37:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e3so15999832wme.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 11:37:09 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id s10si49919951wjm.110.2016.06.01.11.37.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 11:37:08 -0700 (PDT)
Date: Wed, 1 Jun 2016 12:37:05 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 5/8] x86, pkeys: allocation/free syscalls
Message-ID: <20160601123705.72a606e7@lwn.net>
In-Reply-To: <20160531152822.FE8D405E@viggo.jf.intel.com>
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
	<20160531152822.FE8D405E@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

Sorry, I have one more obnoxious question...

> +static inline
> +int mm_pkey_free(struct mm_struct *mm, int pkey)
> +{
> +	/*
> +	 * pkey 0 is special, always allocated and can never
> +	 * be freed.
> +	 */
> +	if (!pkey || !validate_pkey(pkey))
> +		return -EINVAL;
> +	if (!mm_pkey_is_allocated(mm, pkey))
> +		return -EINVAL;
> +
> +	mm_set_pkey_free(mm, pkey);
> +
> +	return 0;
> +}

If I read this right, it doesn't actually remove any pkey restrictions
that may have been applied while the key was allocated.  So there could be
pages with that key assigned that might do surprising things if the key is
reallocated for another use later, right?  Is that how the API is intended
to work?

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
