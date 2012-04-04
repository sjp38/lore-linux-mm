Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 398606B0044
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 05:59:09 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so102777bkw.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 02:59:07 -0700 (PDT)
Message-ID: <4F7C1B67.6030300@openvz.org>
Date: Wed, 04 Apr 2012 13:59:03 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: account VMA before forced-COW via /proc/pid/mem
References: <20120402153631.5101.44091.stgit@zurg> <20120403143752.GA5150@redhat.com>
In-Reply-To: <20120403143752.GA5150@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Oleg Nesterov wrote:
> On 04/02, Konstantin Khlebnikov wrote:
>>
>> Currently kernel does not account read-only private mappings into memory commitment.
>> But these mappings can be force-COW-ed in get_user_pages().
>
> Heh. tail -n3 Documentation/vm/overcommit-accounting
> may be you should update it then.

I just wonder how fragile this accounting...

>
> Can't really comment the patch, this is not my area. Still,
>
>> +	down_write(&mm->mmap_sem);
>> +	*pvma = vma = find_vma(mm, addr);
>> +	if (vma&&  vma->vm_start<= addr) {
>> +		ret = vma->vm_end - addr;
>> +		if ((vma->vm_flags&  (VM_ACCOUNT | VM_NORESERVE | VM_SHARED |
>> +				VM_HUGETLB | VM_MAYWRITE)) == VM_MAYWRITE) {
>> +			if (!security_vm_enough_memory_mm(mm, vma_pages(vma)))
>
> Oooooh, the whole vma. Say, gdb installs the single breakpoint into
> the huge .text mapping...

We cannot split vma right there, this will be really weird. =)

>
> I am not sure, but probably you want to check at least VM_IO/PFNMAP
> as well. We do not want to charge this memory and retry with FOLL_FORCE
> before vm_ops->access(). Say, /dev/mem

No, VM_IO/PFNMAP aren't affect accounting, there is VM_NORESERVE for this.

>
> Hmm. OTOH, if I am right then mprotect_fixup() should be fixed??

mprotect_fixup() does not account area if it already accounted, so all ok.

>
>
> We drop ->mmap_sem... Say, the task does mremap() in between and
> len == 2 * PAGE_SIZE. Then, for example, copy_to_user_page() can
> write to the same page twice. Perhaps not a problem in practice,
> I dunno.

I have an old unfinished patch which implements upgrade_read() for rw-semaphore =)

 >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
