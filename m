Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03E9F6B0268
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 13:32:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 191so3120519pgd.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 10:32:10 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a7si199686pln.245.2017.11.01.10.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 10:31:52 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
 <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com>
Date: Wed, 1 Nov 2017 10:31:50 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------700068124B7E47410723F297"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

This is a multi-part message in MIME format.
--------------700068124B7E47410723F297
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 11/01/2017 09:08 AM, Linus Torvalds wrote:
> On Tue, Oct 31, 2017 at 4:44 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>> On 10/31/2017 04:27 PM, Linus Torvalds wrote:
>>>  (c) am I reading the code correctly, and the shadow page tables are
>>> *completely* duplicated?
>>>
>>>      That seems insane. Why isn't only tyhe top level shadowed, and
>>> then lower levels are shared between the shadowed and the "kernel"
>>> page tables?
>>
>> There are obviously two PGDs.  The userspace half of the PGD is an exact
>> copy so all the lower levels are shared.  The userspace copying is
>> done via the code we add to native_set_pgd().
> 
> So the thing that made me think you do all levels was that confusing
> kaiser_pagetable_walk() code (and to a lesser degree
> get_pa_from_mapping()).
> 
> That code definitely walks and allocates all levels.
> 
> So it really doesn't seem to be just sharing the top page table entry.

Yeah, they're quite lightly commented and badly named now that I go look
at them.

get_pa_from_mapping() should be called something like
get_pa_from_kernel_map().  Its job is to look at the main (kernel) page
tables and go get an address from there.  It's only ever called on
kernel addresses.

kaiser_pagetable_walk() should probably be
kaiser_shadow_pagetable_walk().  Its job is to walk the shadow copy and
find the location of a 4k PTE.  You can then populate that PTE with the
address you got from get_pa_from_mapping() (or clear it in the remove
mapping case).

I've attached an update to the core patch and Documentation that should
help clear this up.

> And that worries me because that seems to be a very fundamental coherency issue.
> 
> I'm assuming that this is about mapping only the individual kernel
> parts, but I'd like to get comments and clarification about that.

I assume that you're really worried about having to go two places to do
one thing, like clearing a dirty bit, or unmapping a PTE, especially
when we have to do that for userspace.  Thankfully, the sharing of the
page tables (under the PGD) for userspace gets rid of most of this
nastiness.

I hope that's more clear now.

--------------700068124B7E47410723F297
Content-Type: text/x-patch;
 name="kaiser-core-update1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="kaiser-core-update1.patch"

diff --git a/Documentation/x86/kaiser.txt b/Documentation/x86/kaiser.txt
index 67a70d2..5b5e9c4 100644
--- a/Documentation/x86/kaiser.txt
+++ b/Documentation/x86/kaiser.txt
@@ -1,3 +1,6 @@
+Overview
+========
+
 KAISER is a countermeasure against attacks on kernel address
 information.  There are at least three existing, published,
 approaches using the shared user/kernel mapping and hardware features
@@ -18,6 +21,35 @@ This helps ensure that side-channel attacks that leverage the
 paging structures do not function when KAISER is enabled.  It
 can be enabled by setting CONFIG_KAISER=y
 
+Page Table Management
+=====================
+
+KAISER logically keeps a "copy" of the page tables which unmap
+the kernel while in userspace.  The kernel manages the page
+tables as normal, but the "copying" is done with a few tricks
+that mean that we do not have to manage two full copies.
+
+The first trick is that for any any new kernel mapping, we
+presume that we do not want it mapped to userspace.  That means
+we normally have no copying to do.  We only copy the kernel
+entries over to the shadow in response to a kaiser_add_*()
+call which is rare.
+
+For a new userspace mapping, the kernel makes the entries in
+its page tables like normal.  The only difference is when the
+kernel makes entries in the top (PGD) level.  In addition to
+setting the entry in the main kernel PGD, a copy if the entry
+is made in the shadow PGD.
+
+PGD entries always point to another page table.  Two PGD
+entries pointing to the same thing gives us shared page tables
+for all the lower entries.  This leaves a single, shared set of
+userspace page tables to manage.  One PTE to lock, one set set
+of accessed bits, dirty bits, etc...
+
+Overhead
+========
+
 Protection against side-channel attacks is important.  But,
 this protection comes at a cost:
 
diff --git a/arch/x86/mm/kaiser.c b/arch/x86/mm/kaiser.c
index 57f7637..cde9014 100644
--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -49,9 +49,21 @@
 static DEFINE_SPINLOCK(shadow_table_allocation_lock);
 
 /*
+ * This is a generic page table walker used only for walking kernel
+ * addresses.  We use it too help recreate the "shadow" page tables
+ * which are used while we are in userspace.
+ *
+ * This can be called on any kernel memory addresses and will work
+ * with any page sizes and any types: normal linear map memory,
+ * vmalloc(), even kmap().
+ *
+ * Note: this is only used when mapping new *kernel* entries into
+ * the user/shadow page tables.  It is never used for userspace
+ * addresses.
+ *
  * Returns -1 on error.
  */
-static inline unsigned long get_pa_from_mapping(unsigned long vaddr)
+static inline unsigned long get_pa_from_kernel_map(unsigned long vaddr)
 {
 	pgd_t *pgd;
 	p4d_t *p4d;
@@ -59,6 +71,8 @@ static inline unsigned long get_pa_from_mapping(unsigned long vaddr)
 	pmd_t *pmd;
 	pte_t *pte;
 
+	WARN_ON_ONCE(vaddr < PAGE_OFFSET);
+
 	pgd = pgd_offset_k(vaddr);
 	/*
 	 * We made all the kernel PGDs present in kaiser_init().
@@ -111,13 +125,19 @@ static inline unsigned long get_pa_from_mapping(unsigned long vaddr)
 }
 
 /*
- * This is a relatively normal page table walk, except that it
- * also tries to allocate page tables pages along the way.
+ * Walk the shadow copy of the page tables (optionally) trying to
+ * allocate page table pages on the way down.  Does not support
+ * large pages since the data we are mapping is (generally) not
+ * large enough or aligned to 2MB.
+ *
+ * Note: this is only used when mapping *new* kernel data into the
+ * user/shadow page tables.  It is never used for userspace data.
  *
  * Returns a pointer to a PTE on success, or NULL on failure.
  */
 #define KAISER_WALK_ATOMIC  0x1
-static pte_t *kaiser_pagetable_walk(unsigned long address, unsigned long flags)
+static pte_t *kaiser_shadow_pagetable_walk(unsigned long address,
+					   unsigned long flags)
 {
 	pmd_t *pmd;
 	pud_t *pud;
@@ -207,11 +227,11 @@ int kaiser_add_user_map(const void *__start_addr, unsigned long size,
 	unsigned long target_address;
 
 	for (; address < end_addr; address += PAGE_SIZE) {
-		target_address = get_pa_from_mapping(address);
+		target_address = get_pa_from_kernel_map(address);
 		if (target_address == -1)
 			return -EIO;
 
-		pte = kaiser_pagetable_walk(address, false);
+		pte = kaiser_shadow_pagetable_walk(address, false);
 		/*
 		 * Errors come from either -ENOMEM for a page
 		 * table page, or something screwy that did a
@@ -348,7 +368,7 @@ void kaiser_remove_mapping(unsigned long start, unsigned long size)
 		 * context.  This should not do any allocations because we
 		 * should only be walking things that are known to be mapped.
 		 */
-		pte_t *pte = kaiser_pagetable_walk(addr, KAISER_WALK_ATOMIC);
+		pte_t *pte = kaiser_shadow_pagetable_walk(addr, KAISER_WALK_ATOMIC);
 
 		/*
 		 * We are removing a mapping that shoud

--------------700068124B7E47410723F297--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
