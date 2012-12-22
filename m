Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 495126B0078
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 19:36:43 -0500 (EST)
Received: by mail-vb0-f44.google.com with SMTP id fc26so5766441vbb.17
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:36:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 21 Dec 2012 16:36:21 -0800
Message-ID: <CALCETrUi4JJSahrDKBARrwGsGE=1RbH8WL4tk1YgDmEowzXtSQ@mail.gmail.com>
Subject: Re: [PATCH 0/9] Avoid populating unbounded num of ptes with mmap_sem held
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2012 at 4:49 PM, Michel Lespinasse <walken@google.com> wrote:
> We have many vma manipulation functions that are fast in the typical case,
> but can optionally be instructed to populate an unbounded number of ptes
> within the region they work on:
> - mmap with MAP_POPULATE or MAP_LOCKED flags;
> - remap_file_pages() with MAP_NONBLOCK not set or when working on a
>   VM_LOCKED vma;
> - mmap_region() and all its wrappers when mlock(MCL_FUTURE) is in effect;
> - brk() when mlock(MCL_FUTURE) is in effect.
>

Something's buggy here.  My evil test case is stuck with lots of
threads spinning at 100% system time.  Stack traces look like:

[<0000000000000000>] __mlock_vma_pages_range+0x66/0x70
[<0000000000000000>] __mm_populate+0xf9/0x150
[<0000000000000000>] vm_mmap_pgoff+0x9f/0xc0
[<0000000000000000>] sys_mmap_pgoff+0x7e/0x150
[<0000000000000000>] sys_mmap+0x22/0x30
[<0000000000000000>] system_call_fastpath+0x16/0x1b
[<0000000000000000>] 0xffffffffffffffff

perf top says:

 38.45%  [kernel]            [k] __mlock_vma_pages_range
 33.04%  [kernel]            [k] __get_user_pages
 28.18%  [kernel]            [k] __mm_populate

The tasks in question use MCL_FUTURE but not MAP_POPULATE.  These
tasks are immune to SIGKILL.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
