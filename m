Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 232C96B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 19:08:53 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n134so1540142itg.3
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 16:08:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i30sor1036878iod.341.2017.11.16.16.08.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 16:08:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1510754620-27088-14-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com> <1510754620-27088-14-git-send-email-elena.reshetova@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 16 Nov 2017 16:08:50 -0800
Message-ID: <CAGXu5jLmG8ZzMg6sU+4fwdf4H60kK37S7xtYJhF3y31HQpj+5g@mail.gmail.com>
Subject: Re: [PATCH 13/16] groups: convert group_info.usage to refcount_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Elena Reshetova <elena.reshetova@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Eric Paris <eparis@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>

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
> The variable group_info.usage is used as pure reference counter.
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
> For the group_info.usage it might make a difference
> in following places:
>  - put_group_info(): decrement in refcount_dec_and_test() only
>    provides RELEASE ordering and control dependency on success
>    vs. fully ordered atomic counterpart

This looks fine to me: there doesn't appear to be anything special in
the refcounting here.

Acked-by: Kees Cook <keescook@chromium.org>

Andrew, can you pick this up?

Thanks,

-Kees

>
> Suggested-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: David Windsor <dwindsor@gmail.com>
> Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> ---
>  include/linux/cred.h | 7 ++++---
>  kernel/cred.c        | 2 +-
>  kernel/groups.c      | 2 +-
>  3 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index 099058e..00948dd 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -17,6 +17,7 @@
>  #include <linux/key.h>
>  #include <linux/selinux.h>
>  #include <linux/atomic.h>
> +#include <linux/refcount.h>
>  #include <linux/uidgid.h>
>  #include <linux/sched.h>
>  #include <linux/sched/user.h>
> @@ -28,7 +29,7 @@ struct inode;
>   * COW Supplementary groups list
>   */
>  struct group_info {
> -       atomic_t        usage;
> +       refcount_t      usage;
>         int             ngroups;
>         kgid_t          gid[0];
>  } __randomize_layout;
> @@ -44,7 +45,7 @@ struct group_info {
>   */
>  static inline struct group_info *get_group_info(struct group_info *gi)
>  {
> -       atomic_inc(&gi->usage);
> +       refcount_inc(&gi->usage);
>         return gi;
>  }
>
> @@ -54,7 +55,7 @@ static inline struct group_info *get_group_info(struct group_info *gi)
>   */
>  #define put_group_info(group_info)                     \
>  do {                                                   \
> -       if (atomic_dec_and_test(&(group_info)->usage))  \
> +       if (refcount_dec_and_test(&(group_info)->usage))        \
>                 groups_free(group_info);                \
>  } while (0)
>
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 0192a94..9604c1a 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -36,7 +36,7 @@ do {                                                                  \
>  static struct kmem_cache *cred_jar;
>
>  /* init to 2 - one for init_task, one to ensure it is never freed */
> -struct group_info init_groups = { .usage = ATOMIC_INIT(2) };
> +struct group_info init_groups = { .usage = REFCOUNT_INIT(2) };
>
>  /*
>   * The initial credentials for the initial task
> diff --git a/kernel/groups.c b/kernel/groups.c
> index e357bc8..2ab0e56 100644
> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -24,7 +24,7 @@ struct group_info *groups_alloc(int gidsetsize)
>         if (!gi)
>                 return NULL;
>
> -       atomic_set(&gi->usage, 1);
> +       refcount_set(&gi->usage, 1);
>         gi->ngroups = gidsetsize;
>         return gi;
>  }
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
