Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCF9E6B0009
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:35:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u68so1557026wmd.5
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:35:35 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a7si1860857wmf.154.2018.03.20.15.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 15:35:34 -0700 (PDT)
Date: Tue, 20 Mar 2018 23:35:30 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC PATCH 7/8] x86: mpx: pass atomic parameter to do_munmap()
In-Reply-To: <1521581486-99134-8-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1803202307330.1714@nanos.tec.linutronix.de>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com> <1521581486-99134-8-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>, x86@kernel.org

On Wed, 21 Mar 2018, Yang Shi wrote:

Please CC everyone involved on the full patch set next time. I had to dig
the rest out from my lkml archive to get the context.

> Pass "true" to do_munmap() to not do unlock/relock to mmap_sem when
> manipulating mpx map.

> This is API change only.

This is wrong. You cannot change the function in one patch and then clean
up the users. That breaks bisectability.

Depending on the number of callers this wants to be a single patch changing
both the function and the callers or you need to create a new function
which has the extra argument and switch all users over to it and then
remove the old function.

> @@ -780,7 +780,7 @@ static int unmap_entire_bt(struct mm_struct *mm,
>  	 * avoid recursion, do_munmap() will check whether it comes
>  	 * from one bounds table through VM_MPX flag.
>  	 */
> -	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL);
> +	return do_munmap(mm, bt_addr, mpx_bt_size_bytes(mm), NULL, true);

But looking at the full context this is the wrong approach.

First of all the name of that parameter 'atomic' is completely
misleading. It suggests that this happens in fully atomic context, which is
not the case.

Secondly, conditional locking is frowned upon in general and rightfully so.

So the right thing to do is to leave do_munmap() alone and add a new
function do_munmap_huge() or whatever sensible name you come up with. Then
convert the places which are considered to be safe one by one with a proper
changelog which explains WHY this is safe.

That way you avoid the chasing game of all existing do_munmap() callers and
just use the new 'free in chunks' approach where it is appropriate and
safe. No suprises, no bisectability issues....

While at it please add proper kernel doc documentation to both do_munmap()
and the new function which explains the intricacies.

Thanks,

	tglx
