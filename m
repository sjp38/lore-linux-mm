Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D00F66B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 06:54:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h126so7725866wmf.10
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:54:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 37si3241302wrt.403.2017.08.09.03.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 03:54:18 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v79Arf4f118172
	for <linux-mm@kvack.org>; Wed, 9 Aug 2017 06:54:17 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c7x0r1ggf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 09 Aug 2017 06:54:17 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 9 Aug 2017 11:54:14 +0100
Subject: Re: [PATCH 02/16] mm: Prepare for FAULT_FLAG_SPECULATIVE
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170809100835.5kz3zf5sd3oqrrj4@node.shutemov.name>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 9 Aug 2017 12:54:06 +0200
MIME-Version: 1.0
In-Reply-To: <20170809100835.5kz3zf5sd3oqrrj4@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d75b8f01-4fc0-bb29-cf80-0e91d91f238f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 09/08/2017 12:08, Kirill A. Shutemov wrote:
> On Tue, Aug 08, 2017 at 04:35:35PM +0200, Laurent Dufour wrote:
>> @@ -2295,7 +2302,11 @@ static int wp_page_copy(struct vm_fault *vmf)
>>  	/*
>>  	 * Re-check the pte - we dropped the lock
>>  	 */
>> -	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
>> +	if (!pte_map_lock(vmf)) {
>> +		mem_cgroup_cancel_charge(new_page, memcg, false);
>> +		ret = VM_FAULT_RETRY;
>> +		goto oom_free_new;
> 
> With the change, label is misleading.

That's right.
But I'm wondering renaming it out to 'out_free_new' and replacing all the
matching 'goto' where the label was making sense will help readability ?
Have you better idea ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
