Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D10196B0038
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 12:05:59 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j3so13574411pfh.16
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 09:05:59 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40106.outbound.protection.outlook.com. [40.107.4.106])
        by mx.google.com with ESMTPS id h8si10459596pfi.0.2017.12.04.09.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 09:05:58 -0800 (PST)
Subject: Re: [PATCH v3 3/5] kasan: support alloca() poisoning
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
References: <20171201213643.2506-1-paullawrence@google.com>
 <20171201213643.2506-4-paullawrence@google.com>
 <20171204164240.GA24425@infradead.org>
 <fb09a40f-1fae-ce4c-9d7c-a13c284b19e9@virtuozzo.com>
Message-ID: <e85d8503-b149-b90f-7737-684e8122d95b@virtuozzo.com>
Date: Mon, 4 Dec 2017 20:09:25 +0300
MIME-Version: 1.0
In-Reply-To: <fb09a40f-1fae-ce4c-9d7c-a13c284b19e9@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Paul Lawrence <paullawrence@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>



On 12/04/2017 07:55 PM, Andrey Ryabinin wrote:
> 
> 
> On 12/04/2017 07:42 PM, Christoph Hellwig wrote:
>> I don't think we are using alloca in kernel mode code, and we shouldn't.
>> What do I miss?  Is this hidden support for on-stack VLAs?  I thought
>> we'd get rid of them as well.
>>
> 
> Yes, this is for on-stack VLA. Last time I checked, we still had a few.
> 

E.g. building with -Wvla:


/home/andrew/linux/sound/core/pcm_native.c: In function a??constrain_params_by_rulesa??:
/home/andrew/linux/sound/core/pcm_native.c:326:2: warning: ISO C90 forbids variable length array a??rstampsa?? [-Wvla]
  unsigned int rstamps[constrs->rules_num];
  ^~~~~~~~
In file included from /home/andrew/linux/crypto/cbc.c:14:0:
/home/andrew/linux/include/crypto/cbc.h: In function a??crypto_cbc_decrypt_inplacea??:
/home/andrew/linux/include/crypto/cbc.h:116:2: warning: ISO C90 forbids variable length array a??last_iva?? [-Wvla]
  u8 last_iv[bsize];
  ^~
/home/andrew/linux/crypto/pcbc.c: In function a??crypto_pcbc_encrypt_inplacea??:
/home/andrew/linux/crypto/pcbc.c:75:2: warning: ISO C90 forbids variable length array a??tmpbufa?? [-Wvla]
  u8 tmpbuf[bsize];
  ^~
/home/andrew/linux/crypto/pcbc.c: In function a??crypto_pcbc_decrypt_inplacea??:
/home/andrew/linux/crypto/pcbc.c:147:2: warning: ISO C90 forbids variable length array a??tmpbufa?? [-Wvla]
  u8 tmpbuf[bsize] __aligned(__alignof__(u32));
  ^~
/home/andrew/linux/crypto/cts.c: In function a??cts_cbc_encrypta??:
/home/andrew/linux/crypto/cts.c:107:2: warning: ISO C90 forbids variable length array a??da?? [-Wvla]
  u8 d[bsize * 2] __aligned(__alignof__(u32));
  ^~
/home/andrew/linux/crypto/cts.c: In function a??cts_cbc_decrypta??:
/home/andrew/linux/crypto/cts.c:186:2: warning: ISO C90 forbids variable length array a??da?? [-Wvla]
  u8 d[bsize * 2] __aligned(__alignof__(u32));
  ^~
/home/andrew/linux/crypto/ctr.c: In function a??crypto_ctr_crypt_finala??:
/home/andrew/linux/crypto/ctr.c:61:2: warning: ISO C90 forbids variable length array a??tmpa?? [-Wvla]
  u8 tmp[bsize + alignmask];
  ^~
/home/andrew/linux/crypto/ctr.c: In function a??crypto_ctr_crypt_inplacea??:
/home/andrew/linux/crypto/ctr.c:109:2: warning: ISO C90 forbids variable length array a??tmpa?? [-Wvla]
  u8 tmp[bsize + alignmask];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
