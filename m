Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 203D06B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 18:01:12 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u140-v6so7008546itc.3
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 15:01:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d34-v6sor114691jaa.59.2018.07.19.15.01.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 15:01:10 -0700 (PDT)
MIME-Version: 1.0
References: <20180701065616.3512-1-wdignazio@gmail.com> <CAH9O0xF8bL+DdQyPV8LeorxjVESB6ehXxAJBmm39veQ0aqmbCQ@mail.gmail.com>
In-Reply-To: <CAH9O0xF8bL+DdQyPV8LeorxjVESB6ehXxAJBmm39veQ0aqmbCQ@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 19 Jul 2018 18:00:33 -0400
Message-ID: <CALZtONAfH2jLKsAet9Tv=6GSTM643V_vL=Lq5v4sgr3-bpp5rA@mail.gmail.com>
Subject: Re: [PATCH] Add option to configure default zswap compressor algorithm.
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wdignazio@gmail.com
Cc: Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>

On Sun, Jul 15, 2018 at 12:22 AM Will Dignazio <wdignazio@gmail.com> wrote:
>
> Apologies for bumping. I also should give a better description:
>
> This patch introduces a configuration option for the default cryptographi=
c compression algorithm used by zswap. Previous to this patch, one would us=
e the default compression algorithm until changed from userspace. This patc=
h allows a compilation time change, which will remain the default from boot=
 until changed.
>
> On Sat, Jun 30, 2018 at 11:56 PM Will Ziener-Dignazio <wdignazio@gmail.co=
m> wrote:
>>
>>     - Add Kconfig option for default compressor algorithm
>>     - Add the deflate and LZ4 algorithms as default options
>>
>> Signed-off-by: Will Ziener-Dignazio <wdignazio@gmail.com>
>> ---
>>  mm/Kconfig | 35 ++++++++++++++++++++++++++++++++++-
>>  mm/zswap.c | 11 ++++++++++-
>>  2 files changed, 44 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index ce95491abd6a..09df6650e96a 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -535,7 +535,6 @@ config MEM_SOFT_DIRTY
>>  config ZSWAP
>>         bool "Compressed cache for swap pages (EXPERIMENTAL)"
>>         depends on FRONTSWAP && CRYPTO=3Dy
>> -       select CRYPTO_LZO
>>         select ZPOOL
>>         default n
>>         help
>> @@ -552,6 +551,40 @@ config ZSWAP
>>           they have not be fully explored on the large set of potential
>>           configurations and workloads that exist.
>>
>> +choice
>> +       prompt "Compressed cache cryptographic compression algorithm"
>> +       default ZSWAP_COMPRESSOR_DEFAULT_LZO
>> +       depends on ZSWAP
>> +       help
>> +         The default cyptrographic compression algorithm to use for
>> +         compressed swap pages.
>> +
>> +config ZSWAP_COMPRESSOR_DEFAULT_LZO
>> +       bool "lzo"
>> +       select CRYPTO_LZO
>> +       help
>> +         This option sets the default zswap compression algorithm to LZ=
O,
>> +         the Lempel-Ziv-Oberhumer algorithm. This algorthm focuses on
>> +         decompression speed, but has a lower compression ratio.
>> +
>> +config ZSWAP_COMPRESSOR_DEFAULT_DEFLATE
>> +       bool "deflate"
>> +       select CRYPTO_DEFLATE
>> +       help
>> +         This option sets the default zswap compression algorithm to DE=
FLATE.
>> +         This algorithm balances compression and decompression speed to
>> +         compresstion ratio.
>> +
>> +config ZSWAP_COMPRESSOR_DEFAULT_LZ4
>> +       bool "lz4"
>> +       select CRYPTO_LZ4
>> +       help
>> +         This option sets the default zswap compression algorithm to LZ=
4.
>> +         This algorithm focuses on high compression speed, but has a lo=
wer
>> +         compression ratio and decompression speed.
>> +
>> +endchoice

would it be better to just use a free-form config string?  these 3
choices don't cover all the current crypto compression algs...it's
missing zlib, 842, lz4hc, and (newly added) zstd, and if any algs are
added in the future, it's unlikely this choices list would be updated
at the same time.  Doesn't hardcoding a few choices here seem
limiting?  if we're going to allow selecting the default, it should
allow selecting any of the available compressors as default, no?

The help text could say 'see the Cryptographic API Compression section
for possible choices' or something similar - or even just list out the
possible choices, and we can try to keep it current if any are added
in the future...

>> +
>>  config ZPOOL
>>         tristate "Common API for compressed memory storage"
>>         default n
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index 7d34e69507e3..30f9f25da4d0 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -91,7 +91,16 @@ static struct kernel_param_ops zswap_enabled_param_op=
s =3D {
>>  module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644=
);
>>
>>  /* Crypto compressor to use */
>> -#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
>> +#if defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZO)
>> +  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
>> +#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_DEFLATE)
>> +  #define ZSWAP_COMPRESSOR_DEFAULT "deflate"
>> +#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZ4)
>> +  #define ZSWAP_COMPRESSOR_DEFAULT "lz4"
>> +#else
>> +  #error "Default zswap compression algorithm not defined."
>> +#endif
>> +
>>  static char *zswap_compressor =3D ZSWAP_COMPRESSOR_DEFAULT;
>>  static int zswap_compressor_param_set(const char *,
>>                                       const struct kernel_param *);
>> --
>> 2.18.0
>>
> --
> Bytes Go In, Words Go Out
