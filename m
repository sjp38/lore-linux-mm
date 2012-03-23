Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 76FF36B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 20:49:51 -0400 (EDT)
Message-ID: <4F6BC8A8.6080202@storytotell.org>
Date: Thu, 22 Mar 2012 18:49:44 -0600
From: Jason Mattax <jmattax@storytotell.org>
MIME-Version: 1.0
Subject: Re: Possible Swapfile bug
References: <4F6B5236.20805@storytotell.org> <20120322124635.85fd4673.akpm@linux-foundation.org>
In-Reply-To: <20120322124635.85fd4673.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On 03/22/2012 01:46 PM, Andrew Morton wrote:
> On Thu, 22 Mar 2012 10:24:22 -0600
> Jason Mattax<jmattax@storytotell.org>  wrote:
>
>> Swapon very slow with swapfiles.
>>
>> After upgrading the kernel my swap file loads very slowly, while a swap
>> partition is unaffected. With the newer kernel (2.6.33.1) I get
>>
>> # time swapon -v /var/swapfile
>> swapon on /var/swapfile
>> swapon: /var/swapfile: found swap signature: version 1, page-size 4,
>> same byte order
>> swapon: /var/swapfile: pagesize=4096, swapsize=6442450944,
>> devsize=6442450944
>>
>> real    4m35.355s
>> user    0m0.001s
>> sys    0m1.786s
>>
>> while with the older kernel (2.6.32.27) I get
>> # time swapon -v /var/swapfile
>> swapon on /var/swapfile
>> swapon: /var/swapfile: found swap signature: version 1, page-size 4,
>> same byte order
>> swapon: /var/swapfile: pagesize=4096, swapsize=6442450944,
>> devsize=6442450944
>>
>> real    0m1.158s
>> user    0m0.000s
>> sys     0m0.876s
>>
>> this stays true even for new swapfiles I create with dd.
>>
>> the file is on an OCZ Vertex2 SSD.
> Probably the vertex2 discard problem.
>
> We just merged a patch which will hopefully fix it:
>
> --- a/mm/swapfile.c~swap-dont-do-discard-if-no-discard-option-added
> +++ a/mm/swapfile.c
> @@ -2103,7 +2103,7 @@ SYSCALL_DEFINE2(swapon, const char __use
>   			p->flags |= SWP_SOLIDSTATE;
>   			p->cluster_next = 1 + (random32() % p->highest_bit);
>   		}
> -		if (discard_swap(p) == 0&&  (swap_flags&  SWAP_FLAG_DISCARD))
> +		if ((swap_flags&  SWAP_FLAG_DISCARD)&&  discard_swap(p) == 0)
>   			p->flags |= SWP_DISCARDABLE;
>   	}
>
>
> But Hugh doesn't like it and won't tell us why :)
>

Patch worked like a charm for me, thanks.

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
