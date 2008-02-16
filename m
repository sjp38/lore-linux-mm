Message-ID: <47B73F81.7090907@qumranet.com>
Date: Sat, 16 Feb 2008 21:54:41 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [patch 3/6] mmu_notifier: invalidate_page callbacks
References: <20080215064859.384203497@sgi.com> <20080215064932.918191502@sgi.com> <20080215193736.9d6e7da3.akpm@linux-foundation.org> <Pine.LNX.4.64.0802161121130.25573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802161121130.25573@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 15 Feb 2008, Andrew Morton wrote:
>
>   
>>> @@ -287,7 +288,8 @@ static int page_referenced_one(struct pa
>>>  	if (vma->vm_flags & VM_LOCKED) {
>>>  		referenced++;
>>>  		*mapcount = 1;	/* break early from loop */
>>> -	} else if (ptep_clear_flush_young(vma, address, pte))
>>> +	} else if (ptep_clear_flush_young(vma, address, pte) |
>>> +		   mmu_notifier_age_page(mm, address))
>>>  		referenced++;
>>>       
>> The "|" is obviously deliberate.  But no explanation is provided telling us
>> why we still call the callback if ptep_clear_flush_young() said the page
>> was recently referenced.  People who read your code will want to understand
>> this.
>>     
>
> Andrea?
>
>   

I'm not Andrea, but the way I read it, ptep_clear_flush_young() and 
->age_page() each have two effects: check whether the page has been 
referenced and clear the referenced bit.  || would retain the semantics 
of the check but lose the clearing.  | does the right thing.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
