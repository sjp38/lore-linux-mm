Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19A926B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 19:32:13 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f35-v6so10894184plb.10
        for <linux-mm@kvack.org>; Mon, 21 May 2018 16:32:13 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id v4-v6si12031526pgn.260.2018.05.21.16.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 16:32:12 -0700 (PDT)
Subject: Re: Why do we let munmap fail?
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
 <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
 <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com>
 <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
 <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com>
 <CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <20c9acc2-fbaf-f02d-19d7-2498f875e4c0@intel.com>
Date: Mon, 21 May 2018 16:32:10 -0700
MIME-Version: 1.0
In-Reply-To: <CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On 05/21/2018 04:16 PM, Daniel Colascione wrote:
> On Mon, May 21, 2018 at 4:02 PM Dave Hansen <dave.hansen@intel.com> wrote:
> 
>> On 05/21/2018 03:54 PM, Daniel Colascione wrote:
>>>> There are also certainly denial-of-service concerns if you allow
>>>> arbitrary numbers of VMAs.  The rbtree, for instance, is O(log(n)), but
>>>> I 'd be willing to be there are plenty of things that fall over if you
>>>> let the ~65k limit get 10x or 100x larger.
>>> Sure. I'm receptive to the idea of having *some* VMA limit. I just think
>>> it's unacceptable let deallocation routines fail.
>> If you have a resource limit and deallocation consumes resources, you
>> *eventually* have to fail a deallocation.  Right?
> That's why robust software sets aside at allocation time whatever resources
> are needed to make forward progress at deallocation time.

I think there's still a potential dead-end here.  "Deallocation" does
not always free resources.

> That's what I'm trying to propose here, essentially: if we specify
> the VMA limit in terms of pages and not the number of VMAs, we've
> effectively "budgeted" for the worst case of VMA splitting, since in
> the worst case, you end up with one page per VMA.
Not a bad idea, but it's not really how we allocate VMAs today.  You
would somehow need per-process (mm?) slabs.  Such a scheme would
probably, on average, waste half of a page per mm.

> Done this way, we still prevent runaway VMA tree growth, but we can also
> make sure that anyone who's successfully called mmap can successfully call
> munmap.

I'd be curious how this works out, but I bet you end up reserving a lot
more resources than people want.
