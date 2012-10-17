Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 381166B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:38:58 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so8503097pad.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 12:38:57 -0700 (PDT)
Date: Wed, 17 Oct 2012 12:38:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
In-Reply-To: <20121017193229.GC16805@redhat.com>
Message-ID: <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com> <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com> <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com> <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com>
 <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com> <20121017193229.GC16805@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Oct 2012, Dave Jones wrote:

>  > Sounds good.  Is it possible to verify that policy_cache isn't getting 
>  > larger than normal in /proc/slabinfo, i.e. when all processes with a 
>  > task mempolicy or shared vma policy have exited, are there still a 
>  > significant number of active objects?
> 
> Killing the fuzzer caused it to drop dramatically.
> 
> Before:
> (15:29:59:davej@bitcrush:trinity[master])$ sudo cat /proc/slabinfo  | grep policy
> shared_policy_node   2931   2967    376   43    4 : tunables    0    0    0 : slabdata     69     69      0
> numa_policy         2971   6545    464   35    4 : tunables    0    0    0 : slabdata    187    187      0
> 
> After:
> (15:30:16:davej@bitcrush:trinity[master])$ sudo cat /proc/slabinfo  | grep policy
> shared_policy_node      0    215    376   43    4 : tunables    0    0    0 : slabdata      5      5      0
> numa_policy           15    175    464   35    4 : tunables    0    0    0 : slabdata      5      5      0
> 

Excellent, thanks.  This shows that the refcounting is working properly 
and we're not leaking any references as a result of this change causing 
the mempolicies to never be freed.  ("numa_policy" turns out to be 
policy_cache in the code, so thanks for checking both of them.)

Could I add your tested-by?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
