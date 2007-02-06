Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l160to4S008587
	for <linux-mm@kvack.org>; Mon, 5 Feb 2007 19:55:50 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l160tovD487972
	for <linux-mm@kvack.org>; Mon, 5 Feb 2007 17:55:50 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l160tnZb008376
	for <linux-mm@kvack.org>; Mon, 5 Feb 2007 17:55:49 -0700
Date: Mon, 5 Feb 2007 16:55:47 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: Hugepages_Rsvd goes huge in 2.6.20-rc7
Message-ID: <20070206005547.GA5071@us.ibm.com>
References: <20070206001903.GP7953@us.ibm.com> <20070206002534.GQ7953@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206002534.GQ7953@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, david@gibson.dropbear.id.au, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On 05.02.2007 [16:25:34 -0800], Nishanth Aravamudan wrote:
> Sorry, I botched Hugh's e-mail address, please make sure to reply to the
> correct one.
> 
> Thanks,
> Nish
> 
> On 05.02.2007 [16:19:04 -0800], Nishanth Aravamudan wrote:
> > Hi all,
> > 
> > So, here's the current state of the hugepages portion of my
> > /proc/meminfo (x86_64, 2.6.20-rc7, will test with 2.6.20 shortly,
> > but AFAICS, there haven't been many changes to hugepage code between
> > the two):

Reproduced on 2.6.20, and I think I've got a means to make it more
easily reproducible (at least on x86_64).

Please note, I found that when HugePages_Rsvd goes very large, I can
make it return to 0 by running `make func`, but killing it before it
gets to the sharing tests.  Rsvd returns to 0 in this case.

So, here's my means of reproducing it (as root, from the libhugetlbfs
root directory [1]):

# make sure everything is clean, hugepages wise
root@arkanoid# rm -rf /mnt/hugetlbfs/*
# if /proc/meminfo is already screwed up, run `make func` and kill it
# around when you see the mprotect testcase run, that seems to always
# work -- I'll try to be more scientific on this in a bit, to see which
# test causes the value to return to sanity

# run the linkshare testcase once, probably will die right away
root@arkanoid# HUGETLB_VERBOSE=99 HUGETLB_ELFMAP=y HUGETLB_SHARE=1 LD_LIBRARY_PATH=./obj64 ./tests/obj64/xBDT.linkshare
# you should see the testcase be killed, something like
# "FAIL    Child 1 killed by signal: Killed"
root@arkanoid# cat /proc/meminfo
# and a large value in meminfo now

Seems to happen every time I do this :) Note, part of this
reproducibility stems from a small modification to the details I gave
before. Before doing the posix_fadvise() call, I now do an fsync() on
the file-descriptor. Without the fsync(), it may take one or two
invocations before the test fails, but it still will in my experience so
far.

Also note, that I'm not trying to defend the way I'm approaching this
problem in libhugetlbfs (I'm very open to alternatives) -- but
regardless of what I do there, I don't think Rsvd should be
18446744073709551615 ...

Thanks,
Nish

[1]

You'll need the latest development snapshot of libhugetlbfs
(http://libhugetlbfs.ozlabs.org/snapshots/libhugetlbfs-dev-20070129.tar.gz)
as well as the following patch applied on top of it:

diff --git a/elflink.c b/elflink.c
index 5a57358..18926fa 100644
--- a/elflink.c
+++ b/elflink.c
@@ -186,8 +186,8 @@ static char share_path[PATH_MAX+1];
 #define MAX_HTLB_SEGS	2
 
 struct seg_info {
-	void *vaddr;
-	unsigned long filesz, memsz;
+	void *vaddr, *extra_vaddr;
+	unsigned long filesz, memsz, extrasz;
 	int prot;
 	int fd;
 	int phdr;
@@ -497,8 +497,7 @@ static inline int keep_symbol(Elf_Sym *s, void *start, void *end)
  * include these initialized variables in our copy.
  */
 
-static void get_extracopy(struct seg_info *seg, void **extra_start,
-							void **extra_end)
+static void get_extracopy(struct seg_info *seg)
 {
 	Elf_Dyn *dyntab;        /* dynamic segment table */
 	Elf_Sym *symtab = NULL; /* dynamic symbol table */
@@ -511,7 +510,7 @@ static void get_extracopy(struct seg_info *seg, void **extra_start,
 	end_orig = seg->vaddr + seg->memsz;
 	start_orig = seg->vaddr + seg->filesz;
 	if (seg->filesz == seg->memsz)
-		goto bail2;
+		return;
 	if (!minimal_copy)
 		goto bail2;
 
@@ -557,23 +556,20 @@ static void get_extracopy(struct seg_info *seg, void **extra_start,
 
 	if (found_sym) {
 		/* Return the copy window */
-		*extra_start = start;
-		*extra_end = end;
-		return;
-	} else {
-		/* No need to copy anything */
-		*extra_start = start_orig;
-		*extra_end = start_orig;
-		goto bail3;
+		seg->extra_vaddr = start;
+		seg->extrasz = end - start;
 	}
+	/*
+	 * else no need to copy anything, so leave seg->extra_vaddr as
+	 * NULL
+	 */
+	return;
 
 bail:
 	DEBUG("Unable to perform minimal copy\n");
 bail2:
-	*extra_start = start_orig;
-	*extra_end = end_orig;
-bail3:
-	return;
+	seg->extra_vaddr = start_orig;
+	seg->extrasz = end_orig - start_orig;
 }
 
 /*
@@ -584,7 +580,7 @@ bail3:
 static int prepare_segment(struct seg_info *seg)
 {
 	int hpage_size = gethugepagesize();
-	void *p, *extra_start, *extra_end;
+	void *p;
 	unsigned long gap;
 	unsigned long size;
 
@@ -592,9 +588,14 @@ static int prepare_segment(struct seg_info *seg)
 	 * Calculate the BSS size that we must copy in order to minimize
 	 * the size of the shared mapping.
 	 */
-	get_extracopy(seg, &extra_start, &extra_end);
-	size = ALIGN((unsigned long)extra_end - (unsigned long)seg->vaddr,
+	get_extracopy(seg);
+	if (seg->extra_vaddr) {
+		size = ALIGN((unsigned long)seg->extra_vaddr +
+				seg->extrasz - (unsigned long)seg->vaddr,
 				hpage_size);
+	} else {
+		size = ALIGN(seg->filesz, hpage_size);
+	}
 
 	/* Prepare the hugetlbfs file */
 
@@ -617,11 +618,12 @@ static int prepare_segment(struct seg_info *seg)
 	memcpy(p, seg->vaddr, seg->filesz);
 	DEBUG_CONT("done\n");
 
-	if (extra_end > extra_start) {
+	if (seg->extra_vaddr) {
 		DEBUG("Copying extra %#0lx bytes from %p...",
-			(unsigned long)(extra_end - extra_start), extra_start);
-		gap = extra_start - (seg->vaddr + seg->filesz);
-		memcpy((p + seg->filesz + gap), extra_start, (extra_end - extra_start));
+					seg->extrasz, seg->extra_vaddr);
+		gap = seg->extra_vaddr - (seg->vaddr + seg->filesz);
+		memcpy((p + seg->filesz + gap), seg->extra_vaddr,
+							seg->extrasz);
 		DEBUG_CONT("done\n");
 	}
 
@@ -791,6 +793,7 @@ static void remap_segments(struct seg_info *seg, int num)
 	long hpage_size = gethugepagesize();
 	int i;
 	void *p;
+	char c;
 
 	/*
 	 * XXX: The bogus call to mmap below forces ld.so to resolve the
@@ -829,6 +832,46 @@ static void remap_segments(struct seg_info *seg, int num)
 	/* The segments are all back at this point.
 	 * and it should be safe to reference static data
 	 */
+
+	/*
+	 * This pagecache dropping code should not be used for shared
+	 * segments.  But we currently only share read-only segments, so
+	 * the below check for PROT_WRITE is implicitly sufficient.
+	 */
+	for (i = 0; i < num; i++) {
+		if (seg[i].prot & PROT_WRITE) {
+			/*
+			 * take a COW fault on each hugepage in the
+			 * segment's file data ...
+			 */
+			for (p = seg[i].vaddr;
+			     p <= seg[i].vaddr + seg[i].filesz;
+			     p += hpage_size) {
+				memcpy(&c, p, 1);
+				memcpy(p, &c, 1);
+			}
+			/*
+			 * ... as well as each huge page in the
+			 * extracopy area
+			 */
+			if (seg[i].extra_vaddr) {
+				for (p = seg[i].extra_vaddr;
+				     p <= seg[i].extra_vaddr +
+							seg[i].extrasz;
+				     p += hpage_size) {
+					memcpy(&c, p, 1);
+					memcpy(p, &c, 1);
+				}
+			}
+			/*
+			 * Note: fadvise() failing is not actually an
+			 * error, as we'll just use an extra set of
+			 * hugepages (in the pagecache).
+			 */
+			fsync(seg[i].fd);
+			posix_fadvise(seg[i].fd, 0, 0, POSIX_FADV_DONTNEED);
+		}
+	}
 }
 
 static int check_env(void)

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
