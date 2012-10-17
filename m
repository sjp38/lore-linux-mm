Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 615FF6B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:21:23 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so8485578pad.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 12:21:22 -0700 (PDT)
Date: Wed, 17 Oct 2012 12:21:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
In-Reply-To: <20121017181413.GA16805@redhat.com>
Message-ID: <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com> <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com> <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Oct 2012, Dave Jones wrote:

> On Tue, Oct 16, 2012 at 10:24:32PM -0700, David Rientjes wrote:
>  > On Wed, 17 Oct 2012, Dave Jones wrote:
>  > 
>  > > BUG: sleeping function called from invalid context at kernel/mutex.c:269
>  > 
>  > Hmm, looks like we need to change the refcount semantics entirely.  We'll 
>  > need to make get_vma_policy() always take a reference and then drop it 
>  > accordingly.  This work sif get_vma_policy() can grab a reference while 
>  > holding task_lock() for the task policy fallback case.
>  > 
>  > Comments on this approach?
> 
> Seems to be surviving my testing at least..
> 

Sounds good.  Is it possible to verify that policy_cache isn't getting 
larger than normal in /proc/slabinfo, i.e. when all processes with a 
task mempolicy or shared vma policy have exited, are there still a 
significant number of active objects?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
