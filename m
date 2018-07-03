Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4803F6B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 05:25:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j8-v6so819523pfn.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 02:25:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i13-v6sor171709pgt.420.2018.07.03.02.25.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 02:25:56 -0700 (PDT)
Date: Tue, 3 Jul 2018 12:19:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180703091911.hhxhnqpeqb2kn42x@kshutemo-mobl1>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180702123350.dktmzlmztulmtrae@kshutemo-mobl1>
 <20180702124928.GQ19043@dhcp22.suse.cz>
 <20180703081205.3ue5722pb3ko4g2w@kshutemo-mobl1>
 <20180703082718.GF16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703082718.GF16767@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org

On Tue, Jul 03, 2018 at 10:27:18AM +0200, Michal Hocko wrote:
> On Tue 03-07-18 11:12:05, Kirill A. Shutemov wrote:
> > On Mon, Jul 02, 2018 at 02:49:28PM +0200, Michal Hocko wrote:
> > > On Mon 02-07-18 15:33:50, Kirill A. Shutemov wrote:
> > > [...]
> > > > I probably miss the explanation somewhere, but what's wrong with allowing
> > > > other thread to re-populate the VMA?
> > > 
> > > We have discussed that earlier and it boils down to how is racy access
> > > to munmap supposed to behave. Right now we have either the original
> > > content or SEGV. If we allow to simply madvise_dontneed before real
> > > unmap we could get a new page as well. There might be (quite broken I
> > > would say) user space code that would simply corrupt data silently that
> > > way.
> > 
> > Okay, so we add a lot of complexity to accommodate broken userspace that
> > may or may not exist. Is it right? :)
> 
> I would really love to do the most simple and obious thing
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 336bee8c4e25..86ffb179c3b5 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2811,6 +2811,8 @@ EXPORT_SYMBOL(vm_munmap);
>  SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>  {
>  	profile_munmap(addr);
> +	if (len > LARGE_NUMBER)
> +		do_madvise(addr, len, MADV_DONTNEED);
>  	return vm_munmap(addr, len);
>  }
>  
> but the argument that current semantic of good data or SEGV on
> racing threads is no longer preserved sounds valid to me. Remember
> optimizations shouldn't eat your data. How do we ensure that we won't
> corrupt data silently?

+linux-api

Frankly, I don't see change in semantics here.

Code that has race between munmap() and page fault would get intermittent
SIGSEGV before and after the approach with simple MADV_DONTNEED.

To be safe, I wouldn't go with the optimization if the process has custom
SIGSEGV handler.

> Besides that if this was so simple then we do not even need any kernel
> code. You could do that from glibc resp. any munmap wrapper. So maybe
> the proper answer is, if you do care then just help the system and
> DONTNEED your data before you munmap as an optimization for large
> mappings.

Kernel latency problems have to be handled by kernel.

-- 
 Kirill A. Shutemov
