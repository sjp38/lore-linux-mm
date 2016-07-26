Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 777876B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 05:00:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so3627070wmp.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 02:00:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u84si406462wmg.19.2016.07.26.02.00.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 02:00:06 -0700 (PDT)
Subject: Re: [PATCH] mm: correctly handle errors during VMA merging
References: <1469514843-23778-1-git-send-email-vegard.nossum@oracle.com>
 <20160726085344.GA7370@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dad10820-47bd-4c6f-d7cf-b6bab665a6ea@suse.cz>
Date: Tue, 26 Jul 2016 11:00:04 +0200
MIME-Version: 1.0
In-Reply-To: <20160726085344.GA7370@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, Leon Yu <chianglungyu@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

On 07/26/2016 10:53 AM, Kirill A. Shutemov wrote:
> On Tue, Jul 26, 2016 at 08:34:03AM +0200, Vegard Nossum wrote:
>> In other words, it is possible to run into a memory allocation error
>> *after* part of the merging work has already been done. In this case,
>> we probably shouldn't return an error back to userspace anyway (since
>> it would not reflect the partial work that was done).
>>
>> I *think* the solution might be to simply ignore the errors from
>> vma_adjust() and carry on with distinct VMAs for adjacent regions that
>> might otherwise have been represented with a single VMA.
>
> I don't like this.
>
> At least, vma_adjust() should be able to handle mering more than three
> vmas together on next call if memory pressure gone. I would keep virtual
> address space fragmentation within reasonable.
>
> I think this wouldn't be easy to validate...

As I said, this shouldn't happen unless the process is being killed 
already. Otherwise the allocation behaves like __GFP_NOFAIL. We could 
also make it explicitly __GFP_NOFAIL but that might only complicate OOM 
situations.

>> I have a reproducer that runs into the bug within a few seconds when
>> fault injection is enabled -- with the patch I no longer see any
>> problems.
>>
>> The patch and resulting code admittedly look odd and I'm *far* from
>> an expert on mm internals, so feel free to propose counter-patches and
>
> One idea is to pre-allocate anon_vma, if remove_next == 2 before merging
> started and use it on second iteration instead of allocation it in
> anon_vma_clone().

It's not just anon_vma, but also anon_vma_chains, their number is not 
constant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
