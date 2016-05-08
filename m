Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4A6E6B0005
	for <linux-mm@kvack.org>; Sun,  8 May 2016 05:17:17 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x67so296422612oix.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 02:17:17 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0090.outbound.protection.outlook.com. [157.56.111.90])
        by mx.google.com with ESMTPS id cj1si19552363igb.65.2016.05.08.02.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 08 May 2016 02:17:17 -0700 (PDT)
Date: Sun, 8 May 2016 12:17:02 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
Message-ID: <20160508085045.GA27394@yury-N73SV>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <20160507102505.GA27794@yury-N73SV>
 <20E775CA4D599049A25800DE5799F6DD1F62744C@G4W3225.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F62744C@G4W3225.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "klimov.linux@gmail.com" <klimov.linux@gmail.com>

On Sat, May 07, 2016 at 03:15:59PM +0000, Luruo, Kuthonuzo wrote:
> Thank you for the review!
> 
> > > +	switch (alloc_data.state) {
> > > +	case KASAN_STATE_QUARANTINE:
> > > +	case KASAN_STATE_FREE:
> > > +		kasan_report((unsigned long)object, 0, false,
> > > +				(unsigned long)__builtin_return_address(1));
> > 
> > __builtin_return_address() is unsafe if argument is non-zero. Use
> > return_address() instead.
> 
> hmm, I/cscope can't seem to find an x86 implementation for return_address().
> Will dig further; thanks.
> 

It seems there's no generic interface to obtain return address. x86
has  working __builtin_return_address() and it's ok with it, others
use their own return_adderss(), and ok as well.

I think unification is needed here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
