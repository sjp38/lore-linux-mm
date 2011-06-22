Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F0276900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:28:33 -0400 (EDT)
Message-ID: <4E027A96.3040905@redhat.com>
Date: Wed, 22 Jun 2011 19:28:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com>	<201106212132.39311.nai.xia@gmail.com>	<4E01C752.10405@redhat.com>	<4E01CC77.10607@ravellosystems.com>	<4E01CDAD.3070202@redhat.com>	<4E01CFD2.6000404@ravellosystems.com>	<4E020CBC.7070604@redhat.com> <BANLkTikidXPzyxySbmrXK=EUXOzqMtm-0g@mail.gmail.com>
In-Reply-To: <BANLkTikidXPzyxySbmrXK=EUXOzqMtm-0g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 06/22/2011 07:13 PM, Nai Xia wrote:
> On Wed, Jun 22, 2011 at 11:39 PM, Rik van Riel<riel@redhat.com>  wrote:
>> On 06/22/2011 07:19 AM, Izik Eidus wrote:
>>
>>> So what we say here is: it is better to have little junk in the unstable
>>> tree that get flushed eventualy anyway, instead of make the guest
>>> slower....
>>> this race is something that does not reflect accurate of ksm anyway due
>>> to the full memcmp that we will eventualy perform...
>>
>> With 2MB pages, I am not convinced they will get "flushed eventually",
>> because there is a good chance at least one of the 4kB pages inside
>> a 2MB page is in active use at all times.
>>
>> I worry that the proposed changes may end up effectively preventing
>> KSM from scanning inside 2MB pages, when even one 4kB page inside
>> is in active use.  This could mean increased swapping on systems
>> that run low on memory, which can be a much larger performance penalty
>> than ksmd CPU use.
>>
>> We need to scan inside 2MB pages when memory runs low, regardless
>> of the accessed or dirty bits.
>
> I agree on this point. Dirty bit , young bit, is by no means accurate. Even
> on 4kB pages, there is always a chance that the pte are dirty but the contents
> are actually the same. Yeah, the whole optimization contains trade-offs and
> trades-offs always have the possibilities to annoy  someone.  Just like
> page-bit-relying LRU approximations none of them is perfect too. But I think
> it can benefit some people. So maybe we could just provide a generic balanced
> solution but provide fine tuning interfaces to make sure tha when it really gets
> in the way of someone, he has a way to walk around.
> Do you agree on my argument? :-)

That's not an argument.

That is a "if I wave my hands vigorously enough, maybe people
will let my patch in without thinking about what I wrote"
style argument.

I believe your optimization makes sense for 4kB pages, but
is going to be counter-productive for 2MB pages.

Your approach of "make ksmd skip over more pages, so it uses
less CPU" is likely to reduce the effectiveness of ksm by not
sharing some pages.

For 4kB pages that is fine, because you'll get around to them
eventually.

However, the internal use of a 2MB page is likely to be quite
different.  Chances are most 2MB pages will have actively used,
barely used and free pages inside.

You absolutely want ksm to get at the barely used and free
sub-pages.  Having just one actively used 4kB sub-page prevent
ksm from merging any of the other 511 sub-pages is a problem.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
