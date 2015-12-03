Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id DE5736B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 13:19:12 -0500 (EST)
Received: by ioc74 with SMTP id 74so89923833ioc.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 10:19:12 -0800 (PST)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id vs1si123175igb.22.2015.12.03.10.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 10:19:12 -0800 (PST)
Received: by igl9 with SMTP id 9so16758493igl.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 10:19:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151202161851.95d8fe811705c038e3fe2d33@linux-foundation.org>
References: <20151203000342.GA30015@www.outflux.net>
	<20151202161851.95d8fe811705c038e3fe2d33@linux-foundation.org>
Date: Thu, 3 Dec 2015 10:19:11 -0800
Message-ID: <CAGXu5jJ+r6rUK=GbZDNOLLduF4wbJUrC7ytBZ6bSA+1cZF+5Ow@mail.gmail.com>
Subject: Re: [PATCH v2] fs: clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 2, 2015 at 4:18 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 2 Dec 2015 16:03:42 -0800 Kees Cook <keescook@chromium.org> wrote:
>
>> Normally, when a user can modify a file that has setuid or setgid bits,
>> those bits are cleared when they are not the file owner or a member
>> of the group. This is enforced when using write and truncate but not
>> when writing to a shared mmap on the file. This could allow the file
>> writer to gain privileges by changing a binary without losing the
>> setuid/setgid/caps bits.
>>
>> Changing the bits requires holding inode->i_mutex, so it cannot be done
>> during the page fault (due to mmap_sem being held during the fault).
>> Instead, clear the bits if PROT_WRITE is being used at mmap time.
>>
>> ...
>>
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -1340,6 +1340,17 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>>                       if (locks_verify_locked(file))
>>                               return -EAGAIN;
>>
>> +                     /*
>> +                      * If we must remove privs, we do it here since
>> +                      * doing it during page COW is expensive and
>> +                      * cannot hold inode->i_mutex.
>> +                      */
>> +                     if (prot & PROT_WRITE && !IS_NOSEC(inode)) {
>> +                             mutex_lock(&inode->i_mutex);
>> +                             file_remove_privs(file);
>> +                             mutex_unlock(&inode->i_mutex);
>> +                     }
>> +
>
> Still ignoring the file_remove_privs() return value.  If this is
> deliberate then a description of the reasons should be included?

Actually, there is a bigger problem:
https://lists.01.org/pipermail/lkp/2015-December/003185.html

[   37.741286] trinity-c0/742 is trying to acquire lock:
[   37.741982]  (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<811c3b34>]
do_mmap+0x544/0x670
[   37.752562]
[   37.752562] but task is already holding lock:
[   37.753442]  (&mm->mmap_sem){++++++}, at: [<811c3d70>]
SyS_remap_file_pages+0xe0/0x350

Jan, any thoughts on avoiding this?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
