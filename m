Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0FB536B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:02:56 -0500 (EST)
Received: by bwz16 with SMTP id 16so20528215bwz.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 13:02:54 -0800 (PST)
Message-ID: <4D2B73FA.807@gmail.com>
Date: Mon, 10 Jan 2011 22:02:50 +0100
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: qemu-kvm defunct due to THP [was: mmotm 2011-01-06-15-41 uploaded]
References: <201101070014.p070Egpo023959@imap1.linux-foundation.org> <4D2B19C5.5060709@gmail.com> <20110110150128.GC9506@random.random>
In-Reply-To: <20110110150128.GC9506@random.random>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 01/10/2011 04:01 PM, Andrea Arcangeli wrote:
> On Mon, Jan 10, 2011 at 03:37:57PM +0100, Jiri Slaby wrote:
>> On 01/07/2011 12:41 AM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2011-01-06-15-41 has been uploaded to
>>
>> Hi, something of the following breaks qemu-kvm:
> 
> Thanks for the report. It's already fixed and I posted this a few days
> ago to linux-mm.
> 
> I had to rewrite the KVM THP support when merging THP in -mm, because
> the kvm code in -mm has async page faults and doing so I eliminated
> one gfn_to_page lookup for each kvm secondary mmu page fault. But
> first new attempt wasn't entirely successful ;), the below incremental
> fix should work. Please test it and let me know if any trouble is
> left.
> 
> Also note again on linux-mm I posted two more patches, I recommend to
> apply the other two as well. The second adds KSM THP support, the
> third cleanup some code but I like to have it tested.
> 
> Thanks a lot,
> Andrea
> 
> ====
> Subject: thp: fix for KVM THP support
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> There were several bugs: dirty_bitmap ignored (migration shutoff largepages),
> has_wrprotect_page(directory_level) ignored, refcount taken on tail page and
> refcount released on pfn head page post-adjustment (now it's being transferred
> during the adjustment, that's where KSM over THP tripped inside
> split_huge_page, the rest I found it by code review).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  arch/x86/kvm/mmu.c         |   97 ++++++++++++++++++++++++++++++++-------------
>  arch/x86/kvm/paging_tmpl.h |   10 +++-
>  2 files changed, 79 insertions(+), 28 deletions(-)

Yup, this works for me. If you point me to the other 2, I will test them
too...

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
