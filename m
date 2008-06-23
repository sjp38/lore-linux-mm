Date: Mon, 23 Jun 2008 15:40:43 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/6] res_counter:  handle limit change
Message-Id: <20080623154043.c4d68d62.randy.dunlap@oracle.com>
In-Reply-To: <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 18:29:24 +0900 KAMEZAWA Hiroyuki wrote:

> Add a support to shrink_usage_at_limit_change feature to res_counter.
> memcg will use this to drop pages.
> 
> Change log: xxx -> v4 (new file.)
>  - cut out the limit-change part from hierarchy patch set.
>  - add "retry_count" arguments to shrink_usage(). This allows that we don't
>    have to set the default retry loop count.
>  - res_counter_check_under_val() is added to support subsystem.
>  - res_counter_init() is res_counter_init_ops(cnt, NULL)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  Documentation/controllers/resource_counter.txt |   19 +++++-
>  include/linux/res_counter.h                    |   33 ++++++++++-
>  kernel/res_counter.c                           |   74 ++++++++++++++++++++++++-
>  3 files changed, 121 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/Documentation/controllers/resource_counter.txt
> +++ linux-2.6.26-rc5-mm3/Documentation/controllers/resource_counter.txt
> @@ -141,8 +145,19 @@ counter fields. They are recommended to 
>  	failcnt		reset to zero
>  
>  
> +5. res_counter_ops (Callbacks)
>  
> -5. Usage example
> +   res_counter_ops is for implementing feedback control from res_counter
> +   to subsystem. Each one has each own purpose and the subsystem doesn't

                                                                    isn't

> +   necessary to provide all callbacks. Just implement necessary ones.

      required

> +
> +   - shrink_usage(res_counter, newlimit, retry)
> +     Called for reducing usage to newlimit, retry is incremented per
> +     loop. (See memory resource controller as example.)
> +     Returns 0 at success. Any error code is acceptable but -EBUSY will be
> +     suitable to show "the kernel can't shrink usage."
> +
> +6. Usage example
>  
>   a. Declare a task group (take a look at cgroups subsystem for this) and
>      fold a res_counter into it


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
