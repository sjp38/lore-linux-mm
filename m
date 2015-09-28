Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id B44D46B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 01:59:12 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so88050710wic.1
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 22:59:12 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id k9si26467608wif.3.2015.09.27.22.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Sep 2015 22:59:11 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so85189876wic.0
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 22:59:11 -0700 (PDT)
Date: Mon, 28 Sep 2015 07:59:07 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
Message-ID: <20150928055907.GA2684@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com>
 <20150924093026.GA29699@gmail.com>
 <560435B4.1010603@sr71.net>
 <20150925071119.GB15753@gmail.com>
 <5605D660.8000009@sr71.net>
 <20150926062023.GB27841@gmail.com>
 <5608703E.5070406@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5608703E.5070406@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Dave Hansen <dave@sr71.net> wrote:

> On 09/25/2015 11:20 PM, Ingo Molnar wrote:
> > * Dave Hansen <dave@sr71.net> wrote:
> ...
> >> Since follow_pte() fails for all huge
> >> pages, it just falls back to pulling the protection key out of the VMA,
> >> which _does_ work for huge pages.
> > 
> > That might be true for explicit hugetlb vmas, but what about transparent hugepages 
> > that can show up in regular vmas?
> 
> All PTEs (large or small) established under a given VMA have the same
> protection key. [...]

So a 'pte' is only small. The 'large' thing is called a pmd. So follow_pte() is 
not adequate. But with that removed everything should be fine as the vma 
(protection) flags are size independent.

> So I think it's safe to rely on the VMA entirely.  Well, as least as safe as the 
> PTE.  It's definitely a wee bit racy, which I'll elaborate on when I repost the 
> patches.

So the race I can see is wrt. mprotect(), and we should fix that, because the 
existing method of recovering the 'page fault reason', error_code, is not racy - 
so the extension of it (the protection key) should not be racy either.

By the time user-space processes the signal we might race with other threads, but 
at least the fault-address/error-reason information itself should be coherent.

This can be solved by getting the protection key while still under the down_read() 
of the vma - instead of your current solution of a second find_vma().

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
