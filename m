Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 16CCA6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 11:06:33 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so17054459igb.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 08:06:33 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id sd6si1535793igb.4.2015.05.12.08.06.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 08:06:32 -0700 (PDT)
Received: by igbyr2 with SMTP id yr2so110825740igb.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 08:06:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150512094305.24768.51807.stgit@buzz>
References: <20150512090156.24768.2521.stgit@buzz>
	<20150512094305.24768.51807.stgit@buzz>
Date: Tue, 12 May 2015 08:06:32 -0700
Message-ID: <CA+55aFyKpWrt_Ajzh1rzp_GcwZ4=6Y=kOv8hBz172CFJp6L8Tg@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] pagemap: hide physical addresses from
 non-privileged users
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mark Williamson <mwilliamson@undo-software.com>, Pavel Emelyanov <xemul@parallels.com>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

On Tue, May 12, 2015 at 2:43 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> @@ -1260,6 +1269,8 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>         if (!count)
>                 goto out_task;
>
> +       /* do not disclose physical addresses: attack vector */
> +       pm.show_pfn = capable(CAP_SYS_ADMIN);
>         pm.v2 = soft_dirty_cleared;
>         pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
>         pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);

NO! Dammit, no, no, no!

How many times must people do this major security faux-pas before we learn?

WE DO NOT CHECK CURRENT CAPABILITIES AT READ/WRITE TIME!

It's a bug. It's a security issue. It's not how Unix capabilities work!

Capabilities are checked at open time.:

> @@ -1335,9 +1346,6 @@ out:
>
>  static int pagemap_open(struct inode *inode, struct file *file)
>  {
> -       /* do not disclose physical addresses: attack vector */
> -       if (!capable(CAP_SYS_ADMIN))
> -               return -EPERM;

THIS  is where you are supposed to check for capabilities. The place
where you removed it!

The reason we check capabilities at open time, and open time ONLY is
because that is really very integral to the whole Unix security model.
Otherwise, you get into this situation:

 - unprivileged process opens file

 - unprivileged process tricks suid process to do the actual access for it

where the traditional model is to just force a "write()" by opening
the file as stderr, and then executing a suid process (traditionally
"sudo") that writes an error message to it.

So *don't* do permission checks using read/write time credentials.
They are wrong.

Now, if there is some reason that you really can't do it when opening
the file, and you actually need to use capability information at
read/write time, you use the "file->f_cred" field, which is the
open-time capabilities. So you _can_ do permission checks at
read/write time, but you have to use the credentials of the opener,
not "current".

So in this case, I guess you could use

        pm.show_pfn = file_ns_capable(file, &init_user_ns, CAP_SYS_ADMIN);

if you really need to do this at read time, and cannot fill in that
"show_pfn" at open-time.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
