Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14A1B6B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 04:27:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z83so8582959wmc.2
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 01:27:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s35si1078462eda.464.2018.04.04.01.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 01:27:04 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w348QMZE030379
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 04:27:03 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h4tv4rvnx-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 04:26:25 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 09:25:06 +0100
Subject: Re: [PATCH v9 09/24] mm: protect mremap() against SPF hanlder
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-10-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803271500540.43106@chino.kir.corp.google.com>
 <1fe7529a-947c-fdb2-12d2-b38bdd41bb04@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803281419460.167685@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 4 Apr 2018 10:24:55 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803281419460.167685@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e9602fb6-7f74-58e0-2567-9c84b63e3383@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 28/03/2018 23:21, David Rientjes wrote:
> On Wed, 28 Mar 2018, Laurent Dufour wrote:
> 
>>>> @@ -326,7 +336,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>>>>  		mremap_userfaultfd_prep(new_vma, uf);
>>>>  		arch_remap(mm, old_addr, old_addr + old_len,
>>>>  			   new_addr, new_addr + new_len);
>>>> +		if (vma != new_vma)
>>>> +			vm_raw_write_end(vma);
>>>>  	}
>>>> +	vm_raw_write_end(new_vma);
>>>
>>> Just do
>>>
>>> vm_raw_write_end(vma);
>>> vm_raw_write_end(new_vma);
>>>
>>> here.
>>
>> Are you sure ? we can have vma = new_vma done if (unlikely(err))
>>
> 
> Sorry, what I meant was do
> 
> if (vma != new_vma)
> 	vm_raw_write_end(vma);
> vm_raw_write_end(new_vma);
> 
> after the conditional.  Having the locking unnecessarily embedded in the 
> conditional has been an issue in the past with other areas of core code, 
> unless you have a strong reason for it.

Unfortunately, I can't see how doing this in another way since vma = new_vma is
done in the error branch.
So releasing the VMAs outside of the conditional may lead to miss 'vma' if the
error branch is taken.

Here is the code snippet as a reminder:

	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff,
			   &need_rmap_locks);
	[...]
	if (vma != new_vma)
		vm_raw_write_begin(vma);
	[...]
	if (unlikely(err)) {
		[...]
		if (vma != new_vma)
			vm_raw_write_end(vma);
		vma = new_vma; <<<< here we lost reference to vma
		[...]
	} else {
		[...]
		if (vma != new_vma)
			vm_raw_write_end(vma);
	}
	vm_raw_write_end(new_vma);
