Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 906456B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 00:05:03 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so163919497pab.0
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 21:05:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id wp3si12705950pab.160.2015.11.07.21.05.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Nov 2015 21:05:02 -0800 (PST)
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1446896665-21818-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<CAHp75VfuH3oBSTmz1ww=H=q0btxBft+Z2Rdzav3VHHZypk6GVQ@mail.gmail.com>
	<CAHp75Vds+xA+Mtb1rCM8ALsgiGmY3MeYs=HjYuaFzSyH1L_C0A@mail.gmail.com>
In-Reply-To: <CAHp75Vds+xA+Mtb1rCM8ALsgiGmY3MeYs=HjYuaFzSyH1L_C0A@mail.gmail.com>
Message-Id: <201511081404.HGJ65681.LOSJFOtMFOVHFQ@I-love.SAKURA.ne.jp>
Date: Sun, 8 Nov 2015 14:04:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andy.shevchenko@gmail.com, julia@diku.dk, joe@perches.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andy Shevchenko wrote:
> Like Joe noticed you have left few places like
> void my_func_kvfree(arg)
> {
> kvfree(arg);
> }
>
> Might make sense to remove them completely, especially in case when
> you have changed the callers.

I think we should stop at

#define my_func_kvfree(arg) kvfree(arg)

in case someone want to add some code in future.

Also, we might want to add a helper that does vmalloc() when
kmalloc() failed because locations that do

  ptr = kmalloc(size, GFP_NOFS);
  if (!ptr)
      ptr = vmalloc(size); /* Wrong because GFP_KERNEL is used implicitly */

are found.

> One more thought. Might be good to provide a coccinelle script for
> such places? Julia?

Welcome. I'm sure I'm missing some locations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
