Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id EA8036B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 17:37:56 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so3994376wib.8
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:37:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id iy13si5938958wic.55.2014.04.22.14.37.54
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 14:37:55 -0700 (PDT)
Date: Tue, 22 Apr 2014 17:37:26 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v3 0/5] hugetlb: add support gigantic page allocation at
 runtime
Message-ID: <20140422173726.738d0635@redhat.com>
In-Reply-To: <20140417160110.3f36b972b25525fbbe23681b@linux-foundation.org>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
	<20140417160110.3f36b972b25525fbbe23681b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, kirill@shutemov.name

On Thu, 17 Apr 2014 16:01:10 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 10 Apr 2014 13:58:40 -0400 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > The HugeTLB subsystem uses the buddy allocator to allocate hugepages during
> > runtime. This means that hugepages allocation during runtime is limited to
> > MAX_ORDER order. For archs supporting gigantic pages (that is, page sizes
> > greater than MAX_ORDER), this in turn means that those pages can't be
> > allocated at runtime.
> 
> Dumb question: what's wrong with just increasing MAX_ORDER?

To be honest I'm not a buddy allocator expert and I'm not familiar with
what is involved in increasing MAX_ORDER. What I do know though is that it's
not just a matter of increasing a macro's value. For example, for sparsemem
support we have this check (include/linux/mmzone.h:1084):

#if (MAX_ORDER - 1 + PAGE_SHIFT) > SECTION_SIZE_BITS
#error Allocator MAX_ORDER exceeds SECTION_SIZE
#endif

I _guess_ it's because we can't allocate more pages than what's within a
section on sparsemem. Can sparsemem and the other stuff be changed to
accommodate a bigger MAX_ORDER? I don't know. Is it worth it to increase
MAX_ORDER and do all the required changes, given that a bigger MAX_ORDER is
only useful for HugeTLB and the archs supporting gigantic pages? I'd guess not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
