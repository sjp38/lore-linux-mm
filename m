Received: by wx-out-0506.google.com with SMTP id h31so2221829wxd.11
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 20:02:37 -0800 (PST)
Message-ID: <8bd0f97a0802192002o3446901dh9140dd166af0f1e@mail.gmail.com>
Date: Tue, 19 Feb 2008 23:02:35 -0500
From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] procfs task exe symlink
In-Reply-To: <1203458065.7408.27.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1202348669.9062.271.camel@localhost.localdomain>
	 <8bd0f97a0802160412ve49103cya446b89d8560458b@mail.gmail.com>
	 <1203458065.7408.27.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Bryan Wu <Bryan.Wu@analog.com>
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 4:54 PM, Matt Helsley <matthltc@us.ibm.com> wrote:
> On Sat, 2008-02-16 at 07:12 -0500, Mike Frysinger wrote:
> > On Feb 6, 2008 8:44 PM, Matt Helsley <matthltc@us.ibm.com> wrote:
> > > The kernel implements readlink of /proc/pid/exe by getting the file from the
> > > first executable VMA. Then the path to the file is reconstructed and reported as
> > > the result.
> > >
> > > Because of the VMA walk the code is slightly different on nommu systems. This
> > > patch avoids separate /proc/pid/exe code on nommu systems. Instead of walking
> > > the VMAs to find the first executable file-backed VMA we store a reference to
> > > the exec'd file in the mm_struct.
> > >
> > > That reference would prevent the filesystem holding the executable file from
> > > being unmounted even after unmapping the VMAs. So we track the number of
> > > VM_EXECUTABLE VMAs and drop the new reference when the last one is unmapped.
> > > This avoids pinning the mounted filesystem.
> > >
> > > Andrew, these are the updates I promised. Please consider this patch for
> > > inclusion in -mm.
> >
> > mm/nommu.c wasnt compiled tested, it's trivially broken:
>
> Thanks for the report. I've looked into this and the "obvious" fix,
> using vma->vm_mm, isn't correct since it's never set. This means the
> portions of the procfs task exe symlink patch using vma->vm_mm in
> mm/nommu.c are incorrect.
>
> The patch below attempts to fix this by using current->mm during mmap
> and passing the current mm to put_vma() as well.
>
> Mike, does this patch fix the compile problem(s)?

thanks, that does fix compiling.

> Mike, I don't have a nommu compile or test environment. I have yet
> to to generate a good CONFIG_MMU=n config on i386 (got one?). Since I
> don't have any nommu hardware I'm also looking into using qemu. It looks
> like I may need to build my own image from scratch. Do you have any
> recommendations on testing nommu configs without hardware?

it should be easy to cross-compile a kernel for the Blackfin
processor, but there is no qemu port.  the Blackfin port is the only
one ive done with no-mmu, so i cant comment on any other port.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
