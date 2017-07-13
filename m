Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E56B4408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 18:40:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d62so69919438pfb.13
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 15:40:04 -0700 (PDT)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id s59si5362159plb.319.2017.07.13.15.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 15:40:03 -0700 (PDT)
Received: by mail-pg0-x22e.google.com with SMTP id u62so36116792pgb.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 15:40:02 -0700 (PDT)
Subject: Re: [PATCH 1/4] kasan: support alloca() poisoning
References: <20170706220114.142438-1-ghackmann@google.com>
 <20170706220114.142438-2-ghackmann@google.com>
 <CACT4Y+YWLc3n-PBcD1Cmu_FLGSDd+vyTTyeBamk2bBZhdWJSoA@mail.gmail.com>
From: Greg Hackmann <ghackmann@google.com>
Message-ID: <c7160aca-a203-e3d8-eb49-b051aff78f0e@google.com>
Date: Thu, 13 Jul 2017 15:40:00 -0700
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YWLc3n-PBcD1Cmu_FLGSDd+vyTTyeBamk2bBZhdWJSoA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>

Hi,

Thanks for taking a look at this patchstack.  I apologize for the delay 
in responding.

On 07/10/2017 01:44 AM, Dmitry Vyukov wrote:
>> +
>> +       const void *left_redzone = (const void *)(addr -
>> +                       KASAN_ALLOCA_REDZONE_SIZE);
>> +       const void *right_redzone = (const void *)(addr + rounded_up_size);
> 
> Please check that size is rounded to KASAN_ALLOCA_REDZONE_SIZE. That's
> the expectation, right? That can change is clang silently.
> 
>> +       kasan_poison_shadow(left_redzone, KASAN_ALLOCA_REDZONE_SIZE,
>> +                       KASAN_ALLOCA_LEFT);
>> +       kasan_poison_shadow(right_redzone,
>> +                       padding_size + KASAN_ALLOCA_REDZONE_SIZE,
>> +                       KASAN_ALLOCA_RIGHT);
> 
> We also need to poison the unaligned part at the end of the object
> from size to rounded_up_size. You can see how we do it for heap
> objects.

The expectation is that `size' is the exact size of the alloca()ed 
object.  `rounded_up_size' then adds the 0-7 bytes needed to adjust the 
size to the ASAN shadow scale.  So `addr + rounded_up_size' should be 
the correct place to start poisoning.

In retrospect this part of the code was pretty confusing.  How about 
this?  I think its intent is clearer, plus it's a closer match for the 
description in my commit message:

	unsigned long left_redzone_start;
	unsigned long object_end;
	unsigned long right_redzone_start, right_redzone_end;

	left_redzone_start = addr - KASAN_ALLOCA_REDZONE_SIZE;
	kasan_poison_shadow((const void *)left_redzone_start,
			KASAN_ALLOCA_REDZONE_SIZE,
			KASAN_ALLOCA_LEFT);

	object_end = round_up(addr + size, KASAN_SHADOW_SCALE_SIZE);
	right_redzone_start = round_up(object_end, KASAN_ALLOCA_REDZONE_SIZE);
	right_redzone_end = right_redzone_start + KASAN_ALLOCA_REDZONE_SIZE;
	kasan_poison_shadow((const void *)object_end,
			right_redzone_end - object_end,
			KASAN_ALLOCA_RIGHT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
