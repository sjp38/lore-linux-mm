Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 342456B026A
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:55 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 194so33102wmv.9
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:55 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o10si11838658wrg.50.2017.12.12.09.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:54 -0800 (PST)
Message-Id: <20171212173333.828974138@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:28 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 07/16] selftest/x86: Implement additional LDT selftests
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=selftest-x86-Implement-additional-LDT-selftests.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

do_ldt_ss_test() - tests modifying the SS segment while in use; this
tends to come apart with RO LDT maps

do_ldt_unmap_test() - tests the mechanics of unmapping the (future)
LDT VMA. Additional tests would make sense; like unmapping it while in
use (TODO).

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 tools/testing/selftests/x86/ldt_gdt.c |   71 +++++++++++++++++++++++++++++++++-
 1 file changed, 70 insertions(+), 1 deletion(-)

--- a/tools/testing/selftests/x86/ldt_gdt.c
+++ b/tools/testing/selftests/x86/ldt_gdt.c
@@ -242,6 +242,72 @@ static void fail_install(struct user_des
 	}
 }
 
+static void do_ldt_ss_test(void)
+{
+	unsigned short prev_sel, sel = (2 << 3) | (1 << 2) | 3;
+	struct user_desc *ldt_desc = low_user_desc + 2;
+	int ret;
+
+	ldt_desc->entry_number	= 2;
+	ldt_desc->base_addr	= (unsigned long)&counter_page[1];
+	ldt_desc->limit		= 0xfffff;
+	ldt_desc->seg_32bit	= 1;
+	ldt_desc->contents		= 0; /* Data, grow-up*/
+	ldt_desc->read_exec_only	= 0;
+	ldt_desc->limit_in_pages	= 1;
+	ldt_desc->seg_not_present	= 0;
+	ldt_desc->useable		= 0;
+
+	ret = safe_modify_ldt(1, ldt_desc, sizeof(*ldt_desc));
+	if (ret)
+		perror("ponies");
+
+	/*
+	 * syscall (eax) 123 - modify_ldt / return value
+	 *         (ebx)     - func
+	 *         (ecx)     - ptr
+	 *         (edx)     - bytecount
+	 */
+
+	int eax = 123;
+	int ebx = 1;
+	int ecx = (unsigned int)(unsigned long)ldt_desc;
+	int edx = sizeof(struct user_desc);
+
+	asm volatile ("movw %%ss, %[prev_sel]\n\t"
+		      "movw %[sel], %%ss\n\t"
+		      "int $0x80\n\t"
+		      "movw %[prev_sel], %%ss"
+		      : [prev_sel] "=&R" (prev_sel), "+a" (eax)
+		      : [sel] "R" (sel), "b" (ebx), "c" (ecx), "d" (edx)
+		      : INT80_CLOBBERS);
+
+	printf("[OK]\tSS modify_ldt()\n");
+}
+
+static void do_ldt_unmap_test(void)
+{
+	FILE *file = fopen("/proc/self/maps", "r");
+	char *line = NULL;
+	size_t len = 0;
+	ssize_t nread;
+	unsigned long start, end;
+
+	while ((nread = getline(&line, &len, file)) != -1) {
+		if (strstr(line, "[ldt]")) {
+			if (sscanf(line, "%lx-%lx", &start, &end) == 2) {
+				munmap((void *)start, end-start);
+				printf("[OK]\tmunmap LDT\n");
+				break;
+			}
+		}
+	}
+
+	free(line);
+	fclose(file);
+
+}
+
 static void do_simple_tests(void)
 {
 	struct user_desc desc = {
@@ -696,7 +762,7 @@ static int invoke_set_thread_area(void)
 
 static void setup_low_user_desc(void)
 {
-	low_user_desc = mmap(NULL, 2 * sizeof(struct user_desc),
+	low_user_desc = mmap(NULL, 3 * sizeof(struct user_desc),
 			     PROT_READ | PROT_WRITE,
 			     MAP_ANONYMOUS | MAP_PRIVATE | MAP_32BIT, -1, 0);
 	if (low_user_desc == MAP_FAILED)
@@ -916,6 +982,9 @@ int main(int argc, char **argv)
 	setup_counter_page();
 	setup_low_user_desc();
 
+	do_ldt_ss_test();
+	do_ldt_unmap_test();
+
 	do_simple_tests();
 
 	do_multicpu_tests();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
