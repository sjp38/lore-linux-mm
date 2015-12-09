Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 254926B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 06:08:29 -0500 (EST)
Received: by wmww144 with SMTP id w144so67935860wmw.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 03:08:28 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id k125si36844928wmd.16.2015.12.09.03.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 03:08:27 -0800 (PST)
Received: by wmvv187 with SMTP id v187so255688206wmv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 03:08:27 -0800 (PST)
Message-ID: <56680BA6.20406@gmail.com>
Date: Wed, 09 Dec 2015 12:08:22 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 26/34] mm: implement new mprotect_key() system call
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011500.69487A6C@viggo.jf.intel.com> <5662894B.7090903@gmail.com> <5665B767.8020802@sr71.net>
In-Reply-To: <5665B767.8020802@sr71.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: mtk.manpages@gmail.com, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org

Hi Dave,

On 7 December 2015 at 17:44, Dave Hansen <dave@sr71.net> wrote:
> On 12/04/2015 10:50 PM, Michael Kerrisk (man-pages) wrote:
>> On 12/04/2015 02:15 AM, Dave Hansen wrote:
>>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>>
>>> mprotect_key() is just like mprotect, except it also takes a
>>> protection key as an argument.  On systems that do not support
>>> protection keys, it still works, but requires that key=0.
>>> Otherwise it does exactly what mprotect does.
>>
>> Is there a man page for this API?
>
> Yep.

Thanks!

> Patch to man-pages source is attached.

Better as inline, for review purposes.

> I actually broke it up in
> to a few separate pages.

Seems the right approach to me.

> I was planning on submitting these after the
> patches themselves go upstream.

Not a good idea. Reading and creating man pages has helped 
me (and others) find a heap of design and implementation
bugs in APIs. Best that that happens before things hit 
upstream.

Would you be willing to revise your man page (and possibly 
your kernel patches) in the light of my comments below?
It would be better to do this sooner than later, since 
I suspect I'll have a few more API comments as I review 
future drafts of the page.

> commit ebb12643876810931ed23992f92b7c77c2c36883
> Author: Dave Hansen <dave.hansen@intel.com>
> Date:   Mon Dec 7 08:42:57 2015 -0800
>
>     pkeys
>
> diff --git a/man2/mprotect.2 b/man2/mprotect.2
> index ae305f6..a3c1e62 100644
> --- a/man2/mprotect.2
> +++ b/man2/mprotect.2
> @@ -38,16 +38,19 @@
>  .\"
>  .TH MPROTECT 2 2015-07-23 "Linux" "Linux Programmer's Manual"
>  .SH NAME
> -mprotect \- set protection on a region of memory
> +mprotect, mprotect_key \- set protection on a region of memory

Elsewhere in your patch series (in a mail with subject 
"mm: implement new mprotect_key() system call") I see:

+SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
+               unsigned long, prot, int, pkey)
+{
+       if (!arch_validate_pkey(pkey))
+               return -EINVAL;
+
+       return do_mprotect_pkey(start, len, prot, pkey);
+}

And lower down in this patch series, I see "mprotect_pkey"!

What is the name of this system call supposed to be?

For what it's worth, I think "mprotect_pkey()" is the best 
name (and secretly, you seem to as well, since we have at 
the bottom of it all the internal function "do_mprotect_pkey()". 
It signifies that this is a modified version of the base 
functionality provided my mprotect(), and "pkey" is 
consistent with the remainder of the APIs.

But, whatever name you do choose, please fix it in all 
of your commit messages, otherwise reading the git 
history gets very confusing.

>  .SH SYNOPSIS
>  .nf
>  .B #include <sys/mman.h>
>  .sp
>  .BI "int mprotect(void *" addr ", size_t " len ", int " prot );
> +.BI "int mprotect_key(void *" addr ", size_t " len ", int " prot , " int " key);
>  .fi
>  .SH DESCRIPTION
>  .BR mprotect ()
> -changes protection for the calling process's memory page(s)
> +and
> +.BR mprotect_key ()
> +change protection for the calling process's memory page(s)
>  containing any part of the address range in the
>  interval [\fIaddr\fP,\ \fIaddr\fP+\fIlen\fP\-1].
>  .I addr
> @@ -74,10 +77,17 @@ The memory can be modified.
>  .TP
>  .B PROT_EXEC
>  The memory can be executed.
> +.PP
> +.I key
> +is the protection or storage key to assign to the memory.

Why "protection or storage key" here? This phrasing seems a
little ambiguous to me, given that we also have a 'prot'
argument.  I think it would be clearer just to say 
"protection key". But maybe I'm missing something.

> +A key must be allocated with pkey_alloc () before it is

Please format syscall cross references as

.BR pkey_alloc (2)

> +passed to pkey_mprotect ().
>  .SH RETURN VALUE
>  On success,
>  .BR mprotect ()
> -returns zero.
> +and
> +.BR mprotect_key ()
> +return zero.
>  On error, \-1 is returned, and
>  .I errno
>  is set appropriately.

Are there no errors specific to mprotect_key()? Is there
an error if pkey is invalid? I see now that there is. That
EINVAL error needs documenting.

> diff --git a/man2/pkey_alloc.2 b/man2/pkey_alloc.2
> new file mode 100644
> index 0000000..980ce3e
> --- /dev/null
> +++ b/man2/pkey_alloc.2
> @@ -0,0 +1,72 @@
> +.\" Copyright (C) 2007 Michael Kerrisk <mtk.manpages@gmail.com>
> +.\" and Copyright (C) 1995 Michael Shields <shields@tembel.org>.

Michaels have many talents, but  documenting kernel APIs 
20 years ahead of their creation is not one of them, I believe. 
Better replace this with the actual copyright holder and author
name.

> +.\" %%%LICENSE_START(VERBATIM)
> +.\" Permission is granted to make and distribute verbatim copies of this
> +.\" manual provided the copyright notice and this permission notice are
> +.\" preserved on all copies.
> +.\"
> +.\" Permission is granted to copy and distribute modified versions of this
> +.\" manual under the conditions for verbatim copying, provided that the
> +.\" entire resulting derived work is distributed under the terms of a
> +.\" permission notice identical to this one.
> +.\"
> +.\" Since the Linux kernel and libraries are constantly changing, this
> +.\" manual page may be incorrect or out-of-date.  The author(s) assume no
> +.\" responsibility for errors or omissions, or for damages resulting from
> +.\" the use of the information contained herein.  The author(s) may not
> +.\" have taken the same level of care in the production of this manual,
> +.\" which is licensed free of charge, as they might when working
> +.\" professionally.
> +.\"
> +.\" Formatted or processed versions of this manual, if unaccompanied by
> +.\" the source, must acknowledge the copyright and author of this work.
> +.\" %%%LICENSE_END
> +.\"
> +.\" Modified 2015-12-04 by Dave Hansen <dave@sr71.net>

This info should be in the copyright notice above.

> +.\"
> +.\"
> +.TH PKEY_ALLOC 2 2015-12-04 "Linux" "Linux Programmer's Manual"
> +.SH NAME
> +pkey_alloc, pkey_free \- allocate or free a protection key
> +.SH SYNOPSIS
> +.nf
> +.B #include <sys/mman.h>
> +.sp
> +.BI "int pkey_alloc(unsigned long" flags ", unsigned long " init_val);

If I understand correctly, 'init_val' is a mask of access rights 
as per pkey_set(). If so, let's name the argument in this man page 
"access_rights" also (or perhaps "init_access_rights" if you must, 
but I think the shorter name is better. This helps the reader 
to understand that we're talking about the same thing. It would be 
good also to make the same change in the kernel code.

> +.BI "int pkey_free(int " pkey);
> +.fi
> +.SH DESCRIPTION
> +.BR pkey_alloc ()
> +and
> +.BR pkey_free ()
> +allow or disallow the calling process's to use the given

s/process's/process/
But should this actually be "thread"?

> +protection key for all protection-key-related operations.
> +
> +.PP
> +.I flags
> +is may contain zero or more disable operation:

s/is may/may/

> +.B PKEY_DISABLE_ACCESS
> +and/or
> +.B PKEY_DISABLE_WRITE

For the above two, please format as
.TP
.B PKEY_DISABLE_ACCESS
<Explanation of this flag>
.TP
.B PKEY_DISABLE_WRITE
<Explanation of this flag>

> +.SH RETURN VALUE
> +On success,
> +.BR pkey_alloc ()
> +and
> +.BR pkey_free ()
> +return zero.

The description of the success return for pkey_alloc() can't 
be right. Doesn't it return a protection key?

> +On error, \-1 is returned, and
> +.I errno
> +is set appropriately.
> +.SH ERRORS
> +.TP
> +.B EINVAL
> +An invalid protection key, flag, or init_val was specified.

Better to write that last line as:

[[
.IR pkey ,
.IR flags ,
or
.I init_val                    [Or: access_rights]
is invalid.
]]

> +.TP
> +.B ENOSPC
> +All protection keys available for the current process have
> +been allocated.

So it seems to me that this page needs a discussion of the
limit that is involved here.

> +.SH SEE ALSO
> +.BR mprotect_pkey (2),
> +.BR pkey_get (2),
> +.BR pkey_set (2),

Remove trailing comma.

> diff --git a/man2/pkey_get.2 b/man2/pkey_get.2
> new file mode 100644
> index 0000000..4cfdea9
> --- /dev/null
> +++ b/man2/pkey_get.2
> @@ -0,0 +1,76 @@
> +.\" Copyright (C) 2007 Michael Kerrisk <mtk.manpages@gmail.com>
> +.\" and Copyright (C) 1995 Michael Shields <shields@tembel.org>.

Again, the copyright notice needs fixing.

> +.\" %%%LICENSE_START(VERBATIM)
> +.\" Permission is granted to make and distribute verbatim copies of this
> +.\" manual provided the copyright notice and this permission notice are
> +.\" preserved on all copies.
> +.\"
> +.\" Permission is granted to copy and distribute modified versions of this
> +.\" manual under the conditions for verbatim copying, provided that the
> +.\" entire resulting derived work is distributed under the terms of a
> +.\" permission notice identical to this one.
> +.\"
> +.\" Since the Linux kernel and libraries are constantly changing, this
> +.\" manual page may be incorrect or out-of-date.  The author(s) assume no
> +.\" responsibility for errors or omissions, or for damages resulting from
> +.\" the use of the information contained herein.  The author(s) may not
> +.\" have taken the same level of care in the production of this manual,
> +.\" which is licensed free of charge, as they might when working
> +.\" professionally.
> +.\"
> +.\" Formatted or processed versions of this manual, if unaccompanied by
> +.\" the source, must acknowledge the copyright and author of this work.
> +.\" %%%LICENSE_END
> +.\"
> +.\" Modified 2015-12-04 by Dave Hansen <dave@sr71.net>
> +.\"
> +.\"
> +.TH PKEY_GET 2 2015-12-04 "Linux" "Linux Programmer's Manual"
> +.SH NAME
> +pkey_get, pkey_set \- manage protection key access permissions
> +.SH SYNOPSIS
> +.nf
> +.B #include <sys/mman.h>
> +.sp
> +.BI "int pkey_get(int " pkey);
> +.BI "int pkey_set(int " pkey ", unsigned long " access_rights);
> +.fi
> +.SH DESCRIPTION
> +.BR pkey_get ()
> +and
> +.BR pkey_set ()
> +query or set the current set of rights for the calling
> +task for the given protection key.

Change "task" to "thread".

> +When rights for a key are disabled, any future access
> +to any memory region with that key set will generate
> +a SIGSEGV.  The rights are local to the calling thread and
> +do not affect any other threads.

I think the last sentence could be simpler ("Access rights are 
private to each thread."), or even removed, since you already 
say above that these operations are per task (should be "per thread").

> +.PP
> +Upon entering any signal handler, the process is given a
> +default set of protection key rights which are separate from
> +the main thread's.  Any calls to pkey_set () in a signal

s/signal/signal hander/

Format the reference to this system call as:

.BR pkey_set ()

> +will not persist upon a return to the calling process.

So, the preceding paragraph leaves me confused. And I'm wondering 
if that confusion reflects some weirdness in the API design. But
I can't tell until I understand it better. These are my problems:

* You throw "process" and "thread" together in the explanation. 
  Is this simply a mistake? If it is not, the distinction 
  you are trying to draw by using the two different terms 
  is not made clear in the text.

* Your text ("separate from the main thread's") makes it
  sound as though a signal handler is somehow invoked in a
  different thread, which makes no sense. I suspect you
  want to say something like this:

  [[
  When a signal handler is invoked, the thread is temporarily
  given a default set of protection key rights. The thread's 
  protection key rights are restored when the signal handler 
  returns.
  ]]

  Is that close to the truth?

* Change "a return to the calling process" to "when the
  signal handler returns". Signal handlers are not "called"
  by the program.

* There needs to be some explanation in this page of *why*
  this special behavior occurs when signal handlers are
  invoked.

And I have a question (and the answer probably should 
be documented in the manual page).  What happens when 
one signal handler interrupts the execution of another? 
Do pkey_set() calls in the first handler persist into the 
second handler? I presume not, but it would be good to 
be a little more explicit about this.

> +.PP
> +.I access_rights
> +is may contain zero or more disable operation:

s/is may/may/

> +.B PKEY_DISABLE_ACCESS
> +and/or
> +.B PKEY_DISABLE_WRITE

For the above two, please format as

[[
.TP
.B PKEY_DISABLE_ACCESS
<Explanation of this flag>
.TP
.B PKEY_DISABLE_WRITE
<Explanation of this flag>
]]

In various commit messages you use two alternative names:
PKEY_DENY_ACCESS and PKEY_DENY_WRITE. I assume bit rot here 
as the the API has evolved. But please fix all of those
commit messages, so that the git history is more sensible.

> +.SH RETURN VALUE
> +On success,
> +.BR pkey_get ()
> +and
> +.BR pkey_set ()
> +return zero.

The success return value of pkey_get() is not correct.
Doesn't it return an access rights mask?

> +On error, \-1 is returned, and
> +.I errno
> +is set appropriately.
> +.SH ERRORS
> +.TP
> +.B EINVAL
> +An invalid protection key or access_rights was specified.

[[
.I access_rights
or
.I pkey
is invalid.
]]

> +.SH SEE ALSO
> +.BR mprotect_pkey (2),
> +.BR pkey_alloc (2),
> +.BR pkey_free (2),

Remove trailing comma.

So at the end of reading these pages, and delving
a little through the commit messages, I still don't
feel convinced that I understand what these APIs are
about. There's several things that I think still need 
to be added to these pages:

* A general overview of why this functionality is useful.
* A note on which architectures support/will support
  this functionality.
* Explanation of what a protection domain is.
* Explanation of how a process (thread?) changes its
  protection domain.
* Explanation of the relationship between page permission
  bits (PROT_READ/PROT_WRITE/PROTE_EXEC) and 
  PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE.
  It's still not clear to me. Do the PKEY_* bits
  override the PROT_* bits. Or, something else?

Thanks,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
