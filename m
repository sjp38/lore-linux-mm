Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id BB2F96B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 16:30:54 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so88200479igc.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 13:30:54 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id qh2si635220igb.84.2015.12.07.13.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 13:30:54 -0800 (PST)
Received: by igcmv3 with SMTP id mv3so88200364igc.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 13:30:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449523512-29200-2-git-send-email-jann@thejh.net>
References: <20151207203824.GA27364@pc.thejh.net>
	<1449523512-29200-1-git-send-email-jann@thejh.net>
	<1449523512-29200-2-git-send-email-jann@thejh.net>
Date: Mon, 7 Dec 2015 13:30:53 -0800
Message-ID: <CAGXu5jKe_b9Kcty2Pv7Y9YnjT2OtSGH_rdREUb09mX=kqNf4rQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] security: let security modules use PTRACE_MODE_* with bitmasks
From: Kees Cook <keescook@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Casey Schaufler <casey@schaufler-ca.com>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Joe Perches <joe@perches.com>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "security@kernel.org" <security@kernel.org>, Willy Tarreau <w@1wt.eu>

On Mon, Dec 7, 2015 at 1:25 PM, Jann Horn <jann@thejh.net> wrote:
> It looks like smack and yama weren't aware that the ptrace mode
> can have flags ORed into it - PTRACE_MODE_NOAUDIT until now, but
> only for /proc/$pid/stat, and with the PTRACE_MODE_*CREDS patch,
> all modes have flags ORed into them.
>
> Signed-off-by: Jann Horn <jann@thejh.net>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  security/smack/smack_lsm.c | 8 +++-----
>  security/yama/yama_lsm.c   | 4 ++--
>  2 files changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index ff81026..7c57c7f 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -398,12 +398,10 @@ static int smk_copy_relabel(struct list_head *nhead, struct list_head *ohead,
>   */
>  static inline unsigned int smk_ptrace_mode(unsigned int mode)
>  {
> -       switch (mode) {
> -       case PTRACE_MODE_READ:
> -               return MAY_READ;
> -       case PTRACE_MODE_ATTACH:
> +       if (mode & PTRACE_MODE_ATTACH)
>                 return MAY_READWRITE;
> -       }
> +       if (mode & PTRACE_MODE_READ)
> +               return MAY_READ;
>
>         return 0;
>  }
> diff --git a/security/yama/yama_lsm.c b/security/yama/yama_lsm.c
> index d3c19c9..cb6ed10 100644
> --- a/security/yama/yama_lsm.c
> +++ b/security/yama/yama_lsm.c
> @@ -281,7 +281,7 @@ static int yama_ptrace_access_check(struct task_struct *child,
>         int rc = 0;
>
>         /* require ptrace target be a child of ptracer on attach */
> -       if (mode == PTRACE_MODE_ATTACH) {
> +       if (mode & PTRACE_MODE_ATTACH) {
>                 switch (ptrace_scope) {
>                 case YAMA_SCOPE_DISABLED:
>                         /* No additional restrictions. */
> @@ -307,7 +307,7 @@ static int yama_ptrace_access_check(struct task_struct *child,
>                 }
>         }
>
> -       if (rc) {
> +       if (rc && (mode & PTRACE_MODE_NOAUDIT) == 0) {
>                 printk_ratelimited(KERN_NOTICE
>                         "ptrace of pid %d was attempted by: %s (pid %d)\n",
>                         child->pid, current->comm, current->pid);
> --
> 2.1.4
>



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
