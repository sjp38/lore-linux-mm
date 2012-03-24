Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8B6656B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 23:56:43 -0400 (EDT)
Message-ID: <4F6D45F2.9080201@storytotell.org>
Date: Fri, 23 Mar 2012 21:56:34 -0600
From: Jason Mattax <jmattax@storytotell.org>
MIME-Version: 1.0
Subject: Re: Possible Swapfile bug
References: <4F6B5236.20805@storytotell.org> <20120322124635.85fd4673.akpm@linux-foundation.org> <4F6BC8A8.6080202@storytotell.org> <alpine.LSU.2.00.1203230440360.31745@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1203230440360.31745@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, linux-mm@kvack.org

On 03/23/2012 06:05 AM, Hugh Dickins wrote:
> On Thu, 22 Mar 2012, Jason Mattax wrote:
>> On 03/22/2012 01:46 PM, Andrew Morton wrote:
>>> On Thu, 22 Mar 2012 10:24:22 -0600
>>> Jason Mattax<jmattax@storytotell.org>   wrote:
>>>
>>>> Swapon very slow with swapfiles.
>>>>
>>>> After upgrading the kernel my swap file loads very slowly, while a swap
>>>> partition is unaffected. With the newer kernel (2.6.33.1) I get
>>>>
>>>> # time swapon -v /var/swapfile
>>>> swapon on /var/swapfile
>>>> swapon: /var/swapfile: found swap signature: version 1, page-size 4,
>>>> same byte order
>>>> swapon: /var/swapfile: pagesize=4096, swapsize=6442450944,
>>>> devsize=6442450944
>>>>
>>>> real    4m35.355s
>>>> user    0m0.001s
>>>> sys    0m1.786s
>>>>
>>>> while with the older kernel (2.6.32.27) I get
>>>> # time swapon -v /var/swapfile
>>>> swapon on /var/swapfile
>>>> swapon: /var/swapfile: found swap signature: version 1, page-size 4,
>>>> same byte order
>>>> swapon: /var/swapfile: pagesize=4096, swapsize=6442450944,
>>>> devsize=6442450944
>>>>
>>>> real    0m1.158s
>>>> user    0m0.000s
>>>> sys     0m0.876s
>>>>
>>>> this stays true even for new swapfiles I create with dd.
>>>>
>>>> the file is on an OCZ Vertex2 SSD.
>>> Probably the vertex2 discard problem.
>>>
>>> We just merged a patch which will hopefully fix it:
>>>
>>> --- a/mm/swapfile.c~swap-dont-do-discard-if-no-discard-option-added
>>> +++ a/mm/swapfile.c
>>> @@ -2103,7 +2103,7 @@ SYSCALL_DEFINE2(swapon, const char __use
>>>    			p->flags |= SWP_SOLIDSTATE;
>>>    			p->cluster_next = 1 + (random32() % p->highest_bit);
>>>    		}
>>> -		if (discard_swap(p) == 0&&   (swap_flags&   SWAP_FLAG_DISCARD))
>>> +		if ((swap_flags&   SWAP_FLAG_DISCARD)&&   discard_swap(p) == 0)
>>>    			p->flags |= SWP_DISCARDABLE;
>>>    	}
>>>
>>>
>>> But Hugh doesn't like it and won't tell us why :)
>>>
>> Patch worked like a charm for me, thanks.
> Thanks for your reports: as Andrew points out, this issue has just
> now surfaced; though there was one report of it fourteen months ago.
>
> I'm not surprised that you saw no problem on 2.6.32.27, but I am
> very surprised that you see the problem on 2.6.33.1 - I'm wondering
> if that's a typo for something else, or a distro kernel which actually
> contains changes from later releases?
I can't say why I saw it then, but I got the 2.6.33.1 kernel off of 
http://www.kernel.org/pub/linux/kernel/v2.6/ so that I wouldn't have to 
worry about distribution changes when reporting the bug here. I just 
recompiled the source and verified that it is still affected even with 
the newest firmware.
> I would expect the slowdown to occur sometime around 2.6.35 (perhaps
> one before or after), when use of barriers in the block layer was
> deprecated in favour of waiting on completion.  That made discard
> significantly slower - but unavoidably so.  It appears now that the use
> of barriers before was incorrect, or potentially incorrect: and if you
> had started real swapping within 4m35s of swapon on 2.6.32.7, then you
> might have been open to data corruption and mysterious segfaults.
>
> Might: it would have depended upon unspecified behaviour in the drive.
>
> Hugh
>


-- 
Jason Mattax
575-418-1791
jmattax@storytotell.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
