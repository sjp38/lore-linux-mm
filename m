Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB4B26B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 13:17:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so20194426wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 10:17:51 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id qu1si2203876lbb.35.2016.05.10.10.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 10:17:50 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id m64so22512901lfd.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 10:17:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGySgwbB8Gh_t4DJUjtA1GcpN_AEfNpNOM62GoNLiGNSEQ@mail.gmail.com>
References: <cover.1458036040.git.glider@google.com>
	<48cc05da0a19447843c6479cf1c15dbc174503a0.1458036040.git.glider@google.com>
	<CAPAsAGySgwbB8Gh_t4DJUjtA1GcpN_AEfNpNOM62GoNLiGNSEQ@mail.gmail.com>
Date: Tue, 10 May 2016 19:17:50 +0200
Message-ID: <CAG_fn=UFvCVRwQ8uPHvabAuRmGEBOXsga-yfA+bz=MtmFZBeqg@mail.gmail.com>
Subject: Re: [PATCH v8 7/7] mm: kasan: Initial memory quarantine implementation
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, May 10, 2016 at 5:39 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> w=
rote:
> 2016-03-15 13:10 GMT+03:00 Alexander Potapenko <glider@google.com>:
>
>>
>>  static inline int kasan_module_alloc(void *addr, size_t size) { return =
0; }
>>  static inline void kasan_free_shadow(const struct vm_struct *vm) {}
>> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
>> index 82169fb..799c98e 100644
>> --- a/lib/test_kasan.c
>> +++ b/lib/test_kasan.c
>> @@ -344,6 +344,32 @@ static noinline void __init kasan_stack_oob(void)
>>         *(volatile char *)p;
>>  }
>>
>> +#ifdef CONFIG_SLAB
>> +static noinline void __init kasan_quarantine_cache(void)
>> +{
>> +       struct kmem_cache *cache =3D kmem_cache_create(
>> +                       "test", 137, 8, GFP_KERNEL, NULL);
>> +       int i;
>> +
>> +       for (i =3D 0; i <  100; i++) {
>> +               void *p =3D kmem_cache_alloc(cache, GFP_KERNEL);
>> +
>> +               kmem_cache_free(cache, p);
>> +               p =3D kmalloc(sizeof(u64), GFP_KERNEL);
>> +               kfree(p);
>> +       }
>> +       kmem_cache_shrink(cache);
>> +       for (i =3D 0; i <  100; i++) {
>> +               u64 *p =3D kmem_cache_alloc(cache, GFP_KERNEL);
>> +
>> +               kmem_cache_free(cache, p);
>> +               p =3D kmalloc(sizeof(u64), GFP_KERNEL);
>> +               kfree(p);
>> +       }
>> +       kmem_cache_destroy(cache);
>> +}
>> +#endif
>> +
>
> Test looks quite useless. The kernel does allocations/frees all the
> time, so I don't think that this test
> adds something valuable.
Agreed.
> And what's the result that we expect from this test? No crashes?
> I'm thinking it would better to remove it.
Do you think it may make sense to improve it by introducing an actual
use-after-free?
Or perhaps we could insert a loop doing 1000 kmalloc()/kfree() calls
into the existing UAF tests.
> [...]
>
>> +
>> +/* smp_load_acquire() here pairs with smp_store_release() in
>> + * quarantine_reduce().
>> + */
>> +#define QUARANTINE_LOW_SIZE (smp_load_acquire(&quarantine_size) * 3 / 4=
)
>
> I'd prefer open coding barrier with a proper comment int place,
> instead of sneaking it into macros.
Ack.
> [...]
>
>> +
>> +void quarantine_reduce(void)
>> +{
>> +       size_t new_quarantine_size;
>> +       unsigned long flags;
>> +       struct qlist to_free =3D QLIST_INIT;
>> +       size_t size_to_free =3D 0;
>> +       void **last;
>> +
>> +       /* smp_load_acquire() here pairs with smp_store_release() below.=
 */
>
> Besides pairing rules, the comment should also explain *why* we need
> this and for what
> load/stores it provides memory ordering guarantees. For example take a
> look at other
> comments near barriers in the kernel tree.
Something along the lines of "We must load A before B, hence the barrier"?
>> +       if (likely(ACCESS_ONCE(global_quarantine.bytes) <=3D
>> +                  smp_load_acquire(&quarantine_size)))
>> +               return;
>> +
>>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
