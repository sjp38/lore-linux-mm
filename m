Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 926346B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 10:03:02 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so22894283ioi.2
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 07:03:02 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 17si4218395iom.144.2015.09.09.07.02.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 07:02:58 -0700 (PDT)
Date: Wed, 9 Sep 2015 09:02:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com> <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com> <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
 <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com> <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org> <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com> <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org>
 <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, 8 Sep 2015, Dmitry Vyukov wrote:

> > There is no access to p in the first thread. If there are such accesses
> > then they are illegal. A user of slab allocators must ensure that there
> > are no accesses after freeing the object. And since there is a thread
> > that  at random checks p and frees it when not NULL then no other thread
> > would be allowed to touch the object.
>
>
> But the memory allocator itself (kmalloc/kfree) generally reads and
> writes the object (e.g. storing object size in header before object,
> writing redzone in debug mode, reading and checking redzone in debug
> mode, building freelist using first word of the object, etc). There is
> no different between user accesses and memory allocator accesses just
> before returning the object from kmalloc and right after accepting the
> object in kfree.

There is a difference. The object is not accessible to any code before
kmalloc() returns. And it must not be accessible anymore when kfree() is called.
Thus the object is under exclusive control of the allocators when it is
handled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
