Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id B66216B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:16:43 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id l139so259481206ywe.5
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:16:43 -0800 (PST)
Received: from mail-yb0-x242.google.com (mail-yb0-x242.google.com. [2607:f8b0:4002:c09::242])
        by mx.google.com with ESMTPS id x187si380120yba.33.2016.12.01.10.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 10:16:43 -0800 (PST)
Received: by mail-yb0-x242.google.com with SMTP id h184so4129978ybb.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:16:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161201135014.jrr65ptxczplmdkn@kmo-pixel>
References: <20161128072315.GC14788@dhcp22.suse.cz> <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz> <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org> <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org> <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
 <20161130203011.GB15989@htj.duckdns.org> <20161201135014.jrr65ptxczplmdkn@kmo-pixel>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 1 Dec 2016 10:16:41 -0800
Message-ID: <CA+55aFxrwATJtaAzVCnHHaHqusDZeu8=eqffTAPFyFJk5Wn78w@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Marc MERLIN <marc@merlins.org>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, Dec 1, 2016 at 5:50 AM, Kent Overstreet
<kent.overstreet@gmail.com> wrote:
>
> That said, I'm not sure how I feel about Jens's exact approach... it seems to me
> that this can really just live within the writeback code, I don't know why it
> should involve the block layer at all. plus, if I understand correctly his code
> has the effect of blocking in generic_make_request() to throttle, which means
> due to the way the writeback code is structured we'll be blocking with page
> locks held.

Yeah, I do *not* believe that throttling at the block layer is at all
the right thing to do.

I do think that the block layer needs to throttle, but it needs to be
seen as a "last resort" kind of thing, where the block layer just
needs to limit how much it will have oending. But it should be seen as
a failure mode, not as a write balancing issue.

Because the real throttling absolutely needs to happen when things are
marked dirty, because no block layer throttling will ever fix the
situation where you just have too much memory dirtied that you cannot
free because it will take a minute to write out.

So throttling at a VM level is sane. Throttling at a block layer level is not.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
