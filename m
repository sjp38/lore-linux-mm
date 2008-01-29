Date: Tue, 29 Jan 2008 10:07:37 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-ID: <20080129160737.GV3058@sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.609249585@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080128202923.609249585@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

I am going to seperate my comments into individual replies to help
reduce the chance they are lost.

> +void mmu_notifier_release(struct mm_struct *mm)
...
> +		hlist_for_each_entry_safe_rcu(mn, n, t,
> +					  &mm->mmu_notifier.head, hlist) {
> +			if (mn->ops->release)
> +				mn->ops->release(mn, mm);
> +			hlist_del(&mn->hlist);

This is a use-after-free issue.  The hlist_del_rcu needs to be done before
the callout as the structure containing the mmu_notifier structure will
need to be freed from within the ->release callout.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
