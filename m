Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 081F26B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 12:31:16 -0400 (EDT)
Date: Sun, 5 Aug 2012 12:31:14 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [RFC v2 6/7] tracepoint: use new hashtable implementation
Message-ID: <20120805163114.GA21768@Krystal>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com> <1344003788-1417-7-git-send-email-levinsasha928@gmail.com> <1344126994.27983.116.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344126994.27983.116.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

* Steven Rostedt (rostedt@goodmis.org) wrote:
> FYI, Mathieu is the author of this file.
> 
> -- Steve
> 
> 
> On Fri, 2012-08-03 at 16:23 +0200, Sasha Levin wrote:
> > Switch tracepoints to use the new hashtable implementation. This reduces the amount of
> > generic unrelated code in the tracepoints.
> > 
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > ---
> >  kernel/tracepoint.c |   26 +++++++++-----------------
> >  1 files changed, 9 insertions(+), 17 deletions(-)
> > 
> > diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
> > index d96ba22..b5a2650 100644
> > --- a/kernel/tracepoint.c
> > +++ b/kernel/tracepoint.c
> > @@ -26,6 +26,7 @@
> >  #include <linux/slab.h>
> >  #include <linux/sched.h>
> >  #include <linux/static_key.h>
> > +#include <linux/hashtable.h>
> >  
> >  extern struct tracepoint * const __start___tracepoints_ptrs[];
> >  extern struct tracepoint * const __stop___tracepoints_ptrs[];
> > @@ -49,8 +50,7 @@ static LIST_HEAD(tracepoint_module_list);
> >   * Protected by tracepoints_mutex.
> >   */
> >  #define TRACEPOINT_HASH_BITS 6
> > -#define TRACEPOINT_TABLE_SIZE (1 << TRACEPOINT_HASH_BITS)
> > -static struct hlist_head tracepoint_table[TRACEPOINT_TABLE_SIZE];
> > +DEFINE_STATIC_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);

I wonder why the "static" has been embedded within
"DEFINE_STATIC_HASHTABLE" ? I'm used to see something similar to:

static DEFINE_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);

elsewhere in the kernel (e.g. static DEFINE_PER_CPU(), static
DEFINE_MUTEX(), etc).

> >  
> >  /*
> >   * Note about RCU :
> > @@ -191,16 +191,14 @@ tracepoint_entry_remove_probe(struct tracepoint_entry *entry,
> >   */
> >  static struct tracepoint_entry *get_tracepoint(const char *name)
> >  {
> > -	struct hlist_head *head;
> >  	struct hlist_node *node;
> >  	struct tracepoint_entry *e;
> >  	u32 hash = jhash(name, strlen(name), 0);
> >  
> > -	head = &tracepoint_table[hash & (TRACEPOINT_TABLE_SIZE - 1)];
> > -	hlist_for_each_entry(e, node, head, hlist) {
> > +	hash_for_each_possible(&tracepoint_table, node, e, hlist, hash)
> >  		if (!strcmp(name, e->name))
> >  			return e;
> > -	}
> > +

Typically, where there are 2 or more nesting levels, I try to keep the
outer brackets, even if the 1st level only contain a single statement
(this is what I did across tracepoint.c). This is especially useful when
nesting multiple if levels, and ensures the "else" clause match the
right if. We might want to keep it that way within the file, to ensure
style consistency.

Other than that, it looks good!

Thanks!

Mathieu

> >  	return NULL;
> >  }
> >  
> > @@ -210,19 +208,13 @@ static struct tracepoint_entry *get_tracepoint(const char *name)
> >   */
> >  static struct tracepoint_entry *add_tracepoint(const char *name)
> >  {
> > -	struct hlist_head *head;
> > -	struct hlist_node *node;
> >  	struct tracepoint_entry *e;
> >  	size_t name_len = strlen(name) + 1;
> >  	u32 hash = jhash(name, name_len-1, 0);
> >  
> > -	head = &tracepoint_table[hash & (TRACEPOINT_TABLE_SIZE - 1)];
> > -	hlist_for_each_entry(e, node, head, hlist) {
> > -		if (!strcmp(name, e->name)) {
> > -			printk(KERN_NOTICE
> > -				"tracepoint %s busy\n", name);
> > -			return ERR_PTR(-EEXIST);	/* Already there */
> > -		}
> > +	if (get_tracepoint(name)) {
> > +		printk(KERN_NOTICE "tracepoint %s busy\n", name);
> > +		return ERR_PTR(-EEXIST);	/* Already there */
> >  	}
> >  	/*
> >  	 * Using kmalloc here to allocate a variable length element. Could
> > @@ -234,7 +226,7 @@ static struct tracepoint_entry *add_tracepoint(const char *name)
> >  	memcpy(&e->name[0], name, name_len);
> >  	e->funcs = NULL;
> >  	e->refcount = 0;
> > -	hlist_add_head(&e->hlist, head);
> > +	hash_add(&tracepoint_table, &e->hlist, hash);
> >  	return e;
> >  }
> >  
> > @@ -244,7 +236,7 @@ static struct tracepoint_entry *add_tracepoint(const char *name)
> >   */
> >  static inline void remove_tracepoint(struct tracepoint_entry *e)
> >  {
> > -	hlist_del(&e->hlist);
> > +	hash_del(&e->hlist);
> >  	kfree(e);
> >  }
> >  
> 
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
