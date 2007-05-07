Received: by qb-out-0506.google.com with SMTP id q17so3485784qba
        for <linux-mm@kvack.org>; Mon, 07 May 2007 12:31:13 -0700 (PDT)
Date: Mon, 7 May 2007 21:31:15 +0200
From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [RFC][PATCH] VM: per-user overcommit policy
Message-ID: <20070507193115.GA14264@dreamland.darkstar.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <463F764E.5050009@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righiandr@users.sourceforge.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
a few comments on the patch:

Andrea Righi <righiandr@users.sourceforge.net> ha scritto:
> diff -urpN linux-2.6.21/include/linux/mman.h linux-2.6.21-vm-acct-user/include/linux/mman.h
> --- linux-2.6.21/include/linux/mman.h   2007-05-07 20:20:24.000000000 +0200
> +++ linux-2.6.21-vm-acct-user/include/linux/mman.h      2007-05-07 20:20:42.000000000 +0200
> @@ -18,6 +18,14 @@
> extern int sysctl_overcommit_memory;
> extern int sysctl_overcommit_ratio;
> extern atomic_t vm_committed_space;
> +#ifdef CONFIG_VM_ACCT_USER
> +struct vm_acct_values
> +{
> +       int overcommit_memory;
> +       int overcommit_ratio;
> +};
> +extern int vm_acct_get_config(struct vm_acct_values *v, uid_t uid);
> +#endif
> 
> #ifdef CONFIG_SMP
> extern void vm_acct_memory(long pages);
> diff -urpN linux-2.6.21/ipc/shm.c linux-2.6.21-vm-acct-user/ipc/shm.c
> --- linux-2.6.21/ipc/shm.c      2007-05-07 20:20:24.000000000 +0200
> +++ linux-2.6.21-vm-acct-user/ipc/shm.c 2007-05-07 20:20:42.000000000 +0200
> @@ -370,12 +370,24 @@ static int newseg (struct ipc_namespace 
>                shp->mlock_user = current->user;
>        } else {
>                int acctflag = VM_ACCOUNT;
> +#ifdef CONFIG_VM_ACCT_USER
> +               int overcommit_memory;
> +               struct vm_acct_values v;
> +       
> +               if (!vm_acct_get_config(&v, current->uid)) {
> +                       overcommit_memory = v.overcommit_memory;
> +               } else {
> +                       overcommit_memory = sysctl_overcommit_memory;
> +               }
> +#else 
> +#define overcommit_memory sysctl_overcommit_memory
> +#endif
>                /*
>                 * Do not allow no accounting for OVERCOMMIT_NEVER, even
>                 * if it's asked for.
>                 */
>                if  ((shmflg & SHM_NORESERVE) &&
> -                               sysctl_overcommit_memory != OVERCOMMIT_NEVER)
> +                               overcommit_memory != OVERCOMMIT_NEVER)

Ugly... very ugly ;) 

Don't hide 'overcommit_memory' inside the ifdef block. The compiler
should be smart enough to optimize away the extra var.

There's also a problem with the #ifdef scattered all over the code. You
need a static inline 'vm_acct_get_config' for the !CONFIG_VM_ACCT_USER
case:

static inline int vm_acct_get_config(struct vm_acct_values *v,
        uid_t uid)
{
        return 0;
}

in this way you can remove the #ifdef. Futhermore, I'd also move the
branch with the fallback to sysctl values inside the vm_acct_get_config.
So, for !CONFIG_VM_ACCT_USER:

static inline int vm_acct_get_config(struct vm_acct_values *v,
        uid_t uid)
{
       v->overcommit_memory = sysctl_overcommit_memory;
       v->overcommit_ratio = sysctl_overcommit_ratio;
}

(Yes, gcc will optimize it)

and for CONFIG_VM_ACCT_USER:

int vm_acct_get_config(struct vm_acct_values *v, uid_t uid)
{
        if (found uid) {
                v->overcommit_memory = foo;
                v->overcommit_ratio = bar;
        } else {
                v->overcommit_memory = sysctl_overcommit_memory;
                v->overcommit_ratio = sysctl_overcommit_ratio;
        }
}


> diff -urpN linux-2.6.21/mm/swap.c linux-2.6.21-vm-acct-user/mm/swap.c
> --- linux-2.6.21/mm/swap.c      2007-05-07 20:20:24.000000000 +0200
> +++ linux-2.6.21-vm-acct-user/mm/swap.c 2007-05-07 20:20:42.000000000 +0200
> @@ -30,6 +30,10 @@
> #include <linux/cpu.h>
> #include <linux/notifier.h>
> #include <linux/init.h>
> +#include <linux/hash.h>
> +#include <linux/seq_file.h>
> +#include <linux/kernel.h>
> +#include <linux/proc_fs.h>
> 
> /* How many pages do we try to swap or page in/out together? */
> int page_cluster;
> @@ -455,6 +459,196 @@ unsigned pagevec_lookup_tag(struct pagev
> 
> EXPORT_SYMBOL(pagevec_lookup_tag);
> 
> +#ifdef CONFIG_VM_ACCT_USER
> +
> +#define VM_ACCT_HASH_SHIFT     10
> +#define VM_ACCT_HASH_SIZE      (1UL << VM_ACCT_HASH_SHIFT)
> +#define vm_acct_hashfn(uid) hash_long((unsigned long)uid, VM_ACCT_HASH_SHIFT)
> +
> +/* User VM overcommit configuration */
> +typedef struct vm_acct_hash_struct
> +{
> +       uid_t uid;
> +       struct vm_acct_values val;
> +       struct hlist_node vm_acct_chain;
> +} vm_acct_hash_t;
> +
> +/* Hash list used to store per-user VM overcommit configurations */
> +static struct hlist_head *vm_acct_hash;
> +
> +/* VM overcommit hash table spinlock */
> +static __cacheline_aligned_in_smp DEFINE_SPINLOCK(vm_acct_lock);
> +
> +/*
> + * Get user VM configuration from the hash list.
> + */
> +int vm_acct_get_config(struct vm_acct_values *v, uid_t uid)
> +{
> +       struct hlist_node *elem;
> +       vm_acct_hash_t *p;
> +
> +       spin_lock_irq(&vm_acct_lock);
> +       hlist_for_each_entry(p, elem, &vm_acct_hash[vm_acct_hashfn(uid)],
> +                            vm_acct_chain) {
> +               if (p->uid == uid) {
> +                       v->overcommit_memory = p->val.overcommit_memory;
> +                       v->overcommit_ratio = p->val.overcommit_ratio;
> +                       spin_unlock_irq(&vm_acct_lock);
> +                       return 0;
> +               }
> +       }
> +       spin_unlock_irq(&vm_acct_lock);
> +
> +       return -ENOENT;
> +}
> +
> +/*
> + * Create a new element in the VM configuration hash list.
> + */
> +static int __vm_acct_set_element(uid_t uid,
> +                       int overcommit_memory, int overcommit_ratio)
> +{
> +       struct hlist_node *elem;
> +       vm_acct_hash_t *p;
> +       int ret = 0;
> +
> +       spin_lock_irq(&vm_acct_lock);
> +       hlist_for_each_entry(p, elem, &vm_acct_hash[vm_acct_hashfn(uid)],
> +                            vm_acct_chain) {
> +               if (p->uid == uid) {
> +                       p->val.overcommit_memory = overcommit_memory;
> +                       p->val.overcommit_ratio = overcommit_ratio;
> +                       goto out;
> +               }
> +       }
> +       spin_unlock_irq(&vm_acct_lock);
> +
> +       /* Allocate new element */
> +       p = kzalloc(sizeof(*p), GFP_KERNEL);
> +       if (unlikely(!p)) {
> +               ret = -ENOMEM;
> +               goto out;
> +       }
> +       p->uid = uid;
> +       p->val.overcommit_memory = overcommit_memory;
> +       p->val.overcommit_ratio = overcommit_ratio;
> +
> +       spin_lock_irq(&vm_acct_lock);
> +       hlist_add_head(&p->vm_acct_chain, &vm_acct_hash[vm_acct_hashfn(uid)]);
> +out:

In the error path (kzalloc failure) you release vm_acct_lock which is not
held.

> +       spin_unlock_irq(&vm_acct_lock);
> +       return ret;
> +}
> +
> +/*
> + * Set VM user parameters via /proc/overcommit_uid.
> + */
> +static int vm_acct_set(struct file *filp, const char __user *buffer,
> +                      size_t count, loff_t *data)
> +{
> +       char buf[128];
> +       char *om, *or;
> +       int __ret;
              ^^ uh?

> +
> +       /*
> +        * Parse ':'-separated arguments
> +        *     uid:overcommit_memory:overcommit_ratio
> +        */
> +       if (count > sizeof(buf) - 1)
> +               return -EFAULT;
> +
> +       if (copy_from_user(buf, buffer, count))
> +               return -EFAULT;
> +
> +       buf[sizeof(buf) - 1] = '\0';
> +
> +       om = strstr(buf, ":");
> +       if ((om == NULL) || (*++om == '\0')) {
> +               return -EINVAL;
> +       }
> +
> +       or = strstr(om, ":");
> +       if ((or == NULL) || (*++or == '\0')) {
> +               return -EINVAL;
> +       }
> +
> +       /* Set VM configuration */
> +       __ret = __vm_acct_set_element((uid_t)simple_strtoul(buf, NULL, 10),
> +                           (int)simple_strtol(om, NULL, 10),
> +                           (int)simple_strtol(or, NULL, 10));
> +       if (__ret)
> +               return __ret;
> +
> +       return count;
> +}
> +
> +/*
> + * Print VM overcommit configurations.
> + */
> +static int vm_acct_show(struct seq_file *m, void *v)
> +{
> +       struct hlist_node *elem;
> +       vm_acct_hash_t *p;
> +       int i;
> +
> +       spin_lock_irq(&vm_acct_lock);
> +       for (i = 0; i < VM_ACCT_HASH_SIZE; i++) {
> +               if (!&vm_acct_hash[i])
> +                       continue;
> +               hlist_for_each_entry(p, elem, &vm_acct_hash[i],
> +                               vm_acct_chain) {
> +                       seq_printf(m, "%i:%i:%i\n",
> +                                  p->uid, p->val.overcommit_memory,
> +                                  p->val.overcommit_ratio);
> +               }
> +       }
> +       spin_unlock_irq(&vm_acct_lock);
> +
> +       return 0;
> +}
> +
> +static int vm_acct_open(struct inode *inode, struct file *filp)
> +{
> +       return single_open(filp, vm_acct_show, NULL);
> +}
> +
> +static struct file_operations vm_acct_ops = {
> +       .open           = vm_acct_open,
> +       .read           = seq_read,
> +       .write          = vm_acct_set,
> +       .llseek         = seq_lseek,
> +       .release        = seq_release,
> +};
> +
> +static int __init init_vm_acct(void)
> +{
> +       struct proc_dir_entry *pe;
> +       int i;
> +
> +       vm_acct_hash = kmalloc(VM_ACCT_HASH_SIZE * sizeof(*(vm_acct_hash)),
> +                              GFP_KERNEL);
> +       if (!vm_acct_hash)
> +               return -ENOMEM;
> +
> +       printk(KERN_INFO "vm_acct_uid hash table entries: %lu\n",
> +              VM_ACCT_HASH_SIZE / sizeof(*(vm_acct_hash)));
> +
> +       spin_lock_irq(&vm_acct_lock);
> +       for (i = 0; i < VM_ACCT_HASH_SIZE; i++)
> +               INIT_HLIST_HEAD(&vm_acct_hash[i]);
> +       spin_unlock_irq(&vm_acct_lock);
> +
> +       pe = create_proc_entry("overcommit_uid", 0600, NULL);
> +       if (!pe)
> +               return -ENOMEM;
> +       pe->proc_fops = &vm_acct_ops;
> +
> +       return 0;
> +}
> +__initcall(init_vm_acct);
> +
> +#endif /* CONFIG_VM_ACCT_USER */
> +
> #ifdef CONFIG_SMP
> /*
>  * We tolerate a little inaccuracy to avoid ping-ponging the counter between
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


Luca
-- 
Porc i' mond che cio' sott i piedi!
V. Catozzo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
