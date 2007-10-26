Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9Q7gxUN211222
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 07:42:59 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9Q7gw7P2215956
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:42:58 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9Q7gwQk009173
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:42:58 +0200
Subject: Re: [patch 2/6] CONFIG_HIGHPTE vs. sub-page page tables.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1193345221.7018.18.camel@pasglop>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.212545095@de.ibm.com>  <1193345221.7018.18.camel@pasglop>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 09:42:58 +0200
Message-Id: <1193384578.31831.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 06:47 +1000, Benjamin Herrenschmidt wrote:
> > Solution: The only solution I found to this dilemma is a new typedef:
> > a pgtable_t. For s390 pgtable_t will be a (pte *) - to be introduced
> > with a later patch. For everybody else it will be a (struct page *).
> > The additional problem with the initialization of the ptl lock and the
> > NR_PAGETABLE accounting is solved with a constructor pgtable_page_ctor
> > and a destructor pgtable_page_dtor. The page table allocation and free
> > functions need to call these two whenever a page table page is allocated
> > or freed. pmd_populate will get a pgtable_t instead of a struct page
> > pointer. To get the pgtable_t back from a pmd entry that has been
> > installed with pmd_populate a new function pmd_pgtable is added. It
> > replaces the pmd_page call in free_pte_range and apply_to_pte_range.
>
> Interesting. That means I don't need to have a PTE page to be a struct
> page anymore ? I can have good use for that on powerpc as well... 

That would be good news. I'm curious, can you elaborate on what the use
case is?

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
