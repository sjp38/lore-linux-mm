Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A41A18D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 07:24:45 -0500 (EST)
Date: Thu, 3 Mar 2011 14:22:39 +0200 (EET)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [PATCH] procfs: fix /proc/<pid>/maps heap check
In-Reply-To: <alpine.DEB.1.10.1103031333020.27610@esdhcp041196.research.nokia.com>
Message-ID: <alpine.DEB.1.10.1103031409140.27610@esdhcp041196.research.nokia.com>
References: <1298996813-8625-1-git-send-email-aaro.koskinen@nokia.com> <alpine.DEB.1.10.1103021449000.27610@esdhcp041196.research.nokia.com> <20110303102631.B939.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.1103031333020.27610@esdhcp041196.research.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, stable@kernel.org

Hi,

On Thu, 3 Mar 2011, Aaro Koskinen wrote:
> On Thu, 3 Mar 2011, KOSAKI Motohiro wrote:
>>> On Tue, 1 Mar 2011, Aaro Koskinen wrote:
>>>> The current check looks wrong and prints "[heap]" only if the mapping
>>>> matches exactly the heap. However, the heap may be merged with some
>>>> other mappings, and there may be also be multiple mappings.
>>>> 
>>>> Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
>>>> Cc: stable@kernel.org
>
> [...]
>
>> Your description said,
>> 	the heap may be merged with some other mappings,
>>                        ^^^^^^
>> but your example is splitting case. not merge. In other words, your
>> patch care splitting case but break merge case.
>> 
>> Ok, we have no obvious correct behavior. This is debatable. So,
>> Why do you think vma splitting case is important than merge?
>
> Sorry, I was unclear.
>
> The current behaviour is wrong for both merged and split cases, and I
> think the patch fixes both.

Argh, this is confusing. The current check:

 	vma->vm_start <= mm->start_brk && vma->vm_end >= mm->brk

obviously works with the merged case. The patch changes this to:

 	vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk

This works with the split case, but it does not break the merged case
(or do I miss something still?).

So the current behaviour is broken only with the splitting case. I will
correct the patch description and resend it.

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
