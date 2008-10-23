Message-ID: <4900B0EF.2000108@cosmosbay.com>
Date: Thu, 23 Oct 2008 19:14:23 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop>  <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>  <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221416130.26639@quilx.com>  <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>  <1224745831.25814.21.camel@penberg-laptop>  <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810230638450.11924@quilx.com>  <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>  <Pine.LNX.4.64.0810230705210.12497@quilx.com> <84144f020810230714g7f5d36bas812ad691140ee453@mail.gmail.com> <Pine.LNX.4.64.0810230721400.12497@quilx.com> <49009575.60004@cosmosbay.com> <Pine.LNX.4.64.0810231035510.17638@quilx.com> <4900A7C8.9020707@cosmosbay.com> <Pine.LNX.4.64.0810231145430.19239@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0810231145430.19239@quilx.com>
Content-Type: multipart/mixed;
 boundary="------------010605080000090002080906"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Miklos Szeredi <miklos@szeredi.hu>, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010605080000090002080906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Christoph Lameter a =E9crit :
> On Thu, 23 Oct 2008, Eric Dumazet wrote:
>=20
>>> SLUB touches objects by default when allocating. And it does it=20
>>> immediately in slab_alloc() in order to retrieve the pointer to the=20
>>> next object. So there is no point of hinting there right now.
>>>
>>
>> Please note SLUB touches by reading object.
>>
>> prefetchw() gives a hint to cpu saying this cache line is going to be =

>> *modified*, even
>> if first access is a read. Some architectures can save some bus=20
>> transactions, acquiring
>> the cache line in an exclusive way instead of shared one.
>=20
> Most architectures actually can do that. Its probably worth to run some=
=20
> tests with that. Conversion of a cacheline from shared to exclusive can=
=20
> cost something.
>=20

Please check following patch as a followup

[PATCH] slub: slab_alloc() can use prefetchw()

Most kmalloced() areas are initialized/written right after allocation.

prefetchw() gives a hint to cpu saying this cache line is going to be
*modified*, even if first access is a read.

Some architectures can save some bus transactions, acquiring
the cache line in an exclusive way instead of shared one.

Same optimization was done in 2005 on SLAB in commit=20
34342e863c3143640c031760140d640a06c6a5f8=20
([PATCH] mm/slab.c: prefetchw the start of new allocated objects)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010605080000090002080906
Content-Type: text/plain;
 name="slub.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slub.patch"

diff --git a/mm/slub.c b/mm/slub.c
index 0c83e6a..c2017a3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1592,13 +1592,14 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
 
 	local_irq_save(flags);
 	c = get_cpu_slab(s, smp_processor_id());
+	object = c->freelist;
+	prefetchw(object);
 	objsize = c->objsize;
-	if (unlikely(!c->freelist || !node_match(c, node)))
+	if (unlikely(!object || !node_match(c, node)))
 
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-		object = c->freelist;
 		c->freelist = object[c->offset];
 		stat(c, ALLOC_FASTPATH);
 	}

--------------010605080000090002080906--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
