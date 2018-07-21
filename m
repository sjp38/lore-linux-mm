Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5E56B0003
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 01:10:41 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s3-v6so8908112plp.21
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 22:10:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j28-v6sor931033pgi.84.2018.07.20.22.10.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 22:10:39 -0700 (PDT)
Date: Fri, 20 Jul 2018 22:10:30 -0700
From: William Ziener-Dignazio <wdignazio@gmail.com>
Subject: Re: [PATCH] Add option to configure default zswap compressor
 algorithm.
Message-ID: <20180721051030.GA24838@Judea>
References: <20180701065616.3512-1-wdignazio@gmail.com>
 <CAH9O0xF8bL+DdQyPV8LeorxjVESB6ehXxAJBmm39veQ0aqmbCQ@mail.gmail.com>
 <CALZtONAfH2jLKsAet9Tv=6GSTM643V_vL=Lq5v4sgr3-bpp5rA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAfH2jLKsAet9Tv=6GSTM643V_vL=Lq5v4sgr3-bpp5rA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: sjenning@redhat.com, linux-mm@kvack.org

On Thu, Jul 19, 2018 at 06:00:33PM -0400, Dan Streetman wrote:
> On Sun, Jul 15, 2018 at 12:22 AM Will Dignazio <wdignazio@gmail.com> wrote:
> >
> > Apologies for bumping. I also should give a better description:
> >
> > This patch introduces a configuration option for the default cryptographic compression algorithm used by zswap. Previous to this patch, one would use the default compression algorithm until changed from userspace. This patch allows a compilation time change, which will remain the default from boot until changed.
> >
> > On Sat, Jun 30, 2018 at 11:56 PM Will Ziener-Dignazio <wdignazio@gmail.com> wrote:
> >>
> >>     - Add Kconfig option for default compressor algorithm
> >>     - Add the deflate and LZ4 algorithms as default options
> >>
> >> Signed-off-by: Will Ziener-Dignazio <wdignazio@gmail.com>
> >> ---
> >>  mm/Kconfig | 35 ++++++++++++++++++++++++++++++++++-
> >>  mm/zswap.c | 11 ++++++++++-
> >>  2 files changed, 44 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/Kconfig b/mm/Kconfig
> >> index ce95491abd6a..09df6650e96a 100644
> >> --- a/mm/Kconfig
> >> +++ b/mm/Kconfig
> >> @@ -535,7 +535,6 @@ config MEM_SOFT_DIRTY
> >>  config ZSWAP
> >>         bool "Compressed cache for swap pages (EXPERIMENTAL)"
> >>         depends on FRONTSWAP && CRYPTO=y
> >> -       select CRYPTO_LZO
> >>         select ZPOOL
> >>         default n
> >>         help
> >> @@ -552,6 +551,40 @@ config ZSWAP
> >>           they have not be fully explored on the large set of potential
> >>           configurations and workloads that exist.
> >>
> >> +choice
> >> +       prompt "Compressed cache cryptographic compression algorithm"
> >> +       default ZSWAP_COMPRESSOR_DEFAULT_LZO
> >> +       depends on ZSWAP
> >> +       help
> >> +         The default cyptrographic compression algorithm to use for
> >> +         compressed swap pages.
> >> +
> >> +config ZSWAP_COMPRESSOR_DEFAULT_LZO
> >> +       bool "lzo"
> >> +       select CRYPTO_LZO
> >> +       help
> >> +         This option sets the default zswap compression algorithm to LZO,
> >> +         the Lempel-Ziv-Oberhumer algorithm. This algorthm focuses on
> >> +         decompression speed, but has a lower compression ratio.
> >> +
> >> +config ZSWAP_COMPRESSOR_DEFAULT_DEFLATE
> >> +       bool "deflate"
> >> +       select CRYPTO_DEFLATE
> >> +       help
> >> +         This option sets the default zswap compression algorithm to DEFLATE.
> >> +         This algorithm balances compression and decompression speed to
> >> +         compresstion ratio.
> >> +
> >> +config ZSWAP_COMPRESSOR_DEFAULT_LZ4
> >> +       bool "lz4"
> >> +       select CRYPTO_LZ4
> >> +       help
> >> +         This option sets the default zswap compression algorithm to LZ4.
> >> +         This algorithm focuses on high compression speed, but has a lower
> >> +         compression ratio and decompression speed.
> >> +
> >> +endchoice
>
> would it be better to just use a free-form config string?  these 3

I wouldn't think this is better from a user/developer perspective. I'd prefer
it if we could ensure that no matter what input is given, the kernel will not
boot into an error condition (which requires userspace reconfiguration).

> choices don't cover all the current crypto compression algs...it's
> missing zlib, 842, lz4hc, and (newly added) zstd, and if any algs are

Yes this is my bad, and somewhat lazy on my part. My initial thought was to
grab only the most popular algorithms.... in retrospect I should have included
them all.

> added in the future, it's unlikely this choices list would be updated
> at the same time.  Doesn't hardcoding a few choices here seem
> limiting?  if we're going to allow selecting the default, it should
> allow selecting any of the available compressors as default, no?
>

Ideally, the list is auto-generated from the list of cryptographic compression
algorithms supported and enabled by the kernel.

> The help text could say 'see the Cryptographic API Compression section
> for possible choices' or something similar - or even just list out the
> possible choices, and we can try to keep it current if any are added
> in the future...
>

Agreed, will do.

Thanks for your review!

> >> +
> >>  config ZPOOL
> >>         tristate "Common API for compressed memory storage"
> >>         default n
> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> index 7d34e69507e3..30f9f25da4d0 100644
> >> --- a/mm/zswap.c
> >> +++ b/mm/zswap.c
> >> @@ -91,7 +91,16 @@ static struct kernel_param_ops zswap_enabled_param_ops = {
> >>  module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
> >>
> >>  /* Crypto compressor to use */
> >> -#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> >> +#if defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZO)
> >> +  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> >> +#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_DEFLATE)
> >> +  #define ZSWAP_COMPRESSOR_DEFAULT "deflate"
> >> +#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZ4)
> >> +  #define ZSWAP_COMPRESSOR_DEFAULT "lz4"
> >> +#else
> >> +  #error "Default zswap compression algorithm not defined."
> >> +#endif
> >> +
> >>  static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> >>  static int zswap_compressor_param_set(const char *,
> >>                                       const struct kernel_param *);
> >> --
> >> 2.18.0
> >>
> > --
> > Bytes Go In, Words Go Out
