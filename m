Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 36CBA6B007D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 17:20:43 -0400 (EDT)
Received: by igdh15 with SMTP id h15so25308956igd.3
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 14:20:43 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 29si6631779ioh.53.2015.03.09.14.20.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 14:20:42 -0700 (PDT)
Message-ID: <54FE0EA0.7030002@parallels.com>
Date: Tue, 10 Mar 2015 00:20:32 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to non-privileged
 userspace
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
In-Reply-To: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin
 Khlebnikov <khlebnikov@openvz.org>, Mark Seaborn <mseaborn@chromium.org>, Andy Lutomirski <luto@amacapital.net>

On 03/10/2015 12:11 AM, Kirill A. Shutemov wrote:
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

If I'm not mistaken, the pagemap file is used by some userspace that does 
working-set size analysis. But this thing only needs the flags (referenced
bit) from the PTE-s. Maybe it would be better not to lock this file completely,
but instead report the PFN part as zero?

Other than this, I don't mind :) Although we use this heavily in CRIU we
anyway work only with the CAP_SYS_ADMIN, so adding the new one doesn't hurt.

Thanks,
Pavel

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
> +	/* do not disclose physical addresses: attack vector */
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;
>  	pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
>  			"to stop being page-shift some time soon. See the "
>  			"linux/Documentation/vm/pagemap.txt for details.\n");
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
