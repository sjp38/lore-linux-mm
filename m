Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f78.google.com (mail-pb0-f78.google.com [209.85.160.78])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD136B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 09:14:28 -0500 (EST)
Received: by mail-pb0-f78.google.com with SMTP id jt11so25859pbb.1
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 06:14:27 -0800 (PST)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id va10si8168057pbc.308.2014.02.08.02.27.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Feb 2014 02:27:40 -0800 (PST)
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 110A520C7F
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 05:27:39 -0500 (EST)
Message-ID: <52F60699.8010204@iki.fi>
Date: Sat, 08 Feb 2014 12:27:37 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: Memory allocator semantics
References: <20140102203320.GA27615@linux.vnet.ibm.com>
In-Reply-To: <20140102203320.GA27615@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

Hi Paul,

On 01/02/2014 10:33 PM, Paul E. McKenney wrote:
>  From what I can see, the Linux-kernel's SLAB, SLOB, and SLUB memory
> allocators would deal with the following sort of race:
>
> A.	CPU 0: r1 = kmalloc(...); ACCESS_ONCE(gp) = r1;
>
> 	CPU 1: r2 = ACCESS_ONCE(gp); if (r2) kfree(r2);
>
> However, my guess is that this should be considered an accident of the
> current implementation rather than a feature.  The reason for this is
> that I cannot see how you would usefully do (A) above without also allowing
> (B) and (C) below, both of which look to me to be quite destructive:
>
> B.	CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
>
>          CPU 1: r2 = ACCESS_ONCE(shared_x); if (r2) kfree(r2);
>
> 	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
>
> 	This results in the memory being on two different freelists.
>
> C.      CPU 0: r1 = kmalloc(...);  ACCESS_ONCE(shared_x) = r1;
>
> 	CPU 1: r2 = ACCESS_ONCE(shared_x); r2->a = 1; r2->b = 2;
>
> 	CPU 2: r3 = ACCESS_ONCE(shared_x); if (r3) kfree(r3);
>
> 	CPU 3: r4 = kmalloc(...);  r4->s = 3; r4->t = 4;
>
> 	This results in the memory being used by two different CPUs,
> 	each of which believe that they have sole access.
>
> But I thought I should ask the experts.
>
> So, am I correct that kernel hackers are required to avoid "drive-by"
> kfree()s of kmalloc()ed memory?

So to be completely honest, I don't understand what is the race in (A) 
that concerns the *memory allocator*.  I also don't what the memory 
allocator can do in (B) and (C) which look like double-free and 
use-after-free, respectively, to me. :-)

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
