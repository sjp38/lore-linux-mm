Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C3B766B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 02:55:19 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1218470qwa.14
        for <linux-mm@kvack.org>; Wed, 03 Aug 2011 23:55:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLGRmR1RNEOrTjtU_y+6mPF0S+Lh5uZyyoKGZ1w0DLEYqQ@mail.gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-2-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-3-git-send-email-lliubbo@gmail.com>
	<CAOJsxLGRmR1RNEOrTjtU_y+6mPF0S+Lh5uZyyoKGZ1w0DLEYqQ@mail.gmail.com>
Date: Thu, 4 Aug 2011 14:55:17 +0800
Message-ID: <CAA_GA1cLg6jwidoYKmxd9rTO8H2WYPzeKjVx6X5brpRizPU80Q@mail.gmail.com>
Subject: Re: [PATCH 3/4] sparse: using kzalloc to clean up code
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com, yinghai@kernel.org, hpa@zytor.com

On Thu, Aug 4, 2011 at 2:10 PM, Pekka Enberg <penberg@kernel.org> wrote:
> On Thu, Aug 4, 2011 at 6:09 AM, Bob Liu <lliubbo@gmail.com> wrote:
>> This patch using kzalloc to clean up sparse_index_alloc() and
>> __GFP_ZERO to clean up __kmalloc_section_memmap().
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0mm/sparse.c | =C2=A0 24 +++++++-----------------
>> =C2=A01 files changed, 7 insertions(+), 17 deletions(-)
>>
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 858e1df..9596635 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -65,15 +65,12 @@ static struct mem_section noinline __init_refok *spa=
rse_index_alloc(int nid)
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (slab_is_available()) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (node_state(ni=
d, N_HIGH_MEMORY))
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 section =3D kmalloc_node(array_size, GFP_KERNEL, nid);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 section =3D kzalloc_node(array_size, GFP_KERNEL, nid);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 section =3D kmalloc(array_size, GFP_KERNEL);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 section =3D kzalloc(array_size, GFP_KERNEL);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0section =3D alloc=
_bootmem_node(NODE_DATA(nid), array_size);
>>
>> - =C2=A0 =C2=A0 =C2=A0 if (section)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(section, 0, ar=
ray_size);
>> -
>
> You now broke the alloc_bootmem_node() path.
>

Yes.
But In my opinion, the alloc_bootmem_node() will also return zeroed memory.
I saw it has used kzalloc or memset() but i'm not pretty sure.
CC'd yinghai@kernel.org,hpa@zytor.com

Thanks for your review.

>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return section;
>> =C2=A0}
>>
>> @@ -636,19 +633,12 @@ static struct page *__kmalloc_section_memmap(unsig=
ned long nr_pages)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page, *ret;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long memmap_size =3D sizeof(struct p=
age) * nr_pages;
>>
>> - =C2=A0 =C2=A0 =C2=A0 page =3D alloc_pages(GFP_KERNEL|__GFP_NOWARN, get=
_order(memmap_size));
>> + =C2=A0 =C2=A0 =C2=A0 page =3D alloc_pages(GFP_KERNEL|__GFP_NOWARN|__GF=
P_ZERO,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 get_order(me=
mmap_size));
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto got_map_page;
>> -
>> - =C2=A0 =C2=A0 =C2=A0 ret =3D vmalloc(memmap_size);
>> - =C2=A0 =C2=A0 =C2=A0 if (ret)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto got_map_ptr;
>> -
>> - =C2=A0 =C2=A0 =C2=A0 return NULL;
>> -got_map_page:
>> - =C2=A0 =C2=A0 =C2=A0 ret =3D (struct page *)pfn_to_kaddr(page_to_pfn(p=
age));
>> -got_map_ptr:
>> - =C2=A0 =C2=A0 =C2=A0 memset(ret, 0, memmap_size);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D (struct page =
*)pfn_to_kaddr(page_to_pfn(page));
>> + =C2=A0 =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D vzalloc(memma=
p_size);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>> =C2=A0}
>> --
>> 1.6.3.3
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemete=
r.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
