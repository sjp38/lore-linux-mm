Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C72B86B006A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 00:03:35 -0400 (EDT)
Message-ID: <4CABF4C0.8060405@zytor.com>
Date: Tue, 05 Oct 2010 21:02:08 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
References: <1286265215-9025-1-git-send-email-walken@google.com> <1286265215-9025-3-git-send-email-walken@google.com>
In-Reply-To: <1286265215-9025-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10/05/2010 12:53 AM, Michel Lespinasse wrote:
> This change reduces mmap_sem hold times that are caused by waiting for
> disk transfers when accessing file mapped VMAs. It introduces the
> VM_FAULT_ALLOW_RETRY flag, which indicates that the call site wants
> mmap_sem to be released if blocking on a pending disk transfer.
> In that case, filemap_fault() returns the VM_FAULT_RETRY status bit
> and do_page_fault() will then re-acquire mmap_sem and retry the page fault.
> It is expected that the retry will hit the same page which will now be
> cached, and thus it will complete with a low mmap_sem hold time.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  arch/x86/mm/fault.c |   38 ++++++++++++++++++++++++++------------
>  include/linux/mm.h  |    2 ++
>  mm/filemap.c        |   23 ++++++++++++++++++++++-
>  mm/memory.c         |    3 ++-
>  4 files changed, 52 insertions(+), 14 deletions(-)
> 

Acked-by: H. Peter Anvin <hpa@zytor.com>

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
