Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9246B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 01:46:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so89618393wme.0
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:46:52 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id 74si18609463lfu.25.2016.05.08.22.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 22:46:50 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id j8so187689439lfd.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:46:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160508085045.GA27394@yury-N73SV>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <20160507102505.GA27794@yury-N73SV> <20E775CA4D599049A25800DE5799F6DD1F62744C@G4W3225.americas.hpqcorp.net>
 <20160508085045.GA27394@yury-N73SV>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 May 2016 07:46:31 +0200
Message-ID: <CACT4Y+Zdy+cyfZ2dqnbZMn3edVteuQTyTswjL83JquFbhcPpTA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "glider@google.com" <glider@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "klimov.linux@gmail.com" <klimov.linux@gmail.com>

On Sun, May 8, 2016 at 11:17 AM, Yury Norov <ynorov@caviumnetworks.com> wrote:
> On Sat, May 07, 2016 at 03:15:59PM +0000, Luruo, Kuthonuzo wrote:
>> Thank you for the review!
>>
>> > > + switch (alloc_data.state) {
>> > > + case KASAN_STATE_QUARANTINE:
>> > > + case KASAN_STATE_FREE:
>> > > +         kasan_report((unsigned long)object, 0, false,
>> > > +                         (unsigned long)__builtin_return_address(1));
>> >
>> > __builtin_return_address() is unsafe if argument is non-zero. Use
>> > return_address() instead.
>>
>> hmm, I/cscope can't seem to find an x86 implementation for return_address().
>> Will dig further; thanks.
>>
>
> It seems there's no generic interface to obtain return address. x86
> has  working __builtin_return_address() and it's ok with it, others
> use their own return_adderss(), and ok as well.
>
> I think unification is needed here.


We use _RET_IP_ in other places in portable part of kasan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
