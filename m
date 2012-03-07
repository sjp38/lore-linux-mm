Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 0324F6B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 12:19:10 -0500 (EST)
Message-ID: <4F5798B1.5070005@jp.fujitsu.com>
Date: Wed, 07 Mar 2012 12:19:45 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com> <20120305215602.GA1693@redhat.com>
In-Reply-To: <20120305215602.GA1693@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jweiner@redhat.com
Cc: satoru.moriya@hds.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com, lwoodman@redhat.com, shaohua.li@intel.com, kosaki.motohiro@jp.fujitsu.com, dle-develop@lists.sourceforge.net, seiji.aguchi@hds.com

On 3/5/2012 4:56 PM, Johannes Weiner wrote:
> On Fri, Mar 02, 2012 at 12:36:40PM -0500, Satoru Moriya wrote:
>> Sometimes we'd like to avoid swapping out anonymous memory
>> in particular, avoid swapping out pages of important process or
>> process groups while there is a reasonable amount of pagecache
>> on RAM so that we can satisfy our customers' requirements.
>>
>> OTOH, we can control how aggressive the kernel will swap memory pages
>> with /proc/sys/vm/swappiness for global and
>> /sys/fs/cgroup/memory/memory.swappiness for each memcg.
>>
>> But with current reclaim implementation, the kernel may swap out
>> even if we set swappiness==0 and there is pagecache on RAM.
>>
>> This patch changes the behavior with swappiness==0. If we set
>> swappiness==0, the kernel does not swap out completely
>> (for global reclaim until the amount of free pages and filebacked
>> pages in a zone has been reduced to something very very small
>> (nr_free + nr_filebacked < high watermark)).
>>
>> Any comments are welcome.
> 
> Last time I tried that (getting rid of sc->may_swap, using
> !swappiness), it was rejected it as there were users who relied on
> swapping very slowly with this setting.
> 
> KOSAKI-san, do I remember correctly?  Do you still think it's an
> issue?
>
> Personally, I still think it's illogical that !swappiness allows
> swapping and would love to see this patch go in.

Thank you. I brought back to memory it. Unfortunately DB folks are still
mainly using RHEL5 generation distros. At that time, swapiness=0 doesn't
mean disabling swap.

They want, "don't swap as far as kernel has any file cache page". but linux
don't have such feature. then they used swappiness for emulate it. So, I
think this patch clearly make userland harm. Because of, we don't have an
alternative way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
