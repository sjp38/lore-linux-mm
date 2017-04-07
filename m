Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 608616B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 09:35:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v44so10552597wrc.9
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 06:35:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i28si7831539wrb.141.2017.04.07.06.35.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 06:35:40 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v37DY22b131124
	for <linux-mm@kvack.org>; Fri, 7 Apr 2017 09:35:39 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29pbrrg1xx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:35:38 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 7 Apr 2017 19:05:35 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v37DZXMR16449626
	for <linux-mm@kvack.org>; Fri, 7 Apr 2017 19:05:33 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v37DZW58010222
	for <linux-mm@kvack.org>; Fri, 7 Apr 2017 19:05:33 +0530
Subject: Re: [PATCH 8/8] x86/mm: Allow to have userspace mappings above
 47-bits
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-9-kirill.shutemov@linux.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 7 Apr 2017 19:05:26 +0530
MIME-Version: 1.0
In-Reply-To: <20170406140106.78087-9-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <8d68093b-670a-7d7e-2216-bf64b19c7a48@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <dsafonov@virtuozzo.com>

On 04/06/2017 07:31 PM, Kirill A. Shutemov wrote:
> On x86, 5-level paging enables 56-bit userspace virtual address space.
> Not all user space is ready to handle wide addresses. It's known that
> at least some JIT compilers use higher bits in pointers to encode their
> information. It collides with valid pointers with 5-level paging and
> leads to crashes.
> 
> To mitigate this, we are not going to allocate virtual address space
> above 47-bit by default.

I am wondering if the commitment of virtual space range to the
user space is kind of an API which needs to be maintained there
after. If that is the case then we need to have some plans when
increasing it from the current level.

Will those JIT compilers keep using the higher bit positions of
the pointer for ever ? Then it will limit the ability of the
kernel to expand the virtual address range later as well. I am
not saying we should not increase till the extent it does not
affect any *known* user but then we should not increase twice
for now, create the hint mechanism to be passed from the user
to avail beyond that (which will settle in as a expectation
from the kernel later on). Do the same thing again while
expanding the address range next time around. I think we need
to have a plan for this and particularly around 'hint' mechanism
and whether it should be decided per mmap() request or at the
task level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
