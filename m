Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDF36B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 03:22:45 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so11864326wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 00:22:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si5738616wia.1.2015.09.10.00.22.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 00:22:44 -0700 (PDT)
Subject: Re: Store Buffers (was Re: Is it OK to pass non-acquired objects to
 kfree?)
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
 <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
 <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F12FC1.2070801@suse.cz>
Date: Thu, 10 Sep 2015 09:22:41 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509091812500.21983@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On 09/10/2015 01:23 AM, Christoph Lameter wrote:
> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
> 
>> > > > A processor that can randomly defer writes to cachelines in the face of
>> > > > other processors owning cachelines exclusively does not seem sane to me.
>> > > > In fact its no longer exclusive.
>> > >
>> > > Welcome to the wonderful world of store buffers, which are present even
>> > > on strongly ordered systems such as x86 and the mainframe.
>> >
>> > Store buffers hold complete cachelines that have been written to by a
>> > processor.
>>
>> In many cases, partial cachelines.  If the cacheline is not available
>> locally, the processor cannot know the contents of the rest of the cache
>> line, only the contents of the portion that it recently stored into.
> 
> For a partial cacheline it would have to read the rest of the cacheline
> before updating. And I would expect the processor to have exclusive access
> to the cacheline that is held in a store buffer. If not then there is
> trouble afoot.

IIRC that (or something similar with same guarantees) basically happens on x86
when you use the LOCK prefix, i.e. for atomic inc etc. Doing that always would
destroy performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
