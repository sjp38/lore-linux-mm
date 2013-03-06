Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 002856B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 00:03:22 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 6 Mar 2013 10:31:09 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 83BE5E004A
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:34:31 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2653Eug25886746
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 10:33:14 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2653Hcb023806
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 16:03:17 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 06/24] powerpc: Reduce PTE table memory wastage
In-Reply-To: <20130305021219.GC2888@iris.ozlabs.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304045853.GB27523@drongo> <874ngr2zz1.fsf@linux.vnet.ibm.com> <20130305021219.GC2888@iris.ozlabs.ibm.com>
Date: Wed, 06 Mar 2013 10:33:16 +0530
Message-ID: <877gll86i3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Mon, Mar 04, 2013 at 04:28:42PM +0530, Aneesh Kumar K.V wrote:
>> The last one that ends up doing atomic_xor_bits which cause the mapcount
>> to go zero, will take the page off the list and free the page. 
>
> No, look at the example again.  page_table_free_rcu() won't take it
> off the list because it uses the (mask & FRAG_MASK) == 0 test, which
> fails (one fragment is still in use).  page_table_free() won't take it
> off the list because it uses the mask == 0 test, which also fails (one
> fragment is still waiting for the RCU grace period).  Finally,
> __page_table_free_rcu() doesn't take it off the list, it just frees
> the page.  Oops. :)


How about the below

--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -425,7 +425,7 @@ void page_table_free(struct mm_struct *mm, unsigned long *table)
        bit = 1 << ((__pa(table) & ~PAGE_MASK) / PTE_FRAG_SIZE);
        spin_lock(&mm->page_table_lock);
        mask = atomic_xor_bits(&page->_mapcount, bit);
-       if (mask == 0)
+       if (!(mask & FRAG_MASK))
                list_del(&page->lru);
        else if (mask & FRAG_MASK) {
                /*
@@ -446,7 +446,7 @@ void page_table_free(struct mm_struct *mm, unsigned long *table)


ie, we always remove the page from the list, when the lower half is
zero or lower half is FRAG_MASK.  We free the page when _mapcount is 0.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
