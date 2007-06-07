From: clameter@sgi.com
Subject: [patch 00/12] Slab defragmentation V3
Date: Thu, 07 Jun 2007 14:55:29 -0700
Message-ID: <20070607215529.147027769@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966214AbXFGV7w@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Will show up shortly at http://ftp.kernel.org/pub/linux/kernel/people/christoph/slab-defrag/

Test results (see appended scripts / user space code for more data)

(3 level tree with 10 entries at first level , 20 at the second and 30 files at the
third level. Files at the lowest level were removed to create inode fragmentation)

%Ra is the allocation ratio (need to apply the slabinfo patch to get those numbers)

inode reclaim in reiserfs

Name                   Objects Objsize    Space Slabs/Part/Cpu  O/S O %Ra %Ef Flg
dentry                   14660     200     3.0M        733/0/1   20 0 100  97 Da
reiser_inode_cache        1596     640     4.1M      256/201/1   25 2  24  24 DCa

Status after defrag

Name                   Objects Objsize    Space Slabs/Part/Cpu  O/S O %Ra %Ef Flg
dentry                    8849     200     1.8M       454/17/1   20 0  97  95 Da
reiser_inode_cache        1381     640     1.0M        65/11/0   25 2  84  82 DCa



Slab defragmentation can be triggered in two ways:

1. Manually by running

slabinfo -s <slabs-to-shrink>

or manually by the kernel calling

kmem_cache_shrink(slab)

(Currently only ACPI is doing such a call to a slab that has no
defragmentation support. In that case we simply do what SLAB does:
drop per cpu caches and sift through partial list for free slabs).

2. Automatically if defragmentable slabs reach a certain degree of
   fragmentation.

The point where slab defragmentation occurs is can be set at

/proc/sys/vm/slab_defrag_ratio

Slab fragmentation is measured by how much of the possible objects in a
slab are in use. The default setting for slab_defrag_ratio is 30%. This
means that slab fragmentation is going to be triggered if there are more than
3 free object slots for each allocated object.

Setting the slab_defrag_ratio higher will cause more defragmentation runs.
If slab_defrag_ratio is set to 0 then no slab defragmentation occurs.

Slabs are checked for their fragmentation levels after the slabs have been shrunk
by running shrinkers in vm/scan.c during memory reclaim. This means that slab
defragmentation is only triggered if we are under memory pressure and if there is
significant slab fragmentation.

V1->V2
- Clean up control flow using a state variable. Simplify API. Back to 2
  functions that now take arrays of objects.
- Inode defrag support for a set of filesystems
- Fix up dentry defrag support to work on negative dentries by adding
  a new dentry flag that indicates that a dentry is not in the process
  of being freed or allocated.

V2->V3
- Support directory reclaim
- Add infrastructure to trigger slab defrag after slab shrinking if we
  have slabs with a high degree of fragmentation.



Test script:

#!/bin/sh

echo 30 >/proc/sys/vm/slab_defrag_ratio

./gazfiles c 3 10 20 30
echo "Status before"
slabinfo -D
./gazfiles d 2
echo "Status after removing files"
slabinfo -D
slabinfo -s
echo "Status after defrag"
slabinfo -D
./gazfiles d 0


gazfiles.c :

/*
 * Create a gazillion of files to be able to create slab fragmentation
 *
 * (C) 2007 sgi, Christoph Lameter <clameter@sgi.com>
 *
 * Create a n layered hierachy of files of empty files
 *
 * gazfiles <action> <levels> <n1> <n2> ...
 *
 * gazfiles c[reate] 3 50 50 50
 *
 * gazfiles s[hrink] <levels>
 *
 * gazfiles r[andomkill] <nr to kill> 
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>
#include <getopt.h>
#include <regex.h>
#include <errno.h>

#define MAXIMUM_LEVELS 10

int level;
int sizes[MAXIMUM_LEVELS];

void fatal(const char *x, ...)
{
        va_list ap;

        va_start(ap, x);
        vfprintf(stderr, x, ap);
        va_end(ap);
        exit(1);
}

int read_gaz(void)
{
	FILE *f = fopen(".gazinfo", "r");
	int rc = 0;
	int i;

	if (!f)
		return 0;

	if (!fscanf(f, "%d", &level))
		goto out;

	if (level >= MAXIMUM_LEVELS)
		goto out;

	for (i = 0; i < level; i++)
		if (!fscanf(f, " %d", &sizes[i]))
			goto out;
	rc = 1;
out:
	fclose(f);
	return rc;
}

void write_gaz(void)
{
	FILE *f = fopen(".gazinfo","w");
	int i;

	fprintf(f, "%d",level);
	for (i = 0; i < level; i++)
		fprintf(f," %d", sizes[i]);
	fprintf(f, "\n");
	fclose(f);
}

void cre(int l)
{
	int i;

	for (i = 0; i < sizes[l - 1]; i++) {
		char name[20];

		sprintf(name, "%03d", i);

		if (l < level) {
			mkdir(name, 0775);
			chdir(name);
			cre(l + 1);
			chdir("..");
		} else {
			FILE *f;

			f = fopen(name,"w");
			fprintf(f, "Test");
			fclose(f);
		}
	}
}

void create(int l, char **sz)
{
	int i;

	level = l;
	for (i = 0; i < level; i++)
		sizes[i] = atoi(sz[i]);

	if (mkdir("gazf", 0775))
		fatal("Cannot create gazf here\n");
	chdir("gazf");
	write_gaz();
	cre(1);
	chdir("..");
}

void shrink(int level)
{
	if (chdir("gazf"))
		fatal("No gazfiles in this directory");
	read_gaz();
	chdir("..");
}

void scand(int l, void (*func)(int, int, char *, unsigned long),
			unsigned long level)
{
	DIR *dir;
	struct dirent *de;

	dir = opendir(".");
	if (!dir)
		fatal("Cannot open directory");
	while ((de = readdir(dir))) {
		struct stat s;

		if (de->d_name[0] == '.')
			continue;

		/*
		 * Some idiot broke the glibc library or made it impossible
		 * to figure out how to make readdir work right
		 */

		stat(de->d_name, &s);
		if (S_ISDIR(s.st_mode))
			de->d_type = DT_DIR;

		if (de->d_type == DT_DIR) {
			if (chdir(de->d_name))
				fatal("Cannot enter %s", de->d_name);
			scand(l + 1, func, level);
			chdir("..");
			func(l, 1, de->d_name, level);
		} else {
			func(l, 0, de->d_name, level);
		}
	}
	closedir(dir);
}

void traverse(void (*func)(int, int, char *, unsigned long),
		unsigned long level)
{
	if (chdir("gazf"))
		fatal("No gazfiles in this directory");
	scand(1, func, level);
	chdir("..");
}

void randomkill(int nr)
{
	if (chdir("gazf"))
		fatal("No gazfiles in this directory");
	read_gaz();
	chdir("..");
}

void del_func(int l, int dir, char *name, unsigned long level)
{
	if (l <= level)
		return;
	if (dir) {
		if (rmdir(name))
			fatal("Cannot remove directory %s");
	} else {
		if (unlink(name))
			fatal("Cannot unlink file %s");
	}
}

void delete(int l)
{
	if (l == 0) {
		system("rm -rf gazf");
		return;
	}
	traverse(del_func, l);
}

void usage(void)
{
	printf("gazfiles: Tool to manage gazillions of files\n\n");
	printf("gazfiles create <levels> <#l1> <#l2> ...\n");
	printf("gazfiles delete <levels>\n");
	printf("gazfiles shrink <levels>\n");
	printf("gazfiles randomkill <nr>\n\n");
	printf("(C) 2007 sgi, Christoph Lameter <clameter@sgi.com>\n");
	exit(0);
}

int main(int argc, char *argv[])
{
	if (argc  <  2)
		usage();

	switch (argv[1][0]) {
		case 'c' :
			create(atoi(argv[2]), argv + 3);
			break;
		case 's' :
			if (argc != 3)
				usage();

			shrink(atoi(argv[2]));
			break;
		case 'r' :
			if (argc != 3)
				usage();

			randomkill(atoi(argv[2]));
			break;
		case 'd':
			if (argc != 3)
				usage();
			delete(atoi(argv[2]));
			break;

		default:
			usage();
	}
	return 0;
}
-- 
