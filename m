Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id D72C6900018
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 18:09:30 -0400 (EDT)
Received: by labgq15 with SMTP id gq15so221634lab.4
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 15:09:30 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id ld3si6810737lac.55.2015.03.09.15.09.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 15:09:29 -0700 (PDT)
Received: by labge10 with SMTP id ge10so7046080lab.7
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 15:09:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
Date: Tue, 10 Mar 2015 01:09:28 +0300
Message-ID: <CALYGNiO44n0QP4Xowk=VaLKSLwQFyXhyEgVLaw13KdO+-LKhDQ@mail.gmail.com>
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to
 non-privileged userspace
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Mark Seaborn <mseaborn@chromium.org>, Andy Lutomirski <luto@amacapital.net>

On Tue, Mar 10, 2015 at 12:11 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> As pointed by recent post[1] on exploiting DRAM physical imperfection,
> /proc/PID/pagemap exposes sensitive information which can be used to do
> attacks.
>
> This is RFC patch which disallow anybody without CAP_SYS_ADMIN to read
> the pagemap.
>
> Any comments?
>
> [1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Mark Seaborn <mseaborn@chromium.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> ---
>  fs/proc/task_mmu.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 246eae84b13b..b72b36e64286 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1322,6 +1322,9 @@ out:
>
>  static int pagemap_open(struct inode *inode, struct file *file)
>  {
> +       /* do not disclose physical addresses: attack vector */
> +       if (!capable(CAP_SYS_ADMIN))
> +               return -EPERM;

This interface is connected to /proc/kpagecount, /proc/kpageflags
and these files are readable only by root. So it's fine, but it's might
be better to change here file owner to root too.

>         pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
>                         "to stop being page-shift some time soon. See the "
>                         "linux/Documentation/vm/pagemap.txt for details.\n");
> --
> 2.3.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
