Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 942418E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 23:49:52 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id s64-v6so2916092lje.19
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:49:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4-v6sor2436612ljc.11.2019.01.17.20.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 20:49:50 -0800 (PST)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id k3-v6sm542700lja.8.2019.01.17.20.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 20:49:47 -0800 (PST)
Received: by mail-lf1-f47.google.com with SMTP id c16so9524678lfj.8
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:49:47 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <20190116063430.GA22938@nautica> <CA+t-nXTfdo07EBvVo+mu8SRhrVyB=mEPLDQikHfpJue1jALJtQ@mail.gmail.com>
 <a056deb7-9c11-612e-2b3a-6482acca4ff6@suse.cz>
In-Reply-To: <a056deb7-9c11-612e-2b3a-6482acca4ff6@suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Jan 2019 16:49:30 +1200
Message-ID: <CAHk-=wi0MXm4zTC6jjS1TBfbHW_sQq_OcyfeLBNGJ29m88pt+g@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Josh Snyder <joshs@netflix.com>, Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Fri, Jan 18, 2019 at 9:45 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> Or maybe we could resort to the 5.0-rc1 page table check (that is now being
> reverted) but only in cases when we are not allowed the page cache residency
> check? Or would that be needlessly complicated?

I think it would  be good fallback semantics, but I'm not sure it's
worth it. Have you tried writing a patch for it? I don't think you'd
want to do the check *when* you find a hole, so you'd have to do it
upfront and then pass the cached data down with the private pointer
(or have a separate "struct mm_walk" structure, perhaps?

So I suspect we're better off with the patch we have. But if somebody
*wants* to try to do that fancier patch, and it doesn't look
horrendous, I think it might be the "quality" solution.

              Linus
