Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 473078E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:00:54 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 41so2237730qto.17
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:00:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m34sor7659260qtc.65.2018.12.20.08.00.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 08:00:52 -0800 (PST)
Date: Thu, 20 Dec 2018 08:00:50 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: Ipmi modules and linux-4.19.1
Message-ID: <20181220160050.GC2509588@devbig004.ftw2.facebook.com>
References: <CAJM9R-JWO1P_qJzw2JboMH2dgPX7K1tF49nO5ojvf=iwGddXRQ@mail.gmail.com>
 <20181220154217.GB2509588@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220154217.GB2509588@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Angel Shtilianov <angel.shtilianov@siteground.com>
Cc: linux-mm@kvack.org, dennis@kernel.org, cl@linux.com, jeyu@kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Corey Minyard <cminyard@mvista.com>

(cc'ing Corey and quoting whole body)

On Thu, Dec 20, 2018 at 07:42:17AM -0800, Tejun Heo wrote:
> Hello, Angel.
> 
> (cc'ing Paul for SRCU)
> 
> On Thu, Dec 20, 2018 at 09:55:10AM +0200, Angel Shtilianov wrote:
> > Hi everybody.
> > A couple of days I've decided to migrate several servers on
> > linux-4.19. What I've observed is that I have no /dev/ipmi. After
> > taking a look into the boot log I've found that ipmi modules are
> > complaining about percpu memory allocation failures:
> > https://pastebin.com/MCDssZzV
> ...
> > -#define PERCPU_DYNAMIC_RESERVE         (28 << 10)
> > +#define PERCPU_DYNAMIC_RESERVE         (28 << 11)
> 
> So, you prolly just needed to bump this number.  The reserved percpu
> area is used to accommodate static percpu variables used by modules.
> They are special because code generation assumes static symbols aren't
> too far from the program counter.  The usual dynamic percpu area is
> way high up in vmalloc area, so if we put static percpu allocations
> there, they go out of range for module symbol relocations.
> 
> The reserved area has some issues.
> 
> 1. The area is not dynamically mapped, meaning that however much we
>    reserve is hard allocated on boot for future module uses, so we
>    don't can't increase it willy-nilly.
> 
> 2. There is no mechanism to adjust the size dynamically.  28k is just
>    a number I pulled out of my ass after looking at some common
>    configs like a decade ago, so it being low now isn't too
>    surprising.  Provided that we can't make it run-time dynamic (and I
>    can't think of a way to do that), the right thing to do would be
>    sizing it during build with some buffer and allow it to be
>    overridden boot time.  This is definitely doable.
> 
> BTW, ipmi's extra usage, 8k, is coming from the use of static SRCU.
> Paul, that's quite a bit of percpu memory to reserve statically.
> Would it be possible to make srcu_struct init dynamic so that it can
> use the normal percpu_alloc?  That way, this problem can be completely
> side-stepped and it only occupies percpu memory which tends to be
> pretty expensive unless ipmi is actually initialized.

So, the transition to SRCU was fairly recent and seems kinda overkill.
This code path isn't expected to be high frequency && concurrency.  Is
the SRCU usage justified here?  Looks like it could have trivially
used a little bit finer grained locking and/or straight-forward
reference count.

Thanks.

-- 
tejun
