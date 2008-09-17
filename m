Message-ID: <48D17A93.4000803@goop.org>
Date: Wed, 17 Sep 2008 14:45:55 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D1625C.7000309@redhat.com>
In-Reply-To: <48D1625C.7000309@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Chris Snook wrote:
> Is it still expensive when you're using nested page tables?

No, nested pagetables are the same as native to update, so the main
benefit in that case is the reduction of faults.

> We already have rather well-tested code in the VM to detect fault
> patterns, complete with userspace hints to set readahead policy.  It
> seems to me that if we're going to read nearby pages into pagecache,
> we might as well actually map them at the same time.  Duplicating the
> readahead code is probably a bad idea.

Right, that was my point.  I'm assuming that that machinery already
exists and would be available for use in this case.

>> Minor faults are easier; if the page already exists in memory, we should
>> just create mappings to it.  If neighbouring pages are also already
>> present, then we can can cheaply create mappings for them too.
>
> If we're mapping pagecache, then sure, this is really cheap, but
> speculatively allocating anonymous pages will hurt, badly, on many
> workloads.

OK, makes sense.  Does the access pattern detecting code measure access
patterns to anonymous mappings?

>> This seems like an obvious idea, so I'm wondering if someone has
>> prototyped it already to see what effects there are.  In the native
>> case, pte updates are much cheaper, so perhaps it doesn't help much
>> there, though it would potentially reduce the number of faults
>> needed. But I think there's scope for measurable benefits in the
>> virtual case.
>
> Sounds like something we might want to enable conditionally on the use
> of pv_ops features.

Perhaps, but I'd rather avoid it.  I'm hoping this is something we could
do that has - at worst - no effect on the native case, while improving
the virtual case.  The test matrix is already large enough without
adding another stateful switch.  After all, any side effect which makes
it a bad idea for the native case will probably be bad enough to
overwhelm any benefit in the virtual case.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
