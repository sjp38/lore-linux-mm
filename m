Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4876B0005
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 21:48:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id l193so3274995qke.1
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 18:48:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t127si403072qkf.125.2018.01.28.18.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jan 2018 18:48:01 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0T2lYiE032933
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 21:48:00 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fssh52ur2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 21:47:59 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 29 Jan 2018 02:47:57 -0000
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
References: <20180109161355.GL1732@dhcp22.suse.cz>
 <a495f210-0015-efb2-a6a7-868f30ac4ace@linux.vnet.ibm.com>
 <20180117080731.GA2900@dhcp22.suse.cz>
 <082aa008-c56a-681d-0949-107245603a97@linux.vnet.ibm.com>
 <20180123124545.GL1526@dhcp22.suse.cz>
 <ef63c070-dcd7-3f26-f6ec-d95404007ae2@linux.vnet.ibm.com>
 <20180123160653.GU1526@dhcp22.suse.cz>
 <2a05eaf2-20fd-57a8-d4bd-5a1fbf57686c@linux.vnet.ibm.com>
 <20180124090539.GH1526@dhcp22.suse.cz>
 <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
 <20180126140415.GD5027@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 29 Jan 2018 08:17:48 +0530
MIME-Version: 1.0
In-Reply-To: <20180126140415.GD5027@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <15da8c87-e6db-13aa-01c8-a913656bfdb6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On 01/26/2018 07:34 PM, Michal Hocko wrote:
> On Fri 26-01-18 18:04:27, Anshuman Khandual wrote:
> [...]
>> I tried to instrument mmap_region() for a single instance of 'sed'
>> binary and traced all it's VMA creation. But there is no trace when
>> that 'anon' VMA got created which suddenly shows up during subsequent
>> elf_map() call eventually failing it. Please note that the following
>> VMA was never created through call into map_region() in the process
>> which is strange.
> 
> Could you share your debugging patch?

Please find the debug patch at the end.

> 
>> =================================================================
>> [    9.076867] Details for VMA[3] c000001fce42b7c0
>> [    9.076925] vma c000001fce42b7c0 start 0000000010030000 end 0000000010040000
>> next c000001fce42b580 prev c000001fce42b880 mm c000001fce40fa00
>> prot 8000000000000104 anon_vma           (null) vm_ops           (null)
>> pgoff 1003 file           (null) private_data           (null)
>> flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
>> =================================================================
> 
> Isn't this vdso or some other special mapping? It is not really an
> anonymous vma. Please hook into __install_special_mapping

Yeah, will do. Its not an anon mapping as it does not have a anon_vma
structure ?

> 
>> VMA creation for 'sed' binary
>> =============================
>> [    9.071902] XXX: mm c000001fce40fa00 registered
>>
>> [    9.071971] Total VMAs 2 on MM c000001fce40fa00
>> ----
>> [    9.072010] Details for VMA[1] c000001fce42bdc0
>> [    9.072064] vma c000001fce42bdc0 start 0000000010000000 end 0000000010020000
>> next c000001fce42b580 prev           (null) mm c000001fce40fa00
>> prot 8000000000000105 anon_vma           (null) vm_ops c008000011ddca18
>> pgoff 0 file c000001fe2969a00 private_data           (null)
>> flags: 0x875(read|exec|mayread|maywrite|mayexec|denywrite)
> 
> This one doesn't have any stack trace either... Yet it is a file
> mapping obviously. Special mappings shouldn't have any file associated.
> Strange...

IIUC, the first VMA (which seems to be an anon VMA) did not have any
stack trace and not sure how it got created.

[    9.077335] vma c000001fce42b580 start 00007fffcafe0000 end 00007fffcb010000
next           (null) prev c000001fce42b7c0 mm c000001fce40fa00
prot 8000000000000104 anon_vma c000001fce4456f0 vm_ops           (null)
pgoff 1fffffffd file           (null) private_data           (null)
flags: 0x100173(read|write|mayread|maywrite|mayexec|growsdown|account)

the subsequent ones, this

[    9.072010] Details for VMA[1] c000001fce42bdc0
[    9.072064] vma c000001fce42bdc0 start 0000000010000000 end 0000000010020000
next c000001fce42b580 prev           (null) mm c000001fce40fa00
prot 8000000000000105 anon_vma           (null) vm_ops c008000011ddca18
pgoff 0 file c000001fe2969a00 private_data           (null)
flags: 0x875(read|exec|mayread|maywrite|mayexec|denywrite)

and this (both are file mapping for sure and getting loaded from elf)

[    9.074170] Details for VMA[2] c000001fce42b880
[    9.074236] vma c000001fce42b880 start 0000000010020000 end 0000000010030000
next c000001fce42b580 prev c000001fce42bdc0 mm c000001fce40fa00
prot 8000000000000104 anon_vma           (null) vm_ops c008000011ddca18
pgoff 1 file c000001fe2969a00 private_data           (null)
flags: 0x100873(read|write|mayread|maywrite|mayexec|denywrite|account)

have similar stack traces

[    9.072839] CPU: 48 PID: 7544 Comm: sed Not tainted 4.14.0-dirty #154
[    9.072928] Call Trace:
[    9.072952] [c000001fbef37840] [c000000000b17a00] dump_stack+0xb0/0xf0 (unreliable)
[    9.073021] [c000001fbef37880] [c0000000002dbc48] mmap_region+0x718/0x720
[    9.073097] [c000001fbef37970] [c0000000002dc034] do_mmap+0x3e4/0x480
[    9.073179] [c000001fbef379f0] [c0000000002a96c8] vm_mmap_pgoff+0xe8/0x120
[    9.073268] [c000001fbef37ac0] [c0000000003cf378] elf_map+0x98/0x270
[    9.073326] [c000001fbef37b60] [c0000000003d1258] load_elf_binary+0x6f8/0x158c
[    9.073416] [c000001fbef37c80] [c00000000035d320] search_binary_handler+0xd0/0x270
[    9.073510] [c000001fbef37d10] [c00000000035f278] do_execveat_common.isra.31+0x658/0x890
[    9.073599] [c000001fbef37df0] [c00000000035f8c0] SyS_execve+0x40/0x50
[    9.073673] [c000001fbef37e30] [c00000000000b220] system_call+0x58/0x6c

and then again this one (which causes the collision subsequently) is neither
a anon VMA nor a file VMA and does not have a stack trace either.

[    9.076867] Details for VMA[3] c000001fce42b7c0
[    9.076925] vma c000001fce42b7c0 start 0000000010030000 end 0000000010040000
next c000001fce42b580 prev c000001fce42b880 mm c000001fce40fa00
prot 8000000000000104 anon_vma           (null) vm_ops           (null)
pgoff 1003 file           (null) private_data           (null)
flags: 0x100073(read|write|mayread|maywrite|mayexec|account)

Will double check the debug patch.

----------------------------------------------
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d8c5657..ccef8fd 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -41,6 +41,7 @@
 #include <linux/cred.h>
 #include <linux/dax.h>
 #include <linux/uaccess.h>
+#include <linux/mmdebug.h>
 #include <asm/param.h>
 #include <asm/page.h>
 
@@ -341,6 +342,10 @@ static int padzero(unsigned long elf_bss)
 
 #ifndef elf_map
 
+extern struct mm_struct *mm_ptr;
+extern bool just_init;
+extern void dump_mm_vmas(const struct mm_struct *mm);
+
 static unsigned long elf_map(struct file *filep, unsigned long addr,
 		struct elf_phdr *eppnt, int prot, int type,
 		unsigned long total_size)
@@ -372,11 +377,21 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
 	} else
 		map_addr = vm_mmap(filep, addr, size, prot, type, off);
 
-	if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr))
-		pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
+	if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr)) {
+		struct vm_area_struct *vma;
+
+		if (strcmp(current->comm, "sed"))
+			return(map_addr);
+
+		vma = find_vma(current->mm, addr);
+		if (just_init && (mm_ptr == vma->vm_mm)) {
+			pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
 				task_pid_nr(current), current->comm,
 				(void *)addr);
 
+			dump_mm_vmas(vma->vm_mm);
+		}
+	}
 	return(map_addr);
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index ca7b1cf..b427a5b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -45,6 +45,7 @@
 #include <linux/moduleparam.h>
 #include <linux/pkeys.h>
 #include <linux/oom.h>
+#include <linux/mmdebug.h>
 
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1611,6 +1612,25 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
+struct mm_struct *mm_ptr;
+bool just_init;
+EXPORT_SYMBOL(mm_ptr);
+EXPORT_SYMBOL(just_init);
+
+void dump_mm_vmas(const struct mm_struct *mm)
+{
+	struct vm_area_struct *vma = mm->mmap;
+	int count;
+
+	printk("Total VMAs %d on MM %lx\n", mm->map_count, (unsigned long) mm);
+
+	for (count = 0; vma && count < mm->map_count; count++, vma = vma->vm_next) {
+		printk("Details for VMA[%d] %lx\n", count + 1, (unsigned long) vma);
+		dump_vma(vma);
+	}
+}
+EXPORT_SYMBOL(dump_mm_vmas);
+
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
 		struct list_head *uf)
@@ -1754,6 +1774,21 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 
 	vma_set_page_prot(vma);
 
+	if (!strcmp(current->comm, "sed")) {
+		if (!just_init) {
+			just_init = 1;
+			mm_ptr = vma->vm_mm;
+			printk("XXX: mm %lx registered\n", (unsigned long) mm_ptr);
+			dump_mm_vmas(vma->vm_mm);
+			dump_stack();
+		} else {
+			if(mm_ptr == vma->vm_mm) {
+				dump_mm_vmas(vma->vm_mm);
+				dump_stack();
+			}
+		}
+	}
+
 	return addr;
 
 unmap_and_free_vma:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
