Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 28CD36B0037
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 16:19:09 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so3084348eek.8
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 13:19:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v2si14340202eel.166.2014.04.25.13.19.06
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 13:19:07 -0700 (PDT)
Date: Fri, 25 Apr 2014 16:18:35 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v3 0/5] hugetlb: add support gigantic page allocation at
 runtime
Message-ID: <20140425161835.4dda4383@redhat.com>
In-Reply-To: <20140422145546.7e1ddb763072edaa286736f9@linux-foundation.org>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
	<20140417160110.3f36b972b25525fbbe23681b@linux-foundation.org>
	<20140422173726.738d0635@redhat.com>
	<20140422145546.7e1ddb763072edaa286736f9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghai@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, n-horiguchi@ah.jp.nec.com, kirill@shutemov.name

On Tue, 22 Apr 2014 14:55:46 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 22 Apr 2014 17:37:26 -0400 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > On Thu, 17 Apr 2014 16:01:10 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Thu, 10 Apr 2014 13:58:40 -0400 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> > > 
> > > > The HugeTLB subsystem uses the buddy allocator to allocate hugepages during
> > > > runtime. This means that hugepages allocation during runtime is limited to
> > > > MAX_ORDER order. For archs supporting gigantic pages (that is, page sizes
> > > > greater than MAX_ORDER), this in turn means that those pages can't be
> > > > allocated at runtime.
> > > 
> > > Dumb question: what's wrong with just increasing MAX_ORDER?
> > 
> > To be honest I'm not a buddy allocator expert and I'm not familiar with
> > what is involved in increasing MAX_ORDER. What I do know though is that it's
> > not just a matter of increasing a macro's value. For example, for sparsemem
> > support we have this check (include/linux/mmzone.h:1084):
> > 
> > #if (MAX_ORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS
> > #error Allocator MAX_ORDER exceeds SECTION_SIZE
> > #endif
> > 
> > I _guess_ it's because we can't allocate more pages than what's within a
> > section on sparsemem. Can sparsemem and the other stuff be changed to
> > accommodate a bigger MAX_ORDER? I don't know. Is it worth it to increase
> > MAX_ORDER and do all the required changes, given that a bigger MAX_ORDER is
> > only useful for HugeTLB and the archs supporting gigantic pages? I'd guess not.
> 
> afacit we'd need to increase SECTION_SIZE_BITS to 29 or more to
> accommodate 1G MAX_ORDER.  I assume this means that some machines with
> sparse physical memory layout may not be able to use all (or as much)
> of the physical memory.  Perhaps Yinghai can advise?

Yinghai?

> I do think we should fully explore this option before giving up and
> adding new special-case code. 

I'll look into that, but it may take a bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
