Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 9F8366B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 05:47:19 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so4337834lbj.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 02:47:17 -0700 (PDT)
Date: Sat, 16 Jun 2012 13:47:14 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 3.5] c/r: prctl: less paranoid prctl_set_mm_exe_file()
Message-ID: <20120616094714.GF32029@moon>
References: <20120616085104.14682.16723.stgit@zurg>
 <20120616090646.GD32029@moon>
 <20120616091712.GA2021@moon>
 <4FDC54FF.3020305@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FDC54FF.3020305@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Pavel Emelianov <xemul@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Helsley <matthltc@us.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Sat, Jun 16, 2012 at 01:42:23PM +0400, Konstantin Khlebnikov wrote:
> >Side note: there is a little nit with this patch actually,
> >because while when we do c/r we do "right things" and unmap
> >all vm-executable mappings before we set up new exe_file. But
> >we can't guarantee that some brave soul would not setup
> >new exe-file just for it's own, then what we migh have
> >
> >  - mm::exe_file set up and points to some file, moreover num_exe_file_vmas might be>  1
> >  - application calls for prctl_set_mm_exe_file
> >  - set_mm_exe_file(mm, exe_file) called, and it drops num_exe_file_vmas to 0
> >  - finally application might call for removed_exe_file_vma
> >
> >void removed_exe_file_vma(struct mm_struct *mm)
> >{
> >	mm->num_exe_file_vmas--;
> >	if ((mm->num_exe_file_vmas == 0)&&  mm->exe_file) {
> >		fput(mm->exe_file);
> >		mm->exe_file = NULL;
> >	}
> >
> >}
> >
> >and it does _not_ test for num_exe_file_vmas being 0 before doing decrement,
> >thus we get inconsistency in counter.
> 
> No, removed_exe_file_vma() is called only for vma with VM_EXECUTABLE flag,
> there no way to get such vma other than sys_execve().
> And this brave soul cannot call prctl_set_mm_exe_file() successfully,
> just because for vma with VM_EXECUTABLE flag vma->vm_file == mm->exe_file.
> 
> Anyway, I plan to get rid of mm->num_exe_file_vmas and VM_EXECUTABLE.

Yeah, you've changed !path_equal to path_equal. And yes, getting rid of
num_exe_file_vmas is good idea. Btw, Konstantin, why do we need to
call for path_equal? Maybe we can simply test for mm->exe_file == NULL,
and refuse to change anything if it's not nil value? This will simplify
the code.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
