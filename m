Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E8EC86B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 04:19:53 -0400 (EDT)
Date: Tue, 10 Mar 2009 16:19:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310081917.GA28968@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/> <20090307122452.bf43fbe4.akpm@linux-foundation.org> <20090307220055.6f79beb8@mjolnir.ossman.eu> <20090309013742.GA11416@localhost> <20090309020701.GA381@localhost> <20090309084045.2c652fbf@mjolnir.ossman.eu> <20090309142241.GA4437@localhost> <20090309160216.2048e898@mjolnir.ossman.eu> <20090310024135.GA6832@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Content-Disposition: inline
In-Reply-To: <20090310024135.GA6832@localhost>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Pierre,

On Tue, Mar 10, 2009 at 10:41:35AM +0800, Wu Fengguang wrote:
> On Mon, Mar 09, 2009 at 05:02:16PM +0200, Pierre Ossman wrote:
> > On Mon, 9 Mar 2009 22:22:41 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> >
> > >
> > > Thanks for the data! Now it seems that some pages are totally missing
> > > from bootmem or slabs or page cache or any application consumptions...
> > >
> >
> > So it isn't just me that's blind. That's something I guess. :)
> >
> > > Will searching through /proc/kpageflags for reserved pages help
> > > identify the problem?
> > >
> > > Oh kpageflags_read() does not include support for PG_reserved:
> > >
> >
> > I can probably hack together something that outputs the served pages.
> > Anything else that is of interest?

Here is the initial patch and tool for finding the missing pages.

In the following example, the pages with no flags set is kind of too
many (1816MB), but hopefully your missing pages will have PG_reserved
or other flags set ;-)

# ./page-types
L:locked E:error R:referenced U:uptodate D:dirty L:lru A:active S:slab W:writeback x:reclaim B:buddy r:reserved c:swapcache b:swapbacked
 
 flags        symbolic-flags    page-count            MB
0x0000        ______________        464967          1816
0x0004        __R___________             1             0
0x0008        ___U__________             2             0
0x0014        __R_D_________             5             0
0x0020        _____L________             1             0
0x0028        ___U_L________          5956            23
0x002c        __RU_L________          5415            21
0x0038        ___UDL________             7             0
0x0068        ___U_LA_______           520             2
0x006c        __RU_LA_______          2083             8
0x0080        _______S______         10820            42
0x0228        ___U_L___x____           104             0
0x022c        __RU_L___x____            52             0
0x0268        ___U_LA__x____            22             0
0x026c        __RU_LA__x____            95             0
0x0400        __________B___           477             1
0x0800        ___________r__         18734            73
0x2008        ___U_________b             9             0
0x2068        ___U_LA______b          4644            18
0x206c        __RU_LA______b            33             0
0x2078        ___UDLA______b             4             0
0x207c        __RUDLA______b            17             0
 
 total                              513968          2007

Thanks,
Fengguang


--UlVJffcvxoiEqYs2
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
#define KPF_LOCKED	0
#define KPF_ERROR	1
#define KPF_REFERENCED	2
#define KPF_UPTODATE	3
#define KPF_DIRTY	4
#define KPF_LRU		5
#define KPF_ACTIVE	6
#define KPF_SLAB	7
#define KPF_WRITEBACK	8
#define KPF_RECLAIM	9
#define KPF_BUDDY	10
#define KPF_RESERVED	11
#define KPF_SWAPCACHE	12
#define KPF_SWAPBACKED	13

#define KPF_NUM		14
#define KPF_BYTES	8

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static char *page_flag_names[] = {
	[KPF_LOCKED]		= "L:locked",
	[KPF_ERROR]		= "E:error",
	[KPF_REFERENCED]	= "R:referenced",
	[KPF_UPTODATE]		= "U:uptodate",
	[KPF_DIRTY]		= "D:dirty",
	[KPF_LRU]		= "L:lru",
	[KPF_ACTIVE]		= "A:active",
	[KPF_SLAB]		= "S:slab",
	[KPF_WRITEBACK]		= "W:writeback",
	[KPF_RECLAIM]		= "x:reclaim",
	[KPF_BUDDY]		= "B:buddy",
	[KPF_RESERVED]		= "r:reserved",
	[KPF_SWAPBACKED]	= "b:swapbacked",
	[KPF_SWAPCACHE]		= "c:swapcache",
};

static unsigned long page_count[(1 << KPF_NUM)];
static unsigned long nr_pages;
static uint64_t kpageflags[KPF_BYTES * (8<<20)];

char *page_flag_name(uint64_t flags, char *buf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++)
		buf[i] = (flags & (1 << i)) ? page_flag_names[i][0] : '_';

	return buf;
}

static unsigned long pages2mb(unsigned long pages)
{
	return (pages * getpagesize()) >> 20;
}

int main(int argc, char *argv[])
{
	static char kpageflags_name[] = "/proc/kpageflags";
	static char buf[64];
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

	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++) {
		printf("%s ", page_flag_names[i]);
	}

	printf("\n\n flags\t      symbolic-flags\tpage-count\t      MB\n");
	for (i = 0; i < ARRAY_SIZE(page_count); i++) {
		if (page_count[i])
			printf("0x%04lx\t%20s\t%10lu\t%8lu\n",
				i,
				page_flag_name(i, buf),
				page_count[i],
				pages2mb(page_count[i]));
	}

	printf("\n total\t\t\t\t%10lu\t%8lu\n",
			nr_pages, pages2mb(nr_pages));

	return 0;
}

--UlVJffcvxoiEqYs2
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="kpageflags-improvements.patch"

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 2d13451..6022f1e 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -79,8 +79,11 @@ static const struct file_operations proc_kpagecount_operations = {
 #define KPF_WRITEBACK  8
 #define KPF_RECLAIM    9
 #define KPF_BUDDY     10
+#define KPF_RESERVED  11
+#define KPF_SWAPCACHE 12
+#define KPF_SWAPBACKED 13
 
-#define kpf_copy_bit(flags, srcpos, dstpos) (((flags >> srcpos) & 1) << dstpos)
+#define kpf_copy_bit(flags, dstpos, srcpos) (((flags >> srcpos) & 1) << dstpos)
 
 static ssize_t kpageflags_read(struct file *file, char __user *buf,
 			     size_t count, loff_t *ppos)
@@ -117,7 +120,10 @@ static ssize_t kpageflags_read(struct file *file, char __user *buf,
 			kpf_copy_bit(kflags, KPF_SLAB, PG_slab) |
 			kpf_copy_bit(kflags, KPF_WRITEBACK, PG_writeback) |
 			kpf_copy_bit(kflags, KPF_RECLAIM, PG_reclaim) |
-			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy);
+			kpf_copy_bit(kflags, KPF_BUDDY, PG_buddy) |
+			kpf_copy_bit(kflags, KPF_SWAPCACHE, PG_swapcache) |
+			kpf_copy_bit(kflags, KPF_SWAPBACKED, PG_swapbacked) |
+			kpf_copy_bit(kflags, KPF_RESERVED, PG_reserved);
 
 		if (put_user(uflags, out++)) {
 			ret = -EFAULT;

--UlVJffcvxoiEqYs2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
