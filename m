Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id A8F8E6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 11:04:26 -0400 (EDT)
Received: by wibhr14 with SMTP id hr14so2568996wib.8
        for <linux-mm@kvack.org>; Tue, 15 May 2012 08:04:25 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <4FB06B91.1080008@kernel.org>
References: <4FAB21E7.7020703@kernel.org>
	<20120510140215.GC26152@phenom.dumpdata.com>
	<4FABD503.4030808@vflare.org>
	<4FABDA9F.1000105@linux.vnet.ibm.com>
	<20120510151941.GA18302@kroah.com>
	<4FABECF5.8040602@vflare.org>
	<20120510164418.GC13964@kroah.com>
	<4FABF9D4.8080303@vflare.org>
	<20120510173322.GA30481@phenom.dumpdata.com>
	<4FAC4E3B.3030909@kernel.org>
	<20120511192831.GC3785@phenom.dumpdata.com>
	<4FB06B91.1080008@kernel.org>
Date: Tue, 15 May 2012 11:04:22 -0400
Message-ID: <CAPbh3ruv9xCV_XpR4ZsZpSGQ8=mibg=a39zvADYETb-tg0kBsA@mail.gmail.com>
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>>
>> The fix is of course to return a pointer (which your function
>> declared), and instead do this:
>>
>> {
>> =A0 =A0 =A0 struct zs_handle *handle;
>>
>> =A0 =A0 =A0 handle =3D zs_malloc(pool, size);
>
>
> It's not a good idea.
> For it, zs_malloc needs memory space to keep zs_handle internally.
> Why should zsallocator do it? Just for zcache?

How different is from now? The zs_malloc keeps the handle internally
as well - it just that is is a void * pointer. Internally, the
ownership and the responsibility to free it lays with zsmalloc.

> It's not good abstraction.

If we want good abstraction, then I don't think 'unsigned long' is
either? I mean it will do for the conversion from 'void *'. Perhaps I
am being a bit optimistic here - and I am trying to jam in this
'struct zs_handle' in all cases but in reality it needs a more
iterative process. So first do 'void *' -> 'unsigned long', and then
later on if we can come up with something more nicely that abstracts
- then use that?
.. snip ..
>>> Why should zsmalloc support such interface?
>>
>> Why not? It is better than a 'void *' or a typedef.
>>
>> It is modeled after a pte_t.
>
>
> It's not same with pte_t.
> We normally don't use pte_val to (void*) for unique index of slot.

Right, but I thought we want to get rid of all of the '(void *)'
usages and instead
pass some opaque pointer.

> The problem is that zcache assume handle of zsmalloc is a sizeof(void*)'s
> unique value but zcache never assume it's a sizeof(void*).

Huh? I am parsing your sentence as: "zcache assumes .. sizeof(void *),
but zcache never assumes its .. sizeof(void *)"?

Zcache has to assume it is a pointer. And providing a 'struct
zs_handle *' would fit the bill?
>>
>>
>>> It's a zcache problem so it's desriable to solve it in zcache internal.
>>
>> Not really. We shouldn't really pass any 'void *' pointers around.
>>
>>> And in future, if we can add/remove zs_handle's fields, we can't make
>>> sure such API.
>>
>> Meaning ... what exactly do you mean? That the size of the structure
>> will change and we won't return the right value? Why not?
>> If you use the 'zs_handle_to_ptr' won't that work? Especially if you
>> add new values to the end of the struct it won't cause issues.
>
>
> I mean we might change zs_handle to following as, in future.
> (It's insane but who know it?)

OK, so BUILD_BUG(sizeof(struct zs_handle *) !=3D sizeof(void *))
with a big fat comment saying that one needs to go over the other users
of zcache/zram/zsmalloc to double check?

But why would it matter? The zs_handle would be returned as a pointer
- so the size is the same to the caller.

>
> struct zs_handle {
> =A0 =A0 =A0 =A0int upper;
> =A0 =A0 =A0 =A0int middle;
> =A0 =A0 =A0 =A0int lower;
> };
>
> How could you handle this for zs_handle_to_ptr?

Gosh, um, I couldn't :-) Well, maybe with something that does
 return "upper | middle | lower", but yeah that is not the goal.


>>>>> Its true that making it a real struct would prevent accidental casts
>>>>> to void * but due to the above problem, I think we have to stick
>>>>> with unsigned long.
>>
>> So the problem you are seeing is that you don't want 'struct zs_handle'
>> be present in the drivers/staging/zsmalloc/zsmalloc.h header file?
>> It looks like the proper place.
>
>
> No. What I want is to remove coupling zsallocator's handle with zram/zcac=
he.
> They shouldn't know internal of handle and assume it's a pointer.

I concur. And hence I was thinking that the 'struct zs_handle *'
pointer would work.

>
> If Nitin confirm zs_handle's format can never change in future, I prefer =
"unsigned long" Nitin suggested than (void *).
> It can prevent confusion that normal allocator's return value is pointer =
for address so the problem is easy.
> But I am not sure he can make sure it.

Well, everything changes over time  so putting a stick in the ground
and saying 'this must
be this way' is not really the best way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
