From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070331193112.1800.83399.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB tool] slabinfo: Display slab statistics
Date: Sat, 31 Mar 2007 11:31:12 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

/*
 * Slabinfo: Tool to get reports about slabs
 *
 * (C) 2007 sgi, Christoph Lameter <clameter@sgi.com>
 *
 * Compile by doing:
 *
 * gcc -o slabinfo slabinfo.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>

char buffer[200];

int show_alias = 0;
int show_slab = 1;
int show_parameter = 0;
int skip_zero = 1;

int page_size;

void fatal(const char *x, ...)
{
	va_list ap;

	va_start(ap, x);
	vfprintf(stderr, x, ap);
	va_end(ap);
	exit(1);
}

/*
 * Get the contents of an attribute
 */
unsigned long get_obj(char *name)
{
	FILE *f = fopen(name, "r");
	unsigned long result = 0;

	if (!f) {
		getcwd(buffer, sizeof(buffer));
		fatal("Cannot open file '%s/%s'\n", buffer, name);
	}

	if (fgets(buffer,sizeof(buffer), f))
		result = atol(buffer);
	fclose(f);
	return result;
}

/*
 * Put a size string together
 */
int store_size(char *buffer, unsigned long value)
{
	unsigned long divisor = 1;
	char trailer = 0;
	int n;

	if (value > 1000000000UL) {
		divisor = 100000000UL;
		trailer = 'G';
	} else if (value > 1000000UL) {
		divisor = 100000UL;
		trailer = 'M';
	} else if (value > 1000UL) {
		divisor = 100;
		trailer = 'K';
	}

	value /= divisor;
	n = sprintf(buffer, "%ld",value);
	if (trailer) {
		buffer[n] = trailer;
		n++;
		buffer[n] = 0;
	}
	if (divisor != 1) {
		memmove(buffer + n - 2, buffer + n - 3, 4);
		buffer[n-2] = '.';
		n++;
	}
	return n;
}

void alias(const char *name)
{
	char *target;

	if (!show_alias)
		return;
	/* Read link target */
	printf("%20s -> %s", name, target);
}

int line = 0;

void first_line(void)
{
	printf("Name                Objects   Objsize    Space "
		"Slabs/Part/Cpu O/S O %%Fr %%Ef Flg\n");
}

void slab(const char *name)
{
	unsigned long aliases, align, cache_dma, cpu_slabs, destroy_by_rcu;
	unsigned long hwcache_align, object_size, objects, objs_per_slab;
	unsigned long order, partial, poison, reclaim_account, red_zone;
	unsigned long sanity_checks, slab_size, slabs, store_user, trace;
	char size_str[20];
	char dist_str[40];
	char flags[20];
	char *p = flags;

	if (!show_slab)
		return;

	if (chdir(name))
		fatal("Unable to access slab %s\n", name);

	aliases = get_obj("aliases");
	align = get_obj("align");
	cache_dma = get_obj("cache_dma");
	cpu_slabs = get_obj("cpu_slabs");
	destroy_by_rcu = get_obj("destroy_by_rcu");
	hwcache_align = get_obj("hwcache_align");
	object_size = get_obj("object_size");
	objects = get_obj("objects");
	objs_per_slab = get_obj("objs_per_slab");
	order = get_obj("order");
	partial = get_obj("partial");
	poison = get_obj("poison");
	reclaim_account = get_obj("reclaim_account");
	red_zone = get_obj("red_zone");
	sanity_checks = get_obj("sanity_checks");
	slab_size = get_obj("slab_size");
	slabs = get_obj("slabs");
	store_user = get_obj("store_user");
	trace = get_obj("trace");

	if (skip_zero && !slabs)
		goto out;

	store_size(size_str, slabs * page_size);
	sprintf(dist_str,"%lu/%lu/%lu", slabs, partial, cpu_slabs);

	if (!line++)
		first_line();

	if (aliases)
		*p++ = '*';
	if (cache_dma)
		*p++ = 'd';
	if (hwcache_align)
		*p++ = 'A';
	if (poison)
		*p++ = 'P';
	if (reclaim_account)
		*p++ = 'a';
	if (red_zone)
		*p++ = 'Z';
	if (sanity_checks)
		*p++ = 'F';
	if (store_user)
		*p++ = 'U';
	if (trace)
		*p++ = 'T';

	*p = 0;
	printf("%-20s %8ld %7d %8s %14s %3ld %1ld %3d %3d %s\n",
			name, objects, object_size, size_str, dist_str,
			objs_per_slab, order,
			slabs ? (partial * 100) / slabs : 100,
			slabs ? (objects * object_size * 100) / (slabs * (page_size << order)) : 100,
			flags);
out:
	chdir("..");
}

void parameter(const char *name)
{
	if (!show_parameter)
		return;
}

int main(int argc, char *argv[])
{
	DIR *dir;
	struct dirent *de;

	page_size = getpagesize();
	if (chdir("/sys/slab"))
		fatal("This kernel does not have SLUB support.\n");

	dir = opendir(".");
	while ((de = readdir(dir))) {
		if (de->d_name[0] == '.')
			continue;
		switch (de->d_type) {
		   case DT_LNK:
			alias(de->d_name);
			break;
		   case DT_DIR:
			slab(de->d_name);
			break;
		   case DT_REG:
			parameter(de->d_name);
			break;
		   default :
			fatal("Unknown file type %lx\n", de->d_type);
		}
	}
	closedir(dir);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
