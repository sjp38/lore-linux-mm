Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1846E6B00C9
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 22:52:45 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oA93qgrk024605
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 19:52:42 -0800
Received: from gya6 (gya6.prod.google.com [10.243.49.6])
	by wpaz21.hot.corp.google.com with ESMTP id oA93qfjH019551
	for <linux-mm@kvack.org>; Mon, 8 Nov 2010 19:52:41 -0800
Received: by gya6 with SMTP id 6so4120245gya.13
        for <linux-mm@kvack.org>; Mon, 08 Nov 2010 19:52:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101109124426.312f9979.nishimura@mxp.nes.nec.co.jp>
References: <1289265320-7025-1-git-send-email-gthelen@google.com> <20101109124426.312f9979.nishimura@mxp.nes.nec.co.jp>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 8 Nov 2010 19:52:20 -0800
Message-ID: <AANLkTi=7sKC_911w7NPtsX_uQ20EapC3QjMrU9Y5iA8N@mail.gmail.com>
Subject: Re: [PATCH] memcg: avoid overflow in memcg_hierarchical_free_pages()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 8, 2010 at 7:44 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> On Mon, =A08 Nov 2010 17:15:20 -0800
> Greg Thelen <gthelen@google.com> wrote:
>
>> Use page counts rather than byte counts to avoid overflowing
>> unsigned long local variables.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> ---
>> =A0mm/memcontrol.c | =A0 10 +++++-----
>> =A01 files changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 6c7115d..b287afd 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1345,17 +1345,17 @@ memcg_hierarchical_free_pages(struct mem_cgroup =
*mem)
>> =A0{
>> =A0 =A0 =A0 unsigned long free, min_free;
>>
> hmm, the default value of RES_LIMIT is LLONG_MAX, so I think we must decl=
are
> "free" as unsinged long long to avoid overflow.

Agreed.  I am testing a fix for that issue now.  I do not want
complicate this patch with the RES_LIMIT issue you mention.  The fix
will be in a separate patch.

> Thanks,
> Daisuke Nishimura.
>
>> - =A0 =A0 min_free =3D global_page_state(NR_FREE_PAGES) << PAGE_SHIFT;
>> + =A0 =A0 min_free =3D global_page_state(NR_FREE_PAGES);
>>
>> =A0 =A0 =A0 while (mem) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 free =3D res_counter_read_u64(&mem->res, RES_L=
IMIT) -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_read_u64(&mem->res=
, RES_USAGE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 free =3D (res_counter_read_u64(&mem->res, RES_=
LIMIT) -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_read_u64(&mem->res=
, RES_USAGE)) >>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PAGE_SHIFT;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 min_free =3D min(min_free, free);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D parent_mem_cgroup(mem);
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 /* Translate free memory in pages */
>> - =A0 =A0 return min_free >> PAGE_SHIFT;
>> + =A0 =A0 return min_free;
>> =A0}
>>
>> =A0/*
>> --
>> 1.7.3.1
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
