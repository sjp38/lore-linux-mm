Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D75E8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 17:48:47 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id p65-v6so7630899ljb.16
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 14:48:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24-v6sor26249469ljy.1.2018.12.29.14.48.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 14:48:45 -0800 (PST)
Date: Sun, 30 Dec 2018 01:48:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Bug 202089] New: transparent hugepage not compatable with
 madvise(MADV_DONTNEED)
Message-ID: <20181229224843.6vsdj3xomifjocbh@kshutemo-mobl1>
References: <bug-202089-27@https.bugzilla.kernel.org/>
 <20181229125316.27f7f1fedacfe4c1a5551a2d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181229125316.27f7f1fedacfe4c1a5551a2d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, jianpanlanyue@163.com

On Sat, Dec 29, 2018 at 12:53:16PM -0800, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sat, 29 Dec 2018 09:00:22 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=202089
> > 
> >             Bug ID: 202089
> >            Summary: transparent hugepage not compatable with
> >                     madvise(MADV_DONTNEED)
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.4.0-117
> >           Hardware: x86-64
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: jianpanlanyue@163.com
> >         Regression: No
> > 
> > environment:  
> >   1.kernel 4.4.0 on x86_64
> >   2.echo always > /sys/kernel/mm/transparent_hugepage/enable
> >     echo always > /sys/kernel/mm/transparent_hugepage/defrag
> >     echo 2000000 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> > ( faster defrag pages to reproduce problem)
> > 
> > problem: 
> >   1. use mmap() to allocate 4096 bytes for 1024*512 times (4096*1024*512=2G).
> >   2. use madvise(MADV_DONTNEED) to free most of the above pages, but reserve a
> > few pages(by if（i%33==0) continue;), then process's physical memory firstly
> > come down, but after a few seconds, it rise back to 2G again, and can't come
> > down forever.
> >   3. if i delete this condition(if（i%33==0) continue;) or disable
> > transparent_hugepage by setting 'enable' and 'defrag' to never, all go well and
> > the physical memory can come down expectly.
> > 
> >   It seems like transparent_hugepage has problems with non-contiguous
> > madvise(MADV_DONTEED).

It's expected behaviour.

MADV_DONTNEED doesn't guarantee that the range will not be repopulated
(with or without direct action on application behalf). It's just a hint
for the kernel.

For sparse mappings, consider using MADV_NOHUGEPAGE.

-- 
 Kirill A. Shutemov
