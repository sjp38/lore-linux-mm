Message-ID: <48D2EBBB.205@goop.org>
Date: Thu, 18 Sep 2008 17:00:59 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D17E75.80807@redhat.com> <48D1851B.70703@goop.org> <48D18919.9060808@redhat.com> <48D18C6B.5010407@goop.org> <48D2B970.7040903@redhat.com> <48D2D3B2.10503@goop.org> <48D2E65A.6020004@redhat.com>
In-Reply-To: <48D2E65A.6020004@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
>> Yes.  At worst Linux would underestimate the process RSS a bit
>> (depending on how many unsynchronized ptes you leave lying around).  I
>>   
>
> Not the RSS (that's pte.present pages) but the working set (aka active
> list).

Yep.

>> bet there's an appropriate pvop hook you could use to force
>> synchronization just before the kernel actually inspects the bits
>> (leaving lazy mode sounds good).
>>   
>
> It would have to be a new lazy mode, not the existing one, I think.

The only direct use of pte_young() is in zap_pte_range, within a
mmu_lazy region.  So syncing the A bit state on entering lazy mmu mode
would work fine there.

The call via page_referenced_one() doesn't seem to have a very
convenient hook though.  Perhaps putting something in
page_check_address() would do the job.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
