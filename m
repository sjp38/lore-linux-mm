Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE0D8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:41:10 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so33954241edd.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:41:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r24si2476912edp.187.2019.01.03.06.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 06:41:08 -0800 (PST)
Date: Thu, 3 Jan 2019 15:41:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 202089] New: transparent hugepage not compatable with
 madvise(MADV_DONTNEED)
Message-ID: <20190103144107.GQ31793@dhcp22.suse.cz>
References: <bug-202089-27@https.bugzilla.kernel.org/>
 <20181229125316.27f7f1fedacfe4c1a5551a2d@linux-foundation.org>
 <20181229224843.6vsdj3xomifjocbh@kshutemo-mobl1>
 <20190103094422.GC31793@dhcp22.suse.cz>
 <20190103143502.GO6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103143502.GO6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, jianpanlanyue@163.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Thu 03-01-19 06:35:02, Matthew Wilcox wrote:
> On Thu, Jan 03, 2019 at 10:44:22AM +0100, Michal Hocko wrote:
> > On Sun 30-12-18 01:48:43, Kirill A. Shutemov wrote:
> > > On Sat, Dec 29, 2018 at 12:53:16PM -0800, Andrew Morton wrote:
> > > > >   1. use mmap() to allocate 4096 bytes for 1024*512 times (4096*1024*512=2G).
> > > > >   2. use madvise(MADV_DONTNEED) to free most of the above pages, but reserve a
> > > > > few pages(by if（i%33==0) continue;), then process's physical memory firstly
> > > > > come down, but after a few seconds, it rise back to 2G again, and can't come
> > > > > down forever.
> > > > >   3. if i delete this condition(if（i%33==0) continue;) or disable
> > > > > transparent_hugepage by setting 'enable' and 'defrag' to never, all go well and
> > > > > the physical memory can come down expectly.
> > > > > 
> > > > >   It seems like transparent_hugepage has problems with non-contiguous
> > > > > madvise(MADV_DONTEED).
> > > 
> > > It's expected behaviour.
> > > 
> > > MADV_DONTNEED doesn't guarantee that the range will not be repopulated
> > > (with or without direct action on application behalf). It's just a hint
> > > for the kernel.
> > 
> > I agree with Kirill here but I would be interested in the underlying
> > usecase that triggered this. The test case is clearly artificial but is
> > any userspace actually relying on MADV_DONTNEED reducing the rss
> > longterm?
> > 
> > > For sparse mappings, consider using MADV_NOHUGEPAGE.
> 
> Should the MADV_DONTNEED hint imply MADV_NOHUGEPAGE?  It'd prevent
> coalescing elsewhere in the VMA, so that might negatively affect other
> programs.

I really do not think this is a good idea. MADV_DONTEED doesn't really
imply anything to future rss. It only wipes out the current content.
In other words do we want to stop fault around/readahead or any other
optimistic faulting on MADV_DONTEED?

-- 
Michal Hocko
SUSE Labs
