Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 65CA4900018
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 20:11:19 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id hy10so16318692vcb.4
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 17:11:19 -0700 (PDT)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com. [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id bq1si8949824vdd.21.2015.03.09.17.11.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 17:11:18 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id la4so13696711vcb.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 17:11:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
Date: Mon, 9 Mar 2015 17:11:18 -0700
Message-ID: <CAGXu5jLvHa0fAV9sBwW5AvzkJY1AvQyhBmrRHLZWAtw5=-9aZg@mail.gmail.com>
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to
 non-privileged userspace
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@linux.intel.com>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Mark Seaborn <mseaborn@chromium.org>, Andy Lutomirski <luto@amacapital.net>

On Mon, Mar 9, 2015 at 2:11 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
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

I prefer Dave Hansen's approach:

http://www.spinics.net/lists/kernel/msg1941939.html

This gives finer grained control without globally dropping the ability
of a non-root process to examine pagemap details (which is the whole
point of the interface).

-Kees

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
>         pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
>                         "to stop being page-shift some time soon. See the "
>                         "linux/Documentation/vm/pagemap.txt for details.\n");
> --
> 2.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
