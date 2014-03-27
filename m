Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id D83196B0036
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 17:34:09 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id jy13so1737405veb.30
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 14:34:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140327205749.GM17679@kvack.org>
References: <20140327134653.GA22407@kvack.org>
	<CA+55aFzFgY4-26SO-MsFagzaj9JevkeeT1OJ3pjj-tcjuNCEeQ@mail.gmail.com>
	<CA+55aFx7vg2rvOu6Bu_e8+BB=ymoUMp0AM9JmAuUuSgo0LVEwg@mail.gmail.com>
	<20140327200851.GL17679@kvack.org>
	<CA+55aFy_sRnFu7KguAUAN5kbHk3Qa_0ZuATPU5i8LOyMMWZ_5g@mail.gmail.com>
	<20140327205749.GM17679@kvack.org>
Date: Thu, 27 Mar 2014 14:34:08 -0700
Message-ID: <CA+55aFyj2XFMkT1T=EPPw1CANt6atyFNmMaeaDm-p-NWfRNA+w@mail.gmail.com>
Subject: Re: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is
 correctly serialised
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Thu, Mar 27, 2014 at 1:57 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> *nod* -- I added that to the below variant.

You still have "goto err" for cases that have the ctx locked. Which
means that the thing gets free'd while still locked, which causes
problems for lockdep etc, so don't do it.

Do what I did: add a "err_unlock" label, and make anybody after the
mutex_lock() call it. No broken shortcuts.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
