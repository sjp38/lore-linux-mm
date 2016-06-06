Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04DA96B026C
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 10:51:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 4so11563171wmz.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 07:51:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8si15391165wmf.62.2016.06.06.07.51.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 07:51:41 -0700 (PDT)
Subject: Re: [PATCH v2 6/7] mm/page_owner: use stackdepot to store stacktrace
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f90a01f2-9336-1322-881b-74755145fe9b@suse.cz>
Date: Mon, 6 Jun 2016 16:51:39 +0200
MIME-Version: 1.0
In-Reply-To: <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Currently, we store each page's allocation stacktrace on corresponding
> page_ext structure and it requires a lot of memory. This causes the problem
> that memory tight system doesn't work well if page_owner is enabled.
> Moreover, even with this large memory consumption, we cannot get full
> stacktrace because we allocate memory at boot time and just maintain
> 8 stacktrace slots to balance memory consumption. We could increase it
> to more but it would make system unusable or change system behaviour.
>
> To solve the problem, this patch uses stackdepot to store stacktrace.
> It obviously provides memory saving but there is a drawback that
> stackdepot could fail.
>
> stackdepot allocates memory at runtime so it could fail if system has
> not enough memory. But, most of allocation stack are generated at very
> early time and there are much memory at this time. So, failure would not
> happen easily. And, one failure means that we miss just one page's
> allocation stacktrace so it would not be a big problem. In this patch,
> when memory allocation failure happens, we store special stracktrace
> handle to the page that is failed to save stacktrace. With it, user
> can guess memory usage properly even if failure happens.
>
> Memory saving looks as following. (4GB memory system with page_owner)
>
> static allocation:
> 92274688 bytes -> 25165824 bytes
>
> dynamic allocation after kernel build:
> 0 bytes -> 327680 bytes
>
> total:
> 92274688 bytes -> 25493504 bytes
>
> 72% reduction in total.
>
> Note that implementation looks complex than someone would imagine because
> there is recursion issue. stackdepot uses page allocator and page_owner
> is called at page allocation. Using stackdepot in page_owner could re-call
> page allcator and then page_owner. That is a recursion. To detect and
> avoid it, whenever we obtain stacktrace, recursion is checked and
> page_owner is set to dummy information if found. Dummy information means
> that this page is allocated for page_owner feature itself
> (such as stackdepot) and it's understandable behavior for user.
>
> v2:
> o calculate memory saving with including dynamic allocation
> after kernel build
> o change maximum stacktrace entry size due to possible stack overflow
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I was surprised that there's no stack removal handling, and then found 
out that stackdepot doesn't support it (e.g. via refcount as one would 
expect). Hopefully the occupied memory doesn't grow indefinitely over 
time then...

Other than that,
Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
