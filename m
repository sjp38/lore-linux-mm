Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA0826B055B
	for <linux-mm@kvack.org>; Wed,  9 May 2018 14:00:34 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w14-v6so24050682wrk.22
        for <linux-mm@kvack.org>; Wed, 09 May 2018 11:00:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j7-v6sor8934638edn.55.2018.05.09.11.00.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 11:00:33 -0700 (PDT)
Subject: Re: [PATCH 04/13] mm: Use array_size() helpers for kmalloc()
References: <20180509004229.36341-1-keescook@chromium.org>
 <20180509004229.36341-5-keescook@chromium.org>
 <20180509113446.GA18549@bombadil.infradead.org>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <fea0a346-6f36-ff8c-f036-13f22dfb9bfe@rasmusvillemoes.dk>
Date: Wed, 9 May 2018 20:00:28 +0200
MIME-Version: 1.0
In-Reply-To: <20180509113446.GA18549@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On 2018-05-09 13:34, Matthew Wilcox wrote:
> On Tue, May 08, 2018 at 05:42:20PM -0700, Kees Cook wrote:
>> @@ -499,6 +500,8 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
>>   */
>>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>>  {
>> +	if (size == SIZE_MAX)
>> +		return NULL;
>>  	if (__builtin_constant_p(size)) {
>>  		if (size > KMALLOC_MAX_CACHE_SIZE)
>>  			return kmalloc_large(size, flags);
> 
> I don't like the add-checking-to-every-call-site part of this patch.
> Fine, the compiler will optimise it away if it can calculate it at compile
> time, but there are a lot of situations where it can't.  You aren't
> adding any safety by doing this; trying to allocate SIZE_MAX bytes is
> guaranteed to fail, and it doesn't need to fail quickly.

Yeah, agree that we don't want to add a size check to all callers,
including those where the size doesn't even come from one of the new
*_size helpers; that just adds bloat. It's true that the overflow case
does not have to fail quickly, but I was worried that the saturating
helpers would end up making gcc emit a cmov instruction, thus stalling
the regular path. But it seems that it actually ends up doing a forward
jump, sets %rdi to SIZE_MAX, then jumps back to the call of __kmalloc,
so it should be ok.

With __builtin_constant_p(size) && size == SIZE_MAX, gcc could be smart
enough to elide those two instructions and have the jo go directly to
the caller's error handling, but at least gcc 5.4 doesn't seem to be
that smart. So let's just omit that part for now.

But in case of the kmalloc_array functions, with a direct call of
__builtin_mul_overflow(), gcc does combine the "return NULL" with the
callers error handling, thus avoiding the six byte "%rdi = -1; jmp
back;" thunk. That, along with the churn factor, might be an argument
for leaving the current callers of *_array alone. But if we are going to
keep those longer-term, we might as well convert kmalloc(a, b) into
kmalloc_array(a, b) instead of kmalloc(array_size(a, b)). In any case, I
do see the usefulness of the struct_size helper, and agree that we
definitely should not introduce a new *_struct variant that needs to be
implemented in all families.

>> @@ -624,11 +629,13 @@ int memcg_update_all_caches(int num_memcgs);
>>   */
>>  static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
>>  {
>> -	if (size != 0 && n > SIZE_MAX / size)
>> +	size_t bytes = array_size(n, size);
>> +
>> +	if (bytes == SIZE_MAX)
>>  		return NULL;
>>  	if (__builtin_constant_p(n) && __builtin_constant_p(size))
>> -		return kmalloc(n * size, flags);
>> -	return __kmalloc(n * size, flags);
>> +		return kmalloc(bytes, flags);
>> +	return __kmalloc(bytes, flags);
>>  }
>>  
>>  /**
>> @@ -639,7 +646,9 @@ static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
>>   */
>>  static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
>>  {
>> -	return kmalloc_array(n, size, flags | __GFP_ZERO);
>> +	size_t bytes = array_size(n, size);
>> +
>> +	return kmalloc(bytes, flags | __GFP_ZERO);
>>  }
> 
> Hmm.  I wonder why we have the kmalloc/__kmalloc "optimisation"
> in kmalloc_array, but not kcalloc.  Bet we don't really need it in
> kmalloc_array.  I'll do some testing.
> 

Huh? Because kcalloc is implemented in terms of kmalloc_array? And can't
we just keep it that way?

Rasmus
