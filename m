Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id E553D6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:52:03 -0500 (EST)
Received: by ioir85 with SMTP id r85so108320247ioi.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 16:52:03 -0800 (PST)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id 17si421856igi.57.2015.11.19.16.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 16:52:03 -0800 (PST)
Received: by igl9 with SMTP id 9so912972igl.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 16:52:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151119164114.6b55662050922bfa45de3a94@linux-foundation.org>
References: <20151120001043.GA28204@www.outflux.net>
	<20151119164114.6b55662050922bfa45de3a94@linux-foundation.org>
Date: Thu, 19 Nov 2015 16:52:02 -0800
Message-ID: <CAGXu5j++UT=qG_hc0yC4H0VSMAnq74hrKaBDdoUL=V7HQUAX=A@mail.gmail.com>
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Willy Tarreau <w@1wt.eu>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Nov 19, 2015 at 4:41 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 19 Nov 2015 16:10:43 -0800 Kees Cook <keescook@chromium.org> wrote:
>
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
>>       }
>>
>>       return VM_FAULT_WRITE;
>
> file_remove_privs() is depressingly heavyweight.  You'd think there was
> some more lightweight way of caching the fact that we've already done
> this.

In theory, the IS_NOSEC(inode) should be fast. Perhaps track it in the
vma or file struct?

> Dumb question: can we run file_remove_privs() once, when the file is
> opened writably, rather than for each and every write into each page?

This got discussed briefly, but I can't remember why it got shot down.

> Also, the proposed patch drops the file_remove_privs() return value on
> the floor and we just go ahead with the modification.  How come?

Oh, excellent catch. If it can't drop it, it shouldn't be writable.
I'm not sure what the right abort scenario is in wp_page_reuse. Maybe
move this to start of wp_page_shared instead?

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
