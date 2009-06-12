Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 25C826B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 09:58:05 -0400 (EDT)
Date: Fri, 12 Jun 2009 21:59:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/5] [RFC] HWPOISON incremental fixes
Message-ID: <20090612135944.GE6751@localhost>
References: <20090611142239.192891591@intel.com> <20090612105610.GK25568@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612105610.GK25568@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 06:56:10PM +0800, Andi Kleen wrote:
> On Thu, Jun 11, 2009 at 10:22:39PM +0800, Wu Fengguang wrote:
> > Hi all,
> > 
> > Here are the hwpoison fixes that aims to address Nick and Hugh's concerns.
> > Note that
> > - the early kill option is dropped for .31. It's obscure option and complex
> >   code and is not must have for .31. Maybe Andi also aims this option for
> >   notifying KVM, but right now KVM is not ready to handle that.
> 
> KVM is ready to handle it, patches for that have been submitted and
> are queued.

Ah OK, with that we'd better to have early kill for .31.

> Also without early kill it's not really possible right now to recover
> in the guest. Also for some other scenarios early kill is much easier
> to handle than late kill: for late kill you always have to bail
> out of your current execution context, while early kill that can be 
> done out of line (e.g. by just dropping a corrupted object similar to 
> what the kernel does). That's a much nicer and gentle model than late
> kill.
> 
> Of course very few programs will try to handle this, but if any does
> it's better to make it easier for them. 

For KVM it's important to send the notification ASAP. Otherwise the
corrupted guest pages may get referenced or go to IO. The same holds
true for applications that do a lot of caching by itself, eg. the big
databases.

> That we send too many signals in a few cases is not fatal right now
> I think. Remember always the alternative is to die completely.

Yeah the possibility of killing innocent processes should be small.

> So please don't drop that code right now.

OK.

> 
> > - It seems that even fsync() processes are not easy to catch, so I abandoned
> >   the SIGKILL on fsync() idea. Instead, I choose to fail any attempt to
> >   populate the poisoned file with new pages, so that the corrupted page offset
> >   won't be repopulated with outdated data. This seems to be a safe way to allow
> >   the process to continue running while still be able to promise good (but not
> >   complete) data consistency.
> 
> The fsync() error reporting is already broken anyways, even without hwpoison,
> for metadata errors which also only rely on the address space bit and not the
> page and run into all the same problems.
> 
> I don't think we need to be better here than normal metadata.
> 
> Possibly if metadata can be fixed then hwpoison will be fixed too in the
> same pass. But that's something longer term.

Yes I admit setting sticky EIO on bdev will be disastrous..

> > - I didn't implement the PANIC-on-corrupted-data option. Instead, I guess
> >   sending uevent notification to user space will be a more flexible scheme?
> 
> Normally you can get very aggressive panics by setting the x86 mce tolerant 
> modus to 0 (default is 1); i suspect that will be good enough.

OK.

> If other architectures add hwpoison support presumably they can add
> a similar tunable.
> 
> Doing that in the low level handler is better than in the high level
> VM because there are some corruption cases which are not reported
> to high level (e.g. not affecting memory directly)

I have worked out some basic code to do the uevent notification :)

It looks like this (the hwpoison_control bits shall be separated out).
Basically it sends the following vars:

+       add_uevent_var(hpc->env, "EVENT=poison");
+       add_uevent_var(hpc->env, "PFN=%#lx", hpc->pfn);
+       add_uevent_var(hpc->env, "PAGE_FLAGS=%#Lx", page_uflags(p));
+       add_uevent_var(hpc->env, "PAGE_COUNT=%d", page_count(p));
+       add_uevent_var(hpc->env, "PAGE_MAPCOUNT=%d", page_mapcount(p));
+               add_uevent_var(hpc->env, "PAGE_DEV=%02x:%02x",
+               add_uevent_var(hpc->env, "PAGE_INODE=%lu", mapping->host->i_ino);
+               add_uevent_var(hpc->env, "PAGE_INDEX=%lu", hpc->page->index);
+       add_uevent_var(hpc->env, "RESULT=%s", action_name[hpc->result]);

Thanks,
Fengguang

---
 mm/memory-failure.c |  137 +++++++++++++++++++++++++++++++++++++-----
 1 file changed, 121 insertions(+), 16 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -68,6 +68,54 @@ static const char *action_name[] = {
 	[RECOVERED] = "Recovered",
 };
 
+static struct kset *hwpoison_kset;
+static struct kobject hwpoison_kobj;
+
+struct hwpoison_uevent_env {
+	char *vars[16];
+	char content[200];
+	int count;
+	int index;
+};
+
+struct hwpoison_control {
+	struct kobj_uevent_env *env;
+	unsigned long pfn;
+	struct page *page;
+	int result;
+};
+
+static void hwpoison_uevent_page(struct hwpoison_control *hpc)
+{
+	struct page *p = compound_head(hpc->page);
+
+	add_uevent_var(hpc->env, "EVENT=poison");
+	add_uevent_var(hpc->env, "PFN=%#lx", hpc->pfn);
+
+	add_uevent_var(hpc->env, "PAGE_FLAGS=%#Lx", page_uflags(p));
+	add_uevent_var(hpc->env, "PAGE_COUNT=%d", page_count(p));
+	add_uevent_var(hpc->env, "PAGE_MAPCOUNT=%d", page_mapcount(p));
+}
+
+static void hwpoison_uevent_file(struct hwpoison_control *hpc)
+{
+	struct address_space *mapping = page_mapping(hpc->page);
+
+	if (mapping && mapping->host) {
+		add_uevent_var(hpc->env, "PAGE_DEV=%02x:%02x",
+			       MAJOR(mapping->host->i_sb->s_dev),
+			       MINOR(mapping->host->i_sb->s_dev));
+		add_uevent_var(hpc->env, "PAGE_INODE=%lu", mapping->host->i_ino);
+		add_uevent_var(hpc->env, "PAGE_INDEX=%lu", hpc->page->index);
+	}
+}
+
+static void hwpoison_uevent_send(struct hwpoison_control *hpc)
+{
+	add_uevent_var(hpc->env, "RESULT=%s", action_name[hpc->result]);
+	kobject_uevent_env(&hwpoison_kobj, KOBJ_CHANGE, hpc->env->envp);
+}
+
 /*
  * Error hit kernel page.
  * Do nothing, try to be lucky and not touch this instead. For a few cases we
@@ -323,24 +371,24 @@ static struct page_state {
 	{ 0,		0,		"unknown page state", me_unknown },
 };
 
-static void action_result(unsigned long pfn, char *msg, int result)
+static void action_result(struct hwpoison_control *hpc, char *msg, int result)
 {
+	hpc->result = result;
 	printk(KERN_ERR "MCE %#lx: %s%s page recovery: %s\n",
-		pfn, PageDirty(pfn_to_page(pfn)) ? "dirty " : "",
+		hpc->pfn, PageDirty(hpc->page) ? "dirty " : "",
 		msg, action_name[result]);
 }
 
-static void page_action(struct page_state *ps, struct page *p,
-			unsigned long pfn)
+static void page_action(struct page_state *ps, struct hwpoison_control *hpc)
 {
-	int result;
+	struct page *p = hpc->page;
 
-	result = ps->action(p, pfn);
-	action_result(pfn, ps->msg, result);
+	hpc->result = ps->action(p, hpc->pfn);
+	action_result(hpc, ps->msg, hpc->result);
 	if (page_count(p) != 1)
 		printk(KERN_ERR
 		       "MCE %#lx: %s page still referenced by %d users\n",
-		       pfn, ps->msg, page_count(p) - 1);
+		       hpc->pfn, ps->msg, page_count(p) - 1);
 
 	/* Could do more checks here if page looks ok */
 	atomic_long_add(1, &mce_bad_pages);
@@ -437,6 +485,13 @@ void memory_failure(unsigned long pfn, i
 {
 	struct page_state *ps;
 	struct page *p;
+	struct hwpoison_control hpc;
+
+	hpc.env = kzalloc(sizeof(struct kobj_uevent_env), GFP_NOIO);
+	if (!hpc.env) {
+		printk(KERN_ERR "MCE %#lx: out of memory: Failed\n", pfn);
+		return;
+	}
 
 	if (!pfn_valid(pfn)) {
 		printk(KERN_ERR
@@ -446,9 +501,13 @@ void memory_failure(unsigned long pfn, i
 	}
 
 	p = pfn_to_page(pfn);
+	hpc.pfn = pfn;
+	hpc.page = p;
+	hwpoison_uevent_page(&hpc);
+
 	if (TestSetPageHWPoison(p)) {
-		action_result(pfn, "already hardware poisoned", IGNORED);
-		return;
+		action_result(&hpc, "already hardware poisoned", IGNORED);
+		goto out;
 	}
 
 	/*
@@ -463,8 +522,8 @@ void memory_failure(unsigned long pfn, i
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
 	if (!get_page_unless_zero(compound_head(p))) {
-		action_result(pfn, "free or high order kernel", IGNORED);
-		return;
+		action_result(&hpc, "free or high order kernel", IGNORED);
+		goto out;
 	}
 
 	/*
@@ -484,16 +543,62 @@ void memory_failure(unsigned long pfn, i
 	 * Torn down by someone else?
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
-		action_result(pfn, "already truncated LRU", IGNORED);
-		goto out;
+		action_result(&hpc, "already truncated LRU", IGNORED);
+		goto out_unlock;
 	}
 
+	hwpoison_uevent_file(&hpc);
+
 	for (ps = error_states;; ps++) {
 		if ((p->flags & ps->mask) == ps->res) {
-			page_action(ps, p, pfn);
+			page_action(ps, &hpc);
 			break;
 		}
 	}
-out:
+out_unlock:
 	unlock_page(p);
+out:
+	hwpoison_uevent_send(&hpc);
+}
+
+static void hwpoison_release(struct kobject *kobj)
+{
+}
+
+static struct kobj_type hwpoison_ktype = {
+	.release = hwpoison_release,
+};
+
+static int create_hwpoison_obj(void)
+{
+	int err;
+
+	hwpoison_kset = kset_create_and_add("hwpoison", NULL, mm_kobj);
+	if (!hwpoison_kset)
+		return -ENOMEM;
+
+	hwpoison_kobj.kset = hwpoison_kset;
+
+	err = kobject_init_and_add(&hwpoison_kobj, &hwpoison_ktype, NULL,
+				   "hwpoison");
+	if (err)
+		return -ENOMEM;
+
+	kobject_uevent(&hwpoison_kobj, KOBJ_ADD);
+
+	return 0;
 }
+
+
+static int __init hwpoison_init(void)
+{
+	return create_hwpoison_obj();
+}
+
+static void __exit hwpoison_exit(void)
+{
+	kset_unregister(hwpoison_kset);
+}
+
+module_init(hwpoison_init);
+module_exit(hwpoison_exit);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
