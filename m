Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 5F3CC6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:35:26 -0400 (EDT)
References: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com> <1348728470-5580-3-git-send-email-laijs@cn.fujitsu.com> <5064CD7F.1040507@gmail.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <5064CD7F.1040507@gmail.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <0000013a09dec004-497e7afa-8c0f-46ff-bf8e-056f7df1ed0b-000000@email.amazonses.com>
From: Christoph <cl@linux.com>
Subject: Re: [PATCH 2/3] slub, hotplug: ignore unrelated node's hot-adding and hot-removing
Date: Thu, 27 Sep 2012 22:35:25 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@gmail.com" <kosaki.motohiro@gmail.com>

While you are at it: Could you move the code into slab_common.c so that ther=
e is only one version to maintain?

On Sep 27, 2012, at 17:04, KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote=
:

> (9/27/12 2:47 AM), Lai Jiangshan wrote:
>> SLUB only fucus on the nodes which has normal memory, so ignore the other=

>> node's hot-adding and hot-removing.
>>=20
>> Aka: if some memroy of a node(which has no onlined memory) is online,
>> but this new memory onlined is not normal memory(HIGH memory example),
>> we should not allocate kmem_cache_node for SLUB.
>>=20
>> And if the last normal memory is offlined, but the node still has memroy,=

>> we should remove kmem_cache_node for that node.(current code delay it whe=
n
>> all of the memory is offlined)
>>=20
>> so we only do something when marg->status_change_nid_normal > 0.
>> marg->status_change_nid is not suitable here.
>>=20
>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>> ---
>> mm/slub.c |    4 ++--
>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 2fdd96f..2d78639 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -3577,7 +3577,7 @@ static void slab_mem_offline_callback(void *arg)
>>    struct memory_notify *marg =3D arg;
>>    int offline_node;
>>=20
>> -    offline_node =3D marg->status_change_nid;
>> +    offline_node =3D marg->status_change_nid_normal;
>>=20
>>    /*
>>     * If the node still has available memory. we need kmem_cache_node
>> @@ -3610,7 +3610,7 @@ static int slab_mem_going_online_callback(void *arg=
)
>>    struct kmem_cache_node *n;
>>    struct kmem_cache *s;
>>    struct memory_notify *marg =3D arg;
>> -    int nid =3D marg->status_change_nid;
>> +    int nid =3D marg->status_change_nid_normal;
>>    int ret =3D 0;
>=20
> Looks reasonable. I think slab need similar fix too.
>=20
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
