Message-ID: <48D18919.9060808@redhat.com>
Date: Wed, 17 Sep 2008 15:47:53 -0700
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D17E75.80807@redhat.com> <48D1851B.70703@goop.org>
In-Reply-To: <48D1851B.70703@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
>> One problem is the accessed bit.  If it's unset, the shadow code
>> cannot make the pte present (since it has to trap in order to set the
>> accessed bit); if it's set, we're lying to the vm.
>>     
>
> So even if the guest pte were present but non-accessed, the shadow pte
> would have to be non-present and you'd end up taking the fault anyway?
>
>   

Yes.

> Hm, that does undermine the benefits.  Does that mean that when the vm
> clears the access bit, you always have to make the shadow non-present? 
> I guess so.  And similarly with dirty and writable shadow.
>
>   

Yes.

> The counter-argument is that something has gone wrong if we start
> populating ptes that aren't going to be used in the near future anyway -
> if they're never used then any effort taken to populate them is wasted. 
> Therefore, setting accessed on them from the outset isn't terribly bad.
>
>   

We don't know whether the page will be used or not.  Keeping the 
accessed bit clear allows the vm to reclaim it early, and in preference 
to the pages it actually used.

We could work around it by having a hypercall to read and clear accessed 
bits.  If we know the guest will only do that via the hypercall, we can 
keep the accessed (and dirty) bits in the host, and not update them in 
the guest at all.  Given good batching, there's potential for a large 
win there.

(If the host throws away a shadow page, it could sync the bits back into 
the guest pte for safekeeping)

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
