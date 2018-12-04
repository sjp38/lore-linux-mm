Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4D26B6C80
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 22:12:19 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so12896527pfe.10
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 19:12:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor21150886plm.47.2018.12.03.19.12.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 19:12:17 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: Number of arguments in vmalloc.c
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181203224920.GQ10377@bombadil.infradead.org>
Date: Mon, 3 Dec 2018 19:12:14 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
 <20181203224920.GQ10377@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

> On Dec 3, 2018, at 2:49 PM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
> On Mon, Dec 03, 2018 at 02:04:41PM -0800, Nadav Amit wrote:
>> On Dec 3, 2018, at 8:13 AM, Matthew Wilcox <willy@infradead.org> =
wrote:
>>> On Mon, Dec 03, 2018 at 02:59:36PM +0100, Vlastimil Babka wrote:
>>>> On 11/28/18 3:01 PM, Matthew Wilcox wrote:
>>>>> Some of the functions in vmalloc.c have as many as nine arguments.
>>>>> So I thought I'd have a quick go at bundling the ones that make =
sense
>>>>> into a struct and pass around a pointer to that struct.  Well, it =
made
>>>>> the generated code worse,
>>>>=20
>>>> Worse in which metric?
>>>=20
>>> More instructions to accomplish the same thing.
>>>=20
>>>>> so I thought I'd share my attempt so nobody
>>>>> else bothers (or soebody points out that I did something stupid).
>>>>=20
>>>> I guess in some of the functions the args parameter could be const?
>>>> Might make some difference.
>>>>=20
>>>> Anyway this shouldn't be a fast path, so even if the generated code =
is
>>>> e.g. somewhat larger, then it still might make sense to reduce the
>>>> insane parameter lists.
>>>=20
>>> It might ... I'm not sure it's even easier to program than the =
original
>>> though.
>>=20
>> My intuition is that if all the fields of vm_args were initialized =
together
>> (in the same function), and a 'const struct vm_args *' was provided =
as
>> an argument to other functions, code would be better (at least better =
than
>> what you got right now).
>>=20
>> I=E2=80=99m not saying it is easily applicable in this use-case =
(since I didn=E2=80=99t
>> check).
>=20
> Your intuition is wrong ...
>=20
>   text	   data	    bss	    dec	    hex	filename
>   9466	     81	     32	   9579	   256b	before.o
>   9546	     81	     32	   9659	   25bb	.build-tiny/mm/vmalloc.o
>   9546	     81	     32	   9659	   25bb	const.o
>=20
> indeed, there's no difference between with or without the const, =
according
> to 'cmp'.
>=20
> Now, only alloc_vmap_area() gets to take a const argument.
> __get_vm_area_node() intentionally modifies the arguments.  But feel
> free to play around with this; you might be able to make it do =
something
> worthwhile.

I was playing with it (a bit). What I suggested (modifying
__get_vm_area_node() so it will not change arguments) helps a bit, but =
not
much.

One insight that I got is that at least part of the overhead comes from =
the
the stack protector code that gcc emits.=
