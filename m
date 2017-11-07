Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB206B02CB
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 08:46:15 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id h9so9362147qtc.2
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 05:46:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o11si1163668qto.480.2017.11.07.05.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 05:46:14 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA7DjlkV032618
	for <linux-mm@kvack.org>; Tue, 7 Nov 2017 08:46:13 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e3dn2sahk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Nov 2017 08:46:12 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 7 Nov 2017 08:46:10 -0500
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <20171105231850.5e313e46@roar.ozlabs.ibm.com>
 <871slcszfl.fsf@linux.vnet.ibm.com>
 <20171106174707.19f6c495@roar.ozlabs.ibm.com>
 <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
 <20171106192524.12ea3187@roar.ozlabs.ibm.com>
 <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
 <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
 <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
 <20171107111543.ep57evfxxbwwlhdh@node.shutemov.name>
 <20171107222228.0c8a50ff@roar.ozlabs.ibm.com>
 <20171107122825.posamr2dmzlzvs2p@node.shutemov.name>
 <20171108002448.6799462e@roar.ozlabs.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 7 Nov 2017 19:15:58 +0530
MIME-Version: 1.0
In-Reply-To: <20171108002448.6799462e@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <2ce0a91c-985c-aad8-abfa-e91bc088bb3e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Florian Weimer <fweimer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


> 
> If it is decided to keep these kind of heuristics, can we get just a
> small but reasonably precise description of each change to the
> interface and ways for using the new functionality, such that would be
> suitable for the man page? I couldn't fix powerpc because nothing
> matches and even Aneesh and you differ on some details (MAP_FIXED
> behaviour).


I would consider MAP_FIXED as my mistake. We never discussed this 
explicitly and I kind of assumed it to behave the same way. ie, we 
search in lower address space (128TB) if the hint addr is below 128TB.

IIUC we agree on the below.

1) MAP_FIXED allow the addr to be used, even if hint addr is below 128TB 
but hint_addr + len is > 128TB.

2) For everything else we search in < 128TB space if hint addr is below 
128TB

3) We don't switch to large address space if hint_addr + len > 128TB. 
The decision to switch to large address space is primarily based on hint 
addr

Is there any other rule we need to outline? Or is any of the above not 
correct?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
