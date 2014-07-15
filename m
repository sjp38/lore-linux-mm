Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1536B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 06:56:03 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so4639220pdj.2
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 03:56:03 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id mt6si1648153pdb.223.2014.07.15.03.56.02
        for <linux-mm@kvack.org>;
        Tue, 15 Jul 2014 03:56:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
References: <748020aaaf5c5c2924a16232313e0175.squirrel@webmail.tu-dortmund.de>
 <alpine.LSU.2.11.1407141209160.17242@eggly.anvils>
 <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
Subject: Re: PROBLEM: repeated remap_file_pages on tmpfs triggers bug on
 process exit
Content-Transfer-Encoding: 7bit
Message-Id: <20140715105547.C4832E00A3@blue.fi.intel.com>
Date: Tue, 15 Jul 2014 13:55:47 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Ingo Korb <ingo.korb@tu-dortmund.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ning Qu <quning@google.com>, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Konstantin Khlebnikov wrote:
> It seems boundng logic in do_fault_around is wrong:
> 
> start_addr = max(address & fault_around_mask(), vma->vm_start);
> off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
> pte -= off;
> pgoff -= off;
> 
> Ok, off  <= 511, but it might be bigger than pte offset in pte table.

I don't see how it possible: fault_around_mask() cannot be more than 0x1ff000
(x86-64, fault_around_bytes == 2M). It means start_addr will be aligned to 2M
boundary in this case which is start of the page table pte belong to.

Do I miss something?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
