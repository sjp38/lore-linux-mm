Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38EBA8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:09:33 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n26-v6so2469605iog.15
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 03:09:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16-v6sor747242jan.115.2018.09.27.03.09.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 03:09:31 -0700 (PDT)
MIME-Version: 1.0
References: <D4C91DBA-CF56-4991-BD7F-6BE334A2C048@amazon.com>
 <CALZtONDpUDAz_PLrt03CaajzAoY_Wr6Tm=PgvqAWyir9=fCd8A@mail.gmail.com>
 <EAFEF5B5-DE5D-42C7-AEF1-9DF6A800E95D@amazon.com> <CALZtONC5FYhmq+U6fga7RbDA4mEB4rTihsLGXG50a-XUCdtxiA@mail.gmail.com>
 <EEC089E8-9F85-483A-8C83-4C8459BA1345@amazon.com> <CALZtONB-y=ePYMZjtRiyfCYbWJ=R-xaR2NHPafzYMohtKOUSYg@mail.gmail.com>
 <A5D25E6B-137C-4E09-9353-30B36C2B192E@amazon.com> <CALZtONCM4KvsbtPJD0bnoocbv90q2niSQbeYypDo=w8oDTJ-CQ@mail.gmail.com>
 <F947C649-044A-4BCF-9E78-A25032B3C7DC@amazon.com>
In-Reply-To: <F947C649-044A-4BCF-9E78-A25032B3C7DC@amazon.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 27 Sep 2018 06:08:54 -0400
Message-ID: <CALZtONAi2VOrqs-UG3dsoCsOkAoMKQKUackCbAniAow35+XzcQ@mail.gmail.com>
Subject: Re: zswap: use PAGE_SIZE * 2 for compression dst buffer size when
 calling crypto compression API
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: taeilum@amazon.com
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>

On Wed, Sep 26, 2018 at 12:10 PM Um, Taeil <taeilum@amazon.com> wrote:
>
>    > compressed size > source buffer size has nothing to do with it.  the
>    > hw compressor must not exceed the *destination* buffer size, no matt=
er
>    > how small or large it is.
>
>    > if your hw compressor can't guarantee that it won't overrun the dest
>    > buffer, you need to use a bounce buffer that's sized large enough to
>    > guarantee your hw won't corrupt memory.
>
>    > again..."greater than source data size" has nothing to do with this.
>
>    > if lzo or lz4 fail to check the output buffer size before writing in=
to
>    > it, that's a serious bug in their code that needs to be fixed.
>
> I see a deviation between the consumer of compression driver and owner of=
 compression driver here.
> See how zram is dealing with this by always passing PAGE_SIZE * 2 for des=
tination length when it calls compression driver.

And that's its choice, but has nothing to do with bugs in compressors
that overrun their provided dest buffers.

>
> =EF=BB=BFOn 9/26/18, 2:01 AM, "Dan Streetman" <ddstreet@ieee.org> wrote:
>
>     On Thu, Sep 20, 2018 at 9:01 PM Um, Taeil <taeilum@amazon.com> wrote:
>     >
>     >    > do you have a specific example of how this causes any actual p=
roblem?
>     > Yes, I have a H/W accelerator that tries to finish compression even=
 if compressed data size is greater than source data size.
>
>     compressed size > source buffer size has nothing to do with it.  the
>     hw compressor must not exceed the *destination* buffer size, no matte=
r
>     how small or large it is.
>
>     if your hw compressor can't guarantee that it won't overrun the dest
>     buffer, you need to use a bounce buffer that's sized large enough to
>     guarantee your hw won't corrupt memory.
>
>     see the ppc PowerNV hw compressor driver for reference.
>
>     >
>     >    > personally, i'd prefer reducing zswap_dstmem down to 1 page to=
 save
>     >    > memory, since there is no case where zswap would ever want to =
use a
>     >    > compressed page larger than that.
>     > I don't think "reducing zswap_dstmem down to 1 page" works in today=
's lzo and lz4 kernel implementation.
>     > If I read kernel's lzo, lz4 code correctly, it does not stop compre=
ssion when compressed data size is greater than source data size.
>
>     again..."greater than source data size" has nothing to do with this.
>
>     if lzo or lz4 fail to check the output buffer size before writing int=
o
>     it, that's a serious bug in their code that needs to be fixed.
>
>     >
>     > On 9/19/18, 8:47 AM, "Dan Streetman" <ddstreet@ieee.org> wrote:
>     >
>     >     On Tue, Sep 18, 2018 at 7:48 PM Um, Taeil <taeilum@amazon.com> =
wrote:
>     >     >
>     >     > We can tell whether compressed size is greater than PAGE_SIZE=
 by looking at the returned *dlen value from crypto_comp_compress. This sho=
uld be fairly easy.
>     >     > This is actually what zram is doing today. zram looks for *dl=
en and not take the compressed result if *dlen is greater than certain size=
.
>     >     > I think errors from crypto_comp_compress should be real error=
s.
>     >     >
>     >     > Today in kernel compression drivers such as lzo and lz4, they=
 do not stop just because compression result size is greater than source si=
ze.
>     >     > Also, some H/W accelerators would not have the option of stop=
ping compression just because of the result size is greater than source siz=
e.
>     >
>     >     do you have a specific example of how this causes any actual pr=
oblem?
>     >
>     >     personally, i'd prefer reducing zswap_dstmem down to 1 page to =
save
>     >     memory, since there is no case where zswap would ever want to u=
se a
>     >     compressed page larger than that.
>     >
>     >     >
>     >     > Thank you,
>     >     > Taeil
>     >     >
>     >     > On 9/18/18, 2:44 PM, "Dan Streetman" <ddstreet@ieee.org> wrot=
e:
>     >     >
>     >     >     On Tue, Sep 18, 2018 at 2:52 PM Um, Taeil <taeilum@amazon=
.com> wrote:
>     >     >     >
>     >     >     > Problem statement:
>     >     >     > "compressed data are not fully copied to destination bu=
ffer when compressed data size is greater than source data"
>     >     >     >
>     >     >     > Why:
>     >     >     > 5th argument of crypto_comp_compress function is *dlen,=
 which tell the compression driver how many bytes the destination buffer sp=
ace is allocated (allowed to write data).
>     >     >     > This *dlen is important especially for H/W accelerator =
based compression driver because it is dangerous if we allow the H/W accele=
rator to access memory beyond *dst + *dlen.
>     >     >     > Note that buffer location would be passed as physical a=
ddress.
>     >     >     > Due to the above reason, H/W accelerator based compress=
ion driver need to honor *dlen value when it serves crypto_comp_compress AP=
I.
>     >     >
>     >     >     and that's exactly what zswap wants to happen - any compr=
essor (hw or
>     >     >     sw) should fail with an error code (ENOSPC makes the most=
 sense, but
>     >     >     zswap doesn't actually care) if the compressed data size =
is larger
>     >     >     than the provided data buffer.
>     >     >
>     >     >     > Today, we pass slen =3D PAGE_SIZE and *dlen=3DPAGE_SIZE=
 to crypto_comp_compress in zswap.c.
>     >     >     > If compressed data size is greater than source (uncompr=
essed) data size,  H/W accelerator cannot copy (deliver) the entire compres=
sed data.
>     >     >
>     >     >     If the "compressed" data is larger than 1 page, then ther=
e is no point
>     >     >     in storing the page in zswap.
>     >     >
>     >     >     remember that zswap is different than zram; in zram, ther=
e's no other
>     >     >     place to store the data.  However, with zswap, if compres=
sion fails or
>     >     >     isn't good, we can just pass the uncompressed page down t=
o the swap
>     >     >     device.
>     >     >
>     >     >     >
>     >     >     > Thank you,
>     >     >     > Taeil
>     >     >     >
>     >     >     > On 9/18/18, 7:15 AM, "Dan Streetman" <ddstreet@ieee.org=
> wrote:
>     >     >     >
>     >     >     >     On Mon, Sep 17, 2018 at 7:10 PM Um, Taeil <taeilum@=
amazon.com> wrote:
>     >     >     >     >
>     >     >     >     > Currently, we allocate PAGE_SIZE * 2 for zswap_ds=
tmem which is used as compression destination buffer.
>     >     >     >     >
>     >     >     >     > However, we pass only half of the size (PAGE_SIZE=
) to crypto_comp_compress.
>     >     >     >     >
>     >     >     >     > This might not be a problem for CPU based existin=
g lzo, lz4 crypto compression driver implantation.
>     >     >     >     >
>     >     >     >     > However, this could be a problem for some H/W acc=
eleration compression drivers, which honor destination buffer size when it =
prepares H/W resources.
>     >     >     >
>     >     >     >     How exactly could it be a problem?
>     >     >     >
>     >     >     >     >
>     >     >     >     > Actually, this patch is aligned with what zram is=
 passing when it calls crypto_comp_compress.
>     >     >     >     >
>     >     >     >     > The following simple patch will solve this proble=
m. I tested it with existing crypto/lzo.c and crypto/lz4.c compression driv=
er and it works fine.
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     > --- mm/zswap.c.orig       2018-09-14 14:36:37.984=
199232 -0700
>     >     >     >     >
>     >     >     >     > +++ mm/zswap.c             2018-09-14 14:36:53.34=
0189681 -0700
>     >     >     >     >
>     >     >     >     > @@ -1001,7 +1001,7 @@ static int zswap_frontswap_=
store(unsigne
>     >     >     >     >
>     >     >     >     >                 struct zswap_entry *entry, *dupen=
try;
>     >     >     >     >
>     >     >     >     >                 struct crypto_comp *tfm;
>     >     >     >     >
>     >     >     >     >                 int ret;
>     >     >     >     >
>     >     >     >     > -              unsigned int hlen, dlen =3D PAGE_S=
IZE;
>     >     >     >     >
>     >     >     >     > +             unsigned int hlen, dlen =3D PAGE_SI=
ZE * 2;
>     >     >     >     >
>     >     >     >     >                 unsigned long handle, value;
>     >     >     >     >
>     >     >     >     >                 char *buf;
>     >     >     >     >
>     >     >     >     >                 u8 *src, *dst;
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     >
>     >     >     >     > Thank you,
>     >     >     >     >
>     >     >     >     > Taeil
>     >     >     >     >
>     >     >     >     >
>     >     >     >
>     >     >     >
>     >     >     >
>     >     >
>     >     >
>     >     >
>     >
>     >
>     >
>
>
>
