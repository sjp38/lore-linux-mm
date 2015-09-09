Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id DF6606B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 11:44:05 -0400 (EDT)
Received: by iofh134 with SMTP id h134so27034864iof.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 08:44:05 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id a19si2576100igr.29.2015.09.09.08.44.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 08:44:04 -0700 (PDT)
Date: Wed, 9 Sep 2015 10:44:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com> <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com> <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
 <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com> <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org> <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com> <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org>
 <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com> <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com> <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Wed, 9 Sep 2015, Dmitry Vyukov wrote:

> Things do not work this way for long time. If you read
> Documentation/memory-barriers.txt or ARM/POWER manual and C language
> standard, you will see that memory accesses from different threads can
> be reordered (as perceived by other threads). So kmalloc still can be
> running when the pointer to the newly allocated object is assigned to
> a global (thus making it available for other threads, which can, in
> particular, call kfree).

Guess this means that cachelines (A) may not have been be written back to
memory when the pointer to the object is written to another cacheline(B)
and that cacheline B arrives at the other processor first which has
outdated cachelines A in its cache? So the other processor uses the
contents of B to get to the pointer to A but then accesses outdated
information since the object contents cachelines (A) have not arrive there
yet?

Ok lets say that is the case then any write attempt to A results in an
exclusive cacheline state and at that point the cacheline is going to
reflect current contents. So if kfree would write to the object then it
will have the current information.

Also what does it matter for kfree since the contents of the object are no
longer in use?

Could you please come up with a concrete example where there is
brokenness that we need to consider.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
