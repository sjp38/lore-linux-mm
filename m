Date: Tue, 13 May 2003 18:00:08 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <220550000.1052866808@baldur.austin.ibm.com>
In-Reply-To: <20030513224929.GX8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
 <3EC15C6D.1040403@kolumbus.fi> <199610000.1052864784@baldur.austin.ibm.com>
 <20030513224929.GX8978@holomorphy.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========2024839384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Mika Penttil? <mika.penttila@kolumbus.fi>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==========2024839384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--On Tuesday, May 13, 2003 15:49:29 -0700 William Lee Irwin III
<wli@holomorphy.com> wrote:

> That doesn't sound like it's going to help, there isn't a unique
> mmap_sem to be taken and so we just get caught between acquisitions
> with the same problem.

Actually it does fix it.  I added code in vmtruncate_list() to do a
down_write(&vma->vm_mm->mmap_sem) around the zap_page_range(), and the
problem went away.  It serializes against any outstanding page faults on a
particular page table.  New faults will see that the page is no longer in
the file and fail with SIGBUS.  Andrew's test case stopped failing.

I've attached the patch so you can see what I did.

Can anyone think of any gotchas to this solution?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========2024839384==========
Content-Type: text/plain; charset=us-ascii; name="vmtrunc-2.5.69-mm3-1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="vmtrunc-2.5.69-mm3-1.diff";
 size=982

--- 2.5.69-mm3/mm/memory.c	2003-05-13 10:34:56.000000000 -0500
+++ 2.5.69-mm3-test/mm/memory.c	2003-05-13 17:39:45.000000000 -0500
@@ -1085,21 +1085,21 @@ static void vmtruncate_list(struct list_
 		len = end - start;
 
 		/* mapping wholly truncated? */
-		if (vma->vm_pgoff >= pgoff) {
-			zap_page_range(vma, start, len);
-			continue;
-		}
+		if (vma->vm_pgoff < pgoff) {
 
-		/* mapping wholly unaffected? */
-		len = len >> PAGE_SHIFT;
-		diff = pgoff - vma->vm_pgoff;
-		if (diff >= len)
-			continue;
-
-		/* Ok, partially affected.. */
-		start += diff << PAGE_SHIFT;
-		len = (len - diff) << PAGE_SHIFT;
+			/* mapping wholly unaffected? */
+			len = len >> PAGE_SHIFT;
+			diff = pgoff - vma->vm_pgoff;
+			if (diff >= len)
+				continue;
+
+			/* Ok, partially affected.. */
+			start += diff << PAGE_SHIFT;
+			len = (len - diff) << PAGE_SHIFT;
+		}
+		down_write(&vma->vm_mm->mmap_sem);
 		zap_page_range(vma, start, len);
+		up_write(&vma->vm_mm->mmap_sem);
 	}
 }
 

--==========2024839384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
