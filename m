Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7FA56B0253
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 19:14:17 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id h205so5975467iof.15
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 16:14:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m87sor1258561ioi.108.2017.11.16.16.14.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 16:14:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1510754620-27088-15-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com> <1510754620-27088-15-git-send-email-elena.reshetova@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 16 Nov 2017 16:14:14 -0800
Message-ID: <CAGXu5jKZ4S=aTYpGff7QiCS0BVFKxvw+TRXKt=Yr0L8M1uTHpg@mail.gmail.com>
Subject: Re: [PATCH 14/16] creds: convert cred.usage to refcount_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Elena Reshetova <elena.reshetova@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Eric Paris <eparis@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, David Howells <dhowells@redhat.com>

On Wed, Nov 15, 2017 at 6:03 AM, Elena Reshetova
<elena.reshetova@intel.com> wrote:
> atomic_t variables are currently used to implement reference
> counters with the following properties:
>  - counter is initialized to 1 using atomic_set()
>  - a resource is freed upon counter reaching zero
>  - once counter reaches zero, its further
>    increments aren't allowed
>  - counter schema uses basic atomic operations
>    (set, inc, inc_not_zero, dec_and_test, etc.)
>
> Such atomic variables should be converted to a newly provided
> refcount_t type and API that prevents accidental counter overflows
> and underflows. This is important since overflows and underflows
> can lead to use-after-free situation and be exploitable.
>
> The variable cred.usage is used as pure reference counter.
> Convert it to refcount_t and fix up the operations.
>
> **Important note for maintainers:
>
> Some functions from refcount_t API defined in lib/refcount.c
> have different memory ordering guarantees than their atomic
> counterparts.
> The full comparison can be seen in
> https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
> in state to be merged to the documentation tree.
> Normally the differences should not matter since refcount_t provides
> enough guarantees to satisfy the refcounting use cases, but in
> some rare cases it might matter.
> Please double check that you don't have some undocumented
> memory guarantees for this variable usage.
>
> For the cred.usage it might make a difference
> in following places:
>  - get_task_cred(): increment in refcount_inc_not_zero() only
>    guarantees control dependency on success vs. fully ordered
>    atomic counterpart
>  - put_cred(): decrement in refcount_dec_and_test() only
>    provides RELEASE ordering and control dependency on success
>    vs. fully ordered atomic counterpart

Both cases seem to operate under these conditions already. Andrew, can
you take this too?

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

>
> Suggested-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: David Windsor <dwindsor@gmail.com>
> Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> ---
>  include/linux/cred.h |  6 +++---
>  kernel/cred.c        | 44 ++++++++++++++++++++++----------------------
>  2 files changed, 25 insertions(+), 25 deletions(-)
>
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index 00948dd..a9f217b 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -109,7 +109,7 @@ extern bool may_setgroups(void);
>   * same context as task->real_cred.
>   */
>  struct cred {
> -       atomic_t        usage;
> +       refcount_t      usage;
>  #ifdef CONFIG_DEBUG_CREDENTIALS
>         atomic_t        subscribers;    /* number of processes subscribed */
>         void            *put_addr;
> @@ -222,7 +222,7 @@ static inline bool cap_ambient_invariant_ok(const struct cred *cred)
>   */
>  static inline struct cred *get_new_cred(struct cred *cred)
>  {
> -       atomic_inc(&cred->usage);
> +       refcount_inc(&cred->usage);
>         return cred;
>  }
>
> @@ -262,7 +262,7 @@ static inline void put_cred(const struct cred *_cred)
>         struct cred *cred = (struct cred *) _cred;
>
>         validate_creds(cred);
> -       if (atomic_dec_and_test(&(cred)->usage))
> +       if (refcount_dec_and_test(&(cred)->usage))
>                 __put_cred(cred);
>  }
>
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 9604c1a..86c039a 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -42,7 +42,7 @@ struct group_info init_groups = { .usage = REFCOUNT_INIT(2) };
>   * The initial credentials for the initial task
>   */
>  struct cred init_cred = {
> -       .usage                  = ATOMIC_INIT(4),
> +       .usage                  = REFCOUNT_INIT(4),
>  #ifdef CONFIG_DEBUG_CREDENTIALS
>         .subscribers            = ATOMIC_INIT(2),
>         .magic                  = CRED_MAGIC,
> @@ -101,17 +101,17 @@ static void put_cred_rcu(struct rcu_head *rcu)
>
>  #ifdef CONFIG_DEBUG_CREDENTIALS
>         if (cred->magic != CRED_MAGIC_DEAD ||
> -           atomic_read(&cred->usage) != 0 ||
> +           refcount_read(&cred->usage) != 0 ||
>             read_cred_subscribers(cred) != 0)
>                 panic("CRED: put_cred_rcu() sees %p with"
>                       " mag %x, put %p, usage %d, subscr %d\n",
>                       cred, cred->magic, cred->put_addr,
> -                     atomic_read(&cred->usage),
> +                     refcount_read(&cred->usage),
>                       read_cred_subscribers(cred));
>  #else
> -       if (atomic_read(&cred->usage) != 0)
> +       if (refcount_read(&cred->usage) != 0)
>                 panic("CRED: put_cred_rcu() sees %p with usage %d\n",
> -                     cred, atomic_read(&cred->usage));
> +                     cred, refcount_read(&cred->usage));
>  #endif
>
>         security_cred_free(cred);
> @@ -135,10 +135,10 @@ static void put_cred_rcu(struct rcu_head *rcu)
>  void __put_cred(struct cred *cred)
>  {
>         kdebug("__put_cred(%p{%d,%d})", cred,
> -              atomic_read(&cred->usage),
> +              refcount_read(&cred->usage),
>                read_cred_subscribers(cred));
>
> -       BUG_ON(atomic_read(&cred->usage) != 0);
> +       BUG_ON(refcount_read(&cred->usage) != 0);
>  #ifdef CONFIG_DEBUG_CREDENTIALS
>         BUG_ON(read_cred_subscribers(cred) != 0);
>         cred->magic = CRED_MAGIC_DEAD;
> @@ -159,7 +159,7 @@ void exit_creds(struct task_struct *tsk)
>         struct cred *cred;
>
>         kdebug("exit_creds(%u,%p,%p,{%d,%d})", tsk->pid, tsk->real_cred, tsk->cred,
> -              atomic_read(&tsk->cred->usage),
> +              refcount_read(&tsk->cred->usage),
>                read_cred_subscribers(tsk->cred));
>
>         cred = (struct cred *) tsk->real_cred;
> @@ -194,7 +194,7 @@ const struct cred *get_task_cred(struct task_struct *task)
>         do {
>                 cred = __task_cred((task));
>                 BUG_ON(!cred);
> -       } while (!atomic_inc_not_zero(&((struct cred *)cred)->usage));
> +       } while (!refcount_inc_not_zero(&((struct cred *)cred)->usage));
>
>         rcu_read_unlock();
>         return cred;
> @@ -212,7 +212,7 @@ struct cred *cred_alloc_blank(void)
>         if (!new)
>                 return NULL;
>
> -       atomic_set(&new->usage, 1);
> +       refcount_set(&new->usage, 1);
>  #ifdef CONFIG_DEBUG_CREDENTIALS
>         new->magic = CRED_MAGIC;
>  #endif
> @@ -258,7 +258,7 @@ struct cred *prepare_creds(void)
>         old = task->cred;
>         memcpy(new, old, sizeof(struct cred));
>
> -       atomic_set(&new->usage, 1);
> +       refcount_set(&new->usage, 1);
>         set_cred_subscribers(new, 0);
>         get_group_info(new->group_info);
>         get_uid(new->user);
> @@ -335,7 +335,7 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
>                 get_cred(p->cred);
>                 alter_cred_subscribers(p->cred, 2);
>                 kdebug("share_creds(%p{%d,%d})",
> -                      p->cred, atomic_read(&p->cred->usage),
> +                      p->cred, refcount_read(&p->cred->usage),
>                        read_cred_subscribers(p->cred));
>                 atomic_inc(&p->cred->user->processes);
>                 return 0;
> @@ -426,7 +426,7 @@ int commit_creds(struct cred *new)
>         const struct cred *old = task->real_cred;
>
>         kdebug("commit_creds(%p{%d,%d})", new,
> -              atomic_read(&new->usage),
> +              refcount_read(&new->usage),
>                read_cred_subscribers(new));
>
>         BUG_ON(task->cred != old);
> @@ -435,7 +435,7 @@ int commit_creds(struct cred *new)
>         validate_creds(old);
>         validate_creds(new);
>  #endif
> -       BUG_ON(atomic_read(&new->usage) < 1);
> +       BUG_ON(refcount_read(&new->usage) < 1);
>
>         get_cred(new); /* we will require a ref for the subj creds too */
>
> @@ -501,13 +501,13 @@ EXPORT_SYMBOL(commit_creds);
>  void abort_creds(struct cred *new)
>  {
>         kdebug("abort_creds(%p{%d,%d})", new,
> -              atomic_read(&new->usage),
> +              refcount_read(&new->usage),
>                read_cred_subscribers(new));
>
>  #ifdef CONFIG_DEBUG_CREDENTIALS
>         BUG_ON(read_cred_subscribers(new) != 0);
>  #endif
> -       BUG_ON(atomic_read(&new->usage) < 1);
> +       BUG_ON(refcount_read(&new->usage) < 1);
>         put_cred(new);
>  }
>  EXPORT_SYMBOL(abort_creds);
> @@ -524,7 +524,7 @@ const struct cred *override_creds(const struct cred *new)
>         const struct cred *old = current->cred;
>
>         kdebug("override_creds(%p{%d,%d})", new,
> -              atomic_read(&new->usage),
> +              refcount_read(&new->usage),
>                read_cred_subscribers(new));
>
>         validate_creds(old);
> @@ -535,7 +535,7 @@ const struct cred *override_creds(const struct cred *new)
>         alter_cred_subscribers(old, -1);
>
>         kdebug("override_creds() = %p{%d,%d}", old,
> -              atomic_read(&old->usage),
> +              refcount_read(&old->usage),
>                read_cred_subscribers(old));
>         return old;
>  }
> @@ -553,7 +553,7 @@ void revert_creds(const struct cred *old)
>         const struct cred *override = current->cred;
>
>         kdebug("revert_creds(%p{%d,%d})", old,
> -              atomic_read(&old->usage),
> +              refcount_read(&old->usage),
>                read_cred_subscribers(old));
>
>         validate_creds(old);
> @@ -612,7 +612,7 @@ struct cred *prepare_kernel_cred(struct task_struct *daemon)
>         validate_creds(old);
>
>         *new = *old;
> -       atomic_set(&new->usage, 1);
> +       refcount_set(&new->usage, 1);
>         set_cred_subscribers(new, 0);
>         get_uid(new->user);
>         get_user_ns(new->user_ns);
> @@ -736,7 +736,7 @@ static void dump_invalid_creds(const struct cred *cred, const char *label,
>         printk(KERN_ERR "CRED: ->magic=%x, put_addr=%p\n",
>                cred->magic, cred->put_addr);
>         printk(KERN_ERR "CRED: ->usage=%d, subscr=%d\n",
> -              atomic_read(&cred->usage),
> +              refcount_read(&cred->usage),
>                read_cred_subscribers(cred));
>         printk(KERN_ERR "CRED: ->*uid = { %d,%d,%d,%d }\n",
>                 from_kuid_munged(&init_user_ns, cred->uid),
> @@ -810,7 +810,7 @@ void validate_creds_for_do_exit(struct task_struct *tsk)
>  {
>         kdebug("validate_creds_for_do_exit(%p,%p{%d,%d})",
>                tsk->real_cred, tsk->cred,
> -              atomic_read(&tsk->cred->usage),
> +              refcount_read(&tsk->cred->usage),
>                read_cred_subscribers(tsk->cred));
>
>         __validate_process_creds(tsk, __FILE__, __LINE__);
> --
> 2.7.4
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
