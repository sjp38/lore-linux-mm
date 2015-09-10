Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0E86B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 03:38:50 -0400 (EDT)
Received: by lbcjc2 with SMTP id jc2so18369210lbc.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 00:38:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si10012074wia.121.2015.09.10.00.38.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 00:38:48 -0700 (PDT)
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
References: <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
 <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org>
 <20150910000847.GV4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091917560.22381@east.gentwo.org>
 <20150910011028.GY4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509092047060.3588@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F13387.4030803@suse.cz>
Date: Thu, 10 Sep 2015 09:38:47 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509092047060.3588@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On 09/10/2015 03:47 AM, Christoph Lameter wrote:
> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
> 
>> > But then again kfree() contains a barrier() which would block the compiler
>> > from moving anything into the free path.
>>
>> That barrier() is implicit in the fact that kfree() is an external
>> function?  Or are my eyes failing me?

Is the "external function" not enough? Does it change e.g. with LTO, or is that
also subject to the aliasing rules (which I admit not knowing exactly)?

> 
> kfree at some point calls slab_free(). That function has a barrier. All
> free operations go through it.

SLAB doesn't have such barrier AFAICS. It will put the object on per-cpu cache
and that's it. Only flushing the full cache takes a spin lock.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
