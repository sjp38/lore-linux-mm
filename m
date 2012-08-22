Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id AEEAA6B0080
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 12:29:57 -0400 (EDT)
Date: Wed, 22 Aug 2012 18:29:55 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between
 secondary MMU and host
Message-ID: <20120822162955.GT29978@redhat.com>
References: <503358FF.3030009@linux.vnet.ibm.com>
 <20120821150618.GJ27696@redhat.com>
 <5034763D.60508@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5034763D.60508@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 22, 2012 at 02:03:41PM +0800, Xiao Guangrong wrote:
> On 08/21/2012 11:06 PM, Andrea Arcangeli wrote:
> > CPU0  		    	    	CPU1
> > 				oldpage[1] == 0 (both guest & host)
> > oldpage[0] = 1
> > trigger do_wp_page
> 
> We always do ptep_clear_flush before set_pte_at_notify(),
> at this point, we have done:
>   pte = 0 and flush all tlbs
> > mmu_notifier_change_pte
> > spte = newpage + writable
> > 				guest does newpage[1] = 1
> > 				vmexit
> > 				host read oldpage[1] == 0
> 
>                   It can not happen, at this point pte = 0, host can not
> 		  access oldpage anymore, host read can generate #PF, it
>                   will be blocked on page table lock until CPU 0 release the lock.

Agreed, this is why your fix is safe.

So the thing is, it is never safe to mangle the secondary MMU before
the primary MMU. This is why your patch triggered all sort of alarm
bells to me and I was tempted to suggest an obviously safe
alternative.

The reason why your patch is safe, is that the required primary MMU
pte mangling happens before the set_pte_at_notify is invoked.

Other details about change_pte:

1) it is only safe to use on an already readonly pte if the pfn is
   being altered

2) it is only safe to run on a read-write mapping to convert it to a
   readonly mapping if the pfn doesn't change

KSM uses it as 2) in page_write_protect.

KSM uses it as 1) in replace_page and do_wp_page uses it as 1) too.

The new constraint for its safety after your fix is that it must
always be preceded by a ptep_clear_flush.

Of course it's quite natural that it is preceded by a
ptep_clear_flush, other things would risk to go wrong if
ptep_clear_flush wasn't done, so there's little risk of getting it
wrong.

I thought, maybe it would be clearer to do it as
ptep_clear_flush_notify_at(pte). That would avoid having methods that
rings the alarm bells. But the O_DIRECT check of KSM in
page_write_protect prevents such a change (there we need to run a
standalone ptep_clear_flush).

I suggest only adding a comment to mention the real primary MMU pte
update happens before set_pte_at_notify is invoked and we're not
really doing secondary MMU updates before primary MMU updates which
wouldn't never be safe.

It never would be safe because the secondary MMU can be just a TLB and
even the KSM sptes can be dropped at any time and refilled through
secondary MMU page faults running gup_fast. The PT lock won't stop it.

Thanks a lot for fixing this subtle race!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
