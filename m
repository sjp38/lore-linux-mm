Message-Id: <4835656D.4020706@mxp.nes.nec.co.jp>
Date: Thu, 22 May 2008 21:22:05 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
References: <48350F15.9070007@mxp.nes.nec.co.jp> <48351120.6000800@mxp.nes.nec.co.jp> <20080522165322.F516.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080522165322.F516.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 2008/05/22 17:00 +0900, KOSAKI Motohiro wrote:
> Hi,
> 
>> +#ifndef CONFIG_CGROUP_SWAP_RES_CTLR
>>  /* Swap 50% full? Release swapcache more aggressively.. */
>> -#define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
>> +#define vm_swap_full(page) (nr_swap_pages*2 < total_swap_pages)
>> +#else
>> +#define vm_swap_full(page) swap_cgroup_vm_swap_full(page)
>> +#endif
> 
> I'd prefer #ifdef rather than #ifndef.
> 
> so...
> 
> #ifdef CONFIG_CGROUP_SWAP_RES_CTLR
>   your definition
> #else
>   original definition
> #endif
> 
OK.
I'll change it.

> and vm_swap_full() isn't page granularity operation.
> this is memory(or swap) cgroup operation.
> 
> this argument is slightly odd.
> 
But what callers of vm_swap_full() know is page,
not mem_cgroup.
I don't want to add to callers something like:

  pc = get_page_cgroup(page);
  mem = pc->mem_cgroup;
  vm_swap_full(mem);


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
