Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DEFE66B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 01:34:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d5so23628523pfg.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 22:34:06 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id x8si360616pfi.574.2017.08.07.22.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Aug 2017 22:34:05 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] mm: ratelimit PFNs busy info message
In-Reply-To: <20170802141720.228502368b534f517e3107ff@linux-foundation.org>
References: <499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com> <20170802141720.228502368b534f517e3107ff@linux-foundation.org>
Date: Tue, 08 Aug 2017 15:34:02 +1000
Message-ID: <87k22eoc6t.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jonathan Toppins <jtoppins@redhat.com>
Cc: linux-mm@kvack.org, linux-rdma@vger.kernel.org, dledford@redhat.com, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, open list <linux-kernel@vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed,  2 Aug 2017 13:44:57 -0400 Jonathan Toppins <jtoppins@redhat.com> wrote:
>
>> The RDMA subsystem can generate several thousand of these messages per
>> second eventually leading to a kernel crash. Ratelimit these messages
>> to prevent this crash.
>
> Well...  why are all these EBUSY's occurring?  It sounds inefficient (at
> least) but if it is expected, normal and unavoidable then perhaps we
> should just remove that message altogether?

We see them on powerpc sometimes when CMA is unable to make large
allocations for the hash table of a KVM guest.

At least in that context they're not useful, CMA will try the
allocation again, and if it really can't allocate then CMA will print
more useful information itself.

So I'd vote for dropping the message and letting the callers decide what
to do.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
