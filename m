Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 026868E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 17:44:39 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id o4-v6so3929117iob.12
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 14:44:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w24-v6sor11923970jah.148.2018.09.18.14.44.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 14:44:37 -0700 (PDT)
MIME-Version: 1.0
References: <D4C91DBA-CF56-4991-BD7F-6BE334A2C048@amazon.com>
 <CALZtONDpUDAz_PLrt03CaajzAoY_Wr6Tm=PgvqAWyir9=fCd8A@mail.gmail.com> <EAFEF5B5-DE5D-42C7-AEF1-9DF6A800E95D@amazon.com>
In-Reply-To: <EAFEF5B5-DE5D-42C7-AEF1-9DF6A800E95D@amazon.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 18 Sep 2018 17:44:00 -0400
Message-ID: <CALZtONC5FYhmq+U6fga7RbDA4mEB4rTihsLGXG50a-XUCdtxiA@mail.gmail.com>
Subject: Re: zswap: use PAGE_SIZE * 2 for compression dst buffer size when
 calling crypto compression API
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: taeilum@amazon.com
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>

On Tue, Sep 18, 2018 at 2:52 PM Um, Taeil <taeilum@amazon.com> wrote:
>
> Problem statement:
> "compressed data are not fully copied to destination buffer when compress=
ed data size is greater than source data"
>
> Why:
> 5th argument of crypto_comp_compress function is *dlen, which tell the co=
mpression driver how many bytes the destination buffer space is allocated (=
allowed to write data).
> This *dlen is important especially for H/W accelerator based compression =
driver because it is dangerous if we allow the H/W accelerator to access me=
mory beyond *dst + *dlen.
> Note that buffer location would be passed as physical address.
> Due to the above reason, H/W accelerator based compression driver need to=
 honor *dlen value when it serves crypto_comp_compress API.

and that's exactly what zswap wants to happen - any compressor (hw or
sw) should fail with an error code (ENOSPC makes the most sense, but
zswap doesn't actually care) if the compressed data size is larger
than the provided data buffer.

> Today, we pass slen =3D PAGE_SIZE and *dlen=3DPAGE_SIZE to crypto_comp_co=
mpress in zswap.c.
> If compressed data size is greater than source (uncompressed) data size, =
 H/W accelerator cannot copy (deliver) the entire compressed data.

If the "compressed" data is larger than 1 page, then there is no point
in storing the page in zswap.

remember that zswap is different than zram; in zram, there's no other
place to store the data.  However, with zswap, if compression fails or
isn't good, we can just pass the uncompressed page down to the swap
device.

>
> Thank you,
> Taeil
>
> =EF=BB=BFOn 9/18/18, 7:15 AM, "Dan Streetman" <ddstreet@ieee.org> wrote:
>
>     On Mon, Sep 17, 2018 at 7:10 PM Um, Taeil <taeilum@amazon.com> wrote:
>     >
>     > Currently, we allocate PAGE_SIZE * 2 for zswap_dstmem which is used=
 as compression destination buffer.
>     >
>     > However, we pass only half of the size (PAGE_SIZE) to crypto_comp_c=
ompress.
>     >
>     > This might not be a problem for CPU based existing lzo, lz4 crypto =
compression driver implantation.
>     >
>     > However, this could be a problem for some H/W acceleration compress=
ion drivers, which honor destination buffer size when it prepares H/W resou=
rces.
>
>     How exactly could it be a problem?
>
>     >
>     > Actually, this patch is aligned with what zram is passing when it c=
alls crypto_comp_compress.
>     >
>     > The following simple patch will solve this problem. I tested it wit=
h existing crypto/lzo.c and crypto/lz4.c compression driver and it works fi=
ne.
>     >
>     >
>     >
>     >
>     >
>     > --- mm/zswap.c.orig       2018-09-14 14:36:37.984199232 -0700
>     >
>     > +++ mm/zswap.c             2018-09-14 14:36:53.340189681 -0700
>     >
>     > @@ -1001,7 +1001,7 @@ static int zswap_frontswap_store(unsigne
>     >
>     >                 struct zswap_entry *entry, *dupentry;
>     >
>     >                 struct crypto_comp *tfm;
>     >
>     >                 int ret;
>     >
>     > -              unsigned int hlen, dlen =3D PAGE_SIZE;
>     >
>     > +             unsigned int hlen, dlen =3D PAGE_SIZE * 2;
>     >
>     >                 unsigned long handle, value;
>     >
>     >                 char *buf;
>     >
>     >                 u8 *src, *dst;
>     >
>     >
>     >
>     >
>     >
>     >
>     >
>     > Thank you,
>     >
>     > Taeil
>     >
>     >
>
>
>
