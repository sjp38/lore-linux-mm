Date: Wed, 23 Oct 2002 10:52:25 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: install_page() lockup
Message-ID: <64680000.1035388345@baldur.austin.ibm.com>
In-Reply-To: <3DB63586.A3D4AC22@digeo.com>
References: <3DB63586.A3D4AC22@digeo.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1868989384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1868989384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--On Tuesday, October 22, 2002 22:37:10 -0700 Andrew Morton
<akpm@digeo.com> wrote:

> 
> I'm getting lockups in install_page() with shared pagetables
> enabled.  I haven't really delved into it.  It happens under
> heavy memory pressure on SMP.
> 
> Ingo's new patch is using install_page much more than we
> used to (I don't think I've ever run it before), so we're
> running fairly untested codepaths here.

As Ingo said, he added install_page.

> I tried this:
> 
> (snip)
> 
> Because doing a pte_page_lock(ptepage) and then losing
> track of the page we just locked looks fishy.  Didn't
> help though.

The code was correct.  pte_unshare moves the lock to the new pte page if it
installs one.  I know that's not real clean, but it eliminates multiple
unlock/relock sequences.

> Dave could you please review the code in there?  It's probably
> something simple.

I found the problem.  In memory.c:do_file_page it unlocks the
page_table_lock.  In the new locking scheme, it's actually the
pte_page_lock that's held instead.

The patch to fix this is attached.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1868989384==========
Content-Type: text/plain; charset=iso-8859-1; name="shpte-2.5.44-mm3-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="shpte-2.5.44-mm3-1.diff"; size=637

--- 2.5.44-mm3/mm/memory.c	2002-10-23 10:20:08.000000000 -0500
+++ 2.5.44-mm3-shsent/mm/memory.c	2002-10-23 10:42:56.000000000 -0500
@@ -1823,6 +1823,7 @@
 static int do_file_page(struct mm_struct * mm, struct vm_area_struct * =
vma,
 	unsigned long address, int write_access, pte_t *pte, pmd_t *pmd)
 {
+	struct page *ptepage =3D pmd_page(*pmd);
 	unsigned long pgoff;
 	int err;
=20
@@ -1840,7 +1841,7 @@
 	pgoff =3D pte_to_pgoff(*pte);
=20
 	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	pte_page_unlock(ptepage);
=20
 	err =3D vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE, =
vma->vm_page_prot, pgoff, 0);
 	if (err =3D=3D -ENOMEM)

--==========1868989384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
