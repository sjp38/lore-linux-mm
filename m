Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m859i3b8026718
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 19:44:03 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m859j901292740
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 19:45:11 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m859j85E025901
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 19:45:09 +1000
Message-ID: <48C0FF9F.3060803@linux.vnet.ibm.com>
Date: Fri, 05 Sep 2008 15:15:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][mmotm]memcg: handle null dereference of mm->owner
References: <20080905165017.b2715fe4.nishimura@mxp.nes.nec.co.jp> <20080905174021.9fa29b01.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080905174021.9fa29b01.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 5 Sep 2008 16:50:17 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
>> Hi.
>>
>> mm_update_next_owner() may clear mm->owner to NULL
>> if it races with swapoff, page migration, etc.
>> (This behavior was introduced by mm-owner-fix-race-between-swap-and-exit.patch.)
>>
>> But memcg doesn't take account of this situation, and causes:
>>
>>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000630
>>
>> This fixes it.
>>
> Thank you for catching this.
> 

Thanks, Daisuke

> BTW, I have a question to Balbir and Paul. (I'm sorry I missed the discussion.)
> Recently I wonder why we need MM_OWNER.
> 
> - What's bad with thread's cgroup ?
> - Why we can't disallow per-thread cgroup under memcg ?)
> 


For the following reasons, I had initially designed it to be that way because

1. There is no concept of a thread maintaining or managing its memory
independently of others
2. If we ever support full migration, it is easier to do so with the thread
group leader owning the memory, rather than figuring out what to do everytime a
task changed a cgroup.
3. A task with appropriate permissions can spread itself across cgroups and hog
memory


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
