Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 600516B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 02:37:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p5so20357583pgn.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 23:37:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h12si9616355plt.673.2017.10.02.23.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 23:37:05 -0700 (PDT)
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
References: <20170905194739.GA31241@amd> <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd>
 <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <CACRpkdYirC+rh_KALgVqKZMjq2DgbW4oi9MJkmrzwn+1O+94-g@mail.gmail.com>
From: Adrian Hunter <adrian.hunter@intel.com>
Message-ID: <7b423dc8-00aa-9cde-3557-8c72863001fd@intel.com>
Date: Tue, 3 Oct 2017 09:30:18 +0300
MIME-Version: 1.0
In-Reply-To: <CACRpkdYirC+rh_KALgVqKZMjq2DgbW4oi9MJkmrzwn+1O+94-g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Pavel Machek <pavel@ucw.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org

On 02/10/17 17:09, Linus Walleij wrote:
> On Sun, Oct 1, 2017 at 12:57 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> 
>>>> I inserted u-SD card, only to realize that it is not detected as it
>>>> should be. And dmesg indeed reveals:
>>>
>>> Tetsuo asked me to report this to linux-mm.
>>>
>>> But 2^4 is 16 pages, IIRC that can't be expected to work reliably, and
>>> thus this sounds like MMC bug, not mm bug.
> 
> 
> I'm not sure I fully understand this error message:
> "worker/2:1: page allocation failure: order:4"
> 
> What I guess from context is that the mmc_init_request()
> call is failing to allocate 16 pages, meaning for 4K pages
> 64KB which is the typical bounce buffer.
> 
> This is what the code has always allocated as bounce buffer,
> but it used to happen upfront, when probing the MMC block layer,
> rather than when allocating the requests.

That is not exactly right.  As I already wrote, the memory allocation used
to be optional but became mandatory with:

  commit 304419d8a7e9204c5d19b704467b814df8c8f5b1
  Author: Linus Walleij <linus.walleij@linaro.org>
  Date:   Thu May 18 11:29:32 2017 +0200

      mmc: core: Allocate per-request data using the block layer core

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
