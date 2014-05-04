Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id E795D6B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 16:42:44 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so4769403eek.20
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:42:44 -0700 (PDT)
Received: from radon.swed.at (b.ns.miles-group.at. [95.130.255.144])
        by mx.google.com with ESMTPS id t3si8185872eeg.91.2014.05.04.13.42.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 04 May 2014 13:42:43 -0700 (PDT)
Message-ID: <5366A63F.9030401@nod.at>
Date: Sun, 04 May 2014 22:42:39 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix force_flush behavior in zap_pte_range()
References: <alpine.LSU.2.11.1404161239320.6778@eggly.anvils>	<1399160247-32093-1-git-send-email-richard@nod.at>	<CA+55aFzbSUPGWyO42KM7geAy8WrP8e=q+KoqdOBY68zay0jrZA@mail.gmail.com>	<5365FB8A.8080303@nod.at> <CA+55aFw9SLeE1fv1-nKMeB7o0YAFZ85mskYy_izCb7Nh3AiicQ@mail.gmail.com>
In-Reply-To: <CA+55aFw9SLeE1fv1-nKMeB7o0YAFZ85mskYy_izCb7Nh3AiicQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>

Am 04.05.2014 20:31, schrieb Linus Torvalds:
>> With your patch applied I see lots of BUG: Bad rss-counter state messages on UML (x86_32)
>> when fuzzing with trinity the mremap syscall.
>> And sometimes I face BUG at mm/filemap.c:202.
> 
> I'm suspecting that it's some UML bug that is triggered by the
> changes. UML has its own tlb gather logic (I'm not quite sure why), I
> wonder what's up.

I cannot tell why UML has it's own tlb gather logic, I suspect nobody
cared so far to clean up the code.
That said, I've converted it today to the generic gather logic and it works.
Sadly I'm still facing the same issues (sigh!).

> Also, are the messages coming from UML or from the host kernel? I'm
> assuming they are UML.

>From UML directly.

>> After killing a trinity child I start observing the said issues.
>>
>> e.g.
>> fix_range_common: failed, killing current process: 841
>> fix_range_common: failed, killing current process: 842
>> fix_range_common: failed, killing current process: 843
>> BUG: Bad rss-counter state mm:28e69600 idx:0 val:2
> 
> That "idx=0" means that it's MM_FILEPAGES. Apparently the killing
> ended up resulting in not freeing all the file mapping pte's.
> 
> So I'm assuming the real issue is that fix_range_common failure that
> triggers this.
> 
> Exactly why the new tlb flushing triggers this is not entirely clear,
> but I'd take a look at how UML reacts to the whole fact that a forced
> flush (which never happened before, because your __tlb_remove_page()
> doesn't batch anything up and always returns 1) updates the tlb
> start/end fields as it does the tlb_flush_mmu_tlbonly().

Thanks for the pointer, I'll dig deeper into the issue.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
