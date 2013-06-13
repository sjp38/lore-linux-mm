Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 244006B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 19:44:03 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so10755559pbb.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2013 16:44:02 -0700 (PDT)
Message-ID: <51BA593E.9000102@linaro.org>
Date: Thu, 13 Jun 2013 16:43:58 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] vrange: Clear volatility on new mmaps
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org> <1371010971-15647-5-git-send-email-john.stultz@linaro.org> <20130613062815.GB5209@bbox>
In-Reply-To: <20130613062815.GB5209@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06/12/2013 11:28 PM, Minchan Kim wrote:
> Hey John,
>
> On Tue, Jun 11, 2013 at 09:22:47PM -0700, John Stultz wrote:
>> At lsf-mm, the issue was brought up that there is a precedence with
>> interfaces like mlock, such that new mappings in a pre-existing range
>> do no inherit the mlock state.
>>
>> This is mostly because mlock only modifies the existing vmas, and so
>> any new mmaps create new vmas, which won't be mlocked.
>>
>> Since volatility is not stored in the vma (for good cause, specfically
>> as we'd have to have manage file volatility differently from anonymous
>> and we're likely to manage volatility on small chunks of memory, which
>> would cause lots of vma splitting and churn), this patch clears volatilty
>> on new mappings, to ensure that we don't inherit volatility if memory in
>> an existing volatile range is unmapped and then re-mapped with something
>> else.
>>
>> Thus, this patch forces any volatility to be cleared on mmap.
> If we have lots of node on vroot but it doesn't include newly mmmaping
> vma range, it's purely unnecessary cost and that's never what we want.
>
>> XXX: We expect this patch to be not well loved by mm folks, and are open
>> to alternative methods here. Its more of a place holder to address
>> the issue from lsf-mm and hopefully will spur some further discussion.
> Another idea is we can add "bool is_vrange" in struct vm_area_struct.
> It is protected by vrange_lock. The scenario is following as,
>
> When do_vrange is called with VRANGE_VOLATILE, it iterates vmas
> and mark the vma->is_vrange to true. So, we can avoid tree traversal
> if the is_vrange is false when munmap is called and newly mmaped vma
> doesn't need to clear any volatility.

We could look further into this approach if folks think its the best way 
to go. Though it has the downside of having the split the vmas when 
we're dealing with a large number of smallish objects. Also we'd be 
increasing the vma_struct size for everyone, even if no one is using 
volatile ranges, which may be a bigger concern.

Also it means we'd be managing anonymous and file volatility with 
different structures (though that's not the end of the world).

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
