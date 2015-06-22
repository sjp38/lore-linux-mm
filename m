Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A71E26B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:40:02 -0400 (EDT)
Received: by wguu7 with SMTP id u7so62667253wgu.3
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:40:02 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTP id cs3si18560325wib.117.2015.06.22.01.40.00
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 01:40:01 -0700 (PDT)
Message-ID: <5587C9DA.7090909@arm.com>
Date: Mon, 22 Jun 2015 09:39:54 +0100
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] memtest: use kstrtouint instead of simple_strtoul
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com> <1434725914-14300-2-git-send-email-vladimir.murzin@arm.com> <CALq1K=J6ZKvBM5aqFGeE_hcZTrLxwuaP=N_8xb_no_LCjjTT9g@mail.gmail.com>
In-Reply-To: <CALq1K=J6ZKvBM5aqFGeE_hcZTrLxwuaP=N_8xb_no_LCjjTT9g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 20/06/15 07:55, Leon Romanovsky wrote:
> On Fri, Jun 19, 2015 at 5:58 PM, Vladimir Murzin
> <vladimir.murzin@arm.com> wrote:
>> Since simple_strtoul is obsolete and memtest_pattern is type of int, use
>> kstrtouint instead.
>>
>> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
>> ---
>>  mm/memtest.c |   14 +++++++++-----
>>  1 file changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memtest.c b/mm/memtest.c
>> index 1997d93..895a43c 100644
>> --- a/mm/memtest.c
>> +++ b/mm/memtest.c
>> @@ -88,14 +88,18 @@ static void __init do_one_pass(u64 pattern, phys_add=
r_t start, phys_addr_t end)
>>  }
>>
>>  /* default is disabled */
>> -static int memtest_pattern __initdata;
>> +static unsigned int memtest_pattern __initdata;
>>
>>  static int __init parse_memtest(char *arg)
>>  {
>> -       if (arg)
>> -               memtest_pattern =3D simple_strtoul(arg, NULL, 0);
>> -       else
>> -               memtest_pattern =3D ARRAY_SIZE(patterns);
>> +       if (arg) {
>> +               int err =3D kstrtouint(arg, 0, &memtest_pattern);
>> +
>> +               if (!err)
>> +                       return 0;
> kstrtouint returns 0 for success, in case of error you will fallback
> and execute following line. It is definetely change of behaviour.

I'd be glad if you can elaborate more on use cases dependent on this
change? I can only imagine providing garbage to the memtest option with
only intention to shut it up... but it looks like the interface abuse
since "memtest=3D0" does exactly the same.

Since memtest is debugging option and numeric parameter is optional I
thought it was not harmful to fallback to default in case something is
wrong with the parameter.

Thanks
Vladimir

>> +       }
>> +
>> +       memtest_pattern =3D ARRAY_SIZE(patterns);
>>
>>         return 0;
>>  }
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
