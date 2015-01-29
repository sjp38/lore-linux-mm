Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E7B9A6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 01:35:15 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so35221001pad.1
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 22:35:15 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id cl8si8510691pdb.257.2015.01.28.22.35.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 22:35:15 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so35220838pad.1
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 22:35:14 -0800 (PST)
Date: Thu, 29 Jan 2015 15:35:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150129063505.GA32331@blaptop>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150129060604.GC2555@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Thu, Jan 29, 2015 at 03:06:04PM +0900, Sergey Senozhatsky wrote:
> On (01/29/15 14:28), Minchan Kim wrote:
> > > I'm still concerned about performance numbers that I see on my x86_64.
> > > it's not always, but mostly slower. I'll give it another try (disable
> > > lockdep, etc.), but if we lose 10% on average then, sorry, I'm not so
> > > positive about srcu change and will tend to vote for your initial commit
> > > that simply moved meta free() out of init_lock and left locking as is
> > > (lockdep warning would have been helpful there, because otherwise it
> > > just looked like we change code w/o any reason).
> > > 
> > > what do you thunk?
> > 
> > Surely I agreee with you. If it suffers from 10% performance regression,
> > it's absolutely no go.
> > 
> > However, I believe it should be no loss because that's one of the reason
> > from RCU birth which should be really win in read-side lock path compared
> > to other locking.
> > 
> > Please test it with dd or something for block-based test for removing
> > noise from FS. I also will test it to confirm that with real machine.
> > 
> 
> do you test with a single dd thread/process?  just dd if=foo of=bar -c... or
> you start N `dd &' processes?

I tested it with multiple dd processes.

> 
> for a single writer there should be no difference, no doubt. I'm more
> interested in multi-writer/multi-reader/mixed use cases.
> 
> the options that I use are: iozone -t 3 -R -r 16K -s 60M -I +Z
> and -I is:
> 	-I  Use VxFS VX_DIRECT, O_DIRECT,or O_DIRECTIO for all file operations
> 
> with O_DIRECT I don't think there is a lot of noise, but I'll try to use
> different benchmarks a bit later.
> 

As you told, the data was not stable.
Anyway, when I read down_read implementation, it's one atomic instruction.
Hmm, it seems te be better for srcu_read_lock which does more things.
But I guessed most of overhead are from [de]compression, memcpy, clear_page
That's why I guessed we don't have measurable difference from that.
What's the data pattern if you use iozone? I guess it's really simple
pattern compressor can do fast. I used /dev/sda for dd write so
more realistic data. Anyway, if we has 10% regression even if the data
is simple, I never want to merge it.
I will test it carefully and if it turns out lots regression,
surely, I will not go with this and send the original patch again.

Thanks.

> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
