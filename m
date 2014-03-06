Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id CA1566B0035
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 17:57:36 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id j5so3328865qaq.14
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 14:57:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v2si3984615qaf.6.2014.03.06.14.57.35
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 14:57:36 -0800 (PST)
Message-ID: <5318FC3F.4080204@redhat.com>
Date: Thu, 06 Mar 2014 17:52:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
References: <5318E4BC.50301@oracle.com> <20140306173137.6a23a0b2@cuia.bos.redhat.com>
In-Reply-To: <20140306173137.6a23a0b2@cuia.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mgorman@suse.de, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com

On 03/06/2014 05:31 PM, Rik van Riel wrote:
> On Thu, 06 Mar 2014 16:12:28 -0500
> Sasha Levin <sasha.levin@oracle.com> wrote:
>
>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've hit the
>> following spew. This seems to be introduced by your patch "mm,numa: reorganize change_pmd_range()".
>
> That patch should not introduce any functional changes, except for
> the VM_BUG_ON that catches the fact that we fell through to the 4kB
> pte handling code, despite having just handled a THP pmd...
>
> Does this patch fix the issue?
>
> Mel, am I overlooking anything obvious? :)
>
> ---8<---
>
> Subject: mm,numa,mprotect: always continue after finding a stable thp page
>
> When turning a thp pmds into a NUMA one, change_huge_pmd will
> return 0 when the pmd already is a NUMA pmd.

I did miss something obvious.  In this case, the code returns 1.

> However, change_pmd_range would fall through to the code that
> handles 4kB pages, instead of continuing on to the next pmd.

Maybe the case that I missed is when khugepaged is in the
process of collapsing pages into a transparent huge page?

If the virtual CPU gets de-scheduled by the host for long
enough, it would be possible for khugepaged to run on
another virtual CPU, and turn the pmd into a THP pmd,
before that VM_BUG_ON test.

I see that khugepaged takes the mmap_sem for writing in the
collapse code, and it looks like task_numa_work takes the
mmap_sem for reading, so I guess that may not be possible?

Andrea, would you happen to know what case am I missing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
