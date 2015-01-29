Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 191D56B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 00:28:36 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so34505812pac.13
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 21:28:35 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id hl8si8384094pad.210.2015.01.28.21.28.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 21:28:35 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so34474094pab.12
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 21:28:34 -0800 (PST)
Date: Thu, 29 Jan 2015 14:28:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150129052827.GB25462@blaptop>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150129022241.GA2555@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Thu, Jan 29, 2015 at 11:22:41AM +0900, Sergey Senozhatsky wrote:
> On (01/29/15 11:01), Minchan Kim wrote:
> > On Thu, Jan 29, 2015 at 10:57:38AM +0900, Sergey Senozhatsky wrote:
> > > On Thu, Jan 29, 2015 at 8:33 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > > On Wed, Jan 28, 2015 at 11:56:51PM +0900, Sergey Senozhatsky wrote:
> > > > > I don't like re-introduced ->init_done.
> > > > > another idea... how about using `zram->disksize == 0' instead of
> > > > > `->init_done' (previously `->meta != NULL')? should do the trick.
> > > >
> > > > It could be.
> > > >
> > > >
> > > care to change it?
> > 
> > Will try!
> > 
> > If it was your concern, I'm happy to remove the check.(ie, actually,
> > I realized that after I push the button to send). Thanks!
> > 
> 
> Thanks a lot, Minchan.
> 
> and, guys, sorry for previous html email (I'm sure I toggled the "plain
> text" mode in gmail web-interface, but somehow it has different meaning
> in gmail world).
> 
> 
> I'm still concerned about performance numbers that I see on my x86_64.
> it's not always, but mostly slower. I'll give it another try (disable
> lockdep, etc.), but if we lose 10% on average then, sorry, I'm not so
> positive about srcu change and will tend to vote for your initial commit
> that simply moved meta free() out of init_lock and left locking as is
> (lockdep warning would have been helpful there, because otherwise it
> just looked like we change code w/o any reason).
> 
> what do you thunk?

Surely I agreee with you. If it suffers from 10% performance regression,
it's absolutely no go.

However, I believe it should be no loss because that's one of the reason
from RCU birth which should be really win in read-side lock path compared
to other locking.

Please test it with dd or something for block-based test for removing
noise from FS. I also will test it to confirm that with real machine.

Thanks for the review!



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
