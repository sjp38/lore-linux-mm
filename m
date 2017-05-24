Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00DF26B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 10:28:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 8so10070435pgc.12
        for <linux-mm@kvack.org>; Wed, 24 May 2017 07:28:30 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00103.outbound.protection.outlook.com. [40.107.0.103])
        by mx.google.com with ESMTPS id u195si24909904pgc.315.2017.05.24.07.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 May 2017 07:28:30 -0700 (PDT)
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx> <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <aec1376e-34b3-56ce-448e-7fbddcda448b@suse.cz>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <ab5bbeb6-0c61-f505-f365-37ca43415696@virtuozzo.com>
Date: Wed, 24 May 2017 17:28:17 +0300
MIME-Version: 1.0
In-Reply-To: <aec1376e-34b3-56ce-448e-7fbddcda448b@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 05/24/2017 02:31 PM, Vlastimil Babka wrote:
> On 05/24/2017 12:39 PM, Mike Rapoport wrote:
>>> Hm so the prctl does:
>>>
>>>                 if (arg2)
>>>                         me->mm->def_flags |= VM_NOHUGEPAGE;
>>>                 else
>>>                         me->mm->def_flags &= ~VM_NOHUGEPAGE;
>>>
>>> That's rather lazy implementation IMHO. Could we change it so the flag
>>> is stored elsewhere in the mm, and the code that decides to (not) use
>>> THP will check both the per-vma flag and the per-mm flag?
>>
>> I afraid I don't understand how that can help.
>> What we need is an ability to temporarily disable collapse of the pages in
>> VMAs that do not have VM_*HUGEPAGE flags set and that after we re-enable
>> THP, the vma->vm_flags for those VMAs will remain intact.
> 
> That's what I'm saying - instead of implementing the prctl flag via
> mm->def_flags (which gets permanently propagated to newly created vma's
> but e.g. doesn't affect already existing ones), it would be setting a
> flag somewhere in mm, which khugepaged (and page faults) would check in
> addition to the per-vma flags.

I do not insist, but this would make existing paths (checking for flags) be 
2 times slower -- from now on these would need to check two bits (vma flags
and mm flags) which are 100% in different cache lines.

What Mike is proposing is the way to fine-tune the existing vma flags. This
would keep current paths as fast (or slow ;) ) as they are now. All the
complexity would go to rare cases when someone needs to turn thp off for a
while and then turn it back on.

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
