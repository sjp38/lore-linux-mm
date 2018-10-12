Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92E5C6B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 01:29:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a12-v6so6376974eda.8
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 22:29:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1-v6si404626edj.108.2018.10.11.22.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 22:29:45 -0700 (PDT)
Subject: Re: [PATCH] mm: Speed up mremap on large regions
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <CAG48ez3yLkMcyaTXFt_+w8_-HtmrjW=XB51DDQSGdjPj43XWmA@mail.gmail.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <42b81ac4-35de-754e-545b-d57b3bab3b7a@suse.com>
Date: Fri, 12 Oct 2018 07:29:42 +0200
MIME-Version: 1.0
In-Reply-To: <CAG48ez3yLkMcyaTXFt_+w8_-HtmrjW=XB51DDQSGdjPj43XWmA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, joel@joelfernandes.org
Cc: kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-team@android.com, Minchan Kim <minchan@google.com>, Hugh Dickins <hughd@google.com>, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, pombredanne@nexb.com, Thomas Gleixner <tglx@linutronix.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org

On 12/10/2018 05:21, Jann Horn wrote:
> +cc xen maintainers and kvm folks
> 
> On Fri, Oct 12, 2018 at 4:40 AM Joel Fernandes (Google)
> <joel@joelfernandes.org> wrote:
>> Android needs to mremap large regions of memory during memory management
>> related operations. The mremap system call can be really slow if THP is
>> not enabled. The bottleneck is move_page_tables, which is copying each
>> pte at a time, and can be really slow across a large map. Turning on THP
>> may not be a viable option, and is not for us. This patch speeds up the
>> performance for non-THP system by copying at the PMD level when possible.
> [...]
>> +bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>> +                 unsigned long new_addr, unsigned long old_end,
>> +                 pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
>> +{
> [...]
>> +       /*
>> +        * We don't have to worry about the ordering of src and dst
>> +        * ptlocks because exclusive mmap_sem prevents deadlock.
>> +        */
>> +       old_ptl = pmd_lock(vma->vm_mm, old_pmd);
>> +       if (old_ptl) {
>> +               pmd_t pmd;
>> +
>> +               new_ptl = pmd_lockptr(mm, new_pmd);
>> +               if (new_ptl != old_ptl)
>> +                       spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
>> +
>> +               /* Clear the pmd */
>> +               pmd = *old_pmd;
>> +               pmd_clear(old_pmd);
>> +
>> +               VM_BUG_ON(!pmd_none(*new_pmd));
>> +
>> +               /* Set the new pmd */
>> +               set_pmd_at(mm, new_addr, new_pmd, pmd);
>> +               if (new_ptl != old_ptl)
>> +                       spin_unlock(new_ptl);
>> +               spin_unlock(old_ptl);
> 
> How does this interact with Xen PV? From a quick look at the Xen PV
> integration code in xen_alloc_ptpage(), it looks to me as if, in a
> config that doesn't use split ptlocks, this is going to temporarily
> drop Xen's type count for the page to zero, causing Xen to de-validate
> and then re-validate the L1 pagetable; if you first set the new pmd
> before clearing the old one, that wouldn't happen. I don't know how
> this interacts with shadow paging implementations.

No, this isn't an issue. As the L1 pagetable isn't being released it
will stay pinned, so there will be no need to revalidate it.

For Xen in shadow mode I'm quite sure it just doesn't matter. In the
case another thread of the process is accessing the memory in parallel
it might even be better to not having a L1 pagetable with 2 references
at the same time, but this is an academic problem which doesn't need to
be tuned for performance IMO.


Juergen
