Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id E34AF6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 01:53:43 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id z11so1027833lbi.6
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 22:53:43 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id zy1si5890320lbb.12.2015.01.12.22.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 22:53:42 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id p9so1049514lbv.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 22:53:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150112122138.f173c6279af0b49565e956d3@linux-foundation.org>
References: <20150111135406.13266.42007.stgit@zurg>
	<20150112122138.f173c6279af0b49565e956d3@linux-foundation.org>
Date: Tue, 13 Jan 2015 10:53:42 +0400
Message-ID: <CALYGNiNtMgiHD9qQnczeWZy25wQ10LfQhoEGkW8KTbVfp9mBoA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix corner case in anon_vma endless growing prevention
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, "Elifaz, Dana" <Dana.Elifaz@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Chris Clayton <chris2553@googlemail.com>, Oded Gabbay <oded.gabbay@amd.com>, Michal Hocko <mhocko@suse.cz>, Greg KH <gregkh@suse.de>

On Mon, Jan 12, 2015 at 11:21 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 11 Jan 2015 16:54:06 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
>> Fix for BUG_ON(anon_vma->degree) splashes in unlink_anon_vmas()
>> ("kernel BUG at mm/rmap.c:399!").
>>
>> Anon_vma_clone() is usually called for a copy of source vma in destination
>> argument. If source vma has anon_vma it should be already in dst->anon_vma.
>> NULL in dst->anon_vma is used as a sign that it's called from anon_vma_fork().
>> In this case anon_vma_clone() finds anon_vma for reusing.
>>
>> Vma_adjust() calls it differently and this breaks anon_vma reusing logic:
>> anon_vma_clone() links vma to old anon_vma and updates degree counters but
>> vma_adjust() overrides vma->anon_vma right after that. As a result final
>> unlink_anon_vmas() decrements degree for wrong anon_vma.
>>
>> This patch assigns ->anon_vma before calling anon_vma_clone().
>>
>> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
>
> I've asked Greg not to take 7a3ef208e662 into -stable because of this
> problem.  So if you still think we should fix this in -stable, could
> you please prepare an updated patch and send it to Greg?

Will do. But let's wait for some just to be sure that is the last bug here.

>
>> Tested-by: Chris Clayton <chris2553@googlemail.com>
>> Tested-by: Oded Gabbay <oded.gabbay@amd.com>
>> Cc: Daniel Forrest <dan.forrest@ssec.wisc.edu>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
