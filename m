Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3E62E6B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 18:35:53 -0400 (EDT)
Received: by eyh6 with SMTP id 6so322168eyh.20
        for <linux-mm@kvack.org>; Tue, 16 Aug 2011 15:35:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110816145427.78f2f8c9.akpm@linux-foundation.org>
References: <1313441856-1419-1-git-send-email-wad@chromium.org>
	<20110816145427.78f2f8c9.akpm@linux-foundation.org>
Date: Tue, 16 Aug 2011 17:35:48 -0500
Message-ID: <CABqD9hZ7jEr+H1gg5ukfoUXkTRDs-oy8uK1PuWwHv6Jc2vgnZg@mail.gmail.com>
Subject: Re: [PATCH] mmap: add sysctl for controlling ~VM_MAYEXEC taint
From: Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, mcgrathr@google.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Al Viro <viro@zeniv.linux.org.uk>, Eric Paris <eparis@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org

On Tue, Aug 16, 2011 at 4:54 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 15 Aug 2011 15:57:35 -0500
> Will Drewry <wad@chromium.org> wrote:
>
>> This patch proposes a sysctl knob that allows a privileged user to
>> disable ~VM_MAYEXEC tainting when mapping in a vma from a MNT_NOEXEC
>> mountpoint. =A0It does not alter the normal behavior resulting from
>> attempting to directly mmap(PROT_EXEC) a vma (-EPERM) nor the behavior
>> of any other subsystems checking MNT_NOEXEC.
>>
>> It is motivated by a common /dev/shm, /tmp usecase. There are few
>> facilities for creating a shared memory segment that can be remapped in
>> the same process address space with different permissions. =A0Often, a
>> file in /tmp provides this functionality. =A0However, on distributions
>> that are more restrictive/paranoid, world-writeable directories are
>> often mounted "noexec". =A0The only workaround to support software that
>> needs this behavior is to either not use that software or remount /tmp
>> exec.
>
> Remounting /tmp would appear to have the same effect as altering this
> sysctl, so why not just remount /tmp?

The main difference is that you still achieve the primary goals of
noexec without the secondary:
1. exec still fails
2. mmap(PROT_EXEC) still fails

This means that with a common gnu-ish userspace, it's not possible to
execute an arbitrary binary in /tmp or use it as a preload or dlopen()
source.  It's like half-noexec.

>> =A0(E.g., https://bugs.gentoo.org/350336?id=3D350336) =A0Given that
>> the only recourse is using SysV IPC, the application programmer loses
>> many of the useful ABI features that they get using a mmap'd file (and
>> as such are often hesitant to explore that more painful path).
>>
>> With this patch, it would be possible to change the sysctl variable
>> such that mprotect(PROT_EXEC) would succeed. =A0In cases like the exampl=
e
>> above, an additional userspace mmap-wrapper would be needed, but in
>> other cases, like how code.google.com/p/nativeclient mmap()s then
>> mprotect()s, the behavior would be unaffected.
>>
>> The tradeoff is a loss of defense in depth, but it seems reasonable when
>> the alternative is to disable the defense entirely.
>>
>> ...
>>
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -89,6 +89,9 @@
>> =A0/* External variables not in a header file. */
>> =A0extern int sysctl_overcommit_memory;
>> =A0extern int sysctl_overcommit_ratio;
>> +#ifdef CONFIG_MMU
>
> The ifdef isn't needed in the header and we generally omit it to avoid
> clutter.

Thanks - I'll remove it!

> afaict this feature could be made available on NOMMU systems?

When I poked around I didn't see VM_MAYEXEC being used in NOMMU
systems, but I may have just been misreading!  I'll relook.

>> +extern int sysctl_mmap_noexec_taint;
>
> The term "taint" has a specific meaning in the kernel (see
> add_taint()). =A0It's regrettable that this patch attaches a second
> meaning to that term. =A0Can we think of a better word to use?
>
> A better word would communicate the sense of the sysctl operation. =A0If
> a "taint" flag is set to true, I don't know whether that means that
> noexec is enabled or disabled. =A0Something like
> sysctl_mmap_noexec_override or sysctl_mmap_noexec_disable, perhaps.

Thanks for the good points and suggestions.  Maybe something like
  sysctl_mprotect_ignores_noexec
would reflect this more closely, though still not quite as accurately
as your examples.
(hrm, maybe sysctl_mmap_noexec_propagates)

> This patch forgot to document the new feature and its sysctl.
> Documentation/sysctl/vm.txt might be the right place.

I will add that along with the changes from your other comments.

Thanks!
will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
