Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB276B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:16:54 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so4207752wgh.28
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:16:53 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id em6si4173120wib.59.2014.06.20.14.16.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 14:16:53 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so1428226wib.3
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:16:52 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [mmotm:master 141/230] include/linux/kernel.h:744:28: note: in expansion of macro 'min'
In-Reply-To: <20140620133954.3cc60a53f60edac2d8001b63@linux-foundation.org>
References: <53a3c359.yUYVC7fzjYpZLyLq%fengguang.wu@intel.com> <20140620055210.GA26552@localhost> <xa1tppi3vc9w.fsf@mina86.com> <20140620133954.3cc60a53f60edac2d8001b63@linux-foundation.org>
Date: Fri, 20 Jun 2014 23:16:49 +0200
Message-ID: <xa1t7g4buvr2.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Hagen Paul Pfeifer <hagen@jauu.net>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jun 20 2014, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 20 Jun 2014 17:19:55 +0200 Michal Nazarewicz <mina86@mina86.com> =
wrote:
>
>> On Fri, Jun 20 2014, Fengguang Wu <fengguang.wu@intel.com> wrote:
>> >>> include/linux/kernel.h:744:28: note: in expansion of macro 'min'
>> >     #define clamp(val, lo, hi) min(max(val, lo), hi)
>> >                                ^
>> >>> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:11: note: in exp=
ansion of macro 'clamp'
>> >       bytes =3D clamp(bytes, (u16)1024, (u16)I40E_MAX_AQ_BUF_SIZE);
>> >               ^
>>=20
>> The obvious fix:
>>=20
>> ----------- >8 ---------------------------------------------------------=
-----
>> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
>> index 44649e0..149864b 100644
>> --- a/include/linux/kernel.h
>> +++ b/include/linux/kernel.h
>> @@ -719,8 +719,8 @@ static inline void ftrace_dump(enum ftrace_dump_mode=
 oops_dump_mode) { }
>>         (void) (&_max1 =3D=3D &_max2);              \
>>         _max1 > _max2 ? _max1 : _max2; })
>>=20=20
>> -#define min3(x, y, z) min(min(x, y), z)
>> -#define max3(x, y, z) max(max(x, y), z)
>> +#define min3(x, y, z) min((typeof(x))min(x, y), z)
>> +#define max3(x, y, z) max((typeof(x))max(x, y), z)
>
> I don't get it.  All the types are u16 so we should be good.
>
> What is the return type of
>
> 	_max1 > _max2 ? _max1 : _max2;

int=E2=80=A6 Since C promotes it.  (Or unsigned, I never remember, but I th=
ink
int if the possible values fit in signed int).

> when both _max1 and _max2 are u16?  Something other than u16 apparently
> - I never knew that.
>
> Maybe we should be fixing min() and max()?

This is also an option.  It would make min() and max() behave more like
a function which takes arguments of type T and returns value of type T.
Currently it behaves as a C operation which undergoes all the promotion
rules other arithmetic operations undergo (i.e. all types smaller than
int get promoted to int).  I don't have opinion either way.

> --- a/include/linux/kernel.h~a
> +++ a/include/linux/kernel.h
> @@ -711,13 +711,13 @@ static inline void ftrace_dump(enum ftra
>  	typeof(x) _min1 =3D (x);			\
>  	typeof(y) _min2 =3D (y);			\
>  	(void) (&_min1 =3D=3D &_min2);		\
> -	_min1 < _min2 ? _min1 : _min2; })
> +	(typeof(x))(_min1 < _min2 ? _min1 : _min2); })
>=20=20
>  #define max(x, y) ({				\
>  	typeof(x) _max1 =3D (x);			\
>  	typeof(y) _max2 =3D (y);			\
>  	(void) (&_max1 =3D=3D &_max2);		\
> -	_max1 > _max2 ? _max1 : _max2; })
> +	(typeof(x))(_max1 > _max2 ? _max1 : _max2); })
>=20=20
>  #define min3(x, y, z) min(min(x, y), z)
>  #define max3(x, y, z) max(max(x, y), z)
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
