Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0B47D6B0087
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 02:55:11 -0400 (EDT)
Date: Thu, 4 Apr 2013 15:55:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 0/4] Support vranges on files
Message-ID: <20130404065509.GE7675@blaptop>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hey John,

First of all, I should confess I just glanced your code and poped
several questions. If I miss something, please slap me.

On Wed, Apr 03, 2013 at 04:52:19PM -0700, John Stultz wrote:
> This patchset is against Minchan's vrange work here:
> 	https://lkml.org/lkml/2013/3/12/105
> 
> Extending it to support volatile ranges on files. In effect
> providing the same functionality of my earlier file based
> volatile range patches on-top of Minchan's anonymous volatile
> range work.
> 
> Volatile ranges on files are different then on anonymous memory,
> because the volatility state can be shared between multiple
> applications. This makes storing the volatile ranges exclusively
> in the mm_struct (or in vmas as in Minchan's earlier work)
> inappropriate.
> 
> The patchset starts with some minor cleanup.
> 
> Then we introduce the idea of a vrange_root, which provides a
> interval-tree root and a lock to protect the tree. This structure
> can then be stored in the mm_struct or in an addres_space. Then the
> same infrastructure can be used to manage volatile ranges on both
> anonymous and file backed memory.

Thanks for the above two patches. It is a nice cleanup.

> 
> Next we introduce a parallel fvrange() syscall for creating
> volatile ranges directly against files.

Okay. It seems you want to replace ashmem interface with fvrange.
I dobut we have to eat a slot for system call. Can't we add "int fd"
in vrange systemcall without inventing new wheel?

> 
> And finally, we change the range pruging logic to be able to
> handle both anonymous and file volatile ranges.

Okay. Then, what's the semantic file-vrange?

There is a file F. Process A mapped some part of file into his
address space. Then, Process B calls fvrange same part.
As I looked over your code, it purges the range although process B
is using now. Right? Is it your intention? Maybe isn't.

Let's define fvrange's semantic same with anon-vrange.
If there is a process using range with non-volatile, at least,
we shouldn't purge at all.

So your [4/4] should investigate all processes mapped the page
atomically. You could do it with i_mmap_mutex and vrange_lock
and percolate the logic into try_to_discard_vpage.

> 
> Now there are some quirks still to be resolved with the approach
> used here. The biggest one being the vrange() call can't be used to
> create volatile ranges against mmapped files. Instead only the

Why?

> fvrange() can be used to create file backed volatile ranges.

I could't understand your point. It would be better to explain
my thought firstly then, you could point out something I am missing
now. Look below.

> 
> This could be overcome by iterating across all the process VMAs to
> determine if they're anonymous or file based, and if file-based,
> create a VMA sized volatile range on the mapping pointed to by the
> VMA.

It needs just when we start to discard pages. Simply, it is related
to reclaim path, NOT system call path so it's not a problem.

> 
> But this would have downsides, as Minchan has been clear that he wants
> to optmize the vrange() calls so that it is very cheap to create and
> destroy volatile ranges. Having simple per-process ranges be created
> means we don't have to iterate across the vmas in the range to
> determine if they're anonymous or file backed. Instead the current
> vrange() code just creates per process ranges (which may or may not
> cover mmapped file data), but will only purge anonymous pages in
> that range. This keeps the vrange() call cheap.

Right.

> 
> Additionally, just creating or destroying a single range is very
> simple to do, and requires a fixed amount of memory known up front.
> Thus we can allocate needed data prior to making any modifications.
> 
> But If we were to create a range that crosses anonymous and file
> backed pages, it must create or destroy multiple per-process or
> per-file ranges. This could require an unknown number of allocations,

This is a part I can fail to parse your opinion.

> opening the possibility of getting an ENOMEM half-way through the
> operation, leaving the volatile range partially created or destroyed.
> 
> So to keep this simple for this first pass, for now we have two
> syscalls for two types of volatile ranges.


My idea is following as

        vrange(fd, start, len, mode, behavior)

A) fd = 0

1) system call context - vrange system call registers new vrange
   in mm_struct.
2) Add new vrange into LRU
3) reclaim context - walk with rmap to confirm all processes make
   the range with volatile -> discard

B) fd = 1

1) system call context - vrange system call registers new vrange
   in address_space
2) Add new vrange into LRU
3) reclaim context - walk with rmap to confirm all processes make
   the range with volatile -> discard

What's the problem in this logic?

> 
> Let me know if you have any thoughts or comments. I'm sure there's
> plenty of room for improvement here.
> 
> In the meantime I'll be playing with some different approaches to
> try to handle single volatile ranges that cross file and anonymous
> vmas.
> 
> The entire queue, both Minchan's changes and mine can be found here:
> git://git.linaro.org/people/jstultz/android-dev.git dev/vrange-minchan
> 
> thanks
> -john
> 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
