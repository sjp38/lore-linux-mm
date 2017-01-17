Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D71656B0253
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:33:21 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id t56so119755032qte.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:33:21 -0800 (PST)
Received: from sender163-mail.zoho.com (sender163-mail.zoho.com. [74.201.84.163])
        by mx.google.com with ESMTPS id k71si15639565qkl.47.2017.01.16.19.33.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 19:33:21 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] slab: add a check for the first kmem_cache not to be destroyed
From: kwon <kwon@toanyone.net>
In-Reply-To: <20170117013300.GA25940@js1304-P5Q-DELUXE>
Date: Tue, 17 Jan 2017 12:32:58 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <764E463A-F743-4BE6-8BFC-07D50FF57DDA@toanyone.net>
References: <20170116070459.43540-1-kwon@toanyone.net> <20170117013300.GA25940@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Jan 17, 2017, at 10:33 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> =
wrote:
>=20
> On Mon, Jan 16, 2017 at 04:04:59PM +0900, Kyunghwan Kwon wrote:
>> The first kmem_cache created at booting up is supposed neither =
mergeable
>> nor destroyable but was possible to destroy. So prevent it.
>>=20
>> Signed-off-by: Kyunghwan Kwon <kwon@toanyone.net>
>> ---
>> mm/slab_common.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 1dfc209..2d30ace 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -744,7 +744,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
>> 	bool need_rcu_barrier =3D false;
>> 	int err;
>>=20
>> -	if (unlikely(!s))
>> +	if (unlikely(!s) || s->refcount =3D=3D -1)
>> 		return;
>=20
> Hello, Kyunghwan.
>=20
> Few lines below, s->refcount is checked.
>=20
> if (s->refcount)
>        goto unlock;
>=20
> Am I missing something?
>=20
> Thanks.

Hello, Joonsoo.

In case it is called the number of int size times. refcount would =
finally reach
to 0 since decreased every time the function called.

When refcount is -1, the count will not change in the patch so no lock =
would be
need to be taken prior, I believe.

Thanks.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
