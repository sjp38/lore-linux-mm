Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA5B6B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 06:31:26 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so62830650pad.1
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 03:31:26 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ij1si16916475pac.143.2015.01.31.03.31.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 31 Jan 2015 03:31:25 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so62661885pab.3
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 03:31:25 -0800 (PST)
Date: Sat, 31 Jan 2015 20:31:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150131113158.GB2299@swordfish>
References: <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130144145.GA2840@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

Hello Minchan,
excellent analysis!

On (01/30/15 23:41), Minchan Kim wrote:
> Yes, __srcu_read_lock is a little bit heavier but the number of instruction
> are not too much difference to make difference 10%. A culprit is
> __cond_resched but I don't think, either because our test was CPU intensive
> soS I don't think schedule latency affects total bandwidth.
> 
> More cuprit is your data pattern.
> It seems you didn't use scramble_buffers=0, zero_buffers in fio so that
> fio fills random data pattern so zram bandwidth could be different by
> compression/decompression ratio.

Completely agree.
Shame on me. gotten so used to iozone (iozone uses same data pattern 0xA5,
this is +Z option what for), so I didn't even think about data pattern
in fio. sorry.

> 1) randread
> srcu is worse as 0.63% but the difference is really marginal.
> 
> 2) randwrite
> srcu is better as 1.24% is better.
> 
> 3) randrw
> srcu is better as 2.3%

hm, interesting. I'll re-check.

> Okay, if you concerns on the data still, how about this?

I'm not so upset to lose 0.6234187%. my concerns were about iozone's
10% different (which looks a bit worse).


I'll review your patch. Thanks for your effort.


> > 
> > by "data pattern" you mean usage scenario? well, I usually use zram for
> > `make -jX', where X=[4..N]. so N concurrent read-write ops scenario.
> 
> What I meant is what data fills I/O buffer, which is really important
> to evaluate zram because the compression/decompression speeds relys on it.
> 

I see. I never test it with `make' anyway, only iozone +Z.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
