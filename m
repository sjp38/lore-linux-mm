Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id F04826B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 13:24:03 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id fl17so2561418vcb.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 10:24:02 -0700 (PDT)
Message-ID: <508975A4.50203@gmail.com>
Date: Thu, 25 Oct 2012 13:23:48 -0400
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
References: <20121008150949.GA15130@redhat.com>  <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>  <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>  <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>  <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>  <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>  <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>  <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>  <20121017040515.GA13505@redhat.com>  <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>  <CA+1xoqe74R6DX8Yx2dsp1MkaWkC1u6yAEd8eWEdiwi88pYdPaw@mail.gmail.com>  <alpine.DEB.2.00.1210241633290.22819@chino.kir.corp.google.com>  <CA+1xoqd6MEFP-eWdnWOrcz2EmE6tpd7UhgJyS8HjQ8qrGaMMMw@mail.gmail.com>  <alpine.DEB.2.00.1210241659260.22819@chino.kir.corp.google.com>  <1351167554.23337.14.camel@twins> <1351175972.12171.14.camel@twins>
In-Reply-To: <1351175972.12171.14.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/25/2012 10:39 AM, Peter Zijlstra wrote:
> On Thu, 2012-10-25 at 14:19 +0200, Peter Zijlstra wrote:
>> On Wed, 2012-10-24 at 17:08 -0700, David Rientjes wrote:
>>> Ok, this looks the same but it's actually a different issue: 
>>> mpol_misplaced(), which now only exists in linux-next and not in 3.7-rc2, 
>>> calls get_vma_policy() which may take the shared policy mutex.  This 
>>> happens while holding page_table_lock from do_huge_pmd_numa_page() but 
>>> also from do_numa_page() while holding a spinlock on the ptl, which is 
>>> coming from the sched/numa branch.
>>>
>>> Is there anyway that we can avoid changing the shared policy mutex back 
>>> into a spinlock (it was converted in b22d127a39dd ["mempolicy: fix a race 
>>> in shared_policy_replace()"])?
>>>
>>> Adding Peter, Rik, and Mel to the cc. 
>>
>> Urgh, crud I totally missed that.
>>
>> So the problem is that we need to compute if the current page is placed
>> 'right' while holding pte_lock in order to avoid multiple pte_lock
>> acquisitions on the 'fast' path.
>>
>> I'll look into this in a bit, but one thing that comes to mind is having
>> both a spnilock and a mutex and require holding both for modification
>> while either one is sufficient for read.
>>
>> That would allow sp_lookup() to use the spinlock, while insert and
>> replace can hold both.
>>
>> Not sure it will work for this, need to stare at this code a little
>> more.
> 
> So I think the below should work, we hold the spinlock over both rb-tree
> modification as sp free, this makes mpol_shared_policy_lookup() which
> returns the policy with an incremented refcount work with just the
> spinlock.
> 
> Comments?
> 
> ---

It made the warnings I've reported go away.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
