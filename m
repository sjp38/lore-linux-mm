Received: from [194.97.55.192] (helo=mx8.freenet.de)
	by mout1.freenet.de with esmtpa (Exim 4.43)
	id 1CVoWa-0000zh-3M
	for Linux-MM@kvack.org; Sun, 21 Nov 2004 11:00:52 +0100
Received: from p213.54.187.140.tisdip.tiscali.de ([213.54.187.140] helo=pc1)
	by mx8.freenet.de with esmtpa (ID mbuesch@freenet.de) (Exim 4.43 #13)
	id 1CVoWZ-0004da-Gx
	for Linux-MM@kvack.org; Sun, 21 Nov 2004 11:00:52 +0100
From: Michael Buesch <mbuesch@freenet.de>
Subject: find_vma() cachehit rate
Date: Sun, 21 Nov 2004 10:54:45 +0100
MIME-Version: 1.0
Message-Id: <200411211054.53560.mbuesch@freenet.de>
Content-Type: multipart/signed;
  boundary="nextPart1739930.FtMGb4Y1fF";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart1739930.FtMGb4Y1fF
Content-Type: multipart/mixed;
  boundary="Boundary-01=_lXGoB2RcDSNvF6u"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_lXGoB2RcDSNvF6u
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I just saw this comment in find_vma():
  /* Check the cache first. */
  /* (Cache hit rate is typically around 35%.) */

I just wanted to play around a bit. Just for fun.
So I wrote the attached patch to collect find_vma()
statistics. I was wondering why my cache hit rate is around
60%. It's always between 55 and 65 percent. Depending on
the workload.
Is this on obsolete comment from the 2.4 days, maybe?

mb@lfs:~$ cat /proc/findvma_stat=20
findvma_stat_cachehit  =3D=3D 356524
findvma_stat_cachemiss =3D=3D 248728
findvma_stat_fail      =3D=3D 0
cachehit percentage    =3D=3D 58%
cachemiss percentage   =3D=3D 41%
fail percentage        =3D=3D 0%

My kernel is:
mb@lfs:~$ uname -r
2.6.10-rc2-ck2-nozeroram-findvmastat

If you are interrested to comment on this, please CC: me,
as I'm not subscribed to this mailing list. Thanks.

=2D-=20
Regards Michael Buesch  [ http://www.tuxsoft.de.vu ]



--Boundary-01=_lXGoB2RcDSNvF6u
Content-Type: text/x-diff;
  charset="us-ascii";
  name="find_vma_stat.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="find_vma_stat.diff"

Index: mm/mmap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
RCS file: /home/mb/develop/linux/rsync/linux-2.5/mm/mmap.c,v
retrieving revision 1.149
diff -u -p -r1.149 mmap.c
=2D-- mm/mmap.c	28 Oct 2004 15:17:10 -0000	1.149
+++ mm/mmap.c	20 Nov 2004 22:14:27 -0000
@@ -23,6 +23,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/proc_fs.h>
=20
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -34,6 +35,12 @@
  */
 #undef DEBUG_MM_RB
=20
+/* enable/disable find_vma() statistics.
+ * 1 =3D> enabled
+ * 0 =3D> disabled
+ */
+#define MMAP_FINDVMA_STATS	1
+
 /* description of effects of mapping type and prot in current implementati=
on.
  * this is due to the limited x86 page protection hardware.  The expected
  * behavior is in parens:
@@ -1246,6 +1253,123 @@ get_unmapped_area(struct file *file, uns
=20
 EXPORT_SYMBOL(get_unmapped_area);
=20
+#if MMAP_FINDVMA_STATS !=3D 0
+static spinlock_t findvma_stat_lock =3D SPIN_LOCK_UNLOCKED;
+static unsigned long findvma_stat_cachehit;
+static unsigned long findvma_stat_cachemiss;
+static unsigned long findvma_stat_fail;
+static struct proc_dir_entry *findvma_stat_proc;
+
+static int findvma_stat_read(char *buf, char **start, off_t offset, int si=
ze, int *eof, void *data)
+{
+	int written;
+	unsigned long total =3D findvma_stat_cachehit + findvma_stat_cachemiss + =
findvma_stat_fail;
+	unsigned long hit_percent =3D findvma_stat_cachehit * 100 / total;
+	unsigned long miss_percent =3D findvma_stat_cachemiss * 100 / total;
+	unsigned long fail_percent =3D findvma_stat_fail * 100 / total;
+
+	spin_lock(&findvma_stat_lock);
+	written =3D snprintf(buf, size, "findvma_stat_cachehit  =3D=3D %lu\n"
+				      "findvma_stat_cachemiss =3D=3D %lu\n"
+				      "findvma_stat_fail      =3D=3D %lu\n"
+				      "cachehit percentage    =3D=3D %lu%%\n"
+				      "cachemiss percentage   =3D=3D %lu%%\n"
+				      "fail percentage        =3D=3D %lu%%\n",
+			   findvma_stat_cachehit,
+			   findvma_stat_cachemiss,
+			   findvma_stat_fail,
+			   hit_percent,
+			   miss_percent,
+			   fail_percent);
+	spin_unlock(&findvma_stat_lock);
+	*eof =3D 1;
+	return written;
+}
+
+static int findvma_stat_write(struct file *f, const char __user *buf, unsi=
gned long cnt, void *data)
+{
+	int ret =3D -EINVAL;
+	char *kbuf;
+
+	if (cnt < 1)
+		goto out;
+
+	kbuf =3D kmalloc(cnt, GFP_KERNEL);
+	if (!kbuf) {
+		ret =3D -ENOMEM;
+		goto out;
+	}
+	if (copy_from_user(kbuf, buf, cnt)) {
+		ret =3D -EFAULT;
+		goto out_free;
+	}
+	if (*kbuf =3D=3D 'c') {
+		/* clear find_vma() statistics. */
+		spin_lock(&findvma_stat_lock);
+		findvma_stat_cachehit =3D 0;
+		findvma_stat_cachemiss =3D 0;
+		findvma_stat_fail =3D 0;
+		spin_unlock(&findvma_stat_lock);
+		ret =3D cnt;
+	}
+out_free:
+	kfree(kbuf);
+out:
+	return ret;
+}
+
+static void findvma_stat_init(void)
+{
+	static int already_tried =3D 0;
+	if (already_tried)
+		return;
+	printk("initializing find_vma() statistics... ");
+	findvma_stat_proc =3D create_proc_entry("findvma_stat", S_IRUGO | S_IWUSR=
, 0);
+	if (!findvma_stat_proc) {
+		printk("FAILED.\n");
+		already_tried =3D 1;
+		return;
+	}
+	findvma_stat_proc->read_proc =3D findvma_stat_read;
+	findvma_stat_proc->write_proc =3D findvma_stat_write;
+	findvma_stat_proc->data =3D 0;
+	printk("Ok.\n");
+}
+
+static inline void findvma_stat_inc_cachehit(void)
+{
+	spin_lock(&findvma_stat_lock);
+	if (!findvma_stat_proc)
+		findvma_stat_init();
+	findvma_stat_cachehit++;
+	spin_unlock(&findvma_stat_lock);
+}
+
+static inline void findvma_stat_inc_cachemiss(void)
+{
+	spin_lock(&findvma_stat_lock);
+	if (!findvma_stat_proc)
+		findvma_stat_init();
+	findvma_stat_cachemiss++;
+	spin_unlock(&findvma_stat_lock);
+}
+
+
+static inline void findvma_stat_inc_fail(void)
+{
+	spin_lock(&findvma_stat_lock);
+	if (unlikely(!findvma_stat_proc))
+		findvma_stat_init();
+	findvma_stat_fail++;
+	spin_unlock(&findvma_stat_lock);
+}
+
+#else /* MMAP_FINDVMA_STATS */
+# define findvma_stat_inc_cachehit()	do { } while (0)
+# define findvma_stat_inc_cachemiss()	do { } while (0)
+# define findvma_stat_inc_fail()	do { } while (0)
+#endif /* MMAP_FINDVMA_STATS */
+
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
 struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
 {
@@ -1275,10 +1399,15 @@ struct vm_area_struct * find_vma(struct=20
 				} else
 					rb_node =3D rb_node->rb_right;
 			}
=2D			if (vma)
+			if (vma) {
 				mm->mmap_cache =3D vma;
=2D		}
+				findvma_stat_inc_cachemiss();
+			}
+		} else
+			findvma_stat_inc_cachehit();
 	}
+	if (!vma)
+		findvma_stat_inc_fail();
 	return vma;
 }
=20

--Boundary-01=_lXGoB2RcDSNvF6u--

--nextPart1739930.FtMGb4Y1fF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBoGXtFGK1OIvVOP4RApvZAJ4l48/AI/8XBJUcc+nky3NydxbeaACgpDCG
mO7YvdPvwFi+1u7i9r7LhQ0=
=U3XA
-----END PGP SIGNATURE-----

--nextPart1739930.FtMGb4Y1fF--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
