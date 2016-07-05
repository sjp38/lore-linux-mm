Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE40E6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 21:00:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so419598975pfa.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:00:24 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id ly10si1130233pab.55.2016.07.04.18.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 18:00:23 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id ib6so876343pad.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:00:23 -0700 (PDT)
Date: Tue, 5 Jul 2016 10:00:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 7/8] mm/zsmalloc: add __init,__exit attribute
Message-ID: <20160705010028.GA459@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-7-git-send-email-opensource.ganesh@gmail.com>
 <20160704084347.GG898@swordfish>
 <CADAEsF91-j-DDXt63-dtG77Q5uowb8hdvT2Zk54B74XwDxFCxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF91-j-DDXt63-dtG77Q5uowb8hdvT2Zk54B74XwDxFCxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, rostedt@goodmis.org, mingo@redhat.com

Hello Ganesh,

On (07/04/16 17:21), Ganesh Mahendran wrote:
> > On (07/04/16 14:49), Ganesh Mahendran wrote:
> > [..]
> >> -static void zs_unregister_cpu_notifier(void)
> >> +static void __exit zs_unregister_cpu_notifier(void)
> >>  {
> >
> > this __exit symbol is called from `__init zs_init()' and thus is
> > free to crash.
> 
> I change code to force the code goto notifier_fail where the
> zs_unregister_cpu_notifier will be called.
> I tested with zsmalloc module buildin and built as a module.

sorry, not sure I understand what do you mean by this.


> Please correct me, if I miss something.

you have an __exit section function being called from
__init section:

static void __exit zs_unregister_cpu_notifier(void)
{
}

static int __init zs_init(void)
{
	zs_unregister_cpu_notifier();
}

it's no good.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
