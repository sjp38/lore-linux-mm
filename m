Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 35CF46B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 19:26:00 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so7148628ied.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 16:25:59 -0700 (PDT)
Date: Fri, 2 Nov 2012 16:26:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
In-Reply-To: <20121102014336.GA1727@redhat.com>
Message-ID: <alpine.LNX.2.00.1211021606580.11106@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com> <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
 <20121102014336.GA1727@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 1 Nov 2012, Dave Jones wrote:
> On Thu, Nov 01, 2012 at 04:48:41PM -0700, Hugh Dickins wrote:
>  > 
>  > Fedora turns on CONFIG_DEBUG_VM?
> 
> Yes.
>  
>  > All mm developers should thank you for the wider testing exposure;
>  > but I'm not so sure that Fedora users should thank you for turning
>  > it on - really it's for mm developers to wrap around !assertions or
>  > more expensive checks (e.g. checking calls) in their development.
> 
> The last time I did some benchmarking the impact wasn't as ridiculous
> as say lockdep, or spinlock debug.

I think you're safe to assume that (outside of an individual developer's
private tree) it will never be nearly as heavy as lockdep or debug
pagealloc.  I hadn't thought of spinlock debug as a heavy one, but
yes, I guess it would be heavier than almost all VM_BUG_ON()s.

> Maybe the benchmarks I was using
> weren't pushing the VM very hard, but it seemed to me that the value
> in getting info in potential problems early was higher than a small
> performance increase.

We thank you.  I may have been over-estimating how much we put inside
those VM_BUG_ON()s, sorry.  Just so long as you're aware that there's
a danger that one day we might slip something heavier in there.

Those few explicit #ifdef CONFIG_DEBUG_VMs sometimes found in mm/
are probably the worst: you might want to check on the current crop.

> 
>  > Or did I read a few months ago that some change had been made to
>  > such definitions, and VM_BUG_ON(contents) are evaluated even when
>  > the config option is off?  I do hope I'm mistaken on that.
> 
> Pretty sure that isn't the case. I remember Andrew chastising people
> a few times for putting checks in VM_BUG_ON's that needed to stay around 
> even when the config option was off. Perhaps you were thinking of one
> of those incidents ?

Avoiding side-effects in BUG_ON and VM_BUG_ON.  Yes, that comes up
from time to time, and I'm a believer on that.  I think the discussion
I'm mis/remembering sprung out of one of those: someone was surprised
by the disassembly they found when it was configured off.

The correct answer is to try it for myself and see.  Not today.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
