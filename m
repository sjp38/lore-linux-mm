Message-ID: <48D1851B.70703@goop.org>
Date: Wed, 17 Sep 2008 15:30:51 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D17E75.80807@redhat.com>
In-Reply-To: <48D17E75.80807@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Jeremy Fitzhardinge wrote:
>> Minor faults are easier; if the page already exists in memory, we should
>> just create mappings to it.  If neighbouring pages are also already
>> present, then we can can cheaply create mappings for them too.
>>

(Just to clarify an ambiguity here: by "present" I mean "exists in
memory" not "a present pte".)

> One problem is the accessed bit.  If it's unset, the shadow code
> cannot make the pte present (since it has to trap in order to set the
> accessed bit); if it's set, we're lying to the vm.

So even if the guest pte were present but non-accessed, the shadow pte
would have to be non-present and you'd end up taking the fault anyway?

Hm, that does undermine the benefits.  Does that mean that when the vm
clears the access bit, you always have to make the shadow non-present? 
I guess so.  And similarly with dirty and writable shadow.

The counter-argument is that something has gone wrong if we start
populating ptes that aren't going to be used in the near future anyway -
if they're never used then any effort taken to populate them is wasted. 
Therefore, setting accessed on them from the outset isn't terribly bad.

(I'm not very convinced by that argument either, and it makes the
potential for bad side-effects much worse if the apparent RSS of a
process is multiplied by some factor.)

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
