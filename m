Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7F26B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 15:33:01 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fg1so18663994pad.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 12:33:01 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id y189si52795726pfb.83.2016.06.01.12.33.00
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 12:33:00 -0700 (PDT)
Subject: Re: [PATCH 5/8] x86, pkeys: allocation/free syscalls
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
 <20160531152822.FE8D405E@viggo.jf.intel.com>
 <20160601123705.72a606e7@lwn.net>
From: Dave Hansen <dave@sr71.net>
Message-ID: <574F386A.8070106@sr71.net>
Date: Wed, 1 Jun 2016 12:32:58 -0700
MIME-Version: 1.0
In-Reply-To: <20160601123705.72a606e7@lwn.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On 06/01/2016 11:37 AM, Jonathan Corbet wrote:
>> +static inline
>> +int mm_pkey_free(struct mm_struct *mm, int pkey)
>> +{
>> +	/*
>> +	 * pkey 0 is special, always allocated and can never
>> +	 * be freed.
>> +	 */
>> +	if (!pkey || !validate_pkey(pkey))
>> +		return -EINVAL;
>> +	if (!mm_pkey_is_allocated(mm, pkey))
>> +		return -EINVAL;
>> +
>> +	mm_set_pkey_free(mm, pkey);
>> +
>> +	return 0;
>> +}
> 
> If I read this right, it doesn't actually remove any pkey restrictions
> that may have been applied while the key was allocated.  So there could be
> pages with that key assigned that might do surprising things if the key is
> reallocated for another use later, right?  Is that how the API is intended
> to work?

Yeah, that's how it works.

It's not ideal.  It would be _best_ if we during mm_pkey_free(), we
ensured that no VMAs under that mm have that vma_pkey() set.  But, that
search would be potentially expensive (a walk over all VMAs), or would
force us to keep a data structure with a count of all the VMAs with a
given key.

I should probably discuss this behavior in the manpages and address it
more directly in the changelog for this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
