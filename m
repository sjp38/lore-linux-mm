Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7476B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 09:34:37 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so10342469wiw.4
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 06:34:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id dg2si20005630wib.98.2015.01.26.06.34.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 06:34:35 -0800 (PST)
Message-ID: <54C6505E.8080905@redhat.com>
Date: Mon, 26 Jan 2015 15:34:06 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
References: <1421992707-32658-1-git-send-email-minchan@kernel.org> <20150123142435.GA2320@swordfish> <54C25F25.9070609@redhat.com> <20150123154707.GA1046@swordfish> <20150126013309.GA26895@blaptop>
In-Reply-To: <20150126013309.GA26895@blaptop>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="XhpLwq3lWssEFVnjs3q3FigIxBRSPul2e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XhpLwq3lWssEFVnjs3q3FigIxBRSPul2e
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 01/26/2015 02:33 AM, Minchan Kim wrote:
> Hello,
>=20
> On Sat, Jan 24, 2015 at 12:47:07AM +0900, Sergey Senozhatsky wrote:
>> On (01/23/15 15:48), Jerome Marchand wrote:
>>> Date: Fri, 23 Jan 2015 15:48:05 +0100
>>> From: Jerome Marchand <jmarchan@redhat.com>
>>> To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim
>>>  <minchan@kernel.org>
>>> CC: Andrew Morton <akpm@linux-foundation.org>,
>>>  linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta
>>>  <ngupta@vflare.org>
>>> Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
>>> User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101
>>>  Thunderbird/31.3.0
>>>
>>> On 01/23/2015 03:24 PM, Sergey Senozhatsky wrote:
>>>> On (01/23/15 14:58), Minchan Kim wrote:
>>>>> We don't need to call zram_meta_free, zcomp_destroy and zs_free
>>>>> under init_lock. What we need to prevent race with init_lock
>>>>> in reset is setting NULL into zram->meta (ie, init_done).
>>>>> This patch does it.
>>>>>
>>>>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>>>>> ---
>>>>>  drivers/block/zram/zram_drv.c | 28 ++++++++++++++++------------
>>>>>  1 file changed, 16 insertions(+), 12 deletions(-)
>>>>>
>>>>> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zra=
m_drv.c
>>>>> index 9250b3f54a8f..0299d82275e7 100644
>>>>> --- a/drivers/block/zram/zram_drv.c
>>>>> +++ b/drivers/block/zram/zram_drv.c
>>>>> @@ -708,6 +708,7 @@ static void zram_reset_device(struct zram *zram=
, bool reset_capacity)
>>>>>  {
>>>>>  	size_t index;
>>>>>  	struct zram_meta *meta;
>>>>> +	struct zcomp *comp;
>>>>> =20
>>>>>  	down_write(&zram->init_lock);
>>>>> =20
>>>>> @@ -719,20 +720,10 @@ static void zram_reset_device(struct zram *zr=
am, bool reset_capacity)
>>>>>  	}
>>>>> =20
>>>>>  	meta =3D zram->meta;
>>>>> -	/* Free all pages that are still in this zram device */
>>>>> -	for (index =3D 0; index < zram->disksize >> PAGE_SHIFT; index++) =
{
>>>>> -		unsigned long handle =3D meta->table[index].handle;
>>>>> -		if (!handle)
>>>>> -			continue;
>>>>> -
>>>>> -		zs_free(meta->mem_pool, handle);
>>>>> -	}
>>>>> -
>>>>> -	zcomp_destroy(zram->comp);
>>>>
>>>> I'm not so sure about moving zcomp destruction. if we would have det=
ached it
>>>> from zram, then yes. otherwise, think of zram ->destoy vs ->init rac=
e.
>>>>
>>>> suppose,
>>>> CPU1 waits for down_write() init lock in disksize_store() with new c=
omp already allocated;
>>>> CPU0 detaches ->meta and releases write init lock;
>>>> CPU1 grabs the lock and does zram->comp =3D comp;
>>>> CPU0 reaches the point of zcomp_destroy(zram->comp);
>>>
>>> I don't see your point: this patch does not call
>>> zcomp_destroy(zram->comp) anymore, but zram_destroy(comp), where comp=
 is
>>> the old zram->comp.
>>
>>
>> oh... yes. sorry! my bad.
>>
>>
>>
>> anyway, on a second thought, do we even want to destoy meta out of ini=
t_lock?
>>
>> I mean, it will let you init new device quicker. but... assume, you ha=
ve
>> 30G zram (or any other bad-enough number). on CPU0 you reset device --=
 iterate
>> over 30G meta->table, etc. out of init_lock.
>> on CPU1 you concurrently re-init device and request again 30G.
>>
>> how bad that can be?
>>
>>
>>
>> diskstore called on already initialised device is also not so perfect.=

>> we first will try to allocate ->meta (vmalloc pages for another 30G),
>> then allocate comp, then down_write() init lock to find out that devic=
e
>> is initialised and we need to release allocated memory.
>>
>>
>>
>> may be we better keep ->meta destruction under init_lock and additiona=
lly
>> move ->meta and ->comp allocation under init_lock in disksize_store()?=

>>
>> like the following one:
>>
>> ---
>>
>>  drivers/block/zram/zram_drv.c | 25 +++++++++++++------------
>>  1 file changed, 13 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_d=
rv.c
>> index 9250b3f..827ab21 100644
>> --- a/drivers/block/zram/zram_drv.c
>> +++ b/drivers/block/zram/zram_drv.c
>> @@ -765,9 +765,18 @@ static ssize_t disksize_store(struct device *dev,=

>>  		return -EINVAL;
>> =20
>>  	disksize =3D PAGE_ALIGN(disksize);
>> +	down_write(&zram->init_lock);
>> +	if (init_done(zram)) {
>> +		up_write(&zram->init_lock);
>> +		pr_info("Cannot change disksize for initialized device\n");
>> +		return -EBUSY;
>> +	}
>> +
>>  	meta =3D zram_meta_alloc(zram->disk->first_minor, disksize);
>> -	if (!meta)
>> -		return -ENOMEM;
>> +	if (!meta) {
>> +		err =3D -ENOMEM;
>> +		goto out_unlock;
>> +	}
>> =20
>>  	comp =3D zcomp_create(zram->compressor, zram->max_comp_streams);
>>  	if (IS_ERR(comp)) {
>> @@ -777,13 +786,6 @@ static ssize_t disksize_store(struct device *dev,=

>>  		goto out_free_meta;
>>  	}
>> =20
>> -	down_write(&zram->init_lock);
>> -	if (init_done(zram)) {
>> -		pr_info("Cannot change disksize for initialized device\n");
>> -		err =3D -EBUSY;
>> -		goto out_destroy_comp;
>> -	}
>> -
>>  	zram->meta =3D meta;
>>  	zram->comp =3D comp;
>>  	zram->disksize =3D disksize;
>> @@ -799,11 +801,10 @@ static ssize_t disksize_store(struct device *dev=
,
>> =20
>>  	return len;
>> =20
>> -out_destroy_comp:
>> -	up_write(&zram->init_lock);
>> -	zcomp_destroy(comp);
>>  out_free_meta:
>>  	zram_meta_free(meta);
>> +out_unlock:
>> +	up_write(&zram->init_lock);
>>  	return err;
>>  }
>> =20
>=20
> The init_lock is really troublesome. We can't do call zram_meta_alloc
> under init_lock due to lockdep report. Please keep in mind.
> The zram_rw_page is one of the function under reclaim path and hold it
> as read_lock while here holds it as write_lock.
> It's a false positive so that we might could make shut lockdep up
> by annotation but I don't want it but want to work with lockdep rather
> than disable. As well, there are other pathes to use init_lock to
> protect other data where would be victims of lockdep.
>=20
> I didn't tell the motivation of this patch because it made you busy
> guys wasted. Let me tell it now.

In my experience, reading a short explanation takes much less time that
trying to figure out why something is done the way it is. Please add
this explanation to the patch description. It might be very useful in
the future to someone "git-blaming" this code.

Jerome

> It was another lockdep report by
> kmem_cache_destroy for zsmalloc compaction about init_lock. That's why
> the patchset was one of the patch in compaction.
>=20
> Yes, the ideal is to remove horrible init_lock of zram in this phase an=
d
> make code more simple and clear but I don't want to stuck zsmalloc
> compaction by the work. Having said that, I feel it's time to revisit
> to remove init_lock.
> At least, I will think over to find a solution to kill init_lock.
>=20
> Thanks!
>=20
>=20



--XhpLwq3lWssEFVnjs3q3FigIxBRSPul2e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUxlBmAAoJEHTzHJCtsuoCwzoH/jxHYiLnkvIHVAKopJxjEmnK
WqCfHuae3kNqmfXibP80j+EINrZaOCKbgH4DjWDzKJVh5YZoVw8WezM3OHBR3Yzb
EIWhbZJnikXNinEh5qS+51dTaNfYo2XWNZcq8CWC+Gc8i6L3fSb7eU0ktOn2V3G/
LTD6NpeyxiwC5eeZwHisX9SUXnpiORqLWfz2Nbg+6Op03yi3FFRtbecsujBrDAzD
C5eOlDjiZ/upw06q1xFPV5/Z3fx4B72tG5NLu/nTQ9FZqdVK8ZESqqzNXrUUAYFq
dxAq9N9850WFtHPYMpZlenutYqq34OFRboGVYKahHP+hwx8LoSdkmGoNgdy+WU4=
=atWl
-----END PGP SIGNATURE-----

--XhpLwq3lWssEFVnjs3q3FigIxBRSPul2e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
