Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD866B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 01:08:44 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so59262591wjb.3
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 22:08:44 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id a19si11509199wmd.119.2016.12.04.22.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 22:08:42 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id u144so13579803wmu.0
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 22:08:42 -0800 (PST)
Date: Mon, 5 Dec 2016 07:08:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] hotplug: make register and unregister notifier API
 symmetric
Message-ID: <20161205060840.GC30758@dhcp22.suse.cz>
References: <20161202151935.GR6830@dhcp22.suse.cz>
 <201612031306.dkl5XlAY%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612031306.dkl5XlAY%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Dan Streetman <ddstreet@ieee.org>, Yu Zhao <yuzhao@google.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

On Sat 03-12-16 13:15:42, kbuild test robot wrote:
> Hi Michal,
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.9-rc7 next-20161202]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/hotplug-make-register-and-unregister-notifier-API-symmetric/20161203-114815
> config: i386-randconfig-r0-201648 (attached as .config)
> compiler: gcc-5 (Debian 5.4.1-2) 5.4.1 20160904
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/x86/oprofile/built-in.o: In function `nmi_timer_shutdown':
> >> nmi_timer_int.c:(.text+0x238b): undefined reference to `__unregister_cpu_notifier'
>    arch/x86/oprofile/built-in.o: In function `nmi_shutdown':
>    nmi_int.c:(.text+0x2793): undefined reference to `__unregister_cpu_notifier'

Ohh, right. I have missed that unregister functions definitions are
guarded as well. This patch should hopefully be correct finally.
Please note it also exports register/unregister callbacks when
CONFIG_HOTPLUG_CPU is not defined which is not really needed strictly
speaking because those are only used when !MODULE but I would rather
not make the code more complicated. If maintainers prefer I can guard
exports separately of course.
---
