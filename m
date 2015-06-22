Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE836B006C
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:46:31 -0400 (EDT)
Received: by qcbcf1 with SMTP id cf1so22901305qcb.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:46:31 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTP id 74si18454602qgp.63.2015.06.22.01.46.29
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 01:46:30 -0700 (PDT)
Message-ID: <5587CB62.4030105@arm.com>
Date: Mon, 22 Jun 2015 09:46:26 +0100
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] memtest: cleanup log messages
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com> <1434725914-14300-3-git-send-email-vladimir.murzin@arm.com> <CALq1K=KU5+s+u-py2oAh9U9iu3Z3yx9CbVNS8xNjpSd7o7639g@mail.gmail.com>
In-Reply-To: <CALq1K=KU5+s+u-py2oAh9U9iu3Z3yx9CbVNS8xNjpSd7o7639g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 20/06/15 07:59, Leon Romanovsky wrote:
> On Fri, Jun 19, 2015 at 5:58 PM, Vladimir Murzin
> <vladimir.murzin@arm.com> wrote:
>> - prefer pr_info(...  to printk(KERN_INFO ...
>> - use %pa for phys_addr_t
>> - use cpu_to_be64 while printing pattern in reserve_bad_mem()
>>
>> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
>> ---
>>  mm/memtest.c |   14 +++++---------
>>  1 file changed, 5 insertions(+), 9 deletions(-)
>>
>> diff --git a/mm/memtest.c b/mm/memtest.c
>> index 895a43c..ccaed3e 100644
>> --- a/mm/memtest.c
>> +++ b/mm/memtest.c
>> @@ -31,10 +31,8 @@ static u64 patterns[] __initdata =3D {
>>
>>  static void __init reserve_bad_mem(u64 pattern, phys_addr_t start_bad, =
phys_addr_t end_bad)
>>  {
>> -       printk(KERN_INFO "  %016llx bad mem addr %010llx - %010llx reser=
ved\n",
>> -              (unsigned long long) pattern,
>> -              (unsigned long long) start_bad,
>> -              (unsigned long long) end_bad);
>> +       pr_info("%016llx bad mem addr %pa - %pa reserved\n",
>> +               cpu_to_be64(pattern), &start_bad, &end_bad);
>>         memblock_reserve(start_bad, end_bad - start_bad);
>>  }
>>
>> @@ -78,10 +76,8 @@ static void __init do_one_pass(u64 pattern, phys_addr=
_t start, phys_addr_t end)
>>                 this_start =3D clamp(this_start, start, end);
>>                 this_end =3D clamp(this_end, start, end);
>>                 if (this_start < this_end) {
>> -                       printk(KERN_INFO "  %010llx - %010llx pattern %0=
16llx\n",
>> -                              (unsigned long long)this_start,
>> -                              (unsigned long long)this_end,
>> -                              (unsigned long long)cpu_to_be64(pattern))=
;
>> +                       pr_info("  %pa - %pa pattern %016llx\n",
> s/(" %pa/("%pa

I don't think so since these messages belong to the "early_memtest:" and
this whitespace highlights where these logs come from.

Thanks
Vladimir

>> +                               &this_start, &this_end, cpu_to_be64(patt=
ern));
>>                         memtest(pattern, this_start, this_end - this_sta=
rt);
>>                 }
>>         }
>> @@ -114,7 +110,7 @@ void __init early_memtest(phys_addr_t start, phys_ad=
dr_t end)
>>         if (!memtest_pattern)
>>                 return;
>>
>> -       printk(KERN_INFO "early_memtest: # of tests: %d\n", memtest_patt=
ern);
>> +       pr_info("early_memtest: # of tests: %u\n", memtest_pattern);
>>         for (i =3D memtest_pattern-1; i < UINT_MAX; --i) {
>>                 idx =3D i % ARRAY_SIZE(patterns);
>>                 do_one_pass(patterns[idx], start, end);
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
