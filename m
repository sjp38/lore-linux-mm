Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id C6C2982F92
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 02:09:09 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so17977806wic.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 23:09:09 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id s16si7968017wiv.39.2015.10.01.23.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 23:09:08 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so19177653wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 23:09:08 -0700 (PDT)
Date: Fri, 2 Oct 2015 08:09:04 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151002060904.GA30051@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560DB4A6.6050107@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Dave Hansen <dave@sr71.net> wrote:

> On 10/01/2015 01:39 PM, Kees Cook wrote:
> > On Thu, Oct 1, 2015 at 4:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >> So could we try to add an (opt-in) kernel option that enables this transparently
> >> and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any
> >> user-space changes and syscalls necessary?
> > 
> > I would like this very much. :)
> 
> Here it is in a quite fugly form (well, it's not opt-in).  Init crashes
> if I boot with this, though.
> 
> I'll see if I can turn it in to a bit more of an opt-in and see what's
> actually going wrong.

So the reality of modern Linux distros is that, according to some limited 
strace-ing around, pure PROT_EXEC usage does not seem to exist: 99% of executable 
mappings are mapped via PROT_EXEC|PROT_READ.

So the most usable kernel testing approach would be to enable these types of pkeys 
for a child task via some mechanism and inherit it to all children (including 
inheriting it over non-suid exec) - but not to any other task.

You could hijack a new personality bit just for debug purposes - see the (totally 
untested) patch below.

Depending on user-space's assumptions it might not end up being anything usable we 
can apply, but it would be a great testing tool if it worked to a certain degree.

I.e. allow the system to boot in without pkeys set for any task, then set the 
personality of a shell process to PER_LINUX_PKEYS and see which binaries (if any!) 
will start up without segfaulting.

This way you don't have to debug SystemD, which is extremely fragile and 
passive-aggressive towards kernels that don't behave in precisely the fashion 
under which SystemD is being developed.

Thanks,

	Ingo

========>

Absolutely-Not-Signed-off-by: Ingo Molnar <mingo@kernel.org>

 include/uapi/linux/personality.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/personality.h b/include/uapi/linux/personality.h
index aa169c4339d2..bead47213419 100644
--- a/include/uapi/linux/personality.h
+++ b/include/uapi/linux/personality.h
@@ -8,6 +8,7 @@
  * These occupy the top three bytes.
  */
 enum {
+	PROT_READ_EXEC_HACK =	0x0010000,	/* PROT_READ|PROT_EXEC == PROT_EXEC hack */
 	UNAME26	=               0x0020000,
 	ADDR_NO_RANDOMIZE = 	0x0040000,	/* disable randomization of VA space */
 	FDPIC_FUNCPTRS =	0x0080000,	/* userspace function ptrs point to descriptors
@@ -41,6 +42,7 @@ enum {
 enum {
 	PER_LINUX =		0x0000,
 	PER_LINUX_32BIT =	0x0000 | ADDR_LIMIT_32BIT,
+	PER_LINUX_PKEYS =	0x0000 | PROT_READ_EXEC_HACK,
 	PER_LINUX_FDPIC =	0x0000 | FDPIC_FUNCPTRS,
 	PER_SVR4 =		0x0001 | STICKY_TIMEOUTS | MMAP_PAGE_ZERO,
 	PER_SVR3 =		0x0002 | STICKY_TIMEOUTS | SHORT_INODE,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
