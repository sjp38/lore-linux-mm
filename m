Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1467D6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 21:39:23 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so55954pad.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 18:39:22 -0700 (PDT)
Date: Wed, 26 Sep 2012 07:09:17 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re:  Re: [PATCH 4/5] Move the check for ra_pages after
 VM_SequentialReadHint()
Message-ID: <20120926013917.GB36532@Archie>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <b3c8b02fb273826f864f64d4588b36758fde2b5d.1348309711.git.rprabhu@wnohang.net>
 <20120922124250.GB15962@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z6Eq5LdranGa6ru8"
Content-Disposition: inline
In-Reply-To: <20120922124250.GB15962@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org


--z6Eq5LdranGa6ru8
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,


* On Sat, Sep 22, 2012 at 08:42:50PM +0800, Fengguang Wu <fengguang.wu@inte=
l.com> wrote:
>On Sat, Sep 22, 2012 at 04:03:13PM +0530, raghu.prabhu13@gmail.com wrote:
>> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
>>
>> page_cache_sync_readahead checks for ra->ra_pages again, so moving the c=
heck
>> after VM_SequentialReadHint.
>
>Well it depends on what case you are optimizing for. I suspect there
>are much more tmpfs users than VM_SequentialReadHint users. So this
>change is actually not desirable wrt the more widely used cases.

Yes, that is true. However, it was meant to eliminate duplicate=20
checking of the same condition in two places. But you are right,=20
it may impose overhead for majority of the cases (assuming=20
POSIX_FADVISE is used less than tmpfs).

>
>Thanks,
>Fengguang
>
>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> ---
>>  mm/filemap.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index 3843445..606a648 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -1523,8 +1523,6 @@ static void do_sync_mmap_readahead(struct vm_area_=
struct *vma,
>>  	/* If we don't want any read-ahead, don't bother */
>>  	if (VM_RandomReadHint(vma))
>>  		return;
>> -	if (!ra->ra_pages)
>> -		return;
>>
>>  	if (VM_SequentialReadHint(vma)) {
>>  		page_cache_sync_readahead(mapping, ra, file, offset,
>> @@ -1532,6 +1530,9 @@ static void do_sync_mmap_readahead(struct vm_area_=
struct *vma,
>>  		return;
>>  	}
>>
>> +	if (!ra->ra_pages)
>> +		return;
>> +
>>  	/* Avoid banging the cache line if not needed */
>>  	if (ra->mmap_miss < MMAP_LOTSAMISS * 10)
>>  		ra->mmap_miss++;
>> --
>> 1.7.12.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>




Regards,
--=20
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--z6Eq5LdranGa6ru8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJQYlzFAAoJEKYW3KHXK+l3NLUH/12jBNt23w9n8ALfYc6cPMYv
85FXbAHayqS/Q+ezZoLHaQrM1oLOBWWnhO64JE8si+2DXisQImpKnUk8atWmF0Jw
DpWFBCn9Pr6ldwiX47c2up7Mv6jc53hE/2FPaRTvXA64l2IE/jFowaZQJV6PJshT
n6EjlFrwlFLWKrml6bvsGKyiXYcOV2L5F42UJc4ejHmE/1IhZnDw0KY+2VfIrRqu
+O+/dzvCwCWNzgDfPkZek+mWfi3fPU36p+g55g3jgyOz6v31kg7Zpv8jZUwc8b7Y
52lI+2XfdSdfViCzFRAFYSTlatPsFSoETgtAw0Ktx1/246ST5Mf3F3GGzm0mKr0=
=lFwN
-----END PGP SIGNATURE-----

--z6Eq5LdranGa6ru8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
