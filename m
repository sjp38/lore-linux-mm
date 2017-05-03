Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65EB76B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 09:01:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q4so21053124pga.4
        for <linux-mm@kvack.org>; Wed, 03 May 2017 06:01:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k12si2467044pfj.301.2017.05.03.06.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 06:01:26 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v43CwpDG044738
	for <linux-mm@kvack.org>; Wed, 3 May 2017 09:01:25 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a7arv5w6x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 May 2017 09:01:24 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 3 May 2017 14:01:20 +0100
Subject: Re: [RFC v3 03/17] mm: Introduce pte_spinlock
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493308376-23851-4-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170430044700.GF27790@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 3 May 2017 15:01:14 +0200
MIME-Version: 1.0
In-Reply-To: <20170430044700.GF27790@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1b334821-1929-38ed-5316-2a7d135b812d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On 30/04/2017 06:47, Matthew Wilcox wrote:
> On Thu, Apr 27, 2017 at 05:52:42PM +0200, Laurent Dufour wrote:
>> +++ b/mm/memory.c
>> @@ -2100,6 +2100,13 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
>>  }
>>  
>> +static bool pte_spinlock(struct vm_fault *vmf)
>> +{
>> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
>> +	spin_lock(vmf->ptl);
>> +	return true;
>> +}
> 
> To me 'pte_spinlock' is a noun, but this is really pte_spin_lock() (a verb).

Fair enough. Even pte_trylock() should be more accurate since patch 8/17
changes this function to call spin_trylock().

> Actually, it's really vmf_lock_pte().  We're locking the pte
> referred to by this vmf.  And so we should probably have a matching
> vmf_unlock_pte(vmf) to preserve the abstraction.

I'm not sure this will ease the reading. In most of this code, the pte
are unlocked through the call to pte_unmap_unlock().
The call to pte_trylock() has been introduced because in few cases there
is the need to check the VMA validity before calling spinlock(ptl). The
unlock is then managed through pte_unmap_unlock().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
