Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 425DE6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 17:21:37 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so9511673pdj.1
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:21:36 -0700 (PDT)
Date: Tue, 15 Oct 2013 14:21:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private
 anonymous memory
Message-Id: <20131015142132.853f383980be58e18fa3c60a@linux-foundation.org>
In-Reply-To: <1381800678-16515-2-git-send-email-ccross@android.com>
References: <1381800678-16515-1-git-send-email-ccross@android.com>
	<1381800678-16515-2-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Kees Cook <keescook@chromium.org>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-mm@kvack.org

On Mon, 14 Oct 2013 18:31:17 -0700 Colin Cross <ccross@android.com> wrote:

> In many userspace applications, and especially in VM based
> applications like Android uses heavily, there are multiple different
> allocators in use.  At a minimum there is libc malloc and the stack,
> and in many cases there are libc malloc, the stack, direct syscalls to
> mmap anonymous memory, and multiple VM heaps (one for small objects,
> one for big objects, etc.).  Each of these layers usually has its own
> tools to inspect its usage; malloc by compiling a debug version, the
> VM through heap inspection tools, and for direct syscalls there is
> usually no way to track them.
> 
> On Android we heavily use a set of tools that use an extended version
> of the logic covered in Documentation/vm/pagemap.txt to walk all pages
> mapped in userspace and slice their usage by process, shared (COW) vs.
> unique mappings, backing, etc.  This can account for real physical
> memory usage even in cases like fork without exec (which Android uses
> heavily to share as many private COW pages as possible between
> processes), Kernel SamePage Merging, and clean zero pages.  It
> produces a measurement of the pages that only exist in that process
> (USS, for unique), and a measurement of the physical memory usage of
> that process with the cost of shared pages being evenly split between
> processes that share them (PSS).
> 
> If all anonymous memory is indistinguishable then figuring out the
> real physical memory usage (PSS) of each heap requires either a pagemap
> walking tool that can understand the heap debugging of every layer, or
> for every layer's heap debugging tools to implement the pagemap
> walking logic, in which case it is hard to get a consistent view of
> memory across the whole system.
> 
> This patch adds a field to /proc/pid/maps and /proc/pid/smaps to
> show a userspace-provided name for anonymous vmas.  The names of
> named anonymous vmas are shown in /proc/pid/maps and /proc/pid/smaps
> as [anon:<name>].

I'm pretty wobbly about this.

- Fishing around in another process's user memory for /proc strings
  is unusual and problems might crop up if we missed something.  

- Adding thing to the userspace interface is a big deal, because we
  should continue to support them evermore.  This becomes more of a
  concern when the implementation and interface is so unusual.

- I'm not aware of anyone else expressing interest in or a need for
  this extension, and Android are well able to carry their own kernel
  patches.

- otoh, it's undesirable that external groups carry their own
  patches, and we should try to get these things integrated to better
  serve our users.

So, wobble wobble.  Does anyone else have an opinion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
