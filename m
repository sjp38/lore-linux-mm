Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 789DA6B00DC
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 06:42:51 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so2229828pdj.20
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 03:42:51 -0700 (PDT)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id hb3si1565627pac.239.2013.10.24.03.42.49
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 03:42:50 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id x13so3628441ief.9
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 03:42:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <526844E6.1080307@codeaurora.org>
References: <526844E6.1080307@codeaurora.org>
Date: Thu, 24 Oct 2013 18:42:48 +0800
Message-ID: <CAL1ERfOSmgo=j4YHHREY8uzyh+nbRrsFdBZ86FhMXxP5GEHQkQ@mail.gmail.com>
Subject: Re: zram/zsmalloc issues in very low memory conditions
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olav Haugan <ohaugan@codeaurora.org>
Cc: minchan@kernel.org, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, semenzato@google.com, bob.liu@oracle.com

On Thu, Oct 24, 2013 at 5:51 AM, Olav Haugan <ohaugan@codeaurora.org> wrote:
> I am trying to use zram in very low memory conditions and I am having
> some issues. zram is in the reclaim path. So if the system is very low
> on memory the system is trying to reclaim pages by swapping out (in this
> case to zram). However, since we are very low on memory zram fails to
> get a page from zsmalloc and thus zram fails to store the page. We get
> into a cycle where the system is low on memory so it tries to swap out
> to get more memory but swap out fails because there is not enough memory
> in the system! The major problem I am seeing is that there does not seem
> to be a way for zram to tell the upper layers to stop swapping out
> because the swap device is essentially "full" (since there is no more
> memory available for zram pages). Has anyone thought about this issue
> already and have ideas how to solve this or am I missing something and I
> should not be seeing this issue?

I agree with Luigi and Bob.

zram's size is based on how many free memory you expect to use for zram.
In my test, the compression ratio is about 1:4, of course the working
sets may be
different with yours.

Further more, may be you can modify vm_swap_full() to let kernel free swap_entry
aggressively.


> I am also seeing a couple other issues that I was wondering whether
> folks have already thought about:
>
> 1) The size of a swap device is statically computed when the swap device
> is turned on (nr_swap_pages). The size of zram swap device is dynamic
> since we are compressing the pages and thus the swap subsystem thinks
> that the zram swap device is full when it is not really full. Any
> plans/thoughts about the possibility of being able to update the size
> and/or the # of available pages in a swap device on the fly?
>
> 2) zsmalloc fails when the page allocated is at physical address 0 (pfn
> = 0) since the handle returned from zsmalloc is encoded as (<PFN>,
> <obj_idx>) and thus the resulting handle will be 0 (since obj_idx starts
> at 0). zs_malloc returns the handle but does not distinguish between a
> valid handle of 0 and a failure to allocate. A possible solution to this
> would be to start the obj_idx at 1. Is this feasible?
>
> Thanks,
>
> Olav Haugan
>
> --
> The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> hosted by The Linux Foundation
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
