Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CA9B96B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:41:29 -0500 (EST)
Received: by pwi1 with SMTP id 1so723473pwi.6
        for <linux-mm@kvack.org>; Fri, 11 Dec 2009 05:41:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B2235F0.4080606@redhat.com>
References: <20091210185626.26f9828a@cuia.bos.redhat.com>
	 <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
	 <4B2235F0.4080606@redhat.com>
Date: Fri, 11 Dec 2009 22:41:27 +0900
Message-ID: <28c262360912110541m2839e151hc9d49b0c251e1b67@mail.gmail.com>
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: Rik van Riel <riel@redhat.com>, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Larry.

On Fri, Dec 11, 2009 at 9:07 PM, Larry Woodman <lwoodman@redhat.com> wrote:
> Minchan Kim wrote:
>>
>> I like this. but why do you select default value as constant 8?
>> Do you have any reason?
>>
>> I think it would be better to select the number proportional to NR_CPU.
>> ex) NR_CPU * 2 or something.
>>
>> Otherwise looks good to me.
>>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>>
>>
>
> This is a per-zone count so perhaps a reasonable default is the number of
> CPUs on the
> NUMA node that the zone resides on ?

For example, It assume one CPU per node.
It means your default value is 1.
On the CPU, process A try to reclaim HIGH zone.
Process B want to reclaim NORMAL zone.
But Process B can't enter reclaim path sincev throttle default value is 1
Even kswap can't reclaim.

I think it's really agressive throttle approach although it would
solve your problem.

I have another idea.

We make default value rather big and we provide latency vaule as knob.
So first many processes can enter reclaim path. When shrinking time exceeds
our konb(ex, some HZ), we can decrease default value of number of concurrent
reclaim process. If shrink time is still long alghouth we do it, we
can decrease
default vaule again. When shrink time is fast, we can allow to enter
reclaim path of another processes as increase the number.

It's like old pdflush mechanism. but it's more complex than Rik's one.
If Rik's approach solve this problem well, my approach is rather
overkill, I think.

I am looking forward to Rik's approach work well.

>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
