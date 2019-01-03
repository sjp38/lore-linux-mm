Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 206FE8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 04:44:26 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so33160728edm.18
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 01:44:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si6935349edi.277.2019.01.03.01.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 01:44:24 -0800 (PST)
Date: Thu, 3 Jan 2019 10:44:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 202089] New: transparent hugepage not compatable with
 madvise(MADV_DONTNEED)
Message-ID: <20190103094422.GC31793@dhcp22.suse.cz>
References: <bug-202089-27@https.bugzilla.kernel.org/>
 <20181229125316.27f7f1fedacfe4c1a5551a2d@linux-foundation.org>
 <20181229224843.6vsdj3xomifjocbh@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181229224843.6vsdj3xomifjocbh@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, jianpanlanyue@163.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Sun 30-12-18 01:48:43, Kirill A. Shutemov wrote:
> On Sat, Dec 29, 2018 at 12:53:16PM -0800, Andrew Morton wrote:
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Sat, 29 Dec 2018 09:00:22 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=202089
> > > 
> > >             Bug ID: 202089
> > >            Summary: transparent hugepage not compatable with
> > >                     madvise(MADV_DONTNEED)
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 4.4.0-117
> > >           Hardware: x86-64
> > >                 OS: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: high
> > >           Priority: P1
> > >          Component: Other
> > >           Assignee: akpm@linux-foundation.org
> > >           Reporter: jianpanlanyue@163.com
> > >         Regression: No
> > > 
> > > environment:  
> > >   1.kernel 4.4.0 on x86_64
> > >   2.echo always > /sys/kernel/mm/transparent_hugepage/enable
> > >     echo always > /sys/kernel/mm/transparent_hugepage/defrag
> > >     echo 2000000 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> > > ( faster defrag pages to reproduce problem)
> > > 
> > > problem: 
> > >   1. use mmap() to allocate 4096 bytes for 1024*512 times (4096*1024*512=2G).
> > >   2. use madvise(MADV_DONTNEED) to free most of the above pages, but reserve a
> > > few pages(by if（i%33==0) continue;), then process's physical memory firstly
> > > come down, but after a few seconds, it rise back to 2G again, and can't come
> > > down forever.
> > >   3. if i delete this condition(if（i%33==0) continue;) or disable
> > > transparent_hugepage by setting 'enable' and 'defrag' to never, all go well and
> > > the physical memory can come down expectly.
> > > 
> > >   It seems like transparent_hugepage has problems with non-contiguous
> > > madvise(MADV_DONTEED).
> 
> It's expected behaviour.
> 
> MADV_DONTNEED doesn't guarantee that the range will not be repopulated
> (with or without direct action on application behalf). It's just a hint
> for the kernel.

I agree with Kirill here but I would be interested in the underlying
usecase that triggered this. The test case is clearly artificial but is
any userspace actually relying on MADV_DONTNEED reducing the rss
longterm?

> For sparse mappings, consider using MADV_NOHUGEPAGE.

Yes or use a high threshold for khugepaged for collapsing.
-- 
Michal Hocko
SUSE Labs
