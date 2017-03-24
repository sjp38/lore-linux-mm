Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8916B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 13:09:42 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id n141so8146222qke.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 10:09:42 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id i5si2448812qtb.52.2017.03.24.10.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 10:09:41 -0700 (PDT)
Message-ID: <58D552D2.9030307@sent.com>
Date: Fri, 24 Mar 2017 12:09:38 -0500
From: Zi Yan <zi.yan@sent.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 06/11] mm: thp: check pmd migration entry in common
 path
References: <20170313154507.3647-1-zi.yan@sent.com> <20170313154507.3647-7-zi.yan@sent.com> <20170324145042.bda52glerop5wydx@node.shutemov.name> <58D544B5.20102@cs.rutgers.edu> <20170324165014.2ibdmurirjd4pa7r@node.shutemov.name>
In-Reply-To: <20170324165014.2ibdmurirjd4pa7r@node.shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, dnellans@nvidia.com



Kirill A. Shutemov wrote:
> On Fri, Mar 24, 2017 at 11:09:25AM -0500, Zi Yan wrote:
>> Kirill A. Shutemov wrote:
>>> On Mon, Mar 13, 2017 at 11:45:02AM -0400, Zi Yan wrote:
>>> Again. That's doesn't look right..
>> It will be changed:
>>
>>  	ptl = pmd_lock(mm, pmd);
>> +retry_locked:
>> +	if (unlikely(!pmd_present(*pmd))) {
>> +		if (likely(!(flags & FOLL_MIGRATION))) {
>> +			spin_unlock(ptl);
>> +			return no_page_table(vma, flags);
>> +		}
>> +		pmd_migration_entry_wait(mm, pmd);
>> +		goto retry_locked;
> 
> Nope. pmd_migration_entry_wait() unlocks the ptl.

Right. This chunk is wrong. pmd_migrtion_entry_wait() actually locks
pmd, then unlocks it and waits on the page if it is suitable.

An simple fix could be:

+retry_locked:
 	ptl = pmd_lock(mm, pmd);
+	if (unlikely(!pmd_present(*pmd))) {
+	        spin_unlock(ptl);
+		if (likely(!(flags & FOLL_MIGRATION)))
+			return no_page_table(vma, flags);
+		pmd_migration_entry_wait(mm, pmd);
+		goto retry_locked;
+       }

Or is it better to change pmd_migration_entry_wait() to
void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
spinlock_t *ptl)? So that if ptl is NULL, then it takes the pmd lock and
unlocks it; if ptl is specified, it only unlocks it. This can avoid the
redundant unlock and lock in the code above, when
pmd_migration_entry_wait() is called.

Thanks.

--
Best Regards,
Yan Zi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
