Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 737838D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:41:00 -0400 (EDT)
Received: by iwg8 with SMTP id 8so931424iwg.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 06:40:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110419062654.GB10698@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	<20110401143457.15455.64839.sendpatchset@localhost6.localdomain6>
	<1303145171.32491.886.camel@twins>
	<20110419062654.GB10698@linux.vnet.ibm.com>
Date: Wed, 20 Apr 2011 09:40:57 -0400
Message-ID: <BANLkTimw7dV9_aSsrUfzwSdwr6UwZDsRwg@mail.gmail.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 12/26] 12: uprobes: slot allocation for uprobes
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, sds@tycho.nsa.gov

On Tue, Apr 19, 2011 at 2:26 AM, Srikar Dronamraju
<srikar@linux.vnet.ibm.com> wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-04-18 18:46:11]:
>
>> On Fri, 2011-04-01 at 20:04 +0530, Srikar Dronamraju wrote:

>> > +static int xol_add_vma(struct uprobes_xol_area *area)
>> > +{
>> > + =A0 struct vm_area_struct *vma;
>> > + =A0 struct mm_struct *mm;
>> > + =A0 struct file *file;
>> > + =A0 unsigned long addr;
>> > + =A0 int ret =3D -ENOMEM;
>> > +
>> > + =A0 mm =3D get_task_mm(current);
>> > + =A0 if (!mm)
>> > + =A0 =A0 =A0 =A0 =A0 return -ESRCH;
>> > +
>> > + =A0 down_write(&mm->mmap_sem);
>> > + =A0 if (mm->uprobes_xol_area) {
>> > + =A0 =A0 =A0 =A0 =A0 ret =3D -EALREADY;
>> > + =A0 =A0 =A0 =A0 =A0 goto fail;
>> > + =A0 }
>> > +
>> > + =A0 /*
>> > + =A0 =A0* Find the end of the top mapping and skip a page.
>> > + =A0 =A0* If there is no space for PAGE_SIZE above
>> > + =A0 =A0* that, mmap will ignore our address hint.
>> > + =A0 =A0*
>> > + =A0 =A0* We allocate a "fake" unlinked shmem file because
>> > + =A0 =A0* anonymous memory might not be granted execute
>> > + =A0 =A0* permission when the selinux security hooks have
>> > + =A0 =A0* their way.
>> > + =A0 =A0*/
>>
>> That just annoys me, so we're working around some stupid sekurity crap,
>> executable anonymous maps are perfectly fine, also what do JITs do?
>
> Yes, we are working around selinux security hooks, but do we have a
> choice.
>
> James can you please comment on this.

[added myself and stephen, the 2 SELinux maintainers]

This is just wrong.  Anything to 'work around' SELinux in the kernel
is wrong.  SELinux access decisions are determined by policy not by
dirty hacks in the code to subvert any kind of security claims that
policy might hope to enforce.

[side note, security_file_mmap() is the right call if there is a file
or not.  It should just be called security_mmap() but the _file_ has
been around a long time and just never had a need to be changed]

Now how to fix the problems you were seeing.  If you run a modern
system with a GUI I'm willing to bet the pop-up window told you
exactly how to fix your problem.  If you are not on a GUI I accept
it's a more difficult as you most likely don't have the setroubleshoot
tools installed to help you out.  I'm just guess what your problem
was, but I think you have two solutions either:

1) chcon -t unconfined_execmem_t /path/to/your/binary
2) setsebool -P allow_execmem 1

The first will cause the binary to execute in a domain with
permissions to execute anonymous memory, the second will allow all
unconfined domains to execute anonymous memory.

I believe there was a question about how JIT's work with SELinux
systems.  They work mostly by method #1.

I did hear this question though: On a different but related note, how
is the use of uprobes controlled? Does it apply the same checking as
for ptrace?

Thanks guys!  If you have SELinux or LSM problems in the future let me
know.  It's likely the solution is easier than you imagine   ;)

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
