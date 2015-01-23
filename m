Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6414A6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:48:28 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id w8so6054917qac.13
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:48:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 68si2261432qgg.9.2015.01.23.06.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 06:48:27 -0800 (PST)
Message-ID: <54C25F25.9070609@redhat.com>
Date: Fri, 23 Jan 2015 15:48:05 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
References: <1421992707-32658-1-git-send-email-minchan@kernel.org> <20150123142435.GA2320@swordfish>
In-Reply-To: <20150123142435.GA2320@swordfish>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="331CEqU88CCo9Lp25IXqvcPqm50GPDixK"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--331CEqU88CCo9Lp25IXqvcPqm50GPDixK
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 01/23/2015 03:24 PM, Sergey Senozhatsky wrote:
> On (01/23/15 14:58), Minchan Kim wrote:
>> We don't need to call zram_meta_free, zcomp_destroy and zs_free
>> under init_lock. What we need to prevent race with init_lock
>> in reset is setting NULL into zram->meta (ie, init_done).
>> This patch does it.
>>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  drivers/block/zram/zram_drv.c | 28 ++++++++++++++++------------
>>  1 file changed, 16 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_d=
rv.c
>> index 9250b3f54a8f..0299d82275e7 100644
>> --- a/drivers/block/zram/zram_drv.c
>> +++ b/drivers/block/zram/zram_drv.c
>> @@ -708,6 +708,7 @@ static void zram_reset_device(struct zram *zram, b=
ool reset_capacity)
>>  {
>>  	size_t index;
>>  	struct zram_meta *meta;
>> +	struct zcomp *comp;
>> =20
>>  	down_write(&zram->init_lock);
>> =20
>> @@ -719,20 +720,10 @@ static void zram_reset_device(struct zram *zram,=
 bool reset_capacity)
>>  	}
>> =20
>>  	meta =3D zram->meta;
>> -	/* Free all pages that are still in this zram device */
>> -	for (index =3D 0; index < zram->disksize >> PAGE_SHIFT; index++) {
>> -		unsigned long handle =3D meta->table[index].handle;
>> -		if (!handle)
>> -			continue;
>> -
>> -		zs_free(meta->mem_pool, handle);
>> -	}
>> -
>> -	zcomp_destroy(zram->comp);
>=20
> I'm not so sure about moving zcomp destruction. if we would have detach=
ed it
> from zram, then yes. otherwise, think of zram ->destoy vs ->init race.
>=20
> suppose,
> CPU1 waits for down_write() init lock in disksize_store() with new comp=
 already allocated;
> CPU0 detaches ->meta and releases write init lock;
> CPU1 grabs the lock and does zram->comp =3D comp;
> CPU0 reaches the point of zcomp_destroy(zram->comp);

I don't see your point: this patch does not call
zcomp_destroy(zram->comp) anymore, but zram_destroy(comp), where comp is
the old zram->comp.

>=20
>=20
> I'd probably prefer to keep zcomp destruction on its current place. I
> see a little real value in introducing zcomp detaching and moving
> destruction out of init_lock.
>=20
> 	-ss
>=20
>> +	comp =3D zram->comp;
>> +	zram->meta =3D NULL;
>>  	zram->max_comp_streams =3D 1;
>> =20
>> -	zram_meta_free(zram->meta);
>> -	zram->meta =3D NULL;
>>  	/* Reset stats */
>>  	memset(&zram->stats, 0, sizeof(zram->stats));
>> =20
>> @@ -742,6 +733,19 @@ static void zram_reset_device(struct zram *zram, =
bool reset_capacity)
>> =20
>>  	up_write(&zram->init_lock);
>> =20
>> +	/* Free all pages that are still in this zram device */
>> +	for (index =3D 0; index < zram->disksize >> PAGE_SHIFT; index++) {
>> +		unsigned long handle =3D meta->table[index].handle;
>> +
>> +		if (!handle)
>> +			continue;
>> +
>> +		zs_free(meta->mem_pool, handle);
>> +	}
>> +
>> +	zcomp_destroy(comp);
>> +	zram_meta_free(meta);
>> +
>>  	/*
>>  	 * Revalidate disk out of the init_lock to avoid lockdep splat.
>>  	 * It's okay because disk's capacity is protected by init_lock
>> --=20
>> 1.9.1
>>



--331CEqU88CCo9Lp25IXqvcPqm50GPDixK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUwl8lAAoJEHTzHJCtsuoCKuUIALmejiu1FV2BV1bcy9S+V8KD
W6FQJPzWcjQ2Gkt90550uvPdlYOlUJZ82RS9JbJZx8vWJq2jq8GvU+acr9avF7eN
+HFkIpq7kY/bJ3eJwgg98Bo5TTICXR+hOxwuD4yu5NS6OveoXyrVZBqsS8JFZDed
LLsr29/EvpYGHaZ/yB9UpFRJ7YcOG0OjCoinOg6KaqCyoFHtcSmtt9HcHPtBEruq
1dUyDhhWuO2urRUyiIsjYjLnt+tuoZ8SA7V+/YS3jw6ZdG3XxKWMWV3eDT+g7Kde
vg2EUuR23N/vZ9I4JqshxW+h2s86Rrxa+pbTtwdVDwFKkFs0+O2jBPMk/3ccWsQ=
=bDSs
-----END PGP SIGNATURE-----

--331CEqU88CCo9Lp25IXqvcPqm50GPDixK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
