Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A2C226B0092
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 11:42:03 -0400 (EDT)
Date: Wed, 4 Apr 2012 17:41:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH RFC] mm: account VMA before forced-COW via /proc/pid/mem
Message-ID: <20120404154148.GA7105@redhat.com>
References: <20120402153631.5101.44091.stgit@zurg> <20120403143752.GA5150@redhat.com> <4F7C1B67.6030300@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F7C1B67.6030300@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 04/04, Konstantin Khlebnikov wrote:
>
> Oleg Nesterov wrote:
>> On 04/02, Konstantin Khlebnikov wrote:
>>>
>>> Currently kernel does not account read-only private mappings into memory commitment.
>>> But these mappings can be force-COW-ed in get_user_pages().
>>
>> Heh. tail -n3 Documentation/vm/overcommit-accounting
>> may be you should update it then.
>
> I just wonder how fragile this accounting...

I meant, this patch could also remove this "TODO" from the docs.

>> Can't really comment the patch, this is not my area. Still,
>>
>>> +	down_write(&mm->mmap_sem);
>>> +	*pvma = vma = find_vma(mm, addr);
>>> +	if (vma&&  vma->vm_start<= addr) {
>>> +		ret = vma->vm_end - addr;
>>> +		if ((vma->vm_flags&  (VM_ACCOUNT | VM_NORESERVE | VM_SHARED |
>>> +				VM_HUGETLB | VM_MAYWRITE)) == VM_MAYWRITE) {
>>> +			if (!security_vm_enough_memory_mm(mm, vma_pages(vma)))
>>
>> Oooooh, the whole vma. Say, gdb installs the single breakpoint into
>> the huge .text mapping...
>
> We cannot split vma right there, this will be really weird. =)

Sure, I understand why you did it this way.

>> I am not sure, but probably you want to check at least VM_IO/PFNMAP
>> as well. We do not want to charge this memory and retry with FOLL_FORCE
>> before vm_ops->access(). Say, /dev/mem
>
> No, VM_IO/PFNMAP aren't affect accounting, there is VM_NORESERVE for this.

You misunderstood. Again, I can be wrong, but.

Suppose the task mmmaps /dev/mem (for example). This vma doesn't have
VM_NORESERVE (but it has VM_IO).

gup() fails correctly with or without FOLL_FORCE, we should fallback
to vma_ops->access().

However. With your patch __access_remote_vm() tries gup() without
FOLL_FORCE first and wrongly assumes that it fails because it neeeds
FOLL_FORCE and we are going to force-cow.

So __account_vma() adds VM_ACCOUNT before (unnecessary) retry, and
this is unnecessary too and wrong.

>> Hmm. OTOH, if I am right then mprotect_fixup() should be fixed??
>
> mprotect_fixup() does not account area if it already accounted, so all ok.

No, I meant another thing. But yes, I think I was wrong, mprotect_fixup()
is fine.

>> We drop ->mmap_sem... Say, the task does mremap() in between and
>> len == 2 * PAGE_SIZE. Then, for example, copy_to_user_page() can
>> write to the same page twice. Perhaps not a problem in practice,
>> I dunno.
>
> I have an old unfinished patch which implements upgrade_read() for rw-semaphore =)

Interesting ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
