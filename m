Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3D3D8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:46:30 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w4so2223556wrt.21
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:46:30 -0800 (PST)
Received: from nautica.notk.org (nautica.notk.org. [91.121.71.147])
        by mx.google.com with ESMTPS id l188si22318495wmf.75.2019.01.15.21.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:46:29 -0800 (PST)
Date: Wed, 16 Jan 2019 06:46:13 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190116054613.GA11670@nautica>
References: <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com>
 <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Linus Torvalds wrote on Wed, Jan 16, 2019:
> *Very* few people want to run their databases as root.

In the case of happycache, this isn't the database doing the
dump/restore, but a separate process that could have the cap - it's
better if we can do without though, and from his readme he runs as user
cassandra in the /var/lib/cassandra directory for example so that'd
match the file owner.

For pgfincore, it's a postgres extension so the main process does it -
but it does have files open as write as well as being the owner.

> Jiri's original patch kind of acknowledged that by making the new test
> be conditional, and off by default. So then it's a "only do this for
> lockdown mode, because normal people won't find it acceptable".
> 
> And I'm not a huge fan of that approach. If you don't protect normal
> people, then what's the point, really?

I agree with that. 
"Being owner or has cap" (whichever cap) is probably OK.
On the other hand, writeability check makes more sense in general -
could we somehow check if the user has write access to the file instead
of checking if it currently is opened read-write?

-- 
Dominique
