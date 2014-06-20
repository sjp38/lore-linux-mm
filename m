Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DDE146B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:18:56 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so2487492pde.38
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 20:18:56 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id hg8si8098176pac.11.2014.06.19.20.18.55
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 20:18:56 -0700 (PDT)
Message-ID: <53A3A864.3020708@cn.fujitsu.com>
Date: Fri, 20 Jun 2014 11:20:04 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in
 kvm.
References: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com> <20140618061230.GA10948@minantech.com> <53A136C4.5070206@cn.fujitsu.com> <20140619092031.GA429@minantech.com> <20140619190024.GA3887@amt.cnet>
In-Reply-To: <20140619190024.GA3887@amt.cnet>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Gleb Natapov <gleb@kernel.org>, pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Avi Kivity <avi.kivity@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hi Marcelo,

Thanks for your reply. Please see below.

On 06/20/2014 03:00 AM, Marcelo Tosatti wrote:
......
>> Remove pinning is preferable. In fact looks like for identity pagetable
>> it should be trivial, just don't pin. APIC access page is a little bit
>> more complicated since its physical address needs to be tracked to be
>> updated in VMCS.
>
> Yes, and there are new users of page pinning as well soon (see PEBS
> threads on kvm-devel).
>
> Was thinking of notifiers scheme. Perhaps:
>
> ->begin_page_unpin(struct page *page)
> 	- Remove any possible access to page.
>
> ->end_page_unpin(struct page *page)
> 	- Reinstantiate any possible access to page.
>
> For KVM:
>
> ->begin_page_unpin()
> 	- Remove APIC-access page address from VMCS.
> 	  or
> 	- Remove spte translation to pinned page.
> 	
> 	- Put vcpu in state where no VM-entries are allowed.
>
> ->end_page_unpin()
> 	- Setup APIC-access page, ...
> 	- Allow vcpu to VM-entry.
>
>
> Because allocating APIC access page from distant NUMA node can
> be a performance problem, i believe.

Yes, I understand this.

>
> I'd be happy to know why notifiers are overkill.

The notifiers are not overkill. I have been thinking about a similar idea.

In fact, we have met the same pinned pages problem in AIO subsystem.
The aio ring pages are pinned in memory, and cannot be migrated.

And in kernel, I believe, there are some other places where pages are 
pinned.


So I was thinking a notifier framework to solve this problem.
But I can see some problems:

1. When getting a page, migration thread doesn't know who is using this 
page
    and how. So we need a callback for each page to be called before and 
after
    it is migrated.
    (A little over thinking, maybe. Please see below.)

2. When migrating a shared page, one callback is not enouch because the 
page
    could be shared by different subsystems. They may have different 
ways to
    pin and unpin the page.

3. Where should we put the callback? Only file backing pages have one 
and only one
    address_space->address_space_operations->migratepage(). For 
anonymous pages,
    nowhere to put the callback.

    (A basic idea: define a global radix tree or hash table to manage 
the pinned
     pages and their callbacks. Mel Gorman mentioned this idea when 
handling
     the aio ring page problem. I'm not sure if this is acceptable.)


The idea above may be a little over thinking. Actually we can reuse the
memory hotplug notify chain if the pinned page migration is only used by
memory hotplug subsystem.

The basic idea is: Each subsystem register a callback to memory hotplug 
notify
chain, and unpin and repin the pages before and after page migration.

But I think, finally we will met this problem: How to remember/manage the
pinned pages in each subsystem.

For example, for kvm, ept identity pagetable page and apic page are pinned.
Since these two pages' struct_page pointer and user_addr are remember in 
kvm,
they are easy to handle. If we pin a page and remember it only in a stack
variable, it could be difficult to handle.


For now for kvm, I think notifiers can solve this problem.

Thanks for the advice. If you guys have any idea about this probelm, please
share with me.

Thanks.



















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
