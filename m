Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id A686A900018
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 20:20:04 -0400 (EDT)
Received: by lbiz11 with SMTP id z11so48933471lbi.13
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 17:20:03 -0700 (PDT)
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com. [209.85.217.182])
        by mx.google.com with ESMTPS id ry4si15377502lbc.90.2015.03.09.17.20.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 17:20:02 -0700 (PDT)
Received: by lbiw7 with SMTP id w7so35498728lbi.7
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 17:20:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLvHa0fAV9sBwW5AvzkJY1AvQyhBmrRHLZWAtw5=-9aZg@mail.gmail.com>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name> <CAGXu5jLvHa0fAV9sBwW5AvzkJY1AvQyhBmrRHLZWAtw5=-9aZg@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 9 Mar 2015 17:19:41 -0700
Message-ID: <CALCETrU_3FS6B7LtkAwdC3e8xfiwdhPjkVWPgxP1Vy2uPeqMtA@mail.gmail.com>
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to
 non-privileged userspace
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@linux.intel.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Mark Seaborn <mseaborn@chromium.org>

On Mon, Mar 9, 2015 at 5:11 PM, Kees Cook <keescook@chromium.org> wrote:
> On Mon, Mar 9, 2015 at 2:11 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>
>> As pointed by recent post[1] on exploiting DRAM physical imperfection,
>> /proc/PID/pagemap exposes sensitive information which can be used to do
>> attacks.
>>
>> This is RFC patch which disallow anybody without CAP_SYS_ADMIN to read
>> the pagemap.
>>
>> Any comments?
>
> I prefer Dave Hansen's approach:
>
> http://www.spinics.net/lists/kernel/msg1941939.html
>
> This gives finer grained control without globally dropping the ability
> of a non-root process to examine pagemap details (which is the whole
> point of the interface).

per-pidns like this is no good.  You shouldn't be able to create a
non-paranoid pidns if your parent is paranoid.

Also, at some point we need actual per-ns controls.  This mount option
stuff is hideous.

--Andy

>
> -Kees
>
>>
>> [1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Pavel Emelyanov <xemul@parallels.com>
>> Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Cc: Mark Seaborn <mseaborn@chromium.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> ---
>>  fs/proc/task_mmu.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 246eae84b13b..b72b36e64286 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -1322,6 +1322,9 @@ out:
>>
>>  static int pagemap_open(struct inode *inode, struct file *file)
>>  {
>> +       /* do not disclose physical addresses: attack vector */
>> +       if (!capable(CAP_SYS_ADMIN))
>> +               return -EPERM;
>>         pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
>>                         "to stop being page-shift some time soon. See the "
>>                         "linux/Documentation/vm/pagemap.txt for details.\n");
>> --
>> 2.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
>
>
> --
> Kees Cook
> Chrome OS Security



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
