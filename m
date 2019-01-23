Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id E547D8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:35:53 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id e8-v6so949371ljg.22
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:35:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor3112783ljg.0.2019.01.23.12.35.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 12:35:52 -0800 (PST)
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com. [209.85.208.173])
        by smtp.gmail.com with ESMTPSA id q3sm635025lff.42.2019.01.23.12.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:35:49 -0800 (PST)
Received: by mail-lj1-f173.google.com with SMTP id t18-v6so3186856ljd.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:35:49 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
In-Reply-To: <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Jan 2019 09:35:32 +1300
Message-ID: <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 24, 2019 at 9:27 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I've reverted the 'let's try to just remove the code' part in my tree.
> But I didn't apply the two other patches yet. Any final comments
> before that should happen?

Side note: the inode_permission() addition to can_do_mincore() in that
patch 0002, seems to be questionable. We do

+static inline bool can_do_mincore(struct vm_area_struct *vma)
+{
+       return vma_is_anonymous(vma)
+               || (vma->vm_file && (vma->vm_file->f_mode & FMODE_WRITE))
+               || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
+}

note how it tests whether vma->vm_file is NULL for the FMODE_WRITE
test, but not for the inode_permission() test.

So either we test unnecessarily in the second line, or we don't
properly test it in the third one.

I think the "test vm_file" thing may be unnecessary, because a
non-anonymous mapping should always have a file pointer and an inode.
But I could  imagine some odd case (vdso mapping, anyone?) that
doesn't have a vm_file, but also isn't anonymous.

Anybody?

Anyway, it's one reason why I didn't actually apply those other two
patches yet. This may be a 5.1 issue..

                   Linus
