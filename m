Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 35EBB6B004D
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 01:06:18 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3827814bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 22:06:16 -0700 (PDT)
Message-ID: <4F7A8544.2020603@openvz.org>
Date: Tue, 03 Apr 2012 09:06:12 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg> <20120402231837.GC32299@count0.beaverton.ibm.com>
In-Reply-To: <20120402231837.GC32299@count0.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

Matt Helsley wrote:
> On Sat, Mar 31, 2012 at 01:29:29PM +0400, Konstantin Khlebnikov wrote:
>> Currently the kernel sets mm->exe_file during sys_execve() and then tracks
>> number of vmas with VM_EXECUTABLE flag in mm->num_exe_file_vmas, as soon as
>> this counter drops to zero kernel resets mm->exe_file to NULL. Plus it resets
>> mm->exe_file at last mmput() when mm->mm_users drops to zero.
>>
>> Vma with VM_EXECUTABLE flag appears after mapping file with flag MAP_EXECUTABLE,
>> such vmas can appears only at sys_execve() or after vma splitting, because
>> sys_mmap ignores this flag. Usually binfmt module sets mm->exe_file and mmaps
>> some executable vmas with this file, they hold mm->exe_file while task is running.
>>
>> comment from v2.6.25-6245-g925d1c4 ("procfs task exe symlink"),
>> where all this stuff was introduced:
>>
>>> The kernel implements readlink of /proc/pid/exe by getting the file from
>>> the first executable VMA.  Then the path to the file is reconstructed and
>>> reported as the result.
>>>
>>> Because of the VMA walk the code is slightly different on nommu systems.
>>> This patch avoids separate /proc/pid/exe code on nommu systems.  Instead of
>>> walking the VMAs to find the first executable file-backed VMA we store a
>>> reference to the exec'd file in the mm_struct.
>>>
>>> That reference would prevent the filesystem holding the executable file
>>> from being unmounted even after unmapping the VMAs.  So we track the number
>>> of VM_EXECUTABLE VMAs and drop the new reference when the last one is
>>> unmapped.  This avoids pinning the mounted filesystem.
>>
>> So, this logic is hooked into every file mmap/unmmap and vma split/merge just to
>> fix some hypothetical pinning fs from umounting by mm which already unmapped all
>> its executable files, but still alive. Does anyone know any real world example?
>> mm can be borrowed by swapoff or some get_task_mm() user, but it's not a big problem.
>>
>> Thus, we can remove all this stuff together with VM_EXECUTABLE flag and
>> keep mm->exe_file alive till final mmput().
>>
>> After that we can access current->mm->exe_file without any locks
>> (after checking current->mm and mm->exe_file for NULL)
>>
>> Some code around security and oprofile still uses VM_EXECUTABLE for retrieving
>> task's executable file, after this patch they will use mm->exe_file directly.
>> In tomoyo and audit mm is always current->mm, oprofile uses get_task_mm().
>
> Perhaps I'm missing something but it seems like you ought to split
> this into two patches. The first could fix up the cell, tile, etc. arch
> code to use the exe_file reference rather than walk the VMAs. Then the
> second patch could remove the unusual logic used to allow userspace to unpin
> the mount and we could continue to discuss that separately. It would
> also make the git log somewhat cleaner I think...

Ok, I'll resend this patch as independent patch-set,
anyway I need to return mm->mmap_sem locking back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
