Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 548E16B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 08:14:58 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 39-v6so1148815ple.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 05:14:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a137-v6sor270840pfa.112.2018.07.03.05.14.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 05:14:56 -0700 (PDT)
Date: Tue, 3 Jul 2018 15:14:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180703121450.6aytgmssmf26bgos@kshutemo-mobl1>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180702123350.dktmzlmztulmtrae@kshutemo-mobl1>
 <20180702124928.GQ19043@dhcp22.suse.cz>
 <20180703081205.3ue5722pb3ko4g2w@kshutemo-mobl1>
 <20180703082718.GF16767@dhcp22.suse.cz>
 <20180703091911.hhxhnqpeqb2kn42x@kshutemo-mobl1>
 <20180703113453.GJ16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703113453.GJ16767@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org

On Tue, Jul 03, 2018 at 01:34:53PM +0200, Michal Hocko wrote:
> On Tue 03-07-18 12:19:11, Kirill A. Shutemov wrote:
> > On Tue, Jul 03, 2018 at 10:27:18AM +0200, Michal Hocko wrote:
> > > On Tue 03-07-18 11:12:05, Kirill A. Shutemov wrote:
> > > > On Mon, Jul 02, 2018 at 02:49:28PM +0200, Michal Hocko wrote:
> > > > > On Mon 02-07-18 15:33:50, Kirill A. Shutemov wrote:
> > > > > [...]
> > > > > > I probably miss the explanation somewhere, but what's wrong with allowing
> > > > > > other thread to re-populate the VMA?
> > > > > 
> > > > > We have discussed that earlier and it boils down to how is racy access
> > > > > to munmap supposed to behave. Right now we have either the original
> > > > > content or SEGV. If we allow to simply madvise_dontneed before real
> > > > > unmap we could get a new page as well. There might be (quite broken I
> > > > > would say) user space code that would simply corrupt data silently that
> > > > > way.
> > > > 
> > > > Okay, so we add a lot of complexity to accommodate broken userspace that
> > > > may or may not exist. Is it right? :)
> > > 
> > > I would really love to do the most simple and obious thing
> > > 
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index 336bee8c4e25..86ffb179c3b5 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -2811,6 +2811,8 @@ EXPORT_SYMBOL(vm_munmap);
> > >  SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
> > >  {
> > >  	profile_munmap(addr);
> > > +	if (len > LARGE_NUMBER)
> > > +		do_madvise(addr, len, MADV_DONTNEED);
> > >  	return vm_munmap(addr, len);
> > >  }
> > >  
> > > but the argument that current semantic of good data or SEGV on
> > > racing threads is no longer preserved sounds valid to me. Remember
> > > optimizations shouldn't eat your data. How do we ensure that we won't
> > > corrupt data silently?
> > 
> > +linux-api
> > 
> > Frankly, I don't see change in semantics here.
> > 
> > Code that has race between munmap() and page fault would get intermittent
> > SIGSEGV before and after the approach with simple MADV_DONTNEED.
> 
> prior to this patch you would either get an expected content (if you
> win the race) or SEGV otherwise. With the above change you would get a
> third state - a fresh new page (zero page) if you lost the race half
> way. That sounds like a change of a long term semantic.
> 
> How much that matters is of course a question. Userspace is known to do
> the most unexpected things you never even dreamed of.

I bet nobody would notice the difference.

Let's go the simple way. The price to protect against *theoretical* broken
userspace is too high.

-- 
 Kirill A. Shutemov
