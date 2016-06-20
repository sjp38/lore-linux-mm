Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E99B828E1
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 09:04:32 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id nq2so27515584lbc.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:04:32 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id pm6si7259945lbc.48.2016.06.20.06.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 06:04:30 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id q132so37183733lfe.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:04:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <f90a01f2-9336-1322-881b-74755145fe9b@suse.cz>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com> <f90a01f2-9336-1322-881b-74755145fe9b@suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 20 Jun 2016 15:04:28 +0200
Message-ID: <CAG_fn=WCuaC+kb44DEVnANTVb3MusNxpLWFo0b3ceBkkf9LK2A@mail.gmail.com>
Subject: Re: [PATCH v2 6/7] mm/page_owner: use stackdepot to store stacktrace
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jun 6, 2016 at 4:51 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
>>
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Currently, we store each page's allocation stacktrace on corresponding
>> page_ext structure and it requires a lot of memory. This causes the
>> problem
>> that memory tight system doesn't work well if page_owner is enabled.
>> Moreover, even with this large memory consumption, we cannot get full
>> stacktrace because we allocate memory at boot time and just maintain
>> 8 stacktrace slots to balance memory consumption. We could increase it
>> to more but it would make system unusable or change system behaviour.
>>
>> To solve the problem, this patch uses stackdepot to store stacktrace.
>> It obviously provides memory saving but there is a drawback that
>> stackdepot could fail.
>>
>> stackdepot allocates memory at runtime so it could fail if system has
>> not enough memory. But, most of allocation stack are generated at very
>> early time and there are much memory at this time. So, failure would not
>> happen easily. And, one failure means that we miss just one page's
>> allocation stacktrace so it would not be a big problem. In this patch,
>> when memory allocation failure happens, we store special stracktrace
>> handle to the page that is failed to save stacktrace. With it, user
>> can guess memory usage properly even if failure happens.
>>
>> Memory saving looks as following. (4GB memory system with page_owner)
>>
>> static allocation:
>> 92274688 bytes -> 25165824 bytes
>>
>> dynamic allocation after kernel build:
>> 0 bytes -> 327680 bytes
>>
>> total:
>> 92274688 bytes -> 25493504 bytes
>>
>> 72% reduction in total.
>>
>> Note that implementation looks complex than someone would imagine becaus=
e
>> there is recursion issue. stackdepot uses page allocator and page_owner
>> is called at page allocation. Using stackdepot in page_owner could re-ca=
ll
>> page allcator and then page_owner. That is a recursion. To detect and
>> avoid it, whenever we obtain stacktrace, recursion is checked and
>> page_owner is set to dummy information if found. Dummy information means
>> that this page is allocated for page_owner feature itself
>> (such as stackdepot) and it's understandable behavior for user.
>>
>> v2:
>> o calculate memory saving with including dynamic allocation
>> after kernel build
>> o change maximum stacktrace entry size due to possible stack overflow
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>
> I was surprised that there's no stack removal handling, and then found ou=
t
> that stackdepot doesn't support it (e.g. via refcount as one would expect=
).
> Hopefully the occupied memory doesn't grow indefinitely over time then...

The existing use case (allocation/deallocation stacks for KASAN
reports) doesn't require reference counts. Introducing those would
have added unwanted contention and increase memory usage.
The amount of memory used by the stack depot is bounded above, and
should be theoretically enough for everyone (as noted in another
thread, the number of unique allocation/deallocation stacks is way
less than 30k).
> Other than that,
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
