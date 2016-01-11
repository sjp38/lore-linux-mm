Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 10FB2828EB
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:39:31 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id cl12so45243625lbc.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 14:39:31 -0800 (PST)
Received: from mail-lb0-x243.google.com (mail-lb0-x243.google.com. [2a00:1450:4010:c04::243])
        by mx.google.com with ESMTPS id rg5si43111569lbb.72.2016.01.11.14.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 14:39:29 -0800 (PST)
Received: by mail-lb0-x243.google.com with SMTP id bc4so17806882lbc.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 14:39:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJaoZC7WL=MndBr915XhEpn9n3HOOhB-ue1xqyKFWxxzQ@mail.gmail.com>
References: <20160108232727.GA23490@www.outflux.net>
	<CALYGNiOUL7ewU3+5Zoi_9qofYWwF0vpqMy=A0wS=jUFZ11haCg@mail.gmail.com>
	<CAGXu5jJaoZC7WL=MndBr915XhEpn9n3HOOhB-ue1xqyKFWxxzQ@mail.gmail.com>
Date: Tue, 12 Jan 2016 01:39:29 +0300
Message-ID: <CALYGNiPC224w7-xeo9NOX9nrHH84o+_KXBtKWtd4TPXQyQMq2w@mail.gmail.com>
Subject: Re: [PATCH v6] fs: clear file privilege bits when mmap writing
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kern>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 11, 2016 at 10:38 PM, Kees Cook <keescook@chromium.org> wrote:
> On Sun, Jan 10, 2016 at 7:48 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>> On Sat, Jan 9, 2016 at 2:27 AM, Kees Cook <keescook@chromium.org> wrote:
>>> Normally, when a user can modify a file that has setuid or setgid bits,
>>> those bits are cleared when they are not the file owner or a member
>>> of the group. This is enforced when using write and truncate but not
>>> when writing to a shared mmap on the file. This could allow the file
>>> writer to gain privileges by changing a binary without losing the
>>> setuid/setgid/caps bits.
>>>
>>> Changing the bits requires holding inode->i_mutex, so it cannot be done
>>> during the page fault (due to mmap_sem being held during the fault). We
>>> could do this during vm_mmap_pgoff, but that would need coverage in
>>> mprotect as well, but to check for MAP_SHARED, we'd need to hold mmap_sem
>>> again. We could clear at open() time, but it's possible things are
>>> accidentally opening with O_RDWR and only reading. Better to clear on
>>> close and error failures (i.e. an improvement over now, which is not
>>> clearing at all).
>>
>> I think this should be done in mmap/mprotect. Code in sys_mmap is trivial.
>>
>> In sys_mprotect you can check file_needs_remove_privs() and VM_SHARED
>> under mmap_sem, then if needed grab reference to struct file from vma and
>> clear suid after unlocking mmap_sem.
>>
>> I haven't seen previous iterations, probably this approach has known flaws.
>
> mmap_sem is still needed in mprotect (to find and hold the vma), so
> it's not possible. I'd love to be proven wrong, but I didn't see a
> way.

something like this

@@ -375,6 +376,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,

        vm_flags = calc_vm_prot_bits(prot);

+restart:
        down_write(&current->mm->mmap_sem);

        vma = find_vma(current->mm, start);
@@ -416,6 +418,21 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start,
size_t, len,
                        goto out;
                }

+               if ((newflags & VM_WRITE) && !(vma->vm_flags & VM_WRITE) &&
+                   vma->vm_file && file_needs_remove_privs(vma->vm_file)) {
+                       struct file *file = get_file(vma->vm_file);
+
+                       start = vma->vm_start;
+                       up_write(&current->mm->mmap_sem);
+                       mutex_lock(&file_inode(file)->i_mutex);
+                       error = file_remove_privs(file);
+                       mutex_unlock(&file_inode(file)->i_mutex);
+                       fput(file);
+                       if (error)
+                               return error;
+                       goto restart;
+               }
+


>
> -Kees
>
> --
> Kees Cook
> Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
