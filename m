Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CF996B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 20:26:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m18so15588387pgd.13
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 17:26:27 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x6si909634pgt.77.2017.10.24.17.26.20
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 17:26:21 -0700 (PDT)
Date: Wed, 25 Oct 2017 09:26:12 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 8/8] block: Assign a lock_class per gendisk used for
 wait_for_completion()
Message-ID: <20171025002612.GN3310@X58A-UD3R>
References: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
 <1508837889-16932-9-git-send-email-byungchul.park@lge.com>
 <20171024101551.sftqsy5mk34fxru7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024101551.sftqsy5mk34fxru7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, axboe@kernel.dk, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

On Tue, Oct 24, 2017 at 12:15:51PM +0200, Ingo Molnar wrote:
> > @@ -1409,9 +1403,12 @@ struct gendisk *alloc_disk_node(int minors, int node_id)
> >  		disk_to_dev(disk)->type = &disk_type;
> >  		device_initialize(disk_to_dev(disk));
> >  	}
> > +
> > +	lockdep_init_map(&disk->lockdep_map, lock_name, key, 0);
> 
> lockdep_init_map() depends on CONFIG_DEBUG_LOCK_ALLOC IIRC, but the data structure 
> change you made depends on CONFIG_LOCKDEP_COMPLETIONS:

OMG, my mistake! I am very sorry. I will fix it.

BTW, lockdep_init_map() seems to decide whether using lockdep_map or
ignoring it, depending on CONFIG_LOCKDEP than CONFIG_DEBUG_LOCK_ALLOC.

> >  	return disk;
> >  }
> > -EXPORT_SYMBOL(alloc_disk_node);
> > +EXPORT_SYMBOL(__alloc_disk_node);
> >  
> >  struct kobject *get_disk(struct gendisk *disk)
> >  {
> > diff --git a/include/linux/genhd.h b/include/linux/genhd.h
> > index 6d85a75..9832e3c 100644
> > --- a/include/linux/genhd.h
> > +++ b/include/linux/genhd.h
> > @@ -206,6 +206,9 @@ struct gendisk {
> >  #endif	/* CONFIG_BLK_DEV_INTEGRITY */
> >  	int node_id;
> >  	struct badblocks *bb;
> > +#ifdef CONFIG_LOCKDEP_COMPLETIONS
> > +	struct lockdep_map lockdep_map;
> > +#endif
> >  };
> 
> Which is risking a future build failure at minimum.
> 
> Isn't lockdep_map a zero size structure that is always defined? If yes then 
> there's no need for an #ifdef.

No, a zero size structure for lockdep_map is not provided yet.
There are two options I can do:

1. Add a zero size structure for lockdep_map and remove #ifdef
2. Replace CONFIG_LOCKDEP_COMPLETIONS with CONFIG_LOCKDEP here.

Or something else?

Which one do you prefer?

> Also:
> 
> >  
> >  static inline struct gendisk *part_to_disk(struct hd_struct *part)
> > @@ -590,8 +593,7 @@ extern struct hd_struct * __must_check add_partition(struct gendisk *disk,
> >  extern void delete_partition(struct gendisk *, int);
> >  extern void printk_all_partitions(void);
> >  
> > -extern struct gendisk *alloc_disk_node(int minors, int node_id);
> > -extern struct gendisk *alloc_disk(int minors);
> > +extern struct gendisk *__alloc_disk_node(int minors, int node_id, struct lock_class_key *key, const char *lock_name);
> >  extern struct kobject *get_disk(struct gendisk *disk);
> >  extern void put_disk(struct gendisk *disk);
> >  extern void blk_register_region(dev_t devt, unsigned long range,
> > @@ -615,6 +617,22 @@ extern ssize_t part_fail_store(struct device *dev,
> >  			       const char *buf, size_t count);
> >  #endif /* CONFIG_FAIL_MAKE_REQUEST */
> >  
> > +#ifdef CONFIG_LOCKDEP_COMPLETIONS
> > +#define alloc_disk_node(m, id) \
> > +({									\
> > +	static struct lock_class_key __key;				\
> > +	const char *__lock_name;					\
> > +									\
> > +	__lock_name = "(complete)"#m"("#id")";				\
> > +									\
> > +	__alloc_disk_node(m, id, &__key, __lock_name);			\
> > +})
> > +#else
> > +#define alloc_disk_node(m, id)	__alloc_disk_node(m, id, NULL, NULL)
> > +#endif
> > +
> > +#define alloc_disk(m)		alloc_disk_node(m, NUMA_NO_NODE)
> > +
> >  static inline int hd_ref_init(struct hd_struct *part)
> >  {
> >  	if (percpu_ref_init(&part->ref, __delete_partition, 0,
> 
> Why is the lockdep_map passed in to the init function? Since it's wrapped in an 
> ugly fashion anyway, why not introduce a clean inline function that calls 

This is the way workqueue adopted for that purpose. BTW, can I make
a lock_class_key distinguishable from another of a different gendisk,
using inline function?

> lockdep_init_map() on the returned structure.

Ok. I will make it work on the returned structre instead of passing it.

> No #ifdefs required, and no uglification of the alloc_disk_node() interface.

Ok. I will remove this #ifdef.

Thank you very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
