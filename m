Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id CD2D56B005C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 13:48:50 -0500 (EST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 11 Jan 2012 00:18:47 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0AImaK93924006
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 00:18:38 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0AIma0s001842
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 05:48:36 +1100
Message-ID: <4F0C8801.3090102@linux.vnet.ibm.com>
Date: Wed, 11 Jan 2012 00:18:33 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Linux-3.2.0 Pid: 1902, comm: modprobe Not tainted 3.2.0 #64
References: <CAAJw_Zt4WvTbnw+qxR-+tGCHZ9APkk0Cp0gTMRbdtTN58_udQg@mail.gmail.com>
In-Reply-To: <CAAJw_Zt4WvTbnw+qxR-+tGCHZ9APkk0Cp0gTMRbdtTN58_udQg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Chua <jeff.chua.linux@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Greg Kroah-Hartman <gregkh@suse.de>, Linux PM mailing list <linux-pm@vger.kernel.org>, mgorman@suse.de, linux-mm@kvack.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>

On 01/08/2012 08:48 PM, Jeff Chua wrote:

> Latest git pull commit at 02550d61f49266930e674286379d3601006b2893.
> Got several of these messages in dmesg ...
> 


Can you please turn on CONFIG_FRAME_POINTER, so that we get more reliable
stack traces? Also, more human-readable stack traces would definitely help..

> vmalloc: allocation failure: 0 bytes
> modprobe: page allocation failure: order:0, mode:0xd2
> Pid: 1902, comm: modprobe Not tainted 3.2.0 #64
> Call Trace:
> [<ffffffff8107e954>] ? 0xffffffff8107e954
> [<ffffffff8105e423>] ? 0xffffffff8105e423
> [<ffffffff8109cddf>] ? 0xffffffff8109cddf
> [<ffffffff8105e423>] ? 0xffffffff8105e423
> [<ffffffff8101bc5c>] ? 0xffffffff8101bc5c
> [<ffffffff8105e423>] ? 0xffffffff8105e423
> [<ffffffff8105e423>] ? 0xffffffff8105e423
> [<ffffffff8105f33f>] ? 0xffffffff8105f33f
> [<ffffffff8105fc58>] ? 0xffffffff8105fc58
> [<ffffffff814e9639>] ? 0xffffffff814e9639
> Mem-Info:
> 
> 
> ------------[ cut here ]------------
> WARNING: at drivers/base/core.c:194 0xffffffff8129298b()
> Hardware name: 5413FGA
> Device 'machinecheck1' does not have a release() function, it is
> broken and must be fixed.
> Modules linked in: i915 drm_kms_helper
> Pid: 2352, comm: power Not tainted 3.2.0 #64
> Call Trace:
> [<ffffffff8102a0ac>] ? 0xffffffff8102a0ac
> [<ffffffff8102a15f>] ? 0xffffffff8102a15f
> [<ffffffff814e8a69>] ? 0xffffffff814e8a69
> [<ffffffff810fd353>] ? 0xffffffff810fd353
> [<ffffffff8129298b>] ? 0xffffffff8129298b
> [<ffffffff811e4b29>] ? 0xffffffff811e4b29
> [<ffffffff814e144d>] ? 0xffffffff814e144d
> [<ffffffff81044c72>] ? 0xffffffff81044c72
> [<ffffffff8102b717>] ? 0xffffffff8102b717
> [<ffffffff8102b74c>] ? 0xffffffff8102b74c
> [<ffffffff814c701d>] ? 0xffffffff814c701d
> [<ffffffff814c7110>] ? 0xffffffff814c7110
> [<ffffffff814c901d>] ? 0xffffffff814c901d
> [<ffffffff810fc424>] ? 0xffffffff810fc424
> [<ffffffff810b26cc>] ? 0xffffffff810b26cc
> [<ffffffff810b2803>] ? 0xffffffff810b2803
> [<ffffffff814e9639>] ? 0xffffffff814e9639
> ---[ end trace 78b4393914412b97 ]---
> 
> ------------[ cut here ]------------
> WARNING: at arch/x86/kernel/smp.c:119 0xffffffff8103476f()


This looks like the IPI to offline CPU issue.

static void native_smp_send_reschedule(int cpu)
{
        if (unlikely(cpu_is_offline(cpu))) {
                WARN_ON(1);  <============
...
}

> Hardware name: 5413FGA
> Modules linked in: i915 drm_kms_helper
> Pid: 1693, comm: rs:main Q:Reg Tainted: G        W    3.2.0 #64
> Call Trace:
> <IRQ>  [<ffffffff8102a0ac>] ? 0xffffffff8102a0ac
> [<ffffffff8105857d>] ? 0xffffffff8105857d
> [<ffffffff8103476f>] ? 0xffffffff8103476f
> [<ffffffff810585dc>] ? 0xffffffff810585dc
> [<ffffffff8104376d>] ? 0xffffffff8104376d
> [<ffffffff81043a2e>] ? 0xffffffff81043a2e
> [<ffffffff81018fe6>] ? 0xffffffff81018fe6
> [<ffffffff814ea05e>] ? 0xffffffff814ea05e
> <EOI>  [<ffffffff814e9639>] ? 0xffffffff814e9639
> ---[ end trace 78b4393914412b98 ]---
> 
> ------------[ cut here ]------------
> WARNING: at drivers/base/core.c:194 0xffffffff8129298b()
> Hardware name: 5413FGA
> Device 'machinecheck3' does not have a release() function, it is
> broken and must be fixed.
> Modules linked in: i915 drm_kms_helper
> Pid: 2352, comm: power Tainted: G        W    3.2.0 #64
> Call Trace:
> [<ffffffff8102a0ac>] ? 0xffffffff8102a0ac
> [<ffffffff8102a15f>] ? 0xffffffff8102a15f
> [<ffffffff814e8a69>] ? 0xffffffff814e8a69
> [<ffffffff810fd353>] ? 0xffffffff810fd353
> [<ffffffff8129298b>] ? 0xffffffff8129298b
> [<ffffffff811e4b29>] ? 0xffffffff811e4b29
> [<ffffffff814e144d>] ? 0xffffffff814e144d
> [<ffffffff81044c72>] ? 0xffffffff81044c72
> [<ffffffff8102b717>] ? 0xffffffff8102b717
> [<ffffffff8102b74c>] ? 0xffffffff8102b74c
> [<ffffffff814c701d>] ? 0xffffffff814c701d
> [<ffffffff814c7110>] ? 0xffffffff814c7110
> [<ffffffff814c901d>] ? 0xffffffff814c901d
> [<ffffffff810fc424>] ? 0xffffffff810fc424
> [<ffffffff810b26cc>] ? 0xffffffff810b26cc
> [<ffffffff810b2803>] ? 0xffffffff810b2803
> [<ffffffff814e9639>] ? 0xffffffff814e9639
> ---[ end trace 78b4393914412b9a ]---
> 
> ------------[ cut here ]------------
> WARNING: at arch/x86/kernel/smp.c:119 0xffffffff8103476f()


Same here.

> Hardware name: 5413FGA
> Modules linked in: i915 drm_kms_helper
> Pid: 2503, comm: default.hotplug Tainted: G        W    3.2.0 #64
> Call Trace:
> <IRQ>  [<ffffffff8102a0ac>] ? 0xffffffff8102a0ac
> [<ffffffff8103476f>] ? 0xffffffff8103476f
> [<ffffffff810578ba>] ? 0xffffffff810578ba
> [<ffffffff81018fe6>] ? 0xffffffff81018fe6
> [<ffffffff814ea05e>] ? 0xffffffff814ea05e
> <EOI>  [<ffffffff811ead77>] ? 0xffffffff811ead77
> [<ffffffff8107f0e4>] ? 0xffffffff8107f0e4
> [<ffffffff8107f49d>] ? 0xffffffff8107f49d
> [<ffffffff8107f49d>] ? 0xffffffff8107f49d
> [<ffffffff81049aaf>] ? 0xffffffff81049aaf
> [<ffffffff8108f37b>] ? 0xffffffff8108f37b
> [<ffffffff81023b9c>] ? 0xffffffff81023b9c
> [<ffffffff81049aaf>] ? 0xffffffff81049aaf
> [<ffffffff8108f46d>] ? 0xffffffff8108f46d
> [<ffffffff8108ee8c>] ? 0xffffffff8108ee8c
> [<ffffffff810927e1>] ? 0xffffffff810927e1
> [<ffffffff81020bd6>] ? 0xffffffff81020bd6
> [<ffffffff810905b2>] ? 0xffffffff810905b2
> [<ffffffff811e693f>] ? 0xffffffff811e693f
> [<ffffffff81089d6b>] ? 0xffffffff81089d6b
> [<ffffffff810958a7>] ? 0xffffffff810958a7
> [<ffffffff814e91b5>] ? 0xffffffff814e91b5
> [<ffffffff811ec547>] ? 0xffffffff811ec547
> [<ffffffff810ebd53>] ? 0xffffffff810ebd53
> [<ffffffff810ece0a>] ? 0xffffffff810ece0a
> [<ffffffff810b722c>] ? 0xffffffff810b722c
> [<ffffffff810b2942>] ? 0xffffffff810b2942
> [<ffffffff810ec129>] ? 0xffffffff810ec129
> [<ffffffff810ebc56>] ? 0xffffffff810ebc56
> [<ffffffff810b6d25>] ? 0xffffffff810b6d25
> [<ffffffff81047c2d>] ? 0xffffffff81047c2d
> [<ffffffff810b722c>] ? 0xffffffff810b722c
> [<ffffffff810eba94>] ? 0xffffffff810eba94
> [<ffffffff810b8913>] ? 0xffffffff810b8913
> [<ffffffff81035614>] ? 0xffffffff81035614
> [<ffffffff81009015>] ? 0xffffffff81009015
> [<ffffffff814e99fc>] ? 0xffffffff814e99fc
> ---[ end trace 78b4393914412b9b ]---
> 
> ------------[ cut here ]------------
> WARNING: at arch/x86/kernel/smp.c:119 0xffffffff8103476f()


And here as well.

> Hardware name: 5413FGA
> Modules linked in: i915 drm_kms_helper
> Pid: 0, comm: swapper/2 Tainted: G        W    3.2.0 #64
> Call Trace:
> <IRQ>  [<ffffffff8102a0ac>] ? 0xffffffff8102a0ac
> [<ffffffff8103476f>] ? 0xffffffff8103476f
> [<ffffffff810578ba>] ? 0xffffffff810578ba
> [<ffffffff81018fe6>] ? 0xffffffff81018fe6
> [<ffffffff814ea05e>] ? 0xffffffff814ea05e
> <EOI>  [<ffffffff81220708>] ? 0xffffffff81220708
> [<ffffffff812206eb>] ? 0xffffffff812206eb
> [<ffffffff813d1f9d>] ? 0xffffffff813d1f9d
> [<ffffffff81001501>] ? 0xffffffff81001501
> ---[ end trace 78b4393914412b9c ]---
> 
> 
> Now suspend/resume seems to broken again!
>


In what sense? Does it suspend successfully but fail to resume?
Or is it that it doesn't even suspend reliably?

Can you kindly try out the pm_test framework (see
Documentation/power/basic-pm-debugging.txt)?
That helps in debugging suspend related issues.

 
> Was very stable pre-3.2.0.
> 


Ok, so that means we can do a git-bisect in case nothing else
works out.

Regards,
Srivatsa S. Bhat
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
