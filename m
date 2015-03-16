Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC096B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 06:49:35 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so33961354wib.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:49:34 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id cs8si17090680wjb.107.2015.03.16.03.49.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 03:49:33 -0700 (PDT)
Received: by wifj2 with SMTP id j2so39509954wif.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:49:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5506B04D.1070506@lge.com>
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
	<5506B04D.1070506@lge.com>
Date: Mon, 16 Mar 2015 19:49:32 +0900
Message-ID: <CACZ9PQXe6C1Cpt+zGD7ew2AXgcA2pD047BrXz9GXfz2ZhKuCAQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] [RFC] mm/vmalloc: fix possible exhaustion of vmalloc space
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Mon, Mar 16, 2015 at 7:28 PM, Gioh Kim <gioh.kim@lge.com> wrote:
>
>
> 2015-03-13 =EC=98=A4=ED=9B=84 9:12=EC=97=90 Roman Pen =EC=9D=B4(=EA=B0=80=
) =EC=93=B4 =EA=B8=80:
>> Hello all.
>>
>> Recently I came across high fragmentation of vm_map_ram allocator: vmap_=
block
>> has free space, but still new blocks continue to appear.  Further invest=
igation
>> showed that certain mapping/unmapping sequence can exhaust vmalloc space=
.  On
>> small 32bit systems that's not a big problem, cause purging will be call=
ed soon
>> on a first allocation failure (alloc_vmap_area), but on 64bit machines, =
e.g.
>> x86_64 has 45 bits of vmalloc space, that can be a disaster.
>
> I think the problem you comments is already known so that I wrote comment=
s about it as
> "it could consume lots of address space through fragmentation".
>
> Could you tell me about your situation and reason why it should be avoide=
d?

In the first patch of this set I explicitly described the function,
which exhausts
vmalloc space without any chance to be purged: vm_map_ram allocator is
greedy and firstly
tries to occupy newly allocated block, even old blocks contain enough
free space.

This can be easily fixed if we put newly allocated block (which has
enough space to
complete further requests) to the tail of a free list, to give a
chance to old blocks.

Why it should be avoided?  Strange question.  For me it looks like a
bug of an allocator,
which should be fair and should not continuously allocate new blocks
without lazy purging
(seems vmap_lazy_nr and  __purge_vmap_area_lazy were created exactly
for those reasons:
 to avoid infinite allocations)


--
Roman


>
>
>>
>> Fixing this I also did some tweaks in allocation logic of a new vmap blo=
ck and
>> replaced dirty bitmap with min/max dirty range values to make the logic =
simpler.
>>
>> I would like to receive comments on the following three patches.
>>
>> Thanks.
>>
>> Roman Pen (3):
>>    mm/vmalloc: fix possible exhaustion of vmalloc space caused by
>>      vm_map_ram allocator
>>    mm/vmalloc: occupy newly allocated vmap block just after allocation
>>    mm/vmalloc: get rid of dirty bitmap inside vmap_block structure
>>
>>   mm/vmalloc.c | 94 ++++++++++++++++++++++++++++++++++------------------=
--------
>>   1 file changed, 54 insertions(+), 40 deletions(-)
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: WANG Chao <chaowang@redhat.com>
>> Cc: Fabian Frederick <fabf@skynet.be>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Gioh Kim <gioh.kim@lge.com>
>> Cc: Rob Jones <rob.jones@codethink.co.uk>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: stable@vger.kernel.org
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
