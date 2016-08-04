Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9468C6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 16:08:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so480871798pfg.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 13:08:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n11si16130155pfj.141.2016.08.04.13.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 13:08:04 -0700 (PDT)
Date: Thu, 4 Aug 2016 13:08:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add restriction when memory_hotplug config enable
Message-Id: <20160804130803.de357aa080482bc3977c77ce@linux-foundation.org>
In-Reply-To: <57A186C6.9050301@huawei.com>
References: <1470063651-29519-1-git-send-email-zhongjiang@huawei.com>
	<20160801125417.ece9c623f03d952a60113a3f@linux-foundation.org>
	<57A078B1.6060408@virtuozzo.com>
	<57A186C6.9050301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On Wed, 3 Aug 2016 13:53:10 +0800 zhong jiang <zhongjiang@huawei.com> wrote:

> On 2016/8/2 18:40, Andrey Ryabinin wrote:
> >
> > On 08/01/2016 10:54 PM, Andrew Morton wrote:
> >> On Mon, 1 Aug 2016 23:00:51 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
> >>
> >>> From: zhong jiang <zhongjiang@huawei.com>
> >>>
> >>> At present, It is obvious that memory online and offline will fail
> >>> when KASAN enable,
> >> huh, I didn't know that.
> > Ahem... https://lkml.kernel.org/r/<20150130133552.580f73b97a9bd007979b5419@linux-foundation.org>
> >
> > Also
> >
> > commit 786a8959912eb94fc2381c2ae487a96ce55dabca
> >     kasan: disable memory hotplug
> >     
> >     Currently memory hotplug won't work with KASan.  As we don't have shadow
> >     for hotplugged memory, kernel will crash on the first access to it.  To
> >     make this work we will need to allocate shadow for new memory.
> >     
> >     At some future point proper memory hotplug support will be implemented.
> >     Until then, print a warning at startup and disable memory hot-add.
> >
> >
> >
> >> What's the problem and are there plans to fix it?
> > Nobody complained, so I didn't bother to fix it.
> > The fix for this should be simple, I'll look into this.
> >
> >>>  therefore, it is necessary to add the condition
> >>> to limit the memory_hotplug when KASAN enable.
> >>>
> > I don't understand why we need Kconfig dependency.
> > Why is that better than runtime warn message?
>   The user rarely care about the runtime warn message when the
>   system is good running.  In fact, They are confilct with each other.
>   For me,  I know the reason. but I always forget to do so. As a result,
>   I test the memory hotplug fails again.  so, I hope to add the explicit dependency.

Yes, I think it's better to disable the configuration than to permit
people to run known-to-be-broken kernel setups - that will just cause
confusion and pointless bug reports.  Let's undo the Kconfig change
when this gets fixed up.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
