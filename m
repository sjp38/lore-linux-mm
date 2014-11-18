Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7796E6B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 21:42:11 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id z107so15873010qgd.4
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 18:42:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r10si66553821qat.106.2014.11.17.18.42.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Nov 2014 18:42:10 -0800 (PST)
Message-ID: <546AB1F5.6030306@redhat.com>
Date: Mon, 17 Nov 2014 21:41:57 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
References: <502D42E5.7090403@redhat.com> <20120818000312.GA4262@evergreen.ssec.wisc.edu> <502F100A.1080401@redhat.com> <alpine.LSU.2.00.1208200032450.24855@eggly.anvils> <CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com> <20120822032057.GA30871@google.com> <50345232.4090002@redhat.com> <20130603195003.GA31275@evergreen.ssec.wisc.edu> <20141114163053.GA6547@cosmos.ssec.wisc.edu> <20141117160212.b86d031e1870601240b0131d@linux-foundation.org> <20141118014135.GA17252@cosmos.ssec.wisc.edu>
In-Reply-To: <20141118014135.GA17252@cosmos.ssec.wisc.edu>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 11/17/2014 08:41 PM, Daniel Forrest wrote:
> On Mon, Nov 17, 2014 at 04:02:12PM -0800, Andrew Morton wrote:
>> On Fri, 14 Nov 2014 10:30:53 -0600 Daniel Forrest
>> <dan.forrest@ssec.wisc.edu> wrote:
>> 
>>> There have been a couple of inquiries about the status of this
>>> patch over the last few months, so I am going to try pushing it
>>> out.
>>> 
>>> Andrea Arcangeli has commented:
>>> 
>>>> Agreed. The only thing I don't like about this patch is the
>>>> hardcoding of number 5: could we make it a variable to tweak
>>>> with sysfs/sysctl so if some weird workload arises we have a
>>>> tuning tweak? It'd cost one cacheline during fork, so it
>>>> doesn't look excessive overhead.
>>> 
>>> Adding this is beyond my experience level, so if it is required
>>> then someone else will have to make it so.
>>> 
>>> Rik van Riel has commented:
>>> 
>>>> I believe we should just merge that patch.
>>>> 
>>>> I have not seen any better ideas come by.
>>>> 
>>>> The comment should probably be fixed to reflect the chain
>>>> length of 5 though :)
>>> 
>>> So here is Michel's patch again with "(length > 1)" modified
>>> to "(length > 5)" and fixed comments.
>>> 
>>> I have been running with this patch (with the threshold set to
>>> 5) for over two years now and it does indeed solve the
>>> problem.
>>> 
>>> ---
>>> 
>>> anon_vma_clone() is modified to return the length of the
>>> existing same_vma anon vma chain, and we create a new anon_vma
>>> in the child if it is more than five forks after the anon_vma
>>> was created, as we don't want the same_vma chain to grow
>>> arbitrarily large.
>> 
>> hoo boy, what's going on here.
>> 
>> - Under what circumstances are we seeing this slab windup?
> 
> The original bug report is here:
> 
> https://lkml.org/lkml/2012/8/15/765
> 
>> - What are the consequences?  Can it OOM the machine?
> 
> Yes, eventually you run out of SLAB space.
> 
>> - Why is this occurring?  There aren't an infinite number of
>> vmas, so there shouldn't be an infinite number of anon_vmas or 
>> anon_vma_chains.
> 
> Because of the serial forking there does indeed end up being an
> infinite number of vmas.  The initial vma can never be deleted
> (even though the initial parent process has long since terminated)
> because the initial vma is referenced by the children.

There is a finite number of VMAs, but an infite number of
anon_vmas.

Subtle, yet deadly...

>> - IOW, what has to be done to fix this properly?
> 
> As far as I know, this is the best solution.  I tried a
> refcounting solution based on comments by Rik van Riel:
> 
> https://lkml.org/lkml/2012/8/17/536
> 
> But it didn't fully work, probably because I didn't quite get the 
> locking done properly.  In any case, at this point questions came
> up about the overhead of the page refcounting and Michel
> Lespinasse suggested the initial version of this patch:
> 
> https://lkml.org/lkml/2012/8/21/730
> 
>> - What are the runtime consequences of limiting the length of the
>> chain?
> 
> I can't say, but it only affects users who fork more than five
> levels deep without doing an exec.  On the other hand, there are at
> least three users (Tim Hartrick, Michal Hocko, and myself) who have
> real world applications where the consequence of no patch is a
> crashed system.
> 
> I would suggest reading the thread starting with my initial bug
> report for what others have had to say about this.

I suspect what Andrew is hinting at is that the
changelog for the patch should contain a detailed
description of exactly what the bug is, how it is
triggered, what the symptoms are, and how the
patch avoids it.

That way people can understand what the code does
simply by looking at the changelog - no need to go
find old linux-kernel mailing list threads.

>>> ...
>>> 
>>> @@ -331,10 +334,17 @@ int anon_vma_fork(struct vm_area_struct
>>> *vma, struct vm_area_struct *pvma) * First, attach the new VMA
>>> to the parent VMA's anon_vmas, * so rmap can find non-COWed
>>> pages in child processes. */ -	if (anon_vma_clone(vma, pvma)) +
>>> length = anon_vma_clone(vma, pvma); +	if (length < 0) return
>>> -ENOMEM;
>> 
>> This should propagate the anon_vma_clone() return val instead of 
>> assuming ENOMEM.  But that won't fix anything...
> 
> Agreed, but the only failure return value of anon_vma_clone is
> -ENOMEM.
> 
> Scanning the code in __split_vma (mm/mmap.c) it looks like the
> error return is lost (between Linux 3.11 and 3.12 the err variable
> is now used before the call to anon_vma_clone and the default
> initial value of -ENOMEM is overwritten).  This is an actual bug in
> the current code.
> 
> I can update the patch to fix these issues.
> 
>>> +	else if (length > 5) +		return 0;
>>> 
>>> -	/* Then add our own anon_vma. */ +	/* +	 * Then add our own
>>> anon_vma. We do this only for five forks after +	 * the
>>> anon_vma was created, as we don't want the same_vma chain to +
>>> * grow arbitrarily large. +	 */ anon_vma = anon_vma_alloc();
> 


- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUarH1AAoJEM553pKExN6DXwUH/RHNwGTYhzzwIQtbtMqnHYjE
YWriqPLIOW8yWh85hkrmTsjWIegbDnEsbgNRX0Y8ANrKgx+vWRRW/eJ/s+Z+m7UY
lD1DKO3vIfUSQvL4QHnViTEgEHfdychnhe0SE/kMeQbnLpUw8ywviJxX0UibeLdK
L/F8xMzpUj/PBkNTtPxQRevWwUEMMMY6RS8RjHNBADe9ym/Fjd0dzAkoPCYCUapT
barWfI9RMC3gYfyObFNBNYyaYyyK1FlAyBq52d/W8xCBW/5EIhEtFBGben/lAuEP
alJt+jnFq4B1tXQtJIu1YBhY4OhuqWQy5lbz7NFPxg8+cECVPd3Vq6O2Bxilz9U=
=GLaM
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
