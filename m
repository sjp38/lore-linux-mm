Date: Tue, 17 Aug 2004 15:18:34 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: arch_get_unmapped_area_topdown vs stack reservations
Message-ID: <170170000.1092781114@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I worry that the current code will allow us to intrude into the 
reserved stack space with a vma allocation if it's requested at
an address too high up. One could argue that they got what they
asked for ... but not sure we should be letting them do that?

Is the following change acceptable? Not tested yet, but will do
if you're happy with it.

Signed-off-by: Martin J. Bligh <mbligh@aracnet.com>

diff -purN -X /home/mbligh/.diff.exclude /home/linux/views/linux-2.6.8.1-mm1/mm/mmap.c 2.6.8.1-mm1-topdown_fix/mm/mmap.c
--- /home/linux/views/linux-2.6.8.1-mm1/mm/mmap.c	2004-08-17 14:43:07.000000000 -0700
+++ 2.6.8.1-mm1-topdown_fix/mm/mmap.c	2004-08-17 14:52:55.000000000 -0700
@@ -1101,7 +1101,7 @@ arch_get_unmapped_area_topdown(struct fi
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
 		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
+		if (base - len >= addr &&
 				(!vma || addr + len <= vma->vm_start))
 			return addr;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
