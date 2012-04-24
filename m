Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 469806B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 04:20:30 -0400 (EDT)
Date: Tue, 24 Apr 2012 09:20:19 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <20120424082019.GA18395@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

On 03/07/2012 18:18 PM, Satoru Moriya wrote:
> On 03/07/2012 12:19 PM, KOSAKI Motohiro wrote:
>> On 3/5/2012 4:56 PM, Johannes Weiner wrote:
>>> On Fri, Mar 02, 2012 at 12:36:40PM -0500, Satoru Moriya wrote:
>>>>
>>>> This patch changes the behavior with swappiness==0. If we set 
>>>> swappiness==0, the kernel does not swap out completely (for global 
>>>> reclaim until the amount of free pages and filebacked pages in a 
>>>> zone has been reduced to something very very small (nr_free + 
>>>> nr_filebacked < high watermark)).
>>>>
>>>> Any comments are welcome.
>>>
>>> Last time I tried that (getting rid of sc->may_swap, using 
>>> !swappiness), it was rejected it as there were users who relied on 
>>> swapping very slowly with this setting.
>>>
>>> KOSAKI-san, do I remember correctly?  Do you still think it's an 
>>> issue?
>>>
>>> Personally, I still think it's illogical that !swappiness allows 
>>> swapping and would love to see this patch go in.
>> 
>> Thank you. I brought back to memory it. Unfortunately DB folks are 
>> still mainly using RHEL5 generation distros. At that time, swapiness=0 
>> doesn't mean disabling swap.
>> 
>> They want, "don't swap as far as kernel has any file cache page". but 
>> linux don't have such feature. then they used swappiness for emulate 
>> it. So, I think this patch clearly make userland harm. Because of, we 
>> don't have an alternative way.
>
> If they expect the behavior that "don't swap as far as kernel
> has any file cache page", this patch definitely helps them
> because if we set swappiness==0, kernel does not swap out
> *until* nr_free + nr_filebacked < high watermark in the zone.
> It means kernel begins to swap out when nr_free + nr_filebacked
> becomes less than high watermark.
>
> But, yes, this patch actually changes the behavior with
> swappiness==0 and so it may make userland harm. 
>
> How about introducing new value e.g -1 to avoid swap and
> maintain compatibility?

I have run into problems with heavy swapping with swappiness==0 and was
pointed to this thread ( http://marc.info/?l=linux-mm&m=133522782307215 )

I strongly believe that Linux should have a way to turn off swapping unless
absolutely necessary. This means that users like us can run with swap
present for emergency use, rather than having to disable it because of the
side effects.

Personally, I feel that swappiness==0 should have this (intuitive) meaning,
and that people running RHEL5 are extremely unlikely to run 3.5 kernels(!)

However, swappiness==-1 or some other hack is definitely better than no
patch.

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
