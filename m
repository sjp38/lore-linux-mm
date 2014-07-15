Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 66C246B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 07:33:30 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id c1so2785257igq.15
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 04:33:30 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id v8si24260083icx.92.2014.07.15.04.33.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 04:33:29 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so4372389iec.40
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 04:33:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140715105547.C4832E00A3@blue.fi.intel.com>
References: <748020aaaf5c5c2924a16232313e0175.squirrel@webmail.tu-dortmund.de>
	<alpine.LSU.2.11.1407141209160.17242@eggly.anvils>
	<CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
	<20140715105547.C4832E00A3@blue.fi.intel.com>
Date: Tue, 15 Jul 2014 15:33:29 +0400
Message-ID: <CALYGNiM3tQUCvSPxPbum5jkhNOPeKpAVL=x3ggFmZH-QaqULcA@mail.gmail.com>
Subject: Re: PROBLEM: repeated remap_file_pages on tmpfs triggers bug on
 process exit
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Ingo Korb <ingo.korb@tu-dortmund.de>, Ning Qu <quning@google.com>, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jul 15, 2014 at 2:55 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Konstantin Khlebnikov wrote:
>> It seems boundng logic in do_fault_around is wrong:
>>
>> start_addr = max(address & fault_around_mask(), vma->vm_start);
>> off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
>> pte -= off;
>> pgoff -= off;
>>
>> Ok, off  <= 511, but it might be bigger than pte offset in pte table.
>
> I don't see how it possible: fault_around_mask() cannot be more than 0x1ff000
> (x86-64, fault_around_bytes == 2M). It means start_addr will be aligned to 2M
> boundary in this case which is start of the page table pte belong to.
>
> Do I miss something?

Nope, you're right. This fixes kernel crash but not the original problem.

Problem is caused by calling do_fault_around for _non-linear_ faiult.
In this case pgoff is shifted and might become negative during calculation.
I'll send another patch.

>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
