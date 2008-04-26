Date: Sat, 26 Apr 2008 09:19:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] procfs task exe symlink
Message-Id: <20080426091930.ffe4e6a8.akpm@linux-foundation.org>
In-Reply-To: <1202348669.9062.271.camel@localhost.localdomain>
References: <1202348669.9062.271.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 06 Feb 2008 17:44:29 -0800 Matt Helsley <matthltc@us.ibm.com> wrote:

> The kernel implements readlink of /proc/pid/exe by getting the file from the
> first executable VMA. Then the path to the file is reconstructed and reported as
> the result. 
> 
> Because of the VMA walk the code is slightly different on nommu systems. This
> patch avoids separate /proc/pid/exe code on nommu systems. Instead of walking
> the VMAs to find the first executable file-backed VMA we store a reference to
> the exec'd file in the mm_struct.
> 
> That reference would prevent the filesystem holding the executable file from
> being unmounted even after unmapping the VMAs. So we track the number of 
> VM_EXECUTABLE VMAs and drop the new reference when the last one is unmapped.
> This avoids pinning the mounted filesystem.
> 
> Andrew, these are the updates I promised. Please consider this patch for
> inclusion in -mm.
> 

A hitherto-unsuspected patch has been instasnuck into mainline:


commit 3b1253880b7a9e6db54b943b2d40bcf2202f58ab
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Tue Apr 22 05:31:30 2008 -0400

    [PATCH] sanitize unshare_files/reset_files_struct
    


which presented me with this:

***************
*** 963,968 ****
  	retval = unshare_files();
  	if (retval)
  		goto out;
  	/*
  	 * Release all of the old mmap stuff
  	 */
--- 963,971 ----
  	retval = unshare_files();
  	if (retval)
  		goto out;
+ 
+ 	set_mm_exe_file(bprm->mm, bprm->file);
+ 
  	/*
  	 * Release all of the old mmap stuff
  	 */


Which I fixed by simply doing:

--- a/fs/exec.c~procfs-task-exe-symlink
+++ a/fs/exec.c
@@ -954,6 +954,8 @@ int flush_old_exec(struct linux_binprm *
 	if (retval)
 		goto out;
 
+	set_mm_exe_file(bprm->mm, bprm->file);
+
 	/*
 	 * Release all of the old mmap stuff
 	 */

However I'd ask that you conform that this is OK.  If set_mm_exe_file() is
independent of unshare_files() then we're OK.  If however there is some
ordering dependency then we'll need to confirm that the present ordering of the
unshare_files() and set_mm_exe_file() is correct.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
