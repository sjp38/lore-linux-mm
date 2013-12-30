Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f48.google.com (mail-qe0-f48.google.com [209.85.128.48])
	by kanga.kvack.org (Postfix) with ESMTP id BB5896B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 15:38:04 -0500 (EST)
Received: by mail-qe0-f48.google.com with SMTP id gc15so11642279qeb.21
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 12:38:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t7si43240582qar.91.2013.12.30.12.38.02
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 12:38:03 -0800 (PST)
Date: Mon, 30 Dec 2013 18:23:42 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep
 syscall
Message-ID: <20131230202342.GA7973@amt.cnet>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
 <20130509141329.GC11497@suse.de>
 <518C5B5E.4010706@gmail.com>
 <CAJSP0QULp5c3tWwZ4ipWn6wS3YWauE07Bmd8nzjp8CJhWaD_oQ@mail.gmail.com>
 <52AFE828.3010500@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <52AFE828.3010500@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Stefan Hajnoczi <stefanha@gmail.com>, wenchao <wenchaolinux@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, walken@google.com, Alexander Viro <viro@zeniv.linux.org.uk>, kirill.shutemov@linux.intel.com, Anthony Liguori <anthony@codemonkey.ws>, KVM <kvm@vger.kernel.org>

On Tue, Dec 17, 2013 at 01:59:04PM +0800, Xiao Guangrong wrote:
> 
> CCed KVM guys.
> 
> On 05/10/2013 01:11 PM, Stefan Hajnoczi wrote:
> > On Fri, May 10, 2013 at 4:28 AM, wenchao <wenchaolinux@gmail.com> wrote:
> >> ao? 2013-5-9 22:13, Mel Gorman a??e??:
> >>
> >>> On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
> >>>>
> >>>> From: Wenchao Xia <wenchaolinux@gmail.com>
> >>>>
> >>>>    This serial try to enable mremap syscall to cow some private memory
> >>>> region,
> >>>> just like what fork() did. As a result, user space application would got
> >>>> a
> >>>> mirror of those region, and it can be used as a snapshot for further
> >>>> processing.
> >>>>
> >>>
> >>> What not just fork()? Even if the application was threaded it should be
> >>> managable to handle fork just for processing the private memory region
> >>> in question. I'm having trouble figuring out what sort of application
> >>> would require an interface like this.
> >>>
> >>   It have some troubles: parent - child communication, sometimes
> >> page copy.
> >>   I'd like to snapshot qemu guest's RAM, currently solution is:
> >> 1) fork()
> >> 2) pipe guest RAM data from child to parent.
> >> 3) parent write down the contents.
> >>
> >>   To avoid complex communication for data control, and file content
> >> protecting, So let parent instead of child handling the data with
> >> a pipe, but this brings additional copy(). I think an explicit API
> >> cow mapping an memory region inside one process, could avoid it,
> >> and faster and cow less pages, also make user space code nicer.
> > 
> > A new Linux-specific API is not portable and not available on existing
> > hosts.  Since QEMU supports non-Linux host operating systems the
> > fork() approach is preferable.
> > 
> > If you're worried about the memory copy - which should be benchmarked
> > - then vmsplice(2) can be used in the child process and splice(2) can
> > be used in the parent.  It probably doesn't help though since QEMU
> > scans RAM pages to find all-zero pages before sending them over the
> > socket, and at that point the memory copy might not make much
> > difference.
> > 
> > Perhaps other applications can use this new flag better, but for QEMU
> > I think fork()'s portability is more important than the convenience of
> > accessing the CoW pages in the same process.
> 
> Yup, I agree with you that the new syscall sometimes is not a good solution.
> 
> Currently, we're working on live-update[1] that will be enabled on Qemu firstly,
> this feature let the guest run on the new Qemu binary smoothly without
> restart, it's good for us to do security-update.
> 
> In this case, we need to move the guest memory on old qemu instance to the
> new one, fork() can not help because we need to exec() a new instance, after
> that all memory mapping will be destroyed.
> 
> We tried to enable SPLICE_F_MOVE[2] for vmsplice() to move the memory without
> memory-copy but the performance isn't so good as we expected: it's due to
> some limitations: the page-size, lock, message-size limitation on pipe, etc.
> Of course, we will continue to improve this, but wenchao's patch seems a new
> direction for us.
> 
> To coordinate with your fork() approach, maybe we can introduce a new flag
> for VMA, something like: VM_KEEP_ONEXEC, to tell exec() to do not destroy
> this VMA. How about this or you guy have new idea? Really appreciate for your
> suggestion.
> 
> [1] http://marc.info/?l=qemu-devel&m=138597598700844&w=2
> [2] https://lkml.org/lkml/2013/10/25/285

Hi,

What is the purpose of snapshotting guest RAM here, in the context of
local migration?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
