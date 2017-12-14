Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3DF6B025E
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:56:05 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so3357925qkl.8
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:56:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c16si4050415qtc.213.2017.12.14.04.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 04:56:04 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBECsMMb111429
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:56:03 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eus58sswr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:56:02 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 14 Dec 2017 12:55:59 -0000
Subject: Re: [PATCH V2] mm/mprotect: Add a cond_resched() inside
 change_pmd_range()
References: <20171214111426.25912-1-khandual@linux.vnet.ibm.com>
 <20171214112928.GH16951@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 14 Dec 2017 18:25:54 +0530
MIME-Version: 1.0
In-Reply-To: <20171214112928.GH16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <28e54a80-73d9-76aa-31d5-f71375f14b96@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 12/14/2017 04:59 PM, Michal Hocko wrote:
> On Thu 14-12-17 16:44:26, Anshuman Khandual wrote:
>> diff --git a/mm/mprotect.c b/mm/mprotect.c
>> index ec39f73..43c29fa 100644
>> --- a/mm/mprotect.c
>> +++ b/mm/mprotect.c
>> @@ -196,6 +196,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>>  		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
>>  				 dirty_accountable, prot_numa);
>>  		pages += this_pages;
>> +		cond_resched();
>>  	} while (pmd++, addr = next, addr != end);
>>  
>>  	if (mni_start)
> 
> this is not exactly what I meant. See how change_huge_pmd does continue.
> That's why I mentioned zap_pmd_range which does goto next...

I might be still missing something but is this what you meant ?
Here we will give cond_resched() cover to the THP backed pages
as well.

diff --git a/mm/mprotect.c b/mm/mprotect.c
index ec39f73..3d445ee 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -188,7 +188,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
                                        }
 
                                        /* huge pmd was handled */
-                                       continue;
+                                       goto next;
                                }
                        }
                        /* fall through, the trans huge pmd just split */
@@ -196,6 +196,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
                this_pages = change_pte_range(vma, pmd, addr, next, newprot,
                                 dirty_accountable, prot_numa);
                pages += this_pages;
+next:
+               cond_resched();
        } while (pmd++, addr = next, addr != end);
 
        if (mni_start)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
