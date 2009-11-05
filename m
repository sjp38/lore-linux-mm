Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A48A6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 08:21:18 -0500 (EST)
Date: Thu, 5 Nov 2009 14:21:09 +0100
Subject: Re: OOM killer, page fault
Message-ID: <20091105132109.GA12676@gamma.logic.tuwien.ac.at>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at> <20091102005218.8352.A69D9226@jp.fujitsu.com> <20091102135640.93de7c2a.minchan.kim@barrios-desktop> <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com> <20091102155543.E60E.A69D9226@jp.fujitsu.com> <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com> <20091102141917.GJ2116@gamma.logic.tuwien.ac.at> <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com>
From: Norbert Preining <preining@logic.at>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Kim, hi all,

(still please Cc)

sorry for the late reply. I have two news, one good and one bad: The good
being that I can reproduce the bug by running VirtualBox with some W7
within. Anyway, I don't have a trace or better debug due to the bad news:
Both 2.6.32-rc5 and 2.6.32-rc6 do *not* boot with the patch below.
Don't ask me why, please, and I don't have a serial/net console so that
I can tell you more, but the booting hangs badly at:
[    6.657492] usb 4-1: Product: Globetrotter HSDPA Modem
[    6.657494] usb 4-1: Manufacturer: Option N.V.
[    6.657496] usb 4-1: SerialNumber: Serial Number
[    6.657558] usb 4-1: configuration #1 chosen from 1 choice
[    6.837364] input: PS/2 Mouse as /devices/platform/i8042/serio2/input/input6
[    6.853693] input: AlpsPS/2 ALPS GlidePoint as /devices/platform/i8042/serio2/input/input7

Normally it continues like that, but with the patch below it hangs here
and does not continue. I need to Sysrq-s/u/b out of it.

[    6.904119] usb 8-2: new full speed USB device using uhci_hcd and address 2
[    7.075524] usb 8-2: New USB device found, idVendor=044e, idProduct=3017

> diff --git a/mm/memory.c b/mm/memory.c
> index 7e91b5f..47e4b15 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2713,7 +2713,11 @@ static int __do_fault(struct mm_struct *mm,
> struct vm_area_struct *vma,
>        vmf.page = NULL;
> 
>        ret = vma->vm_ops->fault(vma, &vmf);
> -       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> +       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
> +               printk(KERN_DEBUG "vma->vm_ops->fault : 0x%lx\n",
> vma->vm_ops->fault);
> +               WARN_ON(1);
> +
> +       }
>                return ret;
> 
>        if (unlikely(PageHWPoison(vmf.page))) {

I know it sounds completely crazy, the patch only does harmless things
afais. But I tried it. Several times. rc6+patch never did boot, while
rc5 without path did boot. Then I patched it into -rc5, recompiled, and 
boom, no boot. booting into .31.5, recompiling rc6 and rc5 without 
that patch and suddenly rc6 boots (and I am sure rc5, too).

Sorry that I cannot give more infos, please let me know what else I can
do.

Ah yes, I can reproduce the original strange bug with oom killer!

Best wishes

Norbert

-------------------------------------------------------------------------------
Dr. Norbert Preining                                        Associate Professor
JAIST Japan Advanced Institute of Science and Technology   preining@jaist.ac.jp
Vienna University of Technology                               preining@logic.at
Debian Developer (Debian TeX Task Force)                    preining@debian.org
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 B094
-------------------------------------------------------------------------------
MELTON CONSTABLE (n.)
A patent anti-wrinkle cream which policemen wear to keep themselves
looking young.
			--- Douglas Adams, The Meaning of Liff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
