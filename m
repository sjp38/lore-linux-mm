Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 66EB56B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 08:27:56 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id i8so7882799qcq.18
        for <linux-mm@kvack.org>; Fri, 23 May 2014 05:27:56 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id w10si3345361qad.80.2014.05.23.05.27.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 05:27:55 -0700 (PDT)
Received: by mail-qc0-f175.google.com with SMTP id w7so7906707qcr.6
        for <linux-mm@kvack.org>; Fri, 23 May 2014 05:27:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJm7N84L7fVJ5x_zPbcYhWm1KMtz3dGA=G9EW=XwBbSKMwxPnw@mail.gmail.com>
References: <CAJm7N84L7fVJ5x_zPbcYhWm1KMtz3dGA=G9EW=XwBbSKMwxPnw@mail.gmail.com>
Date: Fri, 23 May 2014 20:27:55 +0800
Message-ID: <CAJm7N87bRrP6cFhQaEp9kj2rNJhAKvLAFioh5VBx2jjDGn1DWw@mail.gmail.com>
Subject: Re: memory hot-add: the kernel can notify udev daemon before creating
 the sys file state?
From: DX Cui <rijcos@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Fri, May 23, 2014 at 5:46 PM, DX Cui <rijcos@gmail.com> wrote:
> Hi all,
> I'm debugging a strange memory hotplug issue on CentOS 6.5(2.6.32-431.17.1.el6):
> when a chunk of memory is hot-added, it seems the kernel *occasionally* can send
> a MEMORY ADD event to the udev daemon before the kernel actually creates the
> sys file 'state'!
> As a result, udev can't reliably make new memory online by this udev rule:
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}="online"
>
> Please see the end of the mail for the strace log of udevd when I run udevd
> manually:
>
> When udevd gets a MEMORY ADD event for
> /sys/devices/system/memory/memory23, it tries to write "online" to
> /sys/devices/system/memory/memory23/state, but the file hasn't been created by
> the kernel yet. In this case, when I manually check the file at once with ls, it has
> been created, and I can manually echo online into it to make it online correctly.
>
> Please note: this bad behavior of the kernel is only occasional, which may imply
> there is a race condition somewhere?
>
> BTW, it looks the issue does't exist in 3.10+ kernels. Is this a known issue
> already fixed in new kernels?

Hi all,
I think I found out the root cause: when memory hotplug was introduced in 2005:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=3947be1969a9ce455ec30f60ef51efb10e4323d1
there was a race condition in:

+ static int add_memory_block(unsigned long node_id, struct
mem_section *section,
+ unsigned long state, int phys_device)
+{
...
+ ret = register_memory(mem, section, NULL);
+ if (!ret)
+        ret = mem_create_simple_file(mem, phys_index);
+ if (!ret)
+        ret = mem_create_simple_file(mem, state);

Here, first, add_memory_block() invokes register_memory() ->
sysdev_register() -> sysdev_add()->
kobject_uevent(&sysdev->kobj, KOBJ_ADD) to notify udev daemon, then
invokes mem_create_simple_file(). If the current execution is preempted
between the 2 steps, the issue I reported in the previous mail can happen.

Luckily a commit in 2013 has fixed this issue undesignedly:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=96b2c0fc8e74a615888e2bedfe55b439aa4695e1

It looks the new "register_memory() --> ... -> device_add()" path has the
correct order for sysfs creation and notification udev.

It would be great if you can confirm my analysis. :-)

 -- DX

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
