Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A4D4D6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 19:31:10 -0500 (EST)
Message-ID: <50E4D145.5030006@redhat.com>
Date: Wed, 02 Jan 2013 19:31:01 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/9] mm: remap_file_pages() fixes
References: <1356050997-2688-1-git-send-email-walken@google.com> <1356050997-2688-3-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2012 07:49 PM, Michel Lespinasse wrote:
> Assorted small fixes. The first two are quite small:
>
> - Move check for vma->vm_private_data && !(vma->vm_flags & VM_NONLINEAR)
>    within existing if (!(vma->vm_flags & VM_NONLINEAR)) block.
>    Purely cosmetic.
>
> - In the VM_LOCKED case, when dropping PG_Mlocked for the over-mapped
>    range, make sure we own the mmap_sem write lock around the
>    munlock_vma_pages_range call as this manipulates the vma's vm_flags.
>
> Last fix requires a longer explanation. remap_file_pages() can do its work
> either through VM_NONLINEAR manipulation or by creating extra vmas.
> These two cases were inconsistent with each other (and ultimately, both wrong)
> as to exactly when did they fault in the newly mapped file pages:
>
> - In the VM_NONLINEAR case, new file pages would be populated if
>    the MAP_NONBLOCK flag wasn't passed. If MAP_NONBLOCK was passed,
>    new file pages wouldn't be populated even if the vma is already
>    marked as VM_LOCKED.
>
> - In the linear (emulated) case, the work is passed to the mmap_region()
>    function which would populate the pages if the vma is marked as
>    VM_LOCKED, and would not otherwise - regardless of the value of the
>    MAP_NONBLOCK flag, because MAP_POPULATE wasn't being passed to
>    mmap_region().
>
> The desired behavior is that we want the pages to be populated and locked
> if the vma is marked as VM_LOCKED, or to be populated if the MAP_NONBLOCK
> flag is not passed to remap_file_pages().
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
