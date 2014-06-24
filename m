Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 176016B006E
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 12:31:39 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so6259728wiv.9
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:31:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bw20si1953177wib.44.2014.06.24.09.31.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 09:31:31 -0700 (PDT)
Message-ID: <53A9A7D8.2020703@suse.cz>
Date: Tue, 24 Jun 2014 18:31:20 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406151921070.2850@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 06/16/2014 04:29 AM, Hugh Dickins wrote:
> On Thu, 12 Jun 2014, Sasha Levin wrote:
>> On 02/09/2014 08:41 PM, Sasha Levin wrote:
>>> On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>>>> Would trinity be likely to have a thread or process repeatedly faulting
>>>> in pages from the hole while it is being punched?
>>>
>>> I can see how trinity would do that, but just to be certain - Cc davej.
>>>
>>> On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>>>> Does this happen with other holepunch filesystems?  If it does not,
>>>> I'd suppose it's because the tmpfs fault-in-newly-created-page path
>>>> is lighter than a consistent disk-based filesystem's has to be.
>>>> But we don't want to make the tmpfs path heavier to match them.
>>>
>>> No, this is strictly limited to tmpfs, and AFAIK trinity tests hole
>>> punching in other filesystems and I make sure to get a bunch of those
>>> mounted before starting testing.
>>
>> Just pinging this one again. I still see hangs in -next where the hang
>> location looks same as before:
>>
> 
> Please give this patch a try.  It fixes what I can reproduce, but given
> your unexplained page_mapped() BUG in this area, we know there's more
> yet to be understood, so perhaps this patch won't do enough for you.
> 

Hi,

since this got a CVE, I've been looking at backport to an older kernel where
fallocate(FALLOC_FL_PUNCH_HOLE) is not yet supported, and there's also no
range notification mechanism yet. There's just madvise(MADV_REMOVE) and since
it doesn't guarantee anything, it seems simpler just to give up retrying to
truncate really everything. Then I realized that maybe it would work for
current kernel as well, without having to add any checks in the page fault
path. The semantics of fallocate(FALLOC_FL_PUNCH_HOLE) might look different
from madvise(MADV_REMOVE), but it seems to me that as long as it does discard
the old data from the range, it's fine from any information leak point of view.
If someone races page faulting, it IMHO doesn't matter if he gets a new zeroed
page before the parallel truncate has ended, or right after it has ended.
So I'm posting it here as a RFC. I haven't thought about the
i915_gem_object_truncate caller yet. I think that this path wouldn't satisfy
the new "lstart < inode->i_size" condition, but I don't know if it's "vulnerable"
to the problem.

-----8<-----
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH] shmem: prevent livelock between page fault and hole punching

---
 mm/shmem.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index f484c27..6d6005c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -476,6 +476,25 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		if (!pvec.nr) {
 			if (index == start || unfalloc)
 				break;
+                        /* 
+                         * When this condition is true, it means we were
+                         * called from fallocate(FALLOC_FL_PUNCH_HOLE).
+                         * To prevent a livelock when someone else is faulting
+                         * pages back, we are content with single pass and do
+                         * not retry with index = start. It's important that
+                         * previous page content has been discarded, and
+                         * faulter(s) got new zeroed pages.
+                         *
+                         * The other callsites are shmem_setattr (for
+                         * truncation) and shmem_evict_inode, which set i_size
+                         * to truncated size or 0, respectively, and then call
+                         * us with lstart == inode->i_size. There we do want to
+                         * retry, and livelock cannot happen for other reasons.
+                         *
+                         * XXX what about i915_gem_object_truncate?
+                         */
+                        if (lstart < inode->i_size)
+                                break;
 			index = start;
 			continue;
 		}
-- 
1.8.4.5




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
