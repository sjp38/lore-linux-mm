Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77FA68E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 18:12:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so1502803edb.22
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:12:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si722550edh.283.2019.01.23.15.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 15:12:50 -0800 (PST)
Date: Thu, 24 Jan 2019 00:12:47 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com> <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com> <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com> <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com> <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com> <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com> <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
 <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com> <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
 <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, 24 Jan 2019, Linus Torvalds wrote:

> Side note: the inode_permission() addition to can_do_mincore() in that
> patch 0002, seems to be questionable. We do
> 
> +static inline bool can_do_mincore(struct vm_area_struct *vma)
> +{
> +       return vma_is_anonymous(vma)
> +               || (vma->vm_file && (vma->vm_file->f_mode & FMODE_WRITE))
> +               || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
> +}
> 
> note how it tests whether vma->vm_file is NULL for the FMODE_WRITE
> test, but not for the inode_permission() test.
> 
> So either we test unnecessarily in the second line, or we don't
> properly test it in the third one.
> 
> I think the "test vm_file" thing may be unnecessary, because a
> non-anonymous mapping should always have a file pointer and an inode.
> But I could  imagine some odd case (vdso mapping, anyone?) that
> doesn't have a vm_file, but also isn't anonymous.

Hmm, good point.

So dropping the 'vma->vm_file' test and checking whether given vma is 
special mapping should hopefully provide the desired semantics, shouldn't 
it?

-- 
Jiri Kosina
SUSE Labs
