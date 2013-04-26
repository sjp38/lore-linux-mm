Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C703C6B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 02:03:12 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id ed20so3292578lab.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 23:03:10 -0700 (PDT)
Subject: Re: page eviction from the buddy cache
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: multipart/mixed; boundary="Apple-Mail=_D177E9F3-B579-4E0F-9BF5-671E228C36BD"
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <20130425224035.GG2144@suse.de>
Date: Fri, 26 Apr 2013 09:03:00 +0300
Message-Id: <DEB7E312-8DF9-4923-B427-CCDE6B2A6298@gmail.com>
References: <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com> <51730619.3030204@fastmail.fm> <20130420235718.GA28789@thunk.org> <5176785D.5030707@fastmail.fm> <20130423122708.GA31170@thunk.org> <alpine.LNX.2.00.1304231230340.12850@eggly.anvils> <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org> <20130424142650.GA29097@thunk.org> <20130425143056.GF2144@suse.de> <7398CEE9-AF68-4A2A-82E4-940FADF81F97@gmail.com> <20130425224035.GG2144@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Perepechko <anserper@ya.ru>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, Will Huck <will.huckk@gmail.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org


--Apple-Mail=_D177E9F3-B579-4E0F-9BF5-671E228C36BD
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Apr 26, 2013, at 01:40, Mel Gorman wrote:
> No, I would prefer if this was not fixed within ext4. I need =
confirmation
> that fixing mark_page_accessed() addresses the performance problem you
> encounter. The two-line check for PageLRU() followed by a =
lru_add_drain()
> is meant to check that. That is still not my preferred fix because =
even
> if you do not encounter higher LRU contention, other workloads would =
be
> at risk.  The likely fix will involve converting pagevecs to using a =
single
> list and then selecting what LRU to put a page on at drain time but I
> want to know that it's worthwhile.
>=20
> Using shake_page() in ext4 is certainly overkill.
agree, but it's was my prof of concept patch :) just to verify founded

>=20
>>> Andrew, can you try the following patch please? Also, is there any =
chance
>>> you can describe in more detail what the workload does?
>>=20
>> lustre OSS node + IOR with file size twice more then OSS memory.
>>=20
>=20
> Ok, no way I'll be reproducing that workload. Thanks.
>=20
I think you should be try several processes with DIO (so don't put any =
pages in lru_pagevec as that is heap), each have a filesize twice or =
more of available memory.
Main idea you should be have a read a new pages in budy cache (to =
allocate) and have large memory allocation in same time.
DIO chunk should be enough to start streaming allocation.

also you may use attached jprobe module to hit an BUG() if buddy page =
removed from a memory by shrinker.

--Apple-Mail=_D177E9F3-B579-4E0F-9BF5-671E228C36BD
Content-Disposition: attachment;
	filename=jprobe-1.c
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="jprobe-1.c"
Content-Transfer-Encoding: 7bit

#include <linux/kernel.h>
#include <linux/module.h>

#include <linux/kprobes.h>
#include <linux/tracepoint.h>
#include <trace/events/kmem.h>

#include <linux/gfp.h>
#include <linux/pagemap.h>
#include <linux/memcontrol.h>
#include <linux/mm_inline.h>
#include <linux/swap.h>
#include <../fs/ext4/ext4.h>


struct address_space swapper_space;

int check_page(struct page *page)
{
	struct inode *inode;
	struct address_space *mapping;
	struct ext4_sb_info *_sb;


	mapping = page_mapping(page);
	if ((mapping == NULL) || (mapping == &swapper_space))
		goto end;

	inode = mapping->host;
	if (inode == NULL)
		goto end;

	if ((inode->i_sb == NULL) || (inode->i_sb->s_type == NULL))
		goto end;
	
	if (strcmp(inode->i_sb->s_type->name, "ldiskfs") != 0)
//	if (strcmp(inode->i_sb->s_type->name, "ext4") != 0)
		goto end;

	_sb = EXT4_SB(inode->i_sb);
	if (inode != _sb->s_buddy_cache)
		goto end;

	printk(KERN_ERR "found buddy %p %p\n", page, inode);
	BUG();
	return 1;
end:
	return 0;
}

/* Proxy routine having the same arguments as actual do_fork() routine */
static int  my__isolate_lru_page(struct page *page, int mode, int file)
{

	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
		goto end;

	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
		goto end;

	check_page(page);
end:
	/* Always end with a call to jprobe_return(). */
	jprobe_return();
	return 0;
}

static int my__remove_from_page_cache(struct page *page)
{
	check_page(page);
	jprobe_return();
	return 0;
}

static struct jprobe my_jprobe1 = {
	.entry			= my__isolate_lru_page,
	.kp = {
		.symbol_name	= "__isolate_lru_page",
	},
};

static struct jprobe my_jprobe2 = {
	.entry			= my__remove_from_page_cache,
	.kp = {
		.symbol_name	= "__remove_from_page_cache",
	},
};

static void probe_mark_event(struct page *page)
{
	check_page(page);
}


static int __init jprobe_init(void)
{
	int ret;

	ret = register_jprobe(&my_jprobe1);
	if (ret < 0) {
		printk(KERN_INFO "register_jprobe failed, returned %d\n", ret);
		return -1;
	}
	printk(KERN_INFO "Planted jprobe at %p, handler addr %p\n",
	       my_jprobe1.kp.addr, my_jprobe1.entry);

	ret = register_jprobe(&my_jprobe2);
	if (ret < 0) {
		printk(KERN_INFO "register_jprobe failed, returned %d\n", ret);
		return -1;
	}
	printk(KERN_INFO "Planted jprobe at %p, handler addr %p\n",
	       my_jprobe2.kp.addr, my_jprobe2.entry);

//	ret = register_trace_mm_vmscan_mark_accessed(probe_mark_event);
	ret = register_trace_mm_vmscan_lru_move(probe_mark_event);
	printk("register ret %d\n", ret);
	WARN_ON(ret);

	return 0;
}

static void __exit jprobe_exit(void)
{
	unregister_jprobe(&my_jprobe1);
	printk(KERN_INFO "jprobe at %p unregistered\n", my_jprobe1.kp.addr);

	unregister_jprobe(&my_jprobe2);
	printk(KERN_INFO "jprobe at %p unregistered\n", my_jprobe2.kp.addr);

	unregister_trace_mm_vmscan_lru_move(probe_mark_event);
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");

--Apple-Mail=_D177E9F3-B579-4E0F-9BF5-671E228C36BD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
