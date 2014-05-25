Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id B737D6B0035
	for <linux-mm@kvack.org>; Sun, 25 May 2014 11:41:08 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so6456343pbc.32
        for <linux-mm@kvack.org>; Sun, 25 May 2014 08:41:08 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id qz7si11309950pbb.24.2014.05.25.08.41.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 25 May 2014 08:41:07 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so6389772pab.15
        for <linux-mm@kvack.org>; Sun, 25 May 2014 08:41:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJm7N87bRrP6cFhQaEp9kj2rNJhAKvLAFioh5VBx2jjDGn1DWw@mail.gmail.com>
References: <CAJm7N84L7fVJ5x_zPbcYhWm1KMtz3dGA=G9EW=XwBbSKMwxPnw@mail.gmail.com>
	<CAJm7N87bRrP6cFhQaEp9kj2rNJhAKvLAFioh5VBx2jjDGn1DWw@mail.gmail.com>
Date: Sun, 25 May 2014 23:41:07 +0800
Message-ID: <CAJm7N85kM7h_=ovhxutbh_rR1tukDSKcfjFA4zPWKuVtqUH0eg@mail.gmail.com>
Subject: Re: memory hot-add: the kernel can notify udev daemon before creating
 the sys file state?
From: DX Cui <rijcos@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Fri, May 23, 2014 at 8:27 PM, DX Cui <rijcos@gmail.com> wrote:
> Hi all,
> I think I found out the root cause: when memory hotplug was introduced in 2005:
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=3947be1969a9ce455ec30f60ef51efb10e4323d1
> there was a race condition in:
>
> + static int add_memory_block(unsigned long node_id, struct
> mem_section *section,
> + unsigned long state, int phys_device)
> +{
> ...
> + ret = register_memory(mem, section, NULL);
> + if (!ret)
> +        ret = mem_create_simple_file(mem, phys_index);
> + if (!ret)
> +        ret = mem_create_simple_file(mem, state);
>
> Here, first, add_memory_block() invokes register_memory() ->
> sysdev_register() -> sysdev_add()->
> kobject_uevent(&sysdev->kobj, KOBJ_ADD) to notify udev daemon, then
> invokes mem_create_simple_file(). If the current execution is preempted
> between the 2 steps, the issue I reported in the previous mail can happen.
>
> Luckily a commit in 2013 has fixed this issue undesignedly:
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=96b2c0fc8e74a615888e2bedfe55b439aa4695e1
>
> It looks the new "register_memory() --> ... -> device_add()" path has the
> correct order for sysfs creation and notification udev.
>
> It would be great if you can confirm my analysis. :-)

Any comments?
I think we need to backport the patch
96b2c0fc8e74a615888e2bedfe55b439aa4695e1 to <=3.9 stable kernels.

-- DX

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
