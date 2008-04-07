From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Mon, 7 Apr 2008 15:09:56 -0700
Message-ID: <20080407150956.9a29573a.akpm@linux-foundation.org>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757641AbYDGWKl@vger.kernel.org>
In-Reply-To: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
Cc: menage@google.com, xemul@openvz.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, rientjes@google.com, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-Id: linux-mm.kvack.org

On Fri, 04 Apr 2008 13:35:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 1. Add mm->owner change callbacks using cgroups
> 
> ...
>
> +config MM_OWNER
> +	bool "Enable ownership of mm structure"
> +	help
> +	  This option enables mm_struct's to have an owner. The advantage
> +	  of this approach is that it allows for several independent memory
> +	  based cgroup controllers to co-exist independently without too
> +	  much space overhead
> +
> +	  This feature adds fork/exit overhead. So enable this only if
> +	  you need resource controllers

Do we really want to offer this option to people?  It's rather a low-level
thing and it's likely to cause more confusion than it's worth.  Remember
that most kernels get to our users via kernel vendors - to what will they
be setting this config option?

>  config CGROUP_MEM_RES_CTLR
>  	bool "Memory Resource Controller for Control Groups"
>  	depends on CGROUPS && RESOURCE_COUNTERS
> +	select MM_OWNER

Presumably they'll always be setting it to "y" if they are enabling cgroups
at all.

> --- linux-2.6.25-rc8/kernel/cgroup.c~memory-controller-add-mm-owner	2008-04-03 22:43:27.000000000 +0530
> +++ linux-2.6.25-rc8-balbir/kernel/cgroup.c	2008-04-03 22:43:27.000000000 +0530
> @@ -118,6 +118,7 @@ static int root_count;
>   * be called.
>   */
>  static int need_forkexit_callback;
> +static int need_mm_owner_callback;

I suppose these should be __read_mostly.
