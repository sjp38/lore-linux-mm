Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2055B6B0007
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 23:24:08 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 6 Mar 2013 09:51:55 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id AC2AA394004F
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:54:01 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r264NwGK25100434
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 09:53:58 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r264O0tP005021
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 15:24:01 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 07/24] powerpc: Add size argument to pgtable_cache_add
In-Reply-To: <20130305015041.GA2888@iris.ozlabs.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304051340.GC27523@drongo> <871ubv2zsv.fsf@linux.vnet.ibm.com> <20130305015041.GA2888@iris.ozlabs.ibm.com>
Date: Wed, 06 Mar 2013 09:53:59 +0530
Message-ID: <87d2vd88bk.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Mon, Mar 04, 2013 at 04:32:24PM +0530, Aneesh Kumar K.V wrote:
>> 
>> Now with table_size argument, the first arg is no more the shift value,
>> rather it is index into the array. Hence i changed the variable name. I
>> will split that patch to make it easy for review.
>
> OK, so you're saying that the simple relation between index and the
> size of the objects in PGT_CACHE(index) no longer holds. That worries
> me, because now, what guarantees that two callers won't use the same
> index value with two different sizes?  And what guarantees that we
> won't have two callers using different index values but the same size
> (which wouldn't be a disaster but would be a waste of space)?
>
> I think it would be preferable to keep the relation between shift and
> the size of the objects and just arrange to use a different shift
> value for the pmd objects when you need to.

Most of the places we get the cache pointer by doing something like.
PGT_CACHE(PMD_INDEX_SIZE). What we need is that kmem_cache to return an
object twice the size of PMD_TABLE_SIZE. The relevant diff in the later
patch is below.

+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/*
+	 * we store the pgtable details in the second half of PMD
+	 */
+	if (PGT_CACHE(PMD_INDEX_SIZE))
+		pr_err("PMD Page cache already initialized with different size\n");
+	__pgtable_cache_add(PMD_INDEX_SIZE, PMD_TABLE_SIZE * 2, pmd_ctor);
+#else
 	pgtable_cache_add(PMD_INDEX_SIZE, pmd_ctor);
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
