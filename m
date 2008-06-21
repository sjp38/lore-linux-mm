Date: Sat, 21 Jun 2008 17:56:17 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Experimental][PATCH] putback_lru_page rework
In-Reply-To: <1213994489.6474.127.camel@lts-notebook>
References: <1213981843.6474.68.camel@lts-notebook> <1213994489.6474.127.camel@lts-notebook>
Message-Id: <20080621175458.E82A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Quick update:  
> 
> With this patch applied, at ~ 1.5 hours into the test, my system panic'd
> [panic_on_oops set] with a BUG in __find_get_block() -- looks like the
> BUG_ON() in check_irqs_on() called from bh_lru_install() inlined by
> __find_get_block().  Before the panic occurred, I saw warnings from
> native_smp_call_function_mask() [arch/x86/kernel/smp.c]--also because
> irqs_disabled().
> 
> I'll back out the changes [spin_[un]lock() => spin_[un]lock_irq()] to
> shrink_inactive_list() and try again.  Just a hunch.

Yup.
Kamezawa-san's patch remove local_irq_enable(), but don't remove
local_irq_disable().
thus, irq is never enabled.

> -	spin_unlock(&zone->lru_lock);
> +	spin_unlock_irq(&zone->lru_lock);
>  done:
> -	local_irq_enable();



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
