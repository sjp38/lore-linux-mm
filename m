Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1A04C6B0044
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 12:24:23 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id ar20so1707890iec.5
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 09:24:22 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id gw5si13108700icb.184.2014.04.28.09.24.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 09:24:22 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id lx4so6846504iec.37
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 09:24:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140428155540.GJ27561@twins.programming.kicks-ass.net>
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
 <2c87e00d633153ba7b710bab12710cc3a58704dd.1398605516.git.nasa4836@gmail.com>
 <20140428145440.GB7839@dhcp22.suse.cz> <CAHz2CGUueeXR2UdLXBRihVN3R8qEUR8wWhpxYjA6pu3ONO0cJA@mail.gmail.com>
 <20140428155540.GJ27561@twins.programming.kicks-ass.net>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 29 Apr 2014 00:23:41 +0800
Message-ID: <CAHz2CGWJjU5U=pDuyzX=L+gev4cpNxkjCnVAvRpY=vO35tBDLg@mail.gmail.com>
Subject: Re: [PATCH RFC 2/2] mm: introdule compound_head_by_tail()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Rik van Riel <riel@redhat.com>, Jiang Liu <liuj97@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, sasha.levin@oracle.com, liwanp@linux.vnet.ibm.com, khalid.aziz@oracle.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 28, 2014 at 11:55 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> What version,

the code snipt in question is extracted from v3.15-rc3.


for the (1) check in previous email, its assembled code looks like:

       --- (1) snipt ---
       mov    (%rdi),%rax                               (a)
       test   $0x80,%ah                                  (b)
       jne    754 <put_compound_page+0x74> (c)
       --- (1) snipt ---

      (a) %rdi is the struct page pointer
      (b) check if PG_tail(0x80) set(likely not set, we tell the compiler)
      (c) if set, jump; not set, fall through (good, credit to  our hint)

===================================================

for the (3) check in previous email, its assembled code looks like:

        --- (3) snipt ---
        mov    (%rdi),%rax                                    (A)
        mov    %rdi,%r12
        test   $0x80,%ah                                      (B)
        jne    8f8 <put_compound_page+0x218>     (C)
        --- (3) snipt ---

      (A) %rdi is the struct page pointer
      (B) check if PG_tail(0x80) set(likely set in this case, but we
tell compiler unlikely)
      (C) if set, jump; not set, fall through (god! it would better
not jump if set,  but we
           tell compiler unlikely, so it happily did as we told it)


# all code are compiled by gcc (GCC) 4.8.2

> and why didn't your changelog include this useful information?

Sorry, I would have done so.  I will resend the patch.

Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
