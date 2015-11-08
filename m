Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 97C4182F65
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 00:32:10 -0500 (EST)
Received: by padhx2 with SMTP id hx2so155944988pad.1
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 21:32:10 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id a2si12905880pbu.53.2015.11.07.21.32.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 21:32:09 -0800 (PST)
Received: by padhx2 with SMTP id hx2so155944821pad.1
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 21:32:09 -0800 (PST)
Date: Sun, 8 Nov 2015 14:30:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
Message-ID: <20151108053044.GA540@swordfish>
References: <1446896665-21818-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <CAHp75VfuH3oBSTmz1ww=H=q0btxBft+Z2Rdzav3VHHZypk6GVQ@mail.gmail.com>
 <CAHp75Vds+xA+Mtb1rCM8ALsgiGmY3MeYs=HjYuaFzSyH1L_C0A@mail.gmail.com>
 <201511081404.HGJ65681.LOSJFOtMFOVHFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511081404.HGJ65681.LOSJFOtMFOVHFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: andy.shevchenko@gmail.com, julia@diku.dk, joe@perches.com, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (11/08/15 14:04), Tetsuo Handa wrote:
[..]
> Also, we might want to add a helper that does vmalloc() when
> kmalloc() failed because locations that do
> 
>   ptr = kmalloc(size, GFP_NOFS);
>   if (!ptr)
>       ptr = vmalloc(size); /* Wrong because GFP_KERNEL is used implicitly */
> 
> are found.


ext4 does something like that.


void *ext4_kvmalloc(size_t size, gfp_t flags)
{
	void *ret;

	ret = kmalloc(size, flags | __GFP_NOWARN);
	if (!ret)
		ret = __vmalloc(size, flags, PAGE_KERNEL);
	return ret;
}

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
