Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E08F46B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:30:04 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id e127so107026097pfe.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:30:04 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id s80si51823794pfi.55.2016.02.16.07.30.04
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 07:30:04 -0800 (PST)
Subject: Re: [PATCHv2 04/28] mm: make remove_migration_ptes() beyond
 mm/migration.c
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-5-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE0E62.60806@intel.com> <20160216095428.GB46557@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56C34073.6010208@intel.com>
Date: Tue, 16 Feb 2016 07:29:55 -0800
MIME-Version: 1.0
In-Reply-To: <20160216095428.GB46557@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/16/2016 01:54 AM, Kirill A. Shutemov wrote:
> On Fri, Feb 12, 2016 at 08:54:58AM -0800, Dave Hansen wrote:
>> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote
>>> We also shouldn't try to mlock() pte-mapped huge pages: pte-mapeed THP
>>> pages are never mlocked.
>>
>> That's kinda subtle.  Can you explain more?
>>
>> If we did the following:
>>
>> 	ptr = mmap(NULL, 512*PAGE_SIZE, ...);
>> 	mlock(ptr, 512*PAGE_SIZE);
>> 	fork();
>> 	munmap(ptr + 100 * PAGE_SIZE, PAGE_SIZE);
>>
>> I'd expect to get two processes, each mapping the same compound THP, one
>> with a PMD and the other with 511 ptes and one hole.  Is there something
>> different that goes on?
> 
> I'm not sure what exactly you want to ask with this code, but it will have
> the following result:
> 
>  - After fork() process will split the pmd in munlock(). For file thp
>    split pmd, means clear it out. Mapping split_huge_pmd() would munlock
>    the page as we do for anon thp;
> 
>  - In child process the page is never mapped as mlock() is not inherited
>    and we don't copy page tables for shared VMA as they can re-faulted
>    later;

Huh, I didn't realize we don't inherit mlock() across fork(). Learn
something every day!

> The basic semantic for mlock()ed file THP would be the same as for anon
> THP: we only keep the page mlocked as long as it's mapped only with PMDs.
> This way it's relatively simple to make sure that we don't leak mlocked
> pages.

Ahh, I forgot about that bit.  Could you add some of that description to
the changelog so I don't forget again?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
