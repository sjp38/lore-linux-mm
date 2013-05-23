Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 101E36B0039
	for <linux-mm@kvack.org>; Thu, 23 May 2013 01:25:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C19F53EE0C2
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B13E445DE50
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C7B545DD78
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 812D61DB803E
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:37 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 368761DB8038
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:37 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v8 7/9] vmcore: Allow user process to remap ELF note segment
 buffer
Date: Thu, 23 May 2013 14:25:36 +0900
Message-ID: <20130523052536.13864.67507.stgit@localhost6.localdomain6>
In-Reply-To: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

Now ELF note segment has been copied in the buffer on vmalloc
memory. To allow user process to remap the ELF note segment buffer
with remap_vmalloc_page, the corresponding VM area object has to have
VM_USERMAP flag set.

Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
---

 fs/proc/vmcore.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 937709d..9de4d91 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -375,6 +375,7 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 	Elf64_Ehdr *ehdr_ptr;
 	Elf64_Phdr phdr;
 	u64 phdr_sz = 0, note_off;
+	struct vm_struct *vm;
 
 	ehdr_ptr = (Elf64_Ehdr *)elfptr;
 
@@ -391,6 +392,12 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 	if (!*notes_buf)
 		return -ENOMEM;
 
+	/* Allow users to remap ELF note segment buffer on vmalloc
+	 * memory using remap_vmalloc_range. */
+	vm = find_vm_area(*notes_buf);
+	BUG_ON(!vm);
+	vm->flags |= VM_USERMAP;
+
 	rc = copy_notes_elf64(ehdr_ptr, *notes_buf);
 	if (rc < 0)
 		return rc;
@@ -554,6 +561,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
 	Elf32_Ehdr *ehdr_ptr;
 	Elf32_Phdr phdr;
 	u64 phdr_sz = 0, note_off;
+	struct vm_struct *vm;
 
 	ehdr_ptr = (Elf32_Ehdr *)elfptr;
 
@@ -570,6 +578,12 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
 	if (!*notes_buf)
 		return -ENOMEM;
 
+	/* Allow users to remap ELF note segment buffer on vmalloc
+	 * memory using remap_vmalloc_range. */
+	vm = find_vm_area(*notes_buf);
+	BUG_ON(!vm);
+	vm->flags |= VM_USERMAP;
+
 	rc = copy_notes_elf32(ehdr_ptr, *notes_buf);
 	if (rc < 0)
 		return rc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
