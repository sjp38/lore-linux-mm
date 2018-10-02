Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D05FC6B0270
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:47:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a130-v6so1891329qkb.7
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:47:40 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id z127-v6si11260531qke.342.2018.10.02.07.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Oct 2018 07:47:39 -0700 (PDT)
Date: Tue, 2 Oct 2018 14:47:39 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: disallow obj's allocation on page with mismatched
 pfmemalloc purpose
In-Reply-To: <CAFgQCTtXQkiyr5GJuw1u8J0aW-B8ig_=PKyZCknktYB_rj4TEA@mail.gmail.com>
Message-ID: <01000166353fb3e2-2aa1bed8-26f1-4b9e-a48b-fbf0dd66b1d8-000000@email.amazonses.com>
References: <1537944728-18036-1-git-send-email-kernelfans@gmail.com> <0100016616a8e4ba-fb8d5b4e-27cf-4f4f-b86c-a37d4e08a759-000000@email.amazonses.com> <CAFgQCTtUGs6LkJBiZnH-kiOBUCuFpGEDX+ExvJbRTY6W5-Rh6g@mail.gmail.com>
 <CAFgQCTtXQkiyr5GJuw1u8J0aW-B8ig_=PKyZCknktYB_rj4TEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, 30 Sep 2018, Pingfan Liu wrote:

> > > In the debug case the slab needs to be deactivated. Otherwise the
> > > slowpath will not be used and debug checks on the following objects will
> > > not be done.
> > >
> After taking a more closely look at the debug code, I consider whether
> the alloc_debug_processing() can be also called after get_freelist(s,
> page), then deactivate_slab() is not required . My justification is
> the debug code will take the same code path as the non-debug,  hence
> the page will experience the same transition on different list like
> the non-debug code, and help to detect the bug, also it will improve
> scalability on SMP.
> Besides this, I found the debug code is not scalable well, is it worth
> to work on it?

The debug code is kept out of the hot path intentionally because it does
not scale well and reduces performance. Its compiled in in case we have
to track down a nasty memory corruption bug on a prod kernel that cannot
be easily rebuilt.
