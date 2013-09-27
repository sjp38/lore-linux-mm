Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD6C6B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 17:01:52 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so3089578pdj.17
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 14:01:52 -0700 (PDT)
Message-ID: <5245F222.1000603@intel.com>
Date: Fri, 27 Sep 2013 14:01:22 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 02/10] mm: convert mm->nr_ptes to atomic_t
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com> <1380287787-30252-3-git-send-email-kirill.shutemov@linux.intel.com> <5245EEAD.7010901@linux.vnet.ibm.com>
In-Reply-To: <5245EEAD.7010901@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/27/2013 01:46 PM, Cody P Schafer wrote:
> On 09/27/2013 06:16 AM, Kirill A. Shutemov wrote:
>> @@ -339,6 +339,7 @@ struct mm_struct {
>>       pgd_t * pgd;
>>       atomic_t mm_users;            /* How many users with user space? */
>>       atomic_t mm_count;            /* How many references to "struct
>> mm_struct" (users count as 1) */
>> +    atomic_t nr_ptes;            /* Page table pages */
>>       int map_count;                /* number of VMAs */
...
> 
> Will 32bits always be enough here? Should atomic_long_t be used instead?

There are 48 bits of virtual address space on x86 today.  12 bits of
that is the address inside the page, so we've at *most* 2^36 pages.  2^9
(512) pages are mapped by a pte page, so that means the page tables only
hold 2^27 pte pages in a single process.

We've got 31 bits of usable space in the atomic_t, so that definitely
works _today_.  If the virtual address space ever gets bigger, we might
have problems, though.

In practice, though, we steal a big chunk of that virtual address space
for the kernel, and that doesn't get accounted in mm->nr_ptes, so we've
got a _bit_ more wiggle room than just 4 bits.  Also, anybody that's
mapping >4 petabytes of memory with 4k ptes is just off their rocker.

I'm also not sure what the virtual address limits are for the more
obscure architectures, so I guess it's also possible they'll hit this.
I guess it wouldn't hurt to stick an overflow check in there for VM
debugging purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
