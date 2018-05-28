Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7491A6B0003
	for <linux-mm@kvack.org>; Mon, 28 May 2018 12:10:54 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 6-v6so11429403itl.6
        for <linux-mm@kvack.org>; Mon, 28 May 2018 09:10:54 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t18-v6si363402ioc.103.2018.05.28.09.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 May 2018 09:10:53 -0700 (PDT)
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org> <20180524221715.GY10363@dastard>
 <20180525081624.GH11881@dhcp22.suse.cz> <20180527124721.GA4522@rapoport-lnx>
 <20180528092138.GI1517@dhcp22.suse.cz>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d2f6c4c1-856a-d233-8610-67a868b856f9@infradead.org>
Date: Mon, 28 May 2018 09:10:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180528092138.GI1517@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On 05/28/2018 02:21 AM, Michal Hocko wrote:
> On Sun 27-05-18 15:47:22, Mike Rapoport wrote:
>> On Fri, May 25, 2018 at 10:16:24AM +0200, Michal Hocko wrote:
>>> On Fri 25-05-18 08:17:15, Dave Chinner wrote:
>>>> On Thu, May 24, 2018 at 01:43:41PM +0200, Michal Hocko wrote:
>>> [...]
>>>>> +FS/IO code then simply calls the appropriate save function right at the
>>>>> +layer where a lock taken from the reclaim context (e.g. shrinker) and
>>>>> +the corresponding restore function when the lock is released. All that
>>>>> +ideally along with an explanation what is the reclaim context for easier
>>>>> +maintenance.
>>>>
>>>> This paragraph doesn't make much sense to me. I think you're trying
>>>> to say that we should call the appropriate save function "before
>>>> locks are taken that a reclaim context (e.g a shrinker) might
>>>> require access to."
>>>>
>>>> I think it's also worth making a note about recursive/nested
>>>> save/restore stacking, because it's not clear from this description
>>>> that this is allowed and will work as long as inner save/restore
>>>> calls are fully nested inside outer save/restore contexts.
>>>
>>> Any better?
>>>
>>> -FS/IO code then simply calls the appropriate save function right at the
>>> -layer where a lock taken from the reclaim context (e.g. shrinker) and
>>> -the corresponding restore function when the lock is released. All that
>>> -ideally along with an explanation what is the reclaim context for easier
>>> -maintenance.
>>> +FS/IO code then simply calls the appropriate save function before any
>>> +lock shared with the reclaim context is taken.  The corresponding
>>> +restore function when the lock is released. All that ideally along with
>>
>> Maybe: "The corresponding restore function is called when the lock is
>> released"
> 
> This will get rewritten some more based on comments from Dave
>  
>>> +an explanation what is the reclaim context for easier maintenance.
>>> +
>>> +Please note that the proper pairing of save/restore function allows nesting
>>> +so memalloc_noio_save is safe to be called from an existing NOIO or NOFS scope.
>>  
>> so it is safe to call memalloc_noio_save from an existing NOIO or NOFS
>> scope
> 
> Here is what I have right now on top
> 
> diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
> index c0ec212d6773..0cff411693ab 100644
> --- a/Documentation/core-api/gfp_mask-from-fs-io.rst
> +++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
> @@ -34,12 +34,15 @@ scope will inherently drop __GFP_FS respectively __GFP_IO from the given
>  mask so no memory allocation can recurse back in the FS/IO.
>  
>  FS/IO code then simply calls the appropriate save function before any
> -lock shared with the reclaim context is taken.  The corresponding
> -restore function when the lock is released. All that ideally along with
> -an explanation what is the reclaim context for easier maintenance.
> -
> -Please note that the proper pairing of save/restore function allows nesting
> -so memalloc_noio_save is safe to be called from an existing NOIO or NOFS scope.
> +critical section wrt. the reclaim is started - e.g. lock shared with the

Please spell out "with respect to".

> +reclaim context or when a transaction context nesting would be possible
> +via reclaim. The corresponding restore function when the critical

"The corresponding restore ... ends."  << That is not a complete sentence.
It's missing something.

> +section ends. All that ideally along with an explanation what is
> +the reclaim context for easier maintenance.
> +
> +Please note that the proper pairing of save/restore function allows
> +nesting so it is safe to call ``memalloc_noio_save`` respectively
> +``memalloc_noio_restore`` from an existing NOIO or NOFS scope.

Please note that the proper pairing of save/restore functions allows
nesting so it is safe to call ``memalloc_noio_save`` or
``memalloc_noio_restore`` respectively from an existing NOIO or NOFS scope.


>  
>  What about __vmalloc(GFP_NOFS)
>  ==============================
> 


-- 
~Randy
