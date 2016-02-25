Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 67E816B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:52:42 -0500 (EST)
Received: by mail-qk0-f181.google.com with SMTP id o6so15730611qkc.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 20:52:42 -0800 (PST)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id w132si6393168qka.53.2016.02.24.20.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 20:52:41 -0800 (PST)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 24 Feb 2016 23:52:41 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BD887C90041
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:52:35 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1P4qcE329032658
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:52:38 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1P4qceb018088
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:52:38 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: Problems with swapping in v4.5-rc on POWER
In-Reply-To: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils>
Date: Thu, 25 Feb 2016 10:22:34 +0530
Message-ID: <877fhttmr1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> I've plagiarized the subject from Paulus's "Problems with THP" mail
> last weekend; but my similar problems are on PowerMac G5 baremetal,
> with 4kB pages, not capable of THP and no THP configured in.
>
> Under heavily swapping load, running kernel builds on tmpfs in limited
> memory, I've been seeing random segfaults too, internal compiler errors
> etc.  Not easily reproduced: sometimes happens in minutes, sometimes
> not for several hours.
>
> I tried and failed to construct a reproducer for you: my lack of a good
> recipe has deterred me from reporting it, and seeing Paulus's mail on
> THP gave me hope that the answer would come up in that thread; but no,
> that was quickly resolved as a THP issue, since fixed.
>
> (Mine had appeared to be fixed in v4.5-rc4 anyway; but I guess I
> just didn't try hard enough, it resurfaced on -rc5 immediately.)
>
> I've seen no sign of such problems on x86.  And I saw no sign of such
> problems on v4.4-rc8-mm1, when I included the fixes to the _PAGE_PTE
> and _PAGE_SWP_SOFT_DIRTY swapoff issues we discussed back then (in
> 33 hours of load, should be good enough; but did see such problems
> a couple of times before including those fixes - I took them to be
> a side-effect of the page flags issue, but now rather doubt that).
>

Can you test the impact of the merge listed below ?(ie, revert the merge and see if
we can reproduce and also verify with merge applied). This will give us a
set of commits to look closer. We had quiet a lot of page table
related changes going in this merge window. 

f689b742f217b2ffe7 ("Pull powerpc updates from Michael Ellerman:")

That is the merge commit that added _PAGE_PTE. 


> The minutes or hours thing: I wonder if that indicates a missing
> initialization somewhere: that can easily show up soon after booting,
> but then the machine settles into a steady state of reusing the same
> structures, now initialized; until much later something disturbs the
> state and it has to allocate more.  Sheer speculation, but I wonder.
>


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
