Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id AC7F16B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 05:39:47 -0400 (EDT)
Received: by mail-lf0-f50.google.com with SMTP id j11so29448703lfb.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:39:47 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id 88si788469lfw.239.2016.04.06.02.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 02:39:46 -0700 (PDT)
Received: by mail-lb0-x234.google.com with SMTP id u8so26125370lbk.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:39:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160406053325.GA415@swordfish>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
	<20160405153439.GA2647@kroah.com>
	<CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
	<20160406053325.GA415@swordfish>
Date: Wed, 6 Apr 2016 10:39:45 +0100
Message-ID: <CALjTZvZaD7VHieU4A_5JAGZfN-7toWGm1UpM3zqreP6YsvA37A@mail.gmail.com>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on big endian
From: Rui Salvaterra <rsalvaterra@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

2016-04-06 6:33 GMT+01:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> On (04/05/16 17:02), Rui Salvaterra wrote:
> [..]
>> > For some reason it never got merged, sorry, I don't remember why.
>> >
>> > Have you tested this patch?  If so, can you resend it with your
>> > tested-by: line added to it?
>> >
>> > thanks,
>> >
>> > greg k-h
>>
>> Hi, Greg
>>
>>
>> No, I haven't tested the patch at all. I want to do so, and fix if if
>> necessary, but I still need to learn how to (meaning, I need to watch
>> your "first kernel patch" presentation again). I'd love to get
>> involved in kernel development, and this seems to be a good
>> opportunity, if none of the kernel gods beat me to it (I may need a
>> month, but then again nobody complained about this bug in almost two
>> years).
>
> Hello Rui,
>
> may we please ask you to test the patch first? quite possible there
> is nothing to fix there; I've no access to mips h/w but the patch
> seems correct to me.
>
> LZ4_READ_LITTLEENDIAN_16 does get_unaligned_le16(), so
> LZ4_WRITE_LITTLEENDIAN_16 must do put_unaligned_le16() /* not put_unaligned() */
>
>         -ss

Hi, Sergey


Besides ppc64, I have ppc32, x86 and x86_64 hardware readily
available. The only mips (74kc, also big endian) hardware I have
access to is my router, running OpenWrt, I can try to test it there
too, but it will be more complicated. Still, after reading the
existing code [1] more thoroughly, I can't see how Eunbong Song's
patch [2] would fix the ppc case (please correct me if I'm wrong,
which is highly likely, since my C preprocessor knowledge varies
between nonexistent to very superficial).

Now, LZ4_READ_LITTLEENDIAN_16 is unconditionally defined as:

#define LZ4_READ_LITTLEENDIAN_16(d, s, p)
                (d = s - get_unaligned_le16(p))

As far as I can tell, and unlike ppc, mips doesn't define
HAVE_EFFICIENT_UNALIGNED_ACCESS, which means for mips case,
LZ4_WRITE_LITTLEENDIAN_16 will be defined as:

#define LZ4_WRITE_LITTLEENDIAN_16(p, v)
                do {
                                put_unaligned(v, (u16 *)(p));
                                p += 2;
                } while (0)

Whereas for ppc, which defines HAVE_EFFICIENT_UNALIGNED_ACCESS,
LZ4_WRITE_LITTLEENDIAN_16 will be defined as:

#define LZ4_WRITE_LITTLEENDIAN_16(p, v)
                do {
                                A16(p) = v;
                                p += 2;
                } while (0)

Consequentially, while I believe the patch will fix the mips case, I'm
not so sure about ppc (or any other big endian architecture with
efficient unaligned accesses).


Thanks,

Rui

[1] https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/lib/lz4/lz4defs.h?h=v4.4.6
[2] http://permalink.gmane.org/gmane.linux.kernel/1752745

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
