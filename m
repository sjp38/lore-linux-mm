Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id AA5076B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 11:31:18 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so161613738wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 08:31:18 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id cd10si5266881wib.23.2015.09.09.08.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 08:31:17 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so161613160wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 08:31:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
 <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
 <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org> <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com>
 <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org> <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com>
 <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org> <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 9 Sep 2015 17:30:57 +0200
Message-ID: <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Wed, Sep 9, 2015 at 4:36 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 9 Sep 2015, Dmitry Vyukov wrote:
>
>> Yes, the object should not be accessible to other threads when kfree
>> is called. But in all examples above it is accessible.
>
> Ok. Then the code is buggy. If such an access is made then our debugging
> tools will flag that.
>
>> For example, in the last example it is still being accessed by
>> kmalloc. Since there are no memory barriers, kmalloc does not
>> happen-before kfree, it happens concurrently with kfree, thus memory
>
> kmalloc cannot happen concurrently with kfree because the pointer to the
> object is only available after kfree completes. There is therefore an
> ordering implied by the API.
>
>> accesses from kmalloc and kfree can be intermixed.
>
> They cannot be mixed for the same object. kfree cannot run while kmalloc
> is still in progress.

Things do not work this way for long time. If you read
Documentation/memory-barriers.txt or ARM/POWER manual and C language
standard, you will see that memory accesses from different threads can
be reordered (as perceived by other threads). So kmalloc still can be
running when the pointer to the newly allocated object is assigned to
a global (thus making it available for other threads, which can, in
particular, call kfree).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
