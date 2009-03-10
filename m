Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A91A6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 08:23:01 -0400 (EDT)
Date: Tue, 10 Mar 2009 20:22:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310122210.GA8415@localhost>
References: <20090307122452.bf43fbe4.akpm@linux-foundation.org> <20090307220055.6f79beb8@mjolnir.ossman.eu> <20090309013742.GA11416@localhost> <20090309020701.GA381@localhost> <20090309084045.2c652fbf@mjolnir.ossman.eu> <20090309142241.GA4437@localhost> <20090309160216.2048e898@mjolnir.ossman.eu> <20090310024135.GA6832@localhost> <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
Content-Disposition: inline
In-Reply-To: <20090310105523.3dfd4873@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 10, 2009 at 11:55:23AM +0200, Pierre Ossman wrote:
> On Tue, 10 Mar 2009 16:19:17 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > 
> > Here is the initial patch and tool for finding the missing pages.
> > 
> > In the following example, the pages with no flags set is kind of too
> > many (1816MB), but hopefully your missing pages will have PG_reserved
> > or other flags set ;-)
> > 
> > # ./page-types
> > L:locked E:error R:referenced U:uptodate D:dirty L:lru A:active S:slab W:writeback x:reclaim B:buddy r:reserved c:swapcache b:swapbacked
> >  
> 
> Thanks. I'll have a look in a bit. Right now I'm very close to a
> complete bisect. It is just ftrace commits left though, so I'm somewhat
> sceptical that it is correct. ftrace isn't even turned on in the
> kernels I've been testing.
> 
> The remaining commits are ec1bb60bb..6712e299.

And here's my progress, some more page flags are introduced:

# ./page-types
  flags page-count       MB    symbolic-flags    long-symbolic-flags
0x00000       3978       15  __________________  
0x00004          1        0  __R_______________  referenced
0x00014          5        0  __R_D_____________  referenced,dirty
0x00020          2        0  _____l____________  lru
0x00028       8835       34  ___U_l____________  uptodate,lru
0x0002c       9588       37  __RU_l____________  referenced,uptodate,lru
0x00068       1031        4  ___U_lA___________  uptodate,lru,active
0x0006c       3032       11  __RU_lA___________  referenced,uptodate,lru,active
0x00080      11001       42  _______S__________  slab
0x00228        140        0  ___U_l___x________  uptodate,lru,reclaim
0x0022c         79        0  __RU_l___x________  referenced,uptodate,lru,reclaim
0x00268         43        0  ___U_lA__x________  uptodate,lru,active,reclaim
0x0026c        110        0  __RU_lA__x________  referenced,uptodate,lru,active,reclaim
0x00400       1102        4  __________B_______  buddy
0x00800      18735       73  ___________r______  reserved
0x02008         13        0  ___U_________b____  uptodate,swapbacked
0x02068       9371       36  ___U_lA______b____  uptodate,lru,active,swapbacked
0x0206c       1339        5  __RU_lA______b____  referenced,uptodate,lru,active,swapbacked
0x02078         21        0  ___UDlA______b____  uptodate,dirty,lru,active,swapbacked
0x0207c         17        0  __RUDlA______b____  referenced,uptodate,dirty,lru,active,swapbacked
0x20000     445525     1740  _________________n  noflags
  total     513968     2007

Thanks,
Fengguang


--82I3+IH0IqGh5yIs
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="page-types.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/fcntl.h>

/* copied from kpageflags_read() */
enum {
	KPF_LOCKED,	/*  0 */
	KPF_ERROR,	/*  1 */
	KPF_REFERENCED,	/*  2 */
	KPF_UPTODATE,	/*  3 */
	KPF_DIRTY,	/*  4 */
	KPF_LRU,	/*  5 */
	KPF_ACTIVE,	/*  6 */
	KPF_SLAB,	/*  7 */
	KPF_WRITEBACK,	/*  8 */
	KPF_RECLAIM,	/*  9 */
	KPF_BUDDY,	/* 10 */
	KPF_RESERVED,	/* 11 */
	KPF_SWAPCACHE,	/* 12 */
	KPF_SWAPBACKED,	/* 13 */
        KPF_PRIVATE,    /* 14 */
        KPF_PRIVATE2,   /* 15 */
        KPF_NOPAGE,     /* 16 */
        KPF_NOFLAGS,    /* 17 */
	KPF_NUM
};
#define KPF_BYTES	8

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static char *page_flag_names[] = {
	[KPF_LOCKED]		= "L:locked",
	[KPF_ERROR]		= "E:error",
	[KPF_REFERENCED]	= "R:referenced",
	[KPF_UPTODATE]		= "U:uptodate",
	[KPF_DIRTY]		= "D:dirty",
	[KPF_LRU]		= "l:lru",
	[KPF_ACTIVE]		= "A:active",
	[KPF_SLAB]		= "S:slab",
	[KPF_WRITEBACK]		= "W:writeback",
	[KPF_RECLAIM]		= "x:reclaim",
	[KPF_BUDDY]		= "B:buddy",
	[KPF_RESERVED]		= "r:reserved",
	[KPF_SWAPBACKED]	= "b:swapbacked",
	[KPF_SWAPCACHE]		= "c:swapcache",
	[KPF_PRIVATE]		= "P:private",
	[KPF_PRIVATE2]		= "p:private_2",
	[KPF_NOPAGE]		= "N:nopage",
	[KPF_NOFLAGS]		= "n:noflags",
};

static unsigned long page_count[(1 << KPF_NUM)];
static unsigned long nr_pages;
static uint64_t kpageflags[KPF_BYTES * (8<<20)];

char *page_flag_name(uint64_t flags)
{
	int i;
	static char buf[64];

	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++)
		buf[i] = (flags & (1 << i)) ? page_flag_names[i][0] : '_';

	return buf;
}

char *page_flag_longname(uint64_t flags)
{
	int i, n;
	static char buf[1024];

	for (i = 0, n = 0; i < ARRAY_SIZE(page_flag_names); i++)
		if (flags & (1<<i))
		       n += snprintf(buf + n, sizeof(buf) - n, "%s,",
				       page_flag_names[i] + 2);
	if (n)
		n--;
	buf[n] = '\0';

	return buf;
}

static unsigned long pages2mb(unsigned long pages)
{
	return (pages * getpagesize()) >> 20;
}

int main(int argc, char *argv[])
{
	static char kpageflags_name[] = "/proc/kpageflags";
	unsigned long i;
	uint64_t flags;
	int fd;

	fd = open(kpageflags_name, O_RDONLY);
	if (fd < 0) {
		fprintf(stderr, "%s: cannot open `%s': %s\n",
				argv[0], kpageflags_name, strerror(errno));
		exit(1);
	}

	nr_pages = read(fd, kpageflags, sizeof(kpageflags));
	if (nr_pages <= 0) {
		fprintf(stderr, "%s: cannot read `%s': %s\n",
				argv[0], kpageflags_name, strerror(errno));
		exit(2);
	}
	if (nr_pages % KPF_BYTES != 0) {
		fprintf(stderr, "%s: partial read: %lu bytes\n",
				argv[0], nr_pages);
		exit(3);
	}
	nr_pages = nr_pages / KPF_BYTES;

	for (i = 0; i < nr_pages; i++) {
		flags = kpageflags[i];
		if (flags == 0x40000)
			flags = ARRAY_SIZE(page_count) - 1;
		if (flags >= ARRAY_SIZE(page_count)) {
			fprintf(stderr, "%s: flags overflow: 0x%lx > 0x%lx\n",
					argv[0], flags, ARRAY_SIZE(page_count));
			exit(4);
		}
		page_count[flags]++;
	}

#if 0
	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++) {
		printf("%s ", page_flag_names[i]);
	}
#endif

	printf("  flags\tpage-count       MB    symbolic-flags    long-symbolic-flags\n");
	for (i = 0; i < ARRAY_SIZE(page_count); i++) {
		if (page_count[i])
			printf("0x%05lx\t%10lu %8lu  %s  %s\n",
				i,
				page_count[i],
				pages2mb(page_count[i]),
				page_flag_name(i),
				page_flag_longname(i));
	}

	printf("  total\t%10lu %8lu\n",
			nr_pages, pages2mb(nr_pages));

	return 0;
}

--82I3+IH0IqGh5yIs
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="kpageflags-improvements.patch"

---
 fs/proc/page.c |   88 +++++++++++++++++++++++++++++------------------
 1 file changed, 56 insertions(+), 32 deletions(-)

--- mm.orig/fs/proc/page.c
+++ mm/fs/proc/page.c
@@ -68,19 +68,60 @@ static const struct file_operations proc
 
 /* These macros are used to decouple internal flags from exported ones */
 
-#define KPF_LOCKED     0
-#define KPF_ERROR      1
-#define KPF_REFERENCED 2
-#define KPF_UPTODATE   3
-#define KPF_DIRTY      4
-#define KPF_LRU        5
-#define KPF_ACTIVE     6
-#define KPF_SLAB       7
-#define KPF_WRITEBACK  8
-#define KPF_RECLAIM    9
-#define KPF_BUDDY     10
+enum {
+	KPF_LOCKED,	/*  0 */
+	KPF_ERROR,	/*  1 */
+	KPF_REFERENCED,	/*  2 */
+	KPF_UPTODATE,	/*  3 */
+	KPF_DIRTY,	/*  4 */
+	KPF_LRU,	/*  5 */
+	KPF_ACTIVE,	/*  6 */
+	KPF_SLAB,	/*  7 */
+	KPF_WRITEBACK,	/*  8 */
+	KPF_RECLAIM,	/*  9 */
+	KPF_BUDDY,	/* 10 */
+	KPF_RESERVED,	/* 11 */
+	KPF_SWAPCACHE,	/* 12 */
+	KPF_SWAPBACKED,	/* 13 */
+	KPF_PRIVATE,	/* 14 */
+	KPF_PRIVATE2,	/* 15 */
+	KPF_NOPAGE,	/* 16 */
+	KPF_NOFLAGS,	/* 17 */
+	KPF_NUM
+};
+
+#define PAGE_FLAGS_MASK	((1 << __NR_PAGEFLAGS) - 1)
+
+#define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
 
-#define kpf_copy_bit(flags, srcpos, dstpos) (((flags >> srcpos) & 1) << dstpos)
+u64 get_uflags(struct page *page)
+{
+	unsigned long kflags;
+
+	if (!page)
+		return (1 << KPF_NOPAGE);
+
+	kflags = page->flags;
+	if ((kflags & PAGE_FLAGS_MASK) == 0)
+		return (1 << KPF_NOFLAGS);
+
+	return kpf_copy_bit(kflags, KPF_LOCKED,     PG_locked)	   |
+	       kpf_copy_bit(kflags, KPF_ERROR,	    PG_error)	   |
+	       kpf_copy_bit(kflags, KPF_REFERENCED, PG_referenced) |
+	       kpf_copy_bit(kflags, KPF_UPTODATE,   PG_uptodate)   |
+	       kpf_copy_bit(kflags, KPF_DIRTY,	    PG_dirty)	   |
+	       kpf_copy_bit(kflags, KPF_LRU,	    PG_lru)	   |
+	       kpf_copy_bit(kflags, KPF_ACTIVE,     PG_active)	   |
+	       kpf_copy_bit(kflags, KPF_SLAB,	    PG_slab)	   |
+	       kpf_copy_bit(kflags, KPF_WRITEBACK,  PG_writeback)  |
+	       kpf_copy_bit(kflags, KPF_RECLAIM,    PG_reclaim)	   |
+	       kpf_copy_bit(kflags, KPF_BUDDY,	    PG_buddy)	   |
+	       kpf_copy_bit(kflags, KPF_SWAPCACHE,  PG_swapcache)  |
+	       kpf_copy_bit(kflags, KPF_SWAPBACKED, PG_swapbacked) |
+	       kpf_copy_bit(kflags, KPF_PRIVATE,    PG_private)    |
+	       kpf_copy_bit(kflags, KPF_PRIVATE2,   PG_private_2)  |
+	       kpf_copy_bit(kflags, KPF_RESERVED,   PG_reserved);
+};
 
 static ssize_t kpageflags_read(struct file *file, char __user *buf,
 			     size_t count, loff_t *ppos)
@@ -90,7 +131,6 @@ static ssize_t kpageflags_read(struct fi
 	unsigned long src = *ppos;
 	unsigned long pfn;
 	ssize_t ret = 0;
-	u64 kflags, uflags;
 
 	pfn = src / KPMSIZE;
 	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
@@ -98,32 +138,16 @@ static ssize_t kpageflags_read(struct fi
 		return -EINVAL;
 
 	while (count > 0) {
-		ppage = NULL;
 		if (pfn_valid(pfn))
 			ppage = pfn_to_page(pfn);
-		pfn++;
-		if (!ppage)
-			kflags = 0;
 		else
-			kflags = ppage->flags;
-
-		uflags = kpf_copy_bit(kflags, KPF_LOCKED, PG_locked) |
-			kpf_copy_bit(kflags, KPF_ERROR, PG_error) |
-			kpf_copy_bit(kflags, KPF_REFERENCED, PG_referenced) |
-			kpf_copy_bit(kflags, KPF_UPTODATE, PG_uptodate) |
-			kpf_copy_bit(kflags, KPF_DIRTY, PG_dirty) |
-			kpf_copy_bit(kflags, KPF_LRU, PG_lru) |
-			kpf_copy_bit(kflags, KPF_ACTIVE, PG_active) |
-			kpf_copy_bit(kflags, KPF_SLAB, PG_slab) |
-			kpf_copy_bit(kflags, KPF_WRITEBACK, PG_writeback) |
-			kpf_copy_bit(kflags, KPF_RECLAIM, PG_reclaim) |
-			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy);
+			ppage = NULL;
+		pfn++;
 
-		if (put_user(uflags, out++)) {
+		if (put_user(get_uflags(ppage), out++)) {
 			ret = -EFAULT;
 			break;
 		}
-
 		count -= KPMSIZE;
 	}
 

--82I3+IH0IqGh5yIs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
