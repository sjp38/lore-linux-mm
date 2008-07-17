Received: by ag-out-0708.google.com with SMTP id 22so6492612agd.8
        for <linux-mm@kvack.org>; Thu, 17 Jul 2008 11:33:32 -0700 (PDT)
Date: Thu, 17 Jul 2008 21:32:06 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080717183206.GC5360@localhost>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro> <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro> <84144f020807170101x25c9be11qd6e1996460bb24fc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020807170101x25c9be11qd6e1996460bb24fc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 17, 2008 at 11:01:21AM +0300, Pekka Enberg wrote:
> Hi,
> 
> [Adding Randy to cc for the Documentation/ parts and Matt for the core.]
> 
> On Thu, Jul 17, 2008 at 3:46 AM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > diff --git a/Documentation/vm/kmemtrace.txt b/Documentation/vm/kmemtrace.txt
> > new file mode 100644
> > index 0000000..1147ecb
> > --- /dev/null
> > +++ b/Documentation/vm/kmemtrace.txt
> > @@ -0,0 +1,96 @@
> > +                       kmemtrace - Kernel Memory Tracer
> > +
> > +                         by Eduard - Gabriel Munteanu
> > +                            <eduard.munteanu@linux360.ro>
> > +
> 
> A chapter on what kmemtrace is here would probably be helpful.
>

Will do.

> > +2) Get the userspace tool and build it:
> > +$ git-clone git://repo.or.cz/kmemtrace-user.git                # current repository
> > +$ cd kmemtrace-user/
> > +$ autoreconf
> > +$ ./configure          # Supply KERNEL_SOURCES=/path/to/sources/ if you're
> > +                       # _not_ running this on a kmemtrace-enabled kernel.
> > +$ make
> 
> As I mentioned in private, I would prefer we drop autoconf from the
> userspace tool, but maybe that's just my personal preference.
>

Yes, I'm working on a legible plain Makefile. However, I'd leave both
the autoconf variant and the plain Makefile in the package for now. Most
developers can use autoconf since it's part of the standard toolset for
regular userspace.

> > +Q: kmemtrace_report shows many errors, how do I fix this? Should I worry?
> > +A: This is a known issue and I'm working on it. These might be true errors
> > +in kernel code, which may have inconsistent behavior (e.g. allocating memory
> > +with kmem_cache_alloc() and freeing it with kfree()). Pekka Enberg pointed
> > +out this behavior may work with SLAB, but may fail with other allocators.
> > +
> > +It may also be due to lack of tracing in some unusual allocator functions.
> > +
> > +We don't want bug reports regarding this issue yet.
> > +---
> 
> I think you're supposed to document the actual filesystem in
> Documentation/ABI as well.

Sounds like a good idea, I'll get on it.

> > +enum kmemtrace_event_id {
> > +       KMEMTRACE_EVENT_NULL = 0,       /* Erroneous event. */
> 
> I don't think this is used anywhere so why not drop it?
>

We keep this here because we see all-zeros events when relay errors
occur. I'd like to keep it until I'm sure the relay problem was solved
(although I've not seen these errors in a while since I patched
kmemtraced).

> > +       KMEMTRACE_EVENT_ALLOC,
> > +       KMEMTRACE_EVENT_FREE,
> > +};
> > +
> > +enum kmemtrace_type_id {
> > +       KMEMTRACE_TYPE_KERNEL = 0,      /* kmalloc() / kfree(). */
> > +       KMEMTRACE_TYPE_CACHE,           /* kmem_cache_*(). */
> > +       KMEMTRACE_TYPE_PAGES,           /* __get_free_pages() and friends. */
> 
> I still think kernel vs. cache is confusing because both allocations
> *are* for the kernel. So perhaps kmalloc vs. cache?
>

Okay, will s/TYPE_KERNEL/TYPE_KMALLOC/.

> > +};
> > +
> > +struct kmemtrace_event {
> 
> So why don't we have the ABI version embedded here like blktrace has
> so that user-space can check if the format matches its expectations?
> That should be future-proof as well: as long as y ou keep the existing
> fields where they're at now, you can always add new fields at the end
> of the struct.
>

You can't add fields at the end, because the struct size will change and
reads will be erroneous. Also, stamping every 'packet' with ABI version
looks like a huge waste of space.

> > +       __u16           event_id;       /* Allocate or free? */
> > +       __u16           type_id;        /* Kind of allocation/free. */
> > +       __s32           node;           /* Target CPU. */
> > +       __u64           call_site;      /* Caller address. */
> > +       __u64           ptr;            /* Pointer to allocation. */
> > +       __u64           bytes_req;      /* Number of bytes requested. */
> > +       __u64           bytes_alloc;    /* Number of bytes allocated. */
> > +       __u64           gfp_flags;      /* Requested flags. */
> > +       __s64           timestamp;      /* When the operation occured in ns. */
> > +} __attribute__ ((__packed__));
> > +

> > +       ev.bytes_req = va_arg(*args, unsigned long);
> > +       ev.bytes_alloc = va_arg(*args, unsigned long);
> > +       /* ev.timestamp set below, to preserve event ordering. */
> > +       ev.gfp_flags = va_arg(*args, unsigned long);
> > +       ev.node = va_arg(*args, int);
> > +
> > +       local_irq_save(flags);
> 
> Why do we disable local irqs here? (Perhaps a comment is in order.)
> 

We do it to preserve ordering of timestamps. Otherwise, the CPU might
get preempted (by IRQs or otherwise) and the event might not be logged
in the order timestamps were taken.

I thought the previous comment about 'ev.timestamp' was enough. I'll
make things more explicit.

> > +       ev.timestamp = ktime_to_ns(ktime_get());
> > +       kmemtrace_log_event(&ev);
> > +       local_irq_restore(flags);
> > +}
> > +
> > +static void kmemtrace_probe_free(void *probe_data, void *call_data,
> > +                                const char *format, va_list *args)
> > +{
> > +       unsigned long flags;
> > +       struct kmemtrace_event ev;
> > +
> > +       /*
> > +        * Don't convert this to use structure initializers,
> > +        * C99 does not guarantee the rvalues evaluation order.
> > +        */
> > +       ev.event_id = KMEMTRACE_EVENT_FREE;
> > +       ev.type_id = va_arg(*args, int);
> > +       ev.call_site = va_arg(*args, unsigned long);
> > +       ev.ptr = va_arg(*args, unsigned long);
> > +       /* Don't trace ignored allocations. */
> > +       if (!ev.ptr)
> > +               return;
> > +       /* ev.timestamp set below, to preserve event ordering. */
> > +
> > +       local_irq_save(flags);
> 
> (same here)
> 
> > +       ev.timestamp = ktime_to_ns(ktime_get());
> > +       kmemtrace_log_event(&ev);
> > +       local_irq_restore(flags);
> > +}
> > +
> > +static struct dentry *
> > +kmemtrace_create_buf_file(const char *filename, struct dentry *parent,
> > +                         int mode, struct rchan_buf *buf, int *is_global)
> > +{
> > +       return debugfs_create_file(filename, mode, parent, buf,
> > +                                  &relay_file_operations);
> > +}
> > +
> > +static int kmemtrace_remove_buf_file(struct dentry *dentry)
> > +{
> > +       debugfs_remove(dentry);
> > +
> > +       return 0;
> > +}
> > +
> > +static int kmemtrace_count_overruns(struct rchan_buf *buf,
> > +                                   void *subbuf, void *prev_subbuf,
> > +                                   size_t prev_padding)
> > +{
> > +       if (relay_buf_full(buf)) {
> > +               kmemtrace_buf_overruns++;
> > +               return 0;
> > +       }
> > +
> > +       return 1;
> > +}
> > +
> > +static struct rchan_callbacks relay_callbacks = {
> > +       .create_buf_file = kmemtrace_create_buf_file,
> > +       .remove_buf_file = kmemtrace_remove_buf_file,
> > +       .subbuf_start = kmemtrace_count_overruns,
> > +};
> > +
> > +static struct dentry *kmemtrace_dir;
> > +static struct dentry *kmemtrace_overruns_dentry;
> > +
> > +static void kmemtrace_cleanup(void)
> > +{
> > +       relay_close(kmemtrace_chan);
> > +       marker_probe_unregister("kmemtrace_alloc",
> > +                               kmemtrace_probe_alloc, NULL);
> > +       marker_probe_unregister("kmemtrace_free",
> > +                               kmemtrace_probe_free, NULL);
> > +       if (kmemtrace_overruns_dentry)
> > +               debugfs_remove(kmemtrace_overruns_dentry);
> > +}
> > +
> > +static int __init kmemtrace_setup_late(void)
> > +{
> > +       if (!kmemtrace_chan)
> > +               goto failed;
> > +
> > +       kmemtrace_dir = debugfs_create_dir("kmemtrace", NULL);
> > +       if (!kmemtrace_dir)
> > +               goto cleanup;
> > +
> > +       kmemtrace_overruns_dentry =
> > +               debugfs_create_u32("total_overruns", S_IRUSR,
> > +                                  kmemtrace_dir, &kmemtrace_buf_overruns);
> > +       if (!kmemtrace_overruns_dentry)
> > +               goto dir_cleanup;
> > +
> > +       if (relay_late_setup_files(kmemtrace_chan, "cpu", kmemtrace_dir))
> > +               goto overrun_cleanup;
> > +
> > +       printk(KERN_INFO "kmemtrace: fully up.\n");
> > +
> > +       return 0;
> > +
> > +overrun_cleanup:
> > +       debugfs_remove(kmemtrace_overruns_dentry);
> > +       kmemtrace_overruns_dentry = NULL;
> > +dir_cleanup:
> > +       debugfs_remove(kmemtrace_dir);
> > +cleanup:
> > +       kmemtrace_cleanup();
> > +failed:
> > +       return 1;
> > +}
> > +late_initcall(kmemtrace_setup_late);
> > +
> > +static int __init kmemtrace_set_subbuf_size(char *str)
> > +{
> > +       get_option(&str, &kmemtrace_n_subbufs);
> > +       return 0;
> > +}
> > +early_param("kmemtrace.subbufs", kmemtrace_set_subbuf_size);
> > +
> > +void kmemtrace_init(void)
> > +{
> > +       int err;
> > +
> > +       if (!kmemtrace_n_subbufs)
> > +               kmemtrace_n_subbufs = KMEMTRACE_N_SUBBUFS;
> > +
> > +       kmemtrace_chan = relay_open(NULL, NULL, KMEMTRACE_SUBBUF_SIZE,
> > +                                   kmemtrace_n_subbufs, &relay_callbacks,
> > +                                   NULL);
> > +       if (!kmemtrace_chan) {
> > +               printk(KERN_INFO "kmemtrace: could not open relay channel\n");
> > +               return;
> > +       }
> > +
> > +       err = marker_probe_register("kmemtrace_alloc", "type_id %d "
> > +                                   "call_site %lu ptr %lu "
> > +                                   "bytes_req %lu bytes_alloc %lu "
> > +                                   "gfp_flags %lu node %d",
> > +                                   kmemtrace_probe_alloc, NULL);
> > +       if (err)
> > +               goto probe_alloc_fail;
> > +       err = marker_probe_register("kmemtrace_free", "type_id %d "
> > +                                   "call_site %lu ptr %lu",
> > +                                   kmemtrace_probe_free, NULL);
> > +       if (err)
> > +               goto probe_free_fail;
> > +
> > +       printk(KERN_INFO "kmemtrace: early init successful.\n");
> > +       return;
> > +
> > +probe_free_fail:
> > +       err = marker_probe_unregister("kmemtrace_alloc",
> > +                                     kmemtrace_probe_alloc, NULL);
> > +       printk(KERN_INFO "kmemtrace: could not register marker probes!\n");
> > +probe_alloc_fail:
> > +       relay_close(kmemtrace_chan);
> > +       kmemtrace_chan = NULL;
> > +}
> > +
> > --
> > 1.5.6.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
