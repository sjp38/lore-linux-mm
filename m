Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BA8436B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 13:45:24 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so140329463pdb.3
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 10:45:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ug8si12999126pac.7.2015.03.21.10.45.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Mar 2015 10:45:23 -0700 (PDT)
Message-ID: <550DAE23.7030000@oracle.com>
Date: Sat, 21 Mar 2015 11:45:07 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C37C9.2060200@oracle.com>	<CA+55aFxoVPRuFJGuP_=0-NCiqx_NPeJBv+SAZqbAzeC9AhN+CA@mail.gmail.com>	<550CA3F9.9040201@oracle.com>	<550CB8D1.9030608@oracle.com> <CA+55aFwyuVWHMq_oc_hfwWcu6RaPGSifXD9-adX2_TOa-L+PHA@mail.gmail.com>
In-Reply-To: <CA+55aFwyuVWHMq_oc_hfwWcu6RaPGSifXD9-adX2_TOa-L+PHA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 3/20/15 6:47 PM, Linus Torvalds wrote:
>
>> Here's another data point: If I disable NUMA I don't see the problem.
>> Performance drops, but no NULL pointer splats which would have been panics.
>
> So the NUMA case triggers the per-node "n->shared" logic, which
> *should* be protected by "n->list_lock". Maybe there is some bug there
> - but since that code seems to do ok on x86-64 (and apparently older
> sparc too), I really would look at arch-specific issues first.

You raise a lot of valid questions and something to look into. But if 
the root cause were such a fundamental issue (CPU memory ordering, 
compiler bug, etc) why would it only occur on this one code path -- free 
with SLAB and NUMA -- and so consistently?

Continuing to poke around, but open to any suggestions. I have enabled 
every DEBUG I can find in the memory code and nothing is popping out. In 
terms of races wouldn't all the DEBUG checks affect timing? Yet, I am 
still seeing the same stack traces due to the same root cause.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
