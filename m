Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4F0E66B006E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 10:02:15 -0500 (EST)
Date: Fri, 11 Nov 2011 09:02:08 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: INFO: possible recursive locking detected: get_partial_node()
 on 3.2-rc1
In-Reply-To: <1320980671.22361.252.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1111110857330.3557@router.home>
References: <20111109090556.GA5949@zhy>  <201111102335.06046.kernelmail.jms@gmail.com> <1320980671.22361.252.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Julie Sullivan <kernelmail.jms@gmail.com>, Yong Zhang <yong.zhang0@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 11 Nov 2011, Shaohua Li wrote:

> Looks this could be a real dead lock. we hold a lock to free a object,
> but the free need allocate a new object. if the new object and the freed
> object are from the same slab, there is a deadlock.

unfreeze partials is never called when going through get_partial_node()
so there is no deadlock AFAICT.

> discard_slab() doesn't need hold the lock if the slab is already removed
> from partial list. how about below patch, only compile tested.

In general I think it is good to move the call to discard_slab() out from
under the list_lock in unfreeze_partials(). Could you fold
discard_page_list into unfreeze_partials()? __flush_cpu_slab still calls
discard_page_list with disabled interrupts even after your patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
