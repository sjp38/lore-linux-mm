Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 8E9EC6B005C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:58:17 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 19 Dec 2011 13:58:15 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBJKvYgV124538
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 13:57:34 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBJKvX4V024667
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 13:57:34 -0700
Message-ID: <4EEFA51D.2050707@linux.vnet.ibm.com>
Date: Mon, 19 Dec 2011 12:57:01 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com> <4EEF8F85.9010408@gmail.com> <4EEF9F3E.9000107@linux.vnet.ibm.com> <4EEFA278.7010200@gmail.com>
In-Reply-To: <4EEFA278.7010200@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On 12/19/2011 12:45 PM, KOSAKI Motohiro wrote:
> (12/19/11 3:31 PM), Dave Hansen wrote:
>> Let's say you profiled a application and the data shows you're missing
>> the TLB a bunch, but you're also using THP.  This might give you a shot
>> at figuring out which parts of your application are *TRULY* THP-backed
>> instead of just the areas you *think* are backed.
>>
>> I'm not sure there's another way to figure it out at the moment.
> 
> A snapshot status of THP doesn't help your purpose. I think you need
> perf or similar profiling subsystem enhancement.
>
> Because of, if you've seen KPF_THP at once, It has no guarantee to keep
> hugepages until applications run. Opposite, If you only need rough
> statistics, the best way is to add some new stat to
> /sys/kernel/mm/transparent_hugepage.

But, every single one of the pagemap flags is really just a snapshot
KPF_DIRTY, KPF_LOCKED, etc...  The entire interface is inherently a racy
snapshot, and there's not a whole lot you can do about it.
sys_mincore() has the exact same issues.  But, that does not make them
useless, nor mean they shouldn't be in the kernel.

A tracepoint or something similar to watch for THP promotions or
demotions would be a great addition to this interface.  That way, you at
least have a concept if the data you got has become stale.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
