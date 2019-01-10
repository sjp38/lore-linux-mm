Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D31C8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:59:34 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p65-v6so3112965ljb.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:59:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6-v6sor44512306lji.26.2019.01.10.13.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 13:59:32 -0800 (PST)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com. [209.85.208.169])
        by smtp.gmail.com with ESMTPSA id q10-v6sm11799894ljj.3.2019.01.10.13.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:59:28 -0800 (PST)
Received: by mail-lj1-f169.google.com with SMTP id s5-v6so11085803ljd.12
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:59:28 -0800 (PST)
MIME-Version: 1.0
References: <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <CALCETrWxwaBUYMg=aLySJByMgXzuzV4gHS0n6O6Oet2Jm6SAbw@mail.gmail.com>
 <20190110144711.GV6310@bombadil.infradead.org> <20190110214427.GK27534@dastard>
In-Reply-To: <20190110214427.GK27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 13:59:12 -0800
Message-ID: <CAHk-=wheEc=K19yJjr4_rkNVxVmyxmbeOoDpwiuNUHZsR-BFBw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andy Lutomirski <luto@kernel.org>, Jiri Kosina <jikos@kernel.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 1:44 PM Dave Chinner <david@fromorbit.com> wrote:
>
> GUP does page fault on user buffer which is a mmapped region of same
> file. page fault sets up for buffered IO, tries to take rwsem for
> write, deadlocks.
>
> Most of the schemes we come up with fall down at this point - you
> can't hold a lock over gup that is also used in the buffered IO
> path. That's why XFS (and now ext4) have the IOLOCK and MMAPLOCK
> for truncation serialisation - we can't lock out both read()/write()
> and mmap IO paths with the same lock...

Side note: a somewhat similar version of is true even in the absence
of GUP and dio, for the case of doing a mmap of a file, and then
reading or writing from the mapped region into the file itself.

There are "interesting" locking scenarios wrt just holding the page
locked, and trying to then fill that page with information with just a
regular "copy_from_user()".

Page fault -> try to read the file -> oops, the page we're trying to
read from is locked because we're trying to write to it.

So we have that odd dance in generic_perform_write() which does

 - touch the first user byte without holding any lock

 - do write_begin() (which gets the page lock)

 - copy from user space using the "atomic" copy (which just gives up on fault)

 - if nothing got copied, go back and try again with a smaller copy
that can't cross a page. We might have raced with pageout.

It might be possible to do something similar for direct IO, although
simpler: just do the GUP entirely atomically (and in the fault case
just fall back to non-direct IO).

            Linus
