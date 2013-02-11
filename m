Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 11E396B0008
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 14:41:51 -0500 (EST)
Message-ID: <51194960.5080909@redhat.com>
Date: Mon, 11 Feb 2013 14:41:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: mm: Check if PUD is large when validating a kernel
 address
References: <20130211145236.GX21389@suse.de>
In-Reply-To: <20130211145236.GX21389@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/11/2013 09:52 AM, Mel Gorman wrote:
> A user reported the following oops when a backup process read
> /proc/kcore.
>
>   BUG: unable to handle kernel paging request at ffffbb00ff33b000

> Investigation determined that the bug triggered when reading system RAM
> at the 4G mark. On this system, that was the first address using 1G pages
> for the virt->phys direct mapping so the PUD is pointing to a physical
> address, not a PMD page.  The problem is that the page table walker in
> kern_addr_valid() is not checking pud_large() and treats the physical
> address as if it was a PMD.  If it happens to look like pmd_none then it'll
> silently fail, probably returning zeros instead of real data. If the data
> happens to look like a present PMD though, it will be walked resulting in
> the oops above. This patch adds the necessary pud_large() check.
>
> Unfortunately the problem was not readily reproducible and now they are
> running the backup program without accessing /proc/kcore so the patch has
> not been validated but I think it makes sense. If reviewers agree then it
> should also be included in -stable back as far as 3.0-stable.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.coM>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
