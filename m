Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF2F6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 03:39:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t23so68523200pfe.17
        for <linux-mm@kvack.org>; Mon, 01 May 2017 00:39:43 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id y18si13887994pgc.282.2017.05.01.00.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 00:39:42 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id s62so3412839pgc.0
        for <linux-mm@kvack.org>; Mon, 01 May 2017 00:39:42 -0700 (PDT)
Date: Mon, 1 May 2017 15:39:38 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/3] mm/slub: wrap cpu_slab->partial in
 CONFIG_SLUB_CPU_PARTIAL
Message-ID: <20170501073938.GA868@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
 <20170430113152.6590-3-richard.weiyang@gmail.com>
 <20170501024103.GI27790@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
In-Reply-To: <20170501024103.GI27790@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Apr 30, 2017 at 07:41:03PM -0700, Matthew Wilcox wrote:
>On Sun, Apr 30, 2017 at 07:31:51PM +0800, Wei Yang wrote:
>> @@ -2302,7 +2302,11 @@ static bool has_cpu_slab(int cpu, void *info)
>>  	struct kmem_cache *s =3D info;
>>  	struct kmem_cache_cpu *c =3D per_cpu_ptr(s->cpu_slab, cpu);
>> =20
>> -	return c->page || c->partial;
>> +	return c->page
>> +#ifdef CONFIG_SLUB_CPU_PARTIAL
>> +		|| c->partial
>> +#endif
>> +		;
>>  }
>
>No.  No way.  This is disgusting.
>

Thanks for your comment. I believe you are right.

>The right way to do this is to create an accessor like this:
>
>#ifdef CONFIG_SLUB_CPU_PARTIAL
>#define slub_cpu_partial(c)	((c)->partial)
>#else
>#define slub_cpu_partial(c)	0

Since partial is a pointer to a page, would this be more proper?

#define slub_cpu_partial(c)	NULL

>#endif
>
>And then the above becomes:
>
>-	return c->page || c->partial;
>+	return c->page || slub_cpu_partial(c);
>
>All the other ifdefs go away, apart from these two:

Looks most of the ifdefs could be replaced by this format, while not all of
them. For example, the sysfs entry.

I would form another version with your suggestion.

Welcome any other comments :-)

>
>> @@ -4980,6 +4990,7 @@ static ssize_t objects_partial_show(struct kmem_ca=
che *s, char *buf)
>>  }
>>  SLAB_ATTR_RO(objects_partial);
>> =20
>> +#ifdef CONFIG_SLUB_CPU_PARTIAL
>>  static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
>>  {
>>  	int objects =3D 0;
>> @@ -5010,6 +5021,7 @@ static ssize_t slabs_cpu_partial_show(struct kmem_=
cache *s, char *buf)
>>  	return len + sprintf(buf + len, "\n");
>>  }
>>  SLAB_ATTR_RO(slabs_cpu_partial);
>> +#endif
>> =20
>>  static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
>>  {
>> @@ -5364,7 +5376,9 @@ static struct attribute *slab_attrs[] =3D {
>>  	&destroy_by_rcu_attr.attr,
>>  	&shrink_attr.attr,
>>  	&reserved_attr.attr,
>> +#ifdef CONFIG_SLUB_CPU_PARTIAL
>>  	&slabs_cpu_partial_attr.attr,
>> +#endif
>>  #ifdef CONFIG_SLUB_DEBUG
>>  	&total_objects_attr.attr,
>>  	&slabs_attr.attr,

--=20
Wei Yang
Help you, Help me

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZBuY6AAoJEKcLNpZP5cTdGxoP/2P9QPYKFGUuZYc7bbYTdifU
wGHnruOdo0Jf3DTsTSzRoZNXnqvkqOrZjyJV7nadasj43SB0OkW1YYmUI/XaDNEi
WW0/AR6vY6GTmzP+BUL5RkYFgxEXUX77yozNUyYJomQiJ8LAW9id0xqC/LcKoXba
G5PpnPWpXJPscYcrK6F81XwuBVmv93tXMtkzVm+22ZmzDjH8pCjPx6aDxhi9KCKv
2aOgDyIcF301wsPMJvXHZbUzwAYV4IKZx7fgIpJ+REA6b1hS+ob2PS90HbpgEdpg
r/6U2Pw9gdwnbpReCVvI15GoTR6GTqqYtFkG5JWSw33i0ENdwHsqsISAIRyhvN+B
UOTuFaY2tYBErDzDvIc/73bRmy7kqe4MibLixYp+aAx9ferPLuWzdQnuksJBFDuR
t7o9P2ZZ7iZmmf376ZJ3qBj5HQQrIXk061l1fR/2MRfBllbK/I7aWQ3fLVsmgX7k
eD8BzkVcw0yFZPg0Sv8LTdPmDHKPAYP1kMm3o9tKXWp5zVkwvKj/CG8rWx/jr6AD
2hru9BlpkE8s32H0g7s2K+yut+buMOCn0BBjy7ijC16F6sA7I/QVbQY/+XpHMVQ4
pN8ZAH0KqqtPv1S4M6nq35gxiKrRIUfJyLdfqXFfNfVpgL66sL5WuPavW72BkViG
0oIi///5/oLD9VQkVOhZ
=CGj0
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
