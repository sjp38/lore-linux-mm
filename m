Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 499B06B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 16:00:04 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id x10so4521878pdj.20
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 13:00:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id hh1si9448626pac.303.2014.03.07.13.00.03
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 13:00:03 -0800 (PST)
Date: Fri, 7 Mar 2014 13:00:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 452/458] undefined reference to
 `__bad_size_call_parameter'
Message-Id: <20140307130001.25fbbcdc9c6b4a5025a9687f@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1403071106280.21846@nuc>
References: <53188aab.D8+W+0kHpmaV0uFd%fengguang.wu@intel.com>
	<20140306131835.543007307bf38e8986f1229c@linux-foundation.org>
	<alpine.DEB.2.10.1403071106280.21846@nuc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Fri, 7 Mar 2014 11:07:45 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:

> On Thu, 6 Mar 2014, Andrew Morton wrote:
> 
> > On Thu, 06 Mar 2014 22:48:11 +0800 kbuild test robot
> > <fengguang.wu@intel.com> wrote:
> > This has me stumped - the same code
> >
> > 	p = __this_cpu_read(current_kprobe);
> >
> > works OK elsewhere in that file.  I'm suspecting a miscompile - it's
> > not unknown for gcc to screw up when we use this trick.
> >
> > I can reproduce it with gcc-3.4.5 for sh.
> 
> This is again the autoconversion not applying because current_kprobe is
> probably a pointer. __bad_size_call_parameter is failure because reads
> from structures larger than word size are not supported.
> 

But there are two instances of

	__this_cpu_read(current_kprobe);

in arch/sh/kernel/kprobes.c.  One generates the bad_size thing and one
does not.

> p = this_cpu_ptr(&current_kprobe);
> 
> would fix it.

This compiles:

--- a/arch/sh/kernel/kprobes.c~a
+++ a/arch/sh/kernel/kprobes.c
@@ -511,7 +511,7 @@ int __kprobes kprobe_exceptions_notify(s
 				if (kprobe_handler(args->regs)) {
 					ret = NOTIFY_STOP;
 				} else {
-					p = __this_cpu_read(current_kprobe);
+					p = *this_cpu_ptr(&current_kprobe);
 					if (p->break_handler &&
 					    p->break_handler(p, args->regs))
 						ret = NOTIFY_STOP;

But still generates a reference to __bad_size_call_parameter.

As does this:

--- a/arch/sh/kernel/kprobes.c~a
+++ a/arch/sh/kernel/kprobes.c
@@ -249,7 +249,7 @@ static int __kprobes kprobe_handler(stru
 			kcb->kprobe_status = KPROBE_REENTER;
 			return 1;
 		} else {
-			p = __this_cpu_read(current_kprobe);
+			p = *this_cpu_ptr(&current_kprobe);
 			if (p->break_handler && p->break_handler(p, regs)) {
 				goto ss_probe;
 			}
@@ -511,7 +511,7 @@ int __kprobes kprobe_exceptions_notify(s
 				if (kprobe_handler(args->regs)) {
 					ret = NOTIFY_STOP;
 				} else {
-					p = __this_cpu_read(current_kprobe);
+					p = *this_cpu_ptr(&current_kprobe);
 					if (p->break_handler &&
 					    p->break_handler(p, args->regs))
 						ret = NOTIFY_STOP;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
