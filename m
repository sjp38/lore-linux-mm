Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C41B28E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:47:47 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e6-v6so8122490itc.7
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 08:47:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t128-v6sor6014860ita.98.2018.09.19.08.47.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 08:47:46 -0700 (PDT)
MIME-Version: 1.0
References: <D4C91DBA-CF56-4991-BD7F-6BE334A2C048@amazon.com>
 <CALZtONDpUDAz_PLrt03CaajzAoY_Wr6Tm=PgvqAWyir9=fCd8A@mail.gmail.com>
 <EAFEF5B5-DE5D-42C7-AEF1-9DF6A800E95D@amazon.com> <CALZtONC5FYhmq+U6fga7RbDA4mEB4rTihsLGXG50a-XUCdtxiA@mail.gmail.com>
 <EEC089E8-9F85-483A-8C83-4C8459BA1345@amazon.com>
In-Reply-To: <EEC089E8-9F85-483A-8C83-4C8459BA1345@amazon.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 19 Sep 2018 11:47:08 -0400
Message-ID: <CALZtONB-y=ePYMZjtRiyfCYbWJ=R-xaR2NHPafzYMohtKOUSYg@mail.gmail.com>
Subject: Re: zswap: use PAGE_SIZE * 2 for compression dst buffer size when
 calling crypto compression API
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: taeilum@amazon.com
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>

On Tue, Sep 18, 2018 at 7:48 PM Um, Taeil <taeilum@amazon.com> wrote:
>
> We can tell whether compressed size is greater than PAGE_SIZE by looking =
at the returned *dlen value from crypto_comp_compress. This should be fairl=
y easy.
> This is actually what zram is doing today. zram looks for *dlen and not t=
ake the compressed result if *dlen is greater than certain size.
> I think errors from crypto_comp_compress should be real errors.
>
> Today in kernel compression drivers such as lzo and lz4, they do not stop=
 just because compression result size is greater than source size.
> Also, some H/W accelerators would not have the option of stopping compres=
sion just because of the result size is greater than source size.

do you have a specific example of how this causes any actual problem?

personally, i'd prefer reducing zswap_dstmem down to 1 page to save
memory, since there is no case where zswap would ever want to use a
compressed page larger than that.

>
> Thank you,
> Taeil
>
> =EF=BB=BFOn 9/18/18, 2:44 PM, "Dan Streetman" <ddstreet@ieee.org> wrote:
>
>     On Tue, Sep 18, 2018 at 2:52 PM Um, Taeil <taeilum@amazon.com> wrote:
>     >
>     > Problem statement:
>     > "compressed data are not fully copied to destination buffer when co=
mpressed data size is greater than source data"
>     >
>     > Why:
>     > 5th argument of crypto_comp_compress function is *dlen, which tell =
the compression driver how many bytes the destination buffer space is alloc=
ated (allowed to write data).
>     > This *dlen is important especially for H/W accelerator based compre=
ssion driver because it is dangerous if we allow the H/W accelerator to acc=
ess memory beyond *dst + *dlen.
>     > Note that buffer location would be passed as physical address.
>     > Due to the above reason, H/W accelerator based compression driver n=
eed to honor *dlen value when it serves crypto_comp_compress API.
>
>     and that's exactly what zswap wants to happen - any compressor (hw or
>     sw) should fail with an error code (ENOSPC makes the most sense, but
>     zswap doesn't actually care) if the compressed data size is larger
>     than the provided data buffer.
>
>     > Today, we pass slen =3D PAGE_SIZE and *dlen=3DPAGE_SIZE to crypto_c=
omp_compress in zswap.c.
>     > If compressed data size is greater than source (uncompressed) data =
size,  H/W accelerator cannot copy (deliver) the entire compressed data.
>
>     If the "compressed" data is larger than 1 page, then there is no poin=
t
>     in storing the page in zswap.
>
>     remember that zswap is different than zram; in zram, there's no other
>     place to store the data.  However, with zswap, if compression fails o=
r
>     isn't good, we can just pass the uncompressed page down to the swap
>     device.
>
>     >
>     > Thank you,
>     > Taeil
>     >
>     > On 9/18/18, 7:15 AM, "Dan Streetman" <ddstreet@ieee.org> wrote:
>     >
>     >     On Mon, Sep 17, 2018 at 7:10 PM Um, Taeil <taeilum@amazon.com> =
wrote:
>     >     >
>     >     > Currently, we allocate PAGE_SIZE * 2 for zswap_dstmem which i=
s used as compression destination buffer.
>     >     >
>     >     > However, we pass only half of the size (PAGE_SIZE) to crypto_=
comp_compress.
>     >     >
>     >     > This might not be a problem for CPU based existing lzo, lz4 c=
rypto compression driver implantation.
>     >     >
>     >     > However, this could be a problem for some H/W acceleration co=
mpression drivers, which honor destination buffer size when it prepares H/W=
 resources.
>     >
>     >     How exactly could it be a problem?
>     >
>     >     >
>     >     > Actually, this patch is aligned with what zram is passing whe=
n it calls crypto_comp_compress.
>     >     >
>     >     > The following simple patch will solve this problem. I tested =
it with existing crypto/lzo.c and crypto/lz4.c compression driver and it wo=
rks fine.
>     >     >
>     >     >
>     >     >
>     >     >
>     >     >
>     >     > --- mm/zswap.c.orig       2018-09-14 14:36:37.984199232 -0700
>     >     >
>     >     > +++ mm/zswap.c             2018-09-14 14:36:53.340189681 -070=
0
>     >     >
>     >     > @@ -1001,7 +1001,7 @@ static int zswap_frontswap_store(unsign=
e
>     >     >
>     >     >                 struct zswap_entry *entry, *dupentry;
>     >     >
>     >     >                 struct crypto_comp *tfm;
>     >     >
>     >     >                 int ret;
>     >     >
>     >     > -              unsigned int hlen, dlen =3D PAGE_SIZE;
>     >     >
>     >     > +             unsigned int hlen, dlen =3D PAGE_SIZE * 2;
>     >     >
>     >     >                 unsigned long handle, value;
>     >     >
>     >     >                 char *buf;
>     >     >
>     >     >                 u8 *src, *dst;
>     >     >
>     >     >
>     >     >
>     >     >
>     >     >
>     >     >
>     >     >
>     >     > Thank you,
>     >     >
>     >     > Taeil
>     >     >
>     >     >
>     >
>     >
>     >
>
>
>
