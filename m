Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 25BCF6B005D
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 20:00:35 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so7126327pbb.14
        for <linux-mm@kvack.org>; Fri, 14 Sep 2012 17:00:34 -0700 (PDT)
Date: Fri, 14 Sep 2012 17:00:29 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 6/7] mm: add CONFIG_DEBUG_VM_RB build option
Message-ID: <20120915000029.GA29426@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
 <1346750457-12385-7-git-send-email-walken@google.com>
 <5053AC2F.3070203@gmail.com>
 <CANN689Ff3W4z=+3J8aGO-2GrPHGJ=ote_f5q9jzRQRAP+b0T4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689Ff3W4z=+3J8aGO-2GrPHGJ=ote_f5q9jzRQRAP+b0T4Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Jones <davej@redhat.com>, Jiri Slaby <jslaby@suse.cz>

On Fri, Sep 14, 2012 at 3:46 PM, Michel Lespinasse <walken@google.com> wrote:
> On Fri, Sep 14, 2012 at 3:14 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
>> On 09/04/2012 11:20 AM, Michel Lespinasse wrote:
>>> Add a CONFIG_DEBUG_VM_RB build option for the previously existing
>>> DEBUG_MM_RB code. Now that Andi Kleen modified it to avoid using
>>> recursive algorithms, we can expose it a bit more.
>>>
>>> Also extend this code to validate_mm() after stack expansion, and to
>>> check that the vma's start and last pgoffs have not changed since the
>>> nodes were inserted on the anon vma interval tree (as it is important
>>> that the nodes be reindexed after each such update).
>>
>> This patch exposes the following warning:
>>
>> [   24.977502] ------------[ cut here ]------------
>> [   24.979089] WARNING: at mm/interval_tree.c:110
>> anon_vma_interval_tree_verify+0x81/0xa0()
>> [   24.981765] Pid: 5928, comm: trinity-child37 Tainted: G        W
>> 3.6.0-rc5-next-20120914-sasha-00003-g7deb7fa-dirty #333
>> [   24.985501] Call Trace:
>> [   24.986345]  [<ffffffff81224c91>] ? anon_vma_interval_tree_verify+0x81/0xa0
>> [   24.988535]  [<ffffffff81106766>] warn_slowpath_common+0x86/0xb0
>> [   24.990636]  [<ffffffff81106855>] warn_slowpath_null+0x15/0x20
>> [   24.992658]  [<ffffffff81224c91>] anon_vma_interval_tree_verify+0x81/0xa0
>> [   24.994980]  [<ffffffff8122e6e8>] validate_mm+0x58/0x1e0
>> [   24.996772]  [<ffffffff8122e934>] vma_link+0x94/0xe0
>> [   24.997719]  [<ffffffff812315e9>] copy_vma+0x279/0x2e0
>> [   24.998522]  [<ffffffff8117a7fd>] ? trace_hardirqs_off+0xd/0x10
>> [   25.000772]  [<ffffffff81232e89>] move_vma+0xa9/0x260
>> [   25.002499]  [<ffffffff812334b5>] sys_mremap+0x475/0x540
>> [   25.004364]  [<ffffffff8374b6e8>] tracesys+0xe1/0xe6
>> [   25.006108] ---[ end trace 7c901670963aa6e2 ]---
>>
>> The code line is
>>
>>         WARN_ON_ONCE(node->cached_vma_last != avc_last_pgoff(node));
>
> That's very interesting (and potentially relevant to another bug
> that's been reported too).
>
> I'd like to know, what workload did you use that triggered this ?
> (I find it hard to test mremap as I don't know of enough users of it)

All right. Hugh managed to reproduce the issue on his suse laptop, and
I came up with a fix.

The problem was that in mremap, the new vma's vm_{start,end,pgoff}
fields need to be updated before calling anon_vma_clone() so that the
new vma will be properly indexed.

Patch attached. I expect this should also explain Jiri's reported
failure involving splitting THP pages during mremap(), even though we
did not manage to reproduce that one.

---------------------------------8<-------------------------------

From: Michel Lespinasse <walken@google.com>
Date: Fri, 14 Sep 2012 16:43:49 -0700
Subject: [PATCH] mm anon rmap: in mremap, set the new vma's position before
 anon_vma_clone()

anon_vma_clone() expects new_vma->vm_{start,end,pgoff} to be correctly set
so that the new vma can be indexed on the anon interval tree.

copy_vma() was failing to do that, which broke mremap().

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/mmap.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index cc8c64077a42..7e672800b5d4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2446,16 +2446,16 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (new_vma) {
 			*new_vma = *vma;
+			new_vma->vm_start = addr;
+			new_vma->vm_end = addr + len;
+			new_vma->vm_pgoff = pgoff;
 			pol = mpol_dup(vma_policy(vma));
 			if (IS_ERR(pol))
 				goto out_free_vma;
+			vma_set_policy(new_vma, pol);
 			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
 			if (anon_vma_clone(new_vma, vma))
 				goto out_free_mempol;
-			vma_set_policy(new_vma, pol);
-			new_vma->vm_start = addr;
-			new_vma->vm_end = addr + len;
-			new_vma->vm_pgoff = pgoff;
 			if (new_vma->vm_file) {
 				get_file(new_vma->vm_file);
 
-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
