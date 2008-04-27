Received: by wx-out-0506.google.com with SMTP id h31so4360312wxd.11
        for <linux-mm@kvack.org>; Sat, 26 Apr 2008 18:54:31 -0700 (PDT)
Message-ID: <4813DCCF.3020201@codemonkey.ws>
Date: Sat, 26 Apr 2008 20:54:23 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifier #v14
References: <20080426164511.GJ9514@duo.random> <48137B8B.7010202@us.ibm.com> <20080427002019.GL9514@duo.random>
In-Reply-To: <20080427002019.GL9514@duo.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Chris Wright <chrisw@redhat.com>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Steve Wise <swise@opengridcomputing.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Sat, Apr 26, 2008 at 01:59:23PM -0500, Anthony Liguori wrote:
>   
>>> +static void kvm_unmap_spte(struct kvm *kvm, u64 *spte)
>>> +{
>>> +	struct page *page = pfn_to_page((*spte & PT64_BASE_ADDR_MASK) >> 
>>> PAGE_SHIFT);
>>> +	get_page(page);
>>>   
>>>       
>> You should not assume a struct page exists for any given spte. Instead, use 
>> kvm_get_pfn() and kvm_release_pfn_clean().
>>     
>
> Last email from muli@ibm in my inbox argues it's useless to build rmap
> on mmio regions, so the above is more efficient so put_page runs
> directly on the page without going back and forth between spte -> pfn
> -> page -> pfn -> page in a single function.
>   

Avi can correct me if I'm wrong, but I don't think the consensus of that 
discussion was that we're going to avoid putting mmio pages in the 
rmap.  Practically speaking, replacing:

+	struct page *page = pfn_to_page((*spte & PT64_BASE_ADDR_MASK) >> 
PAGE_SHIFT);
+	get_page(page);


With:

unsigned long pfn = (*spte & PT64_BASE_ADDR_MASK) >> PAGE_SHIFT;
kvm_get_pfn(pfn);

Results in exactly the same code except the later allows mmio pfns in 
the rmap.  So ignoring the whole mmio thing, using accessors that are 
already there and used elsewhere seems like a good idea :-)

> Certainly if we start building rmap on mmio regions we'll have to
> change that.
>
>   
>> Perhaps I just have a weak stomach but I am uneasy having a function that 
>> takes a lock on exit. I walked through the logic and it doesn't appear to 
>> be wrong but it also is pretty clear that you could defer the acquisition 
>> of the lock to the caller (in this case, kvm_mmu_pte_write) by moving the 
>> update_pte assignment into kvm_mmu_pte_write.
>>     
>
> I agree out_lock is an uncommon exit path, the problem is that the
> code was buggy, and I tried to fix it with the smallest possible
> change and that resulting in an out_lock. That section likely need a
> refactoring, all those update_pte fields should be at least returned
> by the function guess_....  but I tried to reduce the changes to make
> the issue more readable, I didn't want to rewrite certain functions
> just to take a spinlock a few instructions ahead.
>   

I appreciate the desire to minimize changes, but taking a lock on return 
seems to take that to a bit of an extreme.  It seems like a simple thing 
to fix though, no?

>> Why move the destruction of the vm to the MMU notifier unregister hook? 
>> Does anything else ever call mmu_notifier_unregister that would implicitly 
>> destroy the VM?
>>     
>
> mmu notifier ->release can run at anytime before the filehandle is
> closed. ->release has to zap all sptes and freeze the mmu (hence all
> vcpus) to prevent any further page fault. After ->release returns all
> pages are freed (we'll never relay on the page pin to avoid the
> rmap_remove put_page to be a relevant unpin event). So the idea is
> that I wanted to maintain the same ordering of the current code in the
> vm destroy event, I didn't want to leave a partially shutdown VM on
> the vmlist. If the ordering is entirely irrelevant and the
> kvm_arch_destroy_vm can run well before kvm_destroy_vm is called, then
> I can avoid changes to kvm_main.c but I doubt.
>
> I've done it in a way that archs not needing mmu notifiers like s390
> can simply add the kvm_destroy_common_vm at the top of their
> kvm_arch_destroy_vm. All others using mmu_notifiers have to invoke
> kvm_destroy_common_vm in the ->release of the mmu notifiers.
>
> This will ensure that everything will be ok regardless if exit_mmap is
> called before/after exit_files, and it won't make a whole lot of
> difference anymore, if the driver fd is pinned through vmas->vm_file
> released in exit_mmap or through the task filedescriptors relased in
> exit_files etc... Infact this allows to call mmu_notifier_unregister
> at anytime later after the task has already been killed, without any
> trouble (like if the mmu notifier owner isn't registering in
> current->mm but some other tasks mm).
>   

I see.  It seems a little strange to me as a KVM guest isn't really tied 
to the current mm.  It seems like the net effect of this is that we are 
now tying a KVM guest to an mm.

For instance, if you create a guest, but didn't assign any memory to it, 
you could transfer the fd to another process and then close the fd 
(without destroying the guest).  The other process then could assign 
memory to it and presumably run the guest.

With your change, as soon as the first process exits, the guest will be 
destroyed.  I'm not sure this behavioral difference really matters but 
it is a behavioral difference.

Regards,

Anthony Liguori

> -------------------------------------------------------------------------
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
> Don't miss this year's exciting event. There's still time to save $100. 
> Use priority code J8TL2D2. 
> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
> _______________________________________________
> kvm-devel mailing list
> kvm-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/kvm-devel
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
