Message-ID: <486DFCCF.3070500@openvz.org>
Date: Fri, 04 Jul 2008 14:34:55 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] res_counter : check limit change
References: <20080704181204.44070413.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080704181204.44070413.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Add an interface to set limit. This is necessary to memory resource controller
> because it shrinks usage at set limit.
> 
> (*) Other controller may not need this interface to shrink usage because
>     shrinking is not necessary or impossible in it.
> 
> Changelog:
>   - fixed white space bug.
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
>  include/linux/res_counter.h |   15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> Index: test-2.6.26-rc8-mm1/include/linux/res_counter.h
> ===================================================================
> --- test-2.6.26-rc8-mm1.orig/include/linux/res_counter.h
> +++ test-2.6.26-rc8-mm1/include/linux/res_counter.h
> @@ -176,4 +176,19 @@ static inline bool res_counter_can_add(s
>  	return ret;
>  }
>  
> +static inline int res_counter_set_limit(struct res_counter *cnt,
> +	unsigned long long limit)
> +{
> +	unsigned long flags;
> +	int ret = -EBUSY;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	if (cnt->usage < limit) {
> +		cnt->limit = limit;
> +		ret = 0;
> +	}
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}
> +
>  #endif
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
