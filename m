Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B97846B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 02:32:04 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so12820956pab.19
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 23:32:04 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id hq2si32515717pac.2.2014.12.01.23.32.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 23:32:03 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 2 Dec 2014 17:31:57 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 24FE42CE802D
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 18:31:53 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB27VqE333226962
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 18:31:53 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB27VqLa020262
	for <linux-mm@kvack.org>; Tue, 2 Dec 2014 18:31:52 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
In-Reply-To: <1417473849.7182.9.camel@kernel.crashing.org>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de> <1416578268-19597-4-git-send-email-mgorman@suse.de> <1417473849.7182.9.camel@kernel.crashing.org>
Date: Tue, 02 Dec 2014 13:01:29 +0530
Message-ID: <87h9xeh5im.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Fri, 2014-11-21 at 13:57 +0000, Mel Gorman wrote:
>> void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
>>                 pte_t pte)
>>  {
>> -#ifdef CONFIG_DEBUG_VM
>> -       WARN_ON(pte_val(*ptep) & _PAGE_PRESENT);
>> -#endif
>> +       /*
>> +        * When handling numa faults, we already have the pte marked
>> +        * _PAGE_PRESENT, but we can be sure that it is not in hpte.
>> +        * Hence we can use set_pte_at for them.
>> +        */
>> +       VM_WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
>> +               (_PAGE_PRESENT | _PAGE_USER));
>> +
>
> His is that going to fare with set_pte_at() called for kernel pages ?
>

Yes, we won't capture those errors now. But is there any other debug
check i could use to capture the wrong usage of set_pte_at ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
