Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 57BAA6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 11:41:35 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so9022819lbb.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 08:41:34 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id ao1si10566271lbd.172.2015.05.12.08.41.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 08:41:33 -0700 (PDT)
Message-ID: <55521F28.1020306@yandex-team.ru>
Date: Tue, 12 May 2015 18:41:28 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/3] pagemap: hide physical addresses from non-privileged
 users
References: <20150512090156.24768.2521.stgit@buzz>	<20150512094305.24768.51807.stgit@buzz> <CA+55aFyKpWrt_Ajzh1rzp_GcwZ4=6Y=kOv8hBz172CFJp6L8Tg@mail.gmail.com>
In-Reply-To: <CA+55aFyKpWrt_Ajzh1rzp_GcwZ4=6Y=kOv8hBz172CFJp6L8Tg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mark Williamson <mwilliamson@undo-software.com>, Pavel Emelyanov <xemul@parallels.com>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

On 12.05.2015 18:06, Linus Torvalds wrote:
> On Tue, May 12, 2015 at 2:43 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> @@ -1260,6 +1269,8 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>>          if (!count)
>>                  goto out_task;
>>
>> +       /* do not disclose physical addresses: attack vector */
>> +       pm.show_pfn = capable(CAP_SYS_ADMIN);
>>          pm.v2 = soft_dirty_cleared;
>>          pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
>>          pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
>
> NO! Dammit, no, no, no!
>
> How many times must people do this major security faux-pas before we learn?

Oops. Sorry. I guess everybody must do that mistake at least once.
That's my first time. =)


So, in this case existing call of mm_access() from pagemap_read()
is a bug too because it checks CAP_SYS_PTRACE for current task.

I'll rework it in the same way as /proc/*/[s]maps.

>
> WE DO NOT CHECK CURRENT CAPABILITIES AT READ/WRITE TIME!
>
> It's a bug. It's a security issue. It's not how Unix capabilities work!
>
> Capabilities are checked at open time.:
>
>> @@ -1335,9 +1346,6 @@ out:
>>
>>   static int pagemap_open(struct inode *inode, struct file *file)
>>   {
>> -       /* do not disclose physical addresses: attack vector */
>> -       if (!capable(CAP_SYS_ADMIN))
>> -               return -EPERM;
>
> THIS  is where you are supposed to check for capabilities. The place
> where you removed it!
>
> The reason we check capabilities at open time, and open time ONLY is
> because that is really very integral to the whole Unix security model.
> Otherwise, you get into this situation:
>
>   - unprivileged process opens file
>
>   - unprivileged process tricks suid process to do the actual access for it
>
> where the traditional model is to just force a "write()" by opening
> the file as stderr, and then executing a suid process (traditionally
> "sudo") that writes an error message to it.
>
> So *don't* do permission checks using read/write time credentials.
> They are wrong.
>
> Now, if there is some reason that you really can't do it when opening
> the file, and you actually need to use capability information at
> read/write time, you use the "file->f_cred" field, which is the
> open-time capabilities. So you _can_ do permission checks at
> read/write time, but you have to use the credentials of the opener,
> not "current".
>
> So in this case, I guess you could use
>
>          pm.show_pfn = file_ns_capable(file, &init_user_ns, CAP_SYS_ADMIN);
>
> if you really need to do this at read time, and cannot fill in that
> "show_pfn" at open-time.
>
>                          Linus
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
