Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3F16B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:19:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d18so12877380pfe.8
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:19:05 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id f2si505945plj.110.2017.07.19.15.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 15:19:04 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id y129so1062652pgy.3
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:19:04 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170719214708.wuzq3di6rt43txtn@suse.de>
Date: Wed, 19 Jul 2017 15:19:00 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
References: <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
 <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jul 19, 2017 at 01:20:01PM -0700, Nadav Amit wrote:
>>> =46rom a PTE you cannot know the state of mmap_sem because you can =
rmap
>>> back to multiple mm's for shared mappings. It's also fairly heavy =
handed.
>>> Technically, you could lock on the basis of the VMA but that has =
other
>>> consequences for scalability. The staleness is also a factor because
>>> it's a case of "does the staleness matter". Sometimes it does, =
sometimes
>>> it doesn't.  mmap_sem even if it could be used does not always tell =
us
>>> the right information either because it can matter whether we are =
racing
>>> against a userspace reference or a kernel operation.
>>>=20
>>> It's possible your idea could be made work, but right now I'm not =
seeing a
>>> solution that handles every corner case. I asked to hear what your =
ideas
>>> were because anything I thought of that could batch TLB flushing in =
the
>>> general case had flaws that did not improve over what is already =
there.
>>=20
>> I don???t disagree with what you say - perhaps my scheme is too =
simplistic.
>> But the bottom line, if you cannot form simple rules for when TLB =
needs to
>> be flushed, what are the chances others would get it right?
>=20
> Broad rule is "flush before the page is freed/reallocated for clean =
pages
> or any IO is initiated for dirty pages" with a lot of details that are =
not
> documented. Often it's the PTL and flush with it held that protects =
the
> majority of cases but it's not universal as the page lock and mmap_sem
> play important rules depending ont the context and AFAIK, that's also
> not documented.
>=20
>>> shrink_page_list is the caller of try_to_unmap in reclaim context. =
It
>>> has this check
>>>=20
>>>               if (!trylock_page(page))
>>>                       goto keep;
>>>=20
>>> For pages it cannot lock, they get put back on the LRU and recycled =
instead
>>> of reclaimed. Hence, if KSM or anything else holds the page lock, =
reclaim
>>> can't unmap it.
>>=20
>> Yes, of course, since KSM does not batch TLB flushes. I regarded the =
other
>> direction - first try_to_unmap() removes the PTE (but still does not =
flush),
>> unlocks the page, and then KSM acquires the page lock and calls
>> write_protect_page(). It finds out the PTE is not present and does =
not flush
>> the TLB.
>=20
> When KSM acquires the page lock, it then acquires the PTL where the
> cleared PTE is observed directly and skipped.

I don=E2=80=99t see why. Let=E2=80=99s try again - CPU0 reclaims while =
CPU1 deduplicates:

CPU0				CPU1
----				----
shrink_page_list()

=3D> try_to_unmap()
=3D=3D> try_to_unmap_one()
[ unmaps from some page-tables ]

[ try_to_unmap returns false;
  page not reclaimed ]

=3D> keep_locked: unlock_page()

[ TLB flush deferred ]
				try_to_merge_one_page()
				=3D> trylock_page()
				=3D> write_protect_page()
				=3D=3D> acquire ptl
				  [ PTE non-present =E2=80=94> no PTE =
change
				    and no flush ]
				=3D=3D> release ptl
				=3D=3D> replace_page()


At this point, while replace_page() is running, CPU0 may still not have
flushed the TLBs. Another CPU (CPU2) may hold a stale PTE, which is not
write-protected. It can therefore write to that page while =
replace_page() is
running, resulting in memory corruption.

No?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
