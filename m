Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4946B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:02:11 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g187-v6so5095602ita.7
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:02:11 -0700 (PDT)
Received: from us.icdsoft.com (us.icdsoft.com. [192.252.146.184])
        by mx.google.com with ESMTPS id j129-v6si707261iof.202.2018.08.07.04.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 04:02:09 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
From: Georgi Nikolov <gnikolov@icdsoft.com>
References: <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
 <85c86f17-6f96-6f01-2a3c-e2bad0ccb317@icdsoft.com>
Message-ID: <5b5e872e-5785-2cfd-7d53-e19e017e5636@icdsoft.com>
Date: Tue, 7 Aug 2018 14:02:00 +0300
MIME-Version: 1.0
In-Reply-To: <85c86f17-6f96-6f01-2a3c-e2bad0ccb317@icdsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Florian Westphal <fw@strlen.de>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 08/06/2018 11:42 AM, Georgi Nikolov wrote:
> On 08/02/2018 11:50 AM, Michal Hocko wrote:
>> In other words, why don't we simply do the following? Note that this i=
s
>> not tested. I have also no idea what is the lifetime of this allocatio=
n.
>> Is it bound to any specific process or is it a namespace bound? If the=

>> later then the memcg OOM killer might wipe the whole memcg down withou=
t
>> making any progress. This would make the whole namespace unsuable unti=
l
>> somebody intervenes. Is this acceptable?
>> ---
>> From 4dec96eb64954a7e58264ed551afadf62ca4c5f7 Mon Sep 17 00:00:00 2001=

>> From: Michal Hocko <mhocko@suse.com>
>> Date: Thu, 2 Aug 2018 10:38:57 +0200
>> Subject: [PATCH] netfilter/x_tables: do not fail xt_alloc_table_info t=
oo
>>  easilly
>>
>> eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc()
>> in xt_alloc_table_info()") has unintentionally fortified
>> xt_alloc_table_info allocation when __GFP_RETRY has been dropped from
>> the vmalloc fallback. Later on there was a syzbot report that this
>> can lead to OOM killer invocations when tables are too large and
>> 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
>> has been merged to restore the original behavior. Georgi Nikolov howev=
er
>> noticed that he is not able to install his iptables anymore so this ca=
n
>> be seen as a regression.
>>
>> The primary argument for 0537250fdc6c was that this allocation path
>> shouldn't really trigger the OOM killer and kill innocent tasks. On th=
e
>> other hand the interface requires root and as such should allow what t=
he
>> admin asks for. Root inside a namespaces makes this more complicated
>> because those might be not trusted in general. If they are not then su=
ch
>> namespaces should be restricted anyway. Therefore drop the __GFP_NORET=
RY
>> and replace it by __GFP_ACCOUNT to enfore memcg constrains on it.
>>
>> Fixes: 0537250fdc6c ("netfilter: x_tables: make allocation less aggres=
sive")
>> Reported-by: Georgi Nikolov <gnikolov@icdsoft.com>
>> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
>>  net/netfilter/x_tables.c | 7 +------
>>  1 file changed, 1 insertion(+), 6 deletions(-)
>>
>> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
>> index d0d8397c9588..b769408e04ab 100644
>> --- a/net/netfilter/x_tables.c
>> +++ b/net/netfilter/x_tables.c
>> @@ -1178,12 +1178,7 @@ struct xt_table_info *xt_alloc_table_info(unsig=
ned int size)
>>  	if (sz < sizeof(*info) || sz >=3D XT_MAX_TABLE_SIZE)
>>  		return NULL;
>> =20
>> -	/* __GFP_NORETRY is not fully supported by kvmalloc but it should
>> -	 * work reasonably well if sz is too large and bail out rather
>> -	 * than shoot all processes down before realizing there is nothing
>> -	 * more to reclaim.
>> -	 */
>> -	info =3D kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
>> +	info =3D kvmalloc(sz, GFP_KERNEL | __GFP_ACCOUNT);
>>  	if (!info)
>>  		return NULL;
>> =20
> I will check if this change fixes the problem.
>
> Regards,
>
> --
> Georgi Nikolov

I can't reproduce it anymore.
If i understand correctly this way memory allocated will be
accounted to kmem of this cgroup (if inside cgroup).
