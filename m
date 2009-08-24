Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9641E6B00C3
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:03:24 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2522546fxm.38
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:03:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A92EBB4.1070101@vflare.org>
References: <200908241007.47910.ngupta@vflare.org>
	 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
	 <4A92EBB4.1070101@vflare.org>
Date: Mon, 24 Aug 2009 22:43:53 +0300
Message-ID: <84144f020908241243y11f10e8eudc758b61527e0e9c@mail.gmail.com>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi Nitin,

On Mon, Aug 24, 2009 at 10:36 PM, Nitin Gupta<ngupta@vflare.org> wrote:
> On 08/24/2009 11:03 PM, Pekka Enberg wrote:
>
> <snip>
>
>> On Mon, Aug 24, 2009 at 7:37 AM, Nitin Gupta<ngupta@vflare.org> =A0wrote=
:
>>>
>>> +/**
>>> + * xv_malloc - Allocate block of given size from pool.
>>> + * @pool: pool to allocate from
>>> + * @size: size of block to allocate
>>> + * @pagenum: page no. that holds the object
>>> + * @offset: location of object within pagenum
>>> + *
>>> + * On success,<pagenum, offset> =A0identifies block allocated
>>> + * and 0 is returned. On failure,<pagenum, offset> =A0is set to
>>> + * 0 and -ENOMEM is returned.
>>> + *
>>> + * Allocation requests with size> =A0XV_MAX_ALLOC_SIZE will fail.
>>> + */
>>> +int xv_malloc(struct xv_pool *pool, u32 size, u32 *pagenum, u32 *offse=
t,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t flags)
>
> <snip>
>
>>
>> What's the purpose of passing PFNs around? There's quite a lot of PFN
>> to struct page conversion going on because of it. Wouldn't it make
>> more sense to return (and pass) a pointer to struct page instead?
>
> PFNs are 32-bit on all archs while for 'struct page *', we require 32-bit=
 or
> 64-bit depending on arch. ramzswap allocates a table entry <pagenum, offs=
et>
> corresponding to every swap slot. So, the size of table will unnecessaril=
y
> increase on 64-bit archs. Same is the argument for xvmalloc free list siz=
es.
>
> Also, xvmalloc and ramzswap itself does PFN -> 'struct page *' conversion
> only when freeing the page or to get a deferencable pointer.

I still don't see why the APIs have work on PFNs. You can obviously do
the conversion once for store and load. Look at what the code does,
it's converting struct page to PFN just to do the reverse for kmap().
I think that could be cleaned by passing struct page around.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
