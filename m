Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D6BE46B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 04:20:10 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m22so41870455pgc.4
        for <linux-mm@kvack.org>; Mon, 01 May 2017 01:20:10 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id t128si13666844pgt.337.2017.05.01.01.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 01:20:10 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id t7so15177934pgt.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 01:20:09 -0700 (PDT)
Date: Mon, 1 May 2017 16:20:05 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/3] mm/slub: wrap cpu_slab->partial in
 CONFIG_SLUB_CPU_PARTIAL
Message-ID: <20170501082005.GA2006@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
 <20170430113152.6590-3-richard.weiyang@gmail.com>
 <20170501024103.GI27790@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Content-Disposition: inline
In-Reply-To: <20170501024103.GI27790@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--YiEDa0DAkWCtVeE4
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
>The right way to do this is to create an accessor like this:
>
>#ifdef CONFIG_SLUB_CPU_PARTIAL
>#define slub_cpu_partial(c)	((c)->partial)
>#else
>#define slub_cpu_partial(c)	0
>#endif
>
>And then the above becomes:
>
>-	return c->page || c->partial;
>+	return c->page || slub_cpu_partial(c);
>
>All the other ifdefs go away, apart from these two:
>

Matthew

I have tried to replace the code with slub_cpu_partial(), it works fine on
most of cases except two:

1. slub_cpu_partial(c) =3D page->next;
2. page =3D READ_ONCE(slub_cpu_partial(c));

The sysfs part works fine.

So if you agree, I would leave these two parts as v1.

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

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZBu+1AAoJEKcLNpZP5cTdARgP/3yIOm75HKhOAmacWnOwbdnV
G3fDPx/kpG9P8xhdSfhO3MB3qdzB9Q5n/M/YYdamLmTBPJ4/mWf6tBzVn120PyJ1
xQpGBziWIFm6EdMb4sEfnf2Ey9B7RZYkou1yHYW61ZlEitJk/Avp90ILPB+b4Iog
K6gVOLiMTUBkWNRnb7M8krfzPbuQsAXn/rVW1dIBLP5qth2HTKX1yMd6XXvFKVNT
tGySp9e/a5686hMcK1/MPCZINugAUZjjZIQ0eBgKbLCTmOwQ/HAxnyFqsQdFKmz9
N82uLRckqru7X6+k/zC/gSFptpeMsDt5aoUX+U8QHQjwUuybHTC1ARGALJny0S74
4hBwp1aohylm1jaFhUD1efDkDRBbZuB96P3lB+WQz1ZOrmTSl6PJ+POUB0LgXIQR
ix6h+aoBrmp/6wP7w58k9j8zPl5Kc3qD+zBWMAsW/hrCL9m0g4ABdvYTahP01Pw7
oszeaV7DHTDhW5EarMi1JEL1wfDI4741DUKdd5Vh5jWPHEBV+2C+fMgwD1AvRhEO
6GhN00HV569FET5F5Js/Rg25+4Uu7WlcyG3F0I3KhGpSmJcn5YbV1JYdE+Y7oqcy
Y/UyV7Mw3yRA9yAnFvjBM2c5JHVe2icp8Lkn+7e1GjbYOvCAnQJuf4UnGOmqd+Ag
PCLp2SEwibxzyhVJp5Ok
=ZUxy
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
