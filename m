Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9496B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 08:33:40 -0400 (EDT)
Received: by mail-lf0-f48.google.com with SMTP id e190so54030911lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 05:33:40 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id z65si3968470lff.17.2016.04.07.05.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 05:33:39 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id t203so4147212lfd.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 05:33:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160406130911.GA584@swordfish>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
	<20160405153439.GA2647@kroah.com>
	<CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
	<20160406053325.GA415@swordfish>
	<CALjTZvZaD7VHieU4A_5JAGZfN-7toWGm1UpM3zqreP6YsvA37A@mail.gmail.com>
	<20160406130911.GA584@swordfish>
Date: Thu, 7 Apr 2016 13:33:38 +0100
Message-ID: <CALjTZva=ocKHU8hdwmrQZvK-5QnHcc4EQD7CogJuELYk7=J=Og@mail.gmail.com>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on big endian
From: Rui Salvaterra <rsalvaterra@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org, Chanho Min <chanho.min@lge.com>, Kyungsik Lee <kyungsik.lee@lge.com>

2016-04-06 14:09 GMT+01:00 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>:
> Cc Chanho Min, Kyungsik Lee
>
>
> Hello,
>
> On (04/06/16 10:39), Rui Salvaterra wrote:
>> > may we please ask you to test the patch first? quite possible there
>> > is nothing to fix there; I've no access to mips h/w but the patch
>> > seems correct to me.
>> >
>> > LZ4_READ_LITTLEENDIAN_16 does get_unaligned_le16(), so
>> > LZ4_WRITE_LITTLEENDIAN_16 must do put_unaligned_le16() /* not put_unaligned() */
>> >
> [..]
>> Consequentially, while I believe the patch will fix the mips case, I'm
>> not so sure about ppc (or any other big endian architecture with
>> efficient unaligned accesses).
>
> frankly, yes, I took a quick look today (after I sent my initial
> message, tho) ... and it is fishy, I agree. was going to followup
> on my email but somehow got interrupted, sorry.
>
> so we have, write:
>         ((U16_S *)(p)) = v    OR    put_unaligned(v, (u16 *)(p))
>
> and only one read:
>         get_unaligned_le16(p))
>
> I guess it's either read part also must depend on
> HAVE_EFFICIENT_UNALIGNED_ACCESS, or write path
> should stop doing so.
>
> I ended up with two patches, NONE was tested (!!!). like at all.
>
> 1) provide CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS-dependent
>    LZ4_READ_LITTLEENDIAN_16
>
> 2) provide common LZ4_WRITE_LITTLEENDIAN_16 and LZ4_READ_LITTLEENDIAN_16
>    regardless CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
>
>
> assuming that common LZ4_WRITE_LITTLEENDIAN_16 will somehow hit the
> performance, I'd probably prefer option #1.
>
> the patch is below. would be great if you can help testing it.
>
> ---
>
>  lib/lz4/lz4defs.h | 22 +++++++++++++---------
>  1 file changed, 13 insertions(+), 9 deletions(-)
>
> diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
> index abcecdc..a23e6c2 100644
> --- a/lib/lz4/lz4defs.h
> +++ b/lib/lz4/lz4defs.h
> @@ -36,10 +36,14 @@ typedef struct _U64_S { u64 v; } U64_S;
>  #define PUT4(s, d) (A32(d) = A32(s))
>  #define PUT8(s, d) (A64(d) = A64(s))
>  #define LZ4_WRITE_LITTLEENDIAN_16(p, v)        \
> -       do {    \
> -               A16(p) = v; \
> -               p += 2; \
> +       do {                                    \
> +               A16(p) = v;                     \
> +               p += 2;                         \
>         } while (0)
> +
> +#define LZ4_READ_LITTLEENDIAN_16(d, s, p)      \
> +       (d = s - A16(p))
> +
>  #else /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
>
>  #define A64(x) get_unaligned((u64 *)&(((U16_S *)(x))->v))
> @@ -52,10 +56,13 @@ typedef struct _U64_S { u64 v; } U64_S;
>         put_unaligned(get_unaligned((const u64 *) s), (u64 *) d)
>
>  #define LZ4_WRITE_LITTLEENDIAN_16(p, v)        \
> -       do {    \
> -               put_unaligned(v, (u16 *)(p)); \
> -               p += 2; \
> +       do {                                            \
> +               put_unaligned_le16(v, (u16 *)(p));      \
> +               p += 2;                                 \
>         } while (0)
> +
> +#define LZ4_READ_LITTLEENDIAN_16(d, s, p)              \
> +       (d = s - get_unaligned_le16(p))
>  #endif
>
>  #define COPYLENGTH 8
> @@ -140,9 +147,6 @@ typedef struct _U64_S { u64 v; } U64_S;
>
>  #endif
>
> -#define LZ4_READ_LITTLEENDIAN_16(d, s, p) \
> -       (d = s - get_unaligned_le16(p))
> -
>  #define LZ4_WILDCOPY(s, d, e)          \
>         do {                            \
>                 LZ4_COPYPACKET(s, d);   \
>


Hi again, Sergey


Thanks for the patch, I'll test it as soon as possible. I agree with
your second option, usually one selects lz4 when (especially
decompression) speed is paramount, so it needs all the help it can
get.

Speaking of fishy, the 64-bit detection code also looks suspiciously
bogus. Some of the identifiers don't even exist anywhere in the kernel
(__ppc64__, por example, after grepping all .c and .h files).
Shouldn't we instead check for CONFIG_64BIT or BITS_PER_LONG == 64?


Thanks,

Rui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
