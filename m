Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id D86386B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 20:03:16 -0500 (EST)
Received: by igcph11 with SMTP id ph11so1046654igc.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:03:16 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id mw6si506294igb.4.2015.11.19.17.03.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 17:03:16 -0800 (PST)
Received: by igbxm8 with SMTP id xm8so1184691igb.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:03:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151120010016.GB31694@1wt.eu>
References: <20151120001043.GA28204@www.outflux.net>
	<20151120010016.GB31694@1wt.eu>
Date: Thu, 19 Nov 2015 17:03:15 -0800
Message-ID: <CAGXu5jJR1KqLRUmD5_WM51k=v74gRWNA+CjsrL_oO6D494FMog@mail.gmail.com>
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Nov 19, 2015 at 5:00 PM, Willy Tarreau <w@1wt.eu> wrote:
> Hi Kees,
>
> On Thu, Nov 19, 2015 at 04:10:43PM -0800, Kees Cook wrote:
>> Normally, when a user can modify a file that has setuid or setgid bits,
>> those bits are cleared when they are not the file owner or a member of the
>> group. This is enforced when using write() directly but not when writing
>> to a shared mmap on the file. This could allow the file writer to gain
>> privileges by changing the binary without losing the setuid/setgid bits.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> Cc: stable@vger.kernel.org
>> ---
>>  mm/memory.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index deb679c31f2a..4c970a4e0057 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
>>
>>               if (!page_mkwrite)
>>                       file_update_time(vma->vm_file);
>> +             file_remove_privs(vma->vm_file);
>
> I thought you said in one of the early mails of this thread that it
> didn't work. Or maybe I misunderstood.

I had a think-o in my earlier attempts. I understood the meaning of
page_mkwrite incorrectly.

> Also, don't you think we should move that into the if (!page_mkwrite)
> just like for the time update ?

Nope, page_mkwrite indicates if there was a vmops call to
page_mkwrite. In this case, it means "I will update the file time if
the filesystem driver didn't take care of it like it should". For
file_remove_privs, we want to always do it, since we should not depend
on filesystems to do it.

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
