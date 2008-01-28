Message-ID: <479DFE7F.9030305@qumranet.com>
Date: Mon, 28 Jan 2008 18:10:39 +0200
From: Izik Eidus <izike@qumranet.com>
MIME-Version: 1.0
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
References: <20080125055606.102986685@sgi.com> <20080125114229.GA7454@v2.random>
In-Reply-To: <20080125114229.GA7454@v2.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Thu, Jan 24, 2008 at 09:56:06PM -0800, Christoph Lameter wrote:
>   
>> Andrea's mmu_notifier #4 -> RFC V1
>>
>> - Merge subsystem rmap based with Linux rmap based approach
>> - Move Linux rmap based notifiers out of macro
>> - Try to account for what locks are held while the notifiers are
>>   called.
>> - Develop a patch sequence that separates out the different types of
>>   hooks so that it is easier to review their use.
>> - Avoid adding #include to linux/mm_types.h
>> - Integrate RCU logic suggested by Peter.
>>     
>
> I'm glad you're converging on something a bit saner and much much
> closer to my code, plus perfectly usable by KVM optimal rmap design
> too. It would have preferred if you would have sent me patches like
> Peter did for review and merging etc... that would have made review
> especially easier. Anyway I'm used to that on lkml so it's ok, I just
> need this patch to be included in mainline, everything else is
> irrelevant to me.
>
> On a technical merit this still partially makes me sick and I think
> it's the last issue to debate.
>
> @@ -971,6 +974,9 @@ int try_to_unmap(struct page *page, int 
>         else
>                 ret = try_to_unmap_file(page, migration);
>
> +       if (unlikely(PageExternalRmap(page)))
> +               mmu_rmap_notifier(invalidate_page, page);
> +
>         if (!page_mapped(page))
>                 ret = SWAP_SUCCESS;
>         return ret;
>
> I find the above hard to accept, because the moment you work with
> physical pages and not "mm+address" I think you couldn't possibly care
> if page_mapped is true or false, and I think the above notifier should
> be called _outside_ try_to_unmap. Infact I'd call
> mmu_rmap_notifier(invalidate_page, page); only if page_unmapped is
> false and the linux pte is gone already (practically just before the
> page_count == 2 check and after try_to_unmap).
>   

i dont understand how is that better than notification on tlb flush?
i mean cpus have very smiler problem as we do,
so why not deal with the notification at the same place as they do (tlb 
flush) ?

moreover notification on tlb flush allow unmodified applications to work 
with us
for example the memory merging driver that i wrote was able to work with kvm
without any change to its source code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
