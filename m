Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 646B26B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 07:03:50 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hn9so6759264wib.0
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 04:03:49 -0800 (PST)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id x43si38392068eey.229.2014.02.12.04.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 04:03:48 -0800 (PST)
Message-ID: <52FB62EE.7070205@iogearbox.net>
Date: Wed, 12 Feb 2014 13:02:54 +0100
From: Daniel Borkmann <borkmann@iogearbox.net>
MIME-Version: 1.0
Subject: Re: [BUG] at include/linux/page-flags.h:415 (PageTransHuge)
References: <52D03A9E.2030309@iogearbox.net> <20140110222248.4e8419ca.akpm@linux-foundation.org> <52D147F1.3040803@iogearbox.net> <52D3BCE9.4020405@suse.cz> <52D3D060.1010301@iogearbox.net> <52D69AB4.6000309@suse.cz> <52D6B213.4020602@iogearbox.net> <52EBB5E6.8010007@suse.cz> <20140207185816.GA7764@order.stressinduktion.org>
In-Reply-To: <20140207185816.GA7764@order.stressinduktion.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, Jared Hulbert <jaredeh@gmail.com>, netdev <netdev@vger.kernel.org>, Thomas Hellstrom <thellstrom@vmware.com>, John David Anglin <dave.anglin@bell.net>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Carsten Otte <cotte@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>

Hi Vlastimil,

On 02/07/2014 07:58 PM, Hannes Frederic Sowa wrote:
> On Fri, Jan 31, 2014 at 03:40:38PM +0100, Vlastimil Babka wrote:
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Fri, 31 Jan 2014 11:50:21 +0100
>> Subject: [PATCH] mm: include VM_MIXEDMAP flag in the VM_SPECIAL list to avoid
>>   m(un)locking
>>
>> Daniel Borkmann reported a bug with VM_BUG_ON assertions failing where
>> munlock_vma_pages_range() thinks it's unexpectedly in the middle of a THP page.
>> This can be reproduced in tools/testing/selftests/net/ by running make and
>> then ./psock_tpacket.
>>
>> The problem is that an order=2 compound page (allocated by
>> alloc_one_pg_vec_page() is part of the munlocked VM_MIXEDMAP vma (mapped by
>> packet_mmap()) and mistaken for a THP page and assumed to be order=9.
>>
>> The checks for THP in munlock came with commit ff6a6da60b89 ("mm: accelerate
>> munlock() treatment of THP pages"), i.e. since 3.9, but did not trigger a bug.
>> It just makes munlock_vma_pages_range() skip such compound pages until the next
>> 512-pages-aligned page, when it encounters a head page. This is however not a
>> problem for vma's where mlocking has no effect anyway, but it can distort the
>> accounting.
>> Since commit 7225522bb ("mm: munlock: batch non-THP page isolation and
>> munlock+putback using pagevec") this can trigger a VM_BUG_ON in PageTransHuge()
>> check.
>>
>> This patch fixes the issue by adding VM_MIXEDMAP flag to VM_SPECIAL - a list of
>> flags that make vma's non-mlockable and non-mergeable. The reasoning is that
>> VM_MIXEDMAP vma's are similar to VM_PFNMAP, which is already on the VM_SPECIAL
>> list, and both are intended for non-LRU pages where mlocking makes no sense
>> anyway.

Thanks a lot for your efforts.

Is your patch queued up somewhere for mainline and stable?

> I also ran into this problem and wanted to ask what the status of this
> patch is? Does it need further testing? I can surely help with that. ;)
>
> Thanks,
>
>    Hannes
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
