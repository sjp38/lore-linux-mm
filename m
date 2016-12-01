Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26BCA6B0261
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:37:11 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id g8so27090764ioi.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:37:11 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id 35si1193402iol.81.2016.12.01.10.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 10:37:10 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id j92so2682281ioi.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:37:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <dfa22578-745f-063f-b5f6-fe92a281d957@fb.com>
References: <20161128072315.GC14788@dhcp22.suse.cz> <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz> <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org> <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org> <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
 <20161130203011.GB15989@htj.duckdns.org> <20161201135014.jrr65ptxczplmdkn@kmo-pixel>
 <CA+55aFxrwATJtaAzVCnHHaHqusDZeu8=eqffTAPFyFJk5Wn78w@mail.gmail.com> <dfa22578-745f-063f-b5f6-fe92a281d957@fb.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 1 Dec 2016 10:37:09 -0800
Message-ID: <CA+55aFxFXKS3udYZMmBTqtk=FEb2e+soS7_WO0dDht4sTwRqaQ@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, Tejun Heo <tj@kernel.org>, Marc MERLIN <marc@merlins.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, Dec 1, 2016 at 10:30 AM, Jens Axboe <axboe@fb.com> wrote:
>
> It's two different kinds of throttling. The vm absolutely should
> throttle at dirty time, to avoid having insane amounts of memory dirty.
> On the block layer side, throttling is about avoid the device queues
> being too long. It's very similar to the buffer bloating on the
> networking side. The block layer throttling is not a fix for the vm
> allowing too much memory to be dirty and causing issues, it's about
> keeping the device response latencies in check.

Sure. But if we really do just end up blocking in the block layer (in
situations where we didn't used to), that may be a bad thing. It might
be better to feed that information back to the VM instead,
particularly for writes, where the VM layer already tries to ratelimit
the writes.

And frankly, it's almost purely writes that matter. There  just aren't
a lot of ways to get that many parallel reads in real life.

I haven't looked at your patches, so maybe you already do this.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
