Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D343F6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:43:40 -0400 (EDT)
Received: by pvg11 with SMTP id 11so2904813pvg.14
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 20:43:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x2y28c262361004112038p8699872ay700ebf967cd11907@mail.gmail.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	 <1270900173-10695-2-git-send-email-lliubbo@gmail.com>
	 <x2y28c262361004112038p8699872ay700ebf967cd11907@mail.gmail.com>
Date: Mon, 12 Apr 2010 11:43:38 +0800
Message-ID: <n2gcf18f8341004112043j37bea8echd539b894a4a0dab@mail.gmail.com>
Subject: Re: [PATCH] add alloc_pages_exact_node()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 11:38 AM, Minchan Kim <minchan.kim@gmail.com> wrote=
:
> Hi, Bob.
>
> On Sat, Apr 10, 2010 at 8:49 PM, Bob Liu <lliubbo@gmail.com> wrote:
>> Add alloc_pages_exact_node() to allocate pages from exact
>> node.
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0arch/powerpc/platforms/cell/ras.c | =C2=A0 =C2=A04 ++--
>> =C2=A0include/linux/gfp.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | =C2=A0 =C2=A07 +++++++
>> =C2=A0mm/mempolicy.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
>> =C2=A0mm/migrate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A03 +--
>> =C2=A04 files changed, 11 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/=
cell/ras.c
>> index 6d32594..93a5afd 100644
>> --- a/arch/powerpc/platforms/cell/ras.c
>> +++ b/arch/powerpc/platforms/cell/ras.c
>> @@ -123,8 +123,8 @@ static int __init cbe_ptcal_enable_on_node(int nid, =
int order)
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0area->nid =3D nid;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0area->order =3D order;
>> - =C2=A0 =C2=A0 =C2=A0 area->pages =3D alloc_pages_from_valid_node(area-=
>nid,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 GFP_KERNEL | GFP_THISNODE, area->order);
>> + =C2=A0 =C2=A0 =C2=A0 area->pages =3D alloc_pages_exact_node(area->nid,=
 GFP_KERNEL,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 area->order);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!area->pages) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNI=
NG "%s: no page on node %d\n",
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index c94f2ed..70cf2ae 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -296,6 +296,13 @@ static inline struct page *alloc_pages_from_valid_n=
ode(int nid, gfp_t gfp_mask,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return __alloc_pages(gfp_mask, order, node_zo=
nelist(nid, gfp_mask));
>> =C2=A0}
>>
>> +static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_ma=
sk,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned int order)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 return alloc_pages_from_valid_node(nid, gfp_mask =
| GFP_THISNODE,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 order);
>> +}
>> +
>> =C2=A0#ifdef CONFIG_NUMA
>> =C2=A0extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned o=
rder);
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 6838cd8..08f40a2 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -842,7 +842,7 @@ static void migrate_page_add(struct page *page, stru=
ct list_head *pagelist,
>>
>> =C2=A0static struct page *new_node_page(struct page *page, unsigned long=
 node, int **x)
>> =C2=A0{
>> - =C2=A0 =C2=A0 =C2=A0 return alloc_pages_from_valid_node(node, GFP_HIGH=
USER_MOVABLE, 0);
>> + =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_node(node, GFP_HIGHUSER_=
MOVABLE, 0);
>> =C2=A0}
>
> It's behavior change. Please, write down why you want to change
> behavior in log.
> Although I knew it, you need to explain it for others and git log,
>
Hm, ok.
I will add the log later. Thank you for your suggestion.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
