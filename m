Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F0A7A6B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 18:40:03 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so155186488pac.0
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 15:40:03 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id q3si23515692pap.6.2015.09.27.15.40.01
        for <linux-mm@kvack.org>;
        Sun, 27 Sep 2015 15:40:01 -0700 (PDT)
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com> <20150924093026.GA29699@gmail.com>
 <560435B4.1010603@sr71.net> <20150925071119.GB15753@gmail.com>
 <5605D660.8000009@sr71.net> <20150926062023.GB27841@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5608703E.5070406@sr71.net>
Date: Sun, 27 Sep 2015 15:39:58 -0700
MIME-Version: 1.0
In-Reply-To: <20150926062023.GB27841@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 09/25/2015 11:20 PM, Ingo Molnar wrote:
> * Dave Hansen <dave@sr71.net> wrote:
...
>> Since follow_pte() fails for all huge
>> pages, it just falls back to pulling the protection key out of the VMA,
>> which _does_ work for huge pages.
> 
> That might be true for explicit hugetlb vmas, but what about transparent hugepages 
> that can show up in regular vmas?

All PTEs (large or small) established under a given VMA have the same
protection key.  Any change in protection key for a range will either
change or split the VMA.

So I think it's safe to rely on the VMA entirely.  Well, as least as
safe as the PTE.  It's definitely a wee bit racy, which I'll elaborate
on when I repost the patches.

>> I've actually removed the PTE walking and I just now use the VMA directly.  I 
>> don't see a ton of additional value from walking the page tables when we can get 
>> what we need from the VMA.
> 
> That's actually good, because it's also cheap, especially if we can get rid of the 
> extra find_vma().
> 
> and we (thankfully) have no non-linear vmas to worry about anymore.

Yep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
