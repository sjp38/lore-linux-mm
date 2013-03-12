Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id ED55E6B0036
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 00:23:27 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id v19so4007321obq.7
        for <linux-mm@kvack.org>; Mon, 11 Mar 2013 21:23:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130312002429.GA24360@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
	<1356050997-2688-5-git-send-email-walken@google.com>
	<CA+ydwtqD67m9_JLCNwvdP72rko93aTkVgC-aK4TacyyM5DoCTA@mail.gmail.com>
	<20130311160322.830cc6b670fd24faa8366413@linux-foundation.org>
	<20130312002429.GA24360@google.com>
Date: Tue, 12 Mar 2013 12:23:26 +0800
Message-ID: <CAJd=RBCihXorfLcjHxNUcJcm+CxpnDwMgB9kcC+VrN9bTK0Gkg@mail.gmail.com>
Subject: Re: [PATCH 4/9] mm: use mm_populate() for blocking remap_file_pages()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tommi Rantala <tt.rantala@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 12, 2013 at 8:24 AM, Michel Lespinasse <walken@google.com> wrote:
> (Sorry for the late reply)
>
> On Mon, Mar 11, 2013 at 4:03 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>> On Sun, 10 Mar 2013 20:55:21 +0200 Tommi Rantala <tt.rantala@gmail.com> wrote:
>>
>>> 2012/12/21 Michel Lespinasse <walken@google.com>:
>>> > Signed-off-by: Michel Lespinasse <walken@google.com>
>>>
>>> Hello, this patch introduced the following bug, seen while fuzzing with trinity:
>>>
>>> [  396.825414] BUG: unable to handle kernel NULL pointer dereference
>>> at 0000000000000050
>
> Good catch...
>
>> From: Andrew Morton <akpm@linux-foundation.org>
>> Subject: mm/fremap.c: fix oops on error path
>>
>> If find_vma() fails, sys_remap_file_pages() will dereference `vma', which
>> contains NULL.  Fix it by checking the pointer.
>>
>> (We could alternatively check for err==0, but this seems more direct)
>>
>> (The vm_flags change is to squish a bogus used-uninitialised warning
>> without adding extra code).
>>
>> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
>> Cc: Michel Lespinasse <walken@google.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>  mm/fremap.c |    6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff -puN mm/fremap.c~mm-fremapc-fix-oops-on-error-path mm/fremap.c
>> --- a/mm/fremap.c~mm-fremapc-fix-oops-on-error-path
>> +++ a/mm/fremap.c
>> @@ -163,7 +163,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
>>          * and that the remapped range is valid and fully within
>>          * the single existing vma.
>>          */
>> -       if (!vma || !(vma->vm_flags & VM_SHARED))
>> +       vm_flags = vma->vm_flags;
>> +       if (!vma || !(vm_flags & VM_SHARED))
>>                 goto out;
>
> Your commit message indicates the vm_flags load here doesn't generate any code, but this seems very brittle and compiler dependent. If the compiler was to generate an actual load here, the issue with vma == NULL would reappear.
>
>>         if (!vma->vm_ops || !vma->vm_ops->remap_pages)
>> @@ -254,7 +255,8 @@ get_write_lock:
>>          */
>>
>>  out:
>> -       vm_flags = vma->vm_flags;
>> +       if (vma)
>> +               vm_flags = vma->vm_flags;
>>         if (likely(!has_write_lock))
>>                 up_read(&mm->mmap_sem);
>>         else
>
>
>
> Would the following work ? I think it's simpler, and with the compiler
> I'm using here it doesn't emit warnings:
>
> diff --git a/mm/fremap.c b/mm/fremap.c
> index 0cd4c11488ed..329507e832fb 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -254,7 +254,8 @@ get_write_lock:
>          */
>
>  out:
> -       vm_flags = vma->vm_flags;
> +       if (!err)
> +               vm_flags = vma->vm_flags;
>         if (likely(!has_write_lock))
>                 up_read(&mm->mmap_sem);
>         else
>
Is it still necessary to populate mm if bail out due
to a linear mapping encountered?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
