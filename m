Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A404828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 22:47:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so484617070pfb.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 19:47:44 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 66si1573234pfe.135.2016.07.05.19.47.43
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 19:47:43 -0700 (PDT)
Date: Wed, 6 Jul 2016 11:48:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 7/8] mm/zsmalloc: add __init,__exit attribute
Message-ID: <20160706024830.GG13566@bbox>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-7-git-send-email-opensource.ganesh@gmail.com>
 <20160704084347.GG898@swordfish>
 <CADAEsF91-j-DDXt63-dtG77Q5uowb8hdvT2Zk54B74XwDxFCxQ@mail.gmail.com>
 <20160705010028.GA459@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160705010028.GA459@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, rostedt@goodmis.org, mingo@redhat.com

On Tue, Jul 05, 2016 at 10:00:28AM +0900, Sergey Senozhatsky wrote:
> Hello Ganesh,
> 
> On (07/04/16 17:21), Ganesh Mahendran wrote:
> > > On (07/04/16 14:49), Ganesh Mahendran wrote:
> > > [..]
> > >> -static void zs_unregister_cpu_notifier(void)
> > >> +static void __exit zs_unregister_cpu_notifier(void)
> > >>  {
> > >
> > > this __exit symbol is called from `__init zs_init()' and thus is
> > > free to crash.
> > 
> > I change code to force the code goto notifier_fail where the
> > zs_unregister_cpu_notifier will be called.
> > I tested with zsmalloc module buildin and built as a module.
> 
> sorry, not sure I understand what do you mean by this.

It seems he tested it both builtin and module with simulating to fail
zs_register_cpu_notifier so that finally called zs_unergister_cpu_notifier.
With that, he cannot find any problem.
> 

> 
> > Please correct me, if I miss something.
> 
> you have an __exit section function being called from
> __init section:
> 
> static void __exit zs_unregister_cpu_notifier(void)
> {
> }
> 
> static int __init zs_init(void)
> {
> 	zs_unregister_cpu_notifier();
> }
> 
> it's no good.

Agree.

I didn't look at linker script how to handle it. Although it works well,
it would be not desirable to mark __exit to the function we already
know it would be called from non-exit functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
