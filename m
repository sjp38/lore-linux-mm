Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 28B8B6B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 19:10:30 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id e41so1042063itd.5
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 16:10:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f136sor1102787ioe.99.2017.11.16.16.10.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 16:10:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1510754620-27088-16-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com> <1510754620-27088-16-git-send-email-elena.reshetova@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 16 Nov 2017 16:10:27 -0800
Message-ID: <CAGXu5jL-=piQvvKoqdRvRLqqm+KcB64FEQTBBMVbq2409iJnZg@mail.gmail.com>
Subject: Re: [PATCH 15/16] kcov: convert kcov.refcount to refcount_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Elena Reshetova <elena.reshetova@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Eric Paris <eparis@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Dmitry Vyukov <dvyukov@google.com>

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
> The variable kcov.refcount is used as pure reference counter.
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
> For the kcov.refcount it might make a difference
> in following places:
>  - kcov_put(): decrement in refcount_dec_and_test() only
>    provides RELEASE ordering and control dependency on success
>    vs. fully ordered atomic counterpart

This also looks correct to me. Andrew, you appear to be the person for
kcov changes. :)

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

>
> Suggested-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: David Windsor <dwindsor@gmail.com>
> Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> ---
>  kernel/kcov.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/kernel/kcov.c b/kernel/kcov.c
> index 15f33fa..343288c 100644
> --- a/kernel/kcov.c
> +++ b/kernel/kcov.c
> @@ -20,6 +20,7 @@
>  #include <linux/debugfs.h>
>  #include <linux/uaccess.h>
>  #include <linux/kcov.h>
> +#include <linux/refcount.h>
>  #include <asm/setup.h>
>
>  /* Number of 64-bit words written per one comparison: */
> @@ -44,7 +45,7 @@ struct kcov {
>          *  - opened file descriptor
>          *  - task with enabled coverage (we can't unwire it from another task)
>          */
> -       atomic_t                refcount;
> +       refcount_t              refcount;
>         /* The lock protects mode, size, area and t. */
>         spinlock_t              lock;
>         enum kcov_mode          mode;
> @@ -228,12 +229,12 @@ EXPORT_SYMBOL(__sanitizer_cov_trace_switch);
>
>  static void kcov_get(struct kcov *kcov)
>  {
> -       atomic_inc(&kcov->refcount);
> +       refcount_inc(&kcov->refcount);
>  }
>
>  static void kcov_put(struct kcov *kcov)
>  {
> -       if (atomic_dec_and_test(&kcov->refcount)) {
> +       if (refcount_dec_and_test(&kcov->refcount)) {
>                 vfree(kcov->area);
>                 kfree(kcov);
>         }
> @@ -311,7 +312,7 @@ static int kcov_open(struct inode *inode, struct file *filep)
>         if (!kcov)
>                 return -ENOMEM;
>         kcov->mode = KCOV_MODE_DISABLED;
> -       atomic_set(&kcov->refcount, 1);
> +       refcount_set(&kcov->refcount, 1);
>         spin_lock_init(&kcov->lock);
>         filep->private_data = kcov;
>         return nonseekable_open(inode, filep);
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
