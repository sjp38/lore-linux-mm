Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 20E716B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 11:33:28 -0400 (EDT)
Received: by igxx6 with SMTP id x6so19291948igx.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:33:28 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id d71si3511810ioe.50.2015.09.08.08.33.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 08:33:27 -0700 (PDT)
Date: Tue, 8 Sep 2015 10:33:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com> <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com> <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
 <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, 8 Sep 2015, Dmitry Vyukov wrote:

> Yes, this is a case of use-after-free bug. But the use-after-free can
> happen only due to memory access reordering in a multithreaded
> environment.
> OK, here is a simpler code snippet:
>
> void *p; // = NULL
>
> // thread 1
> p = kmalloc(8);
>
> // thread 2
> void *r = READ_ONCE(p);
> if (r != NULL)
>     kfree(r);
>
> I would expect that this is illegal code. Is my understanding correct?

This should work. It could be a problem if thread 1 is touching
the object.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
