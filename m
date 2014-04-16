Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4B87B6B003A
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 19:19:06 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id n16so13373394oag.27
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 16:19:05 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id wu5si19790663oeb.139.2014.04.16.16.19.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 16:19:05 -0700 (PDT)
Message-ID: <1397690343.2556.15.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 16 Apr 2014 16:19:03 -0700
In-Reply-To: <20140416154631.6d0173498c60619d454ae651@linux-foundation.org>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	 <20140331170546.3b3e72f0.akpm@linux-foundation.org>
	 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
	 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
	 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
	 <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
	 <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
	 <20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
	 <1396389751.25314.26.camel@buesod1.americas.hpqcorp.net>
	 <20140401150843.13da3743554ad541629c936d@linux-foundation.org>
	 <534AD1EE.3050705@colorfullife.com>
	 <20140416154631.6d0173498c60619d454ae651@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>

On Wed, 2014-04-16 at 15:46 -0700, Andrew Morton wrote:
> On Sun, 13 Apr 2014 20:05:34 +0200 Manfred Spraul <manfred@colorfullife.com> wrote:
> 
> > Hi Andrew,
> > 
> > On 04/02/2014 12:08 AM, Andrew Morton wrote:
> > > Well, I'm assuming 64GB==infinity. It *was* infinity in the RHEL5 
> > > timeframe, but infinity has since become larger so pickanumber. 
> > 
> > I think infinity is the right solution:
> > The only common case where infinity is wrong would be Android - and 
> > Android disables sysv shm entirely.
> > 
> > There are two patches:
> > http://marc.info/?l=linux-kernel&m=139730332306185&q=raw
> > http://marc.info/?l=linux-kernel&m=139727299800644&q=raw
> > 
> > Could you apply one of them?
> > I wrote the first one, thus I'm biased which one is better.
> 
> I like your patch because applying it might encourage you to send more
> kernel patches - I miss the old days ;)
> 
> But I do worry about disrupting existing systems so I like Davidlohr's
> idea of making the change a no-op for people who are currently
> explicitly setting shmmax and shmall.
> 
> In an ideal world, system administrators would review this change,
> would remove their explicit limit-setting and would retest everything
> then roll it out.  But in the real world with Davidlohr's patch, they
> just won't know that we did this and they'll still be manually
> configuring shmmax/shmall ten years from now.  I almost wonder if we
> should drop a printk_once("hey, you don't need to do that any more")
> when shmmax/shmall are altered?

That's a good idea, and along with the manpage update (+ probably some
blog/lwn post) users should be well informed. We want them to update
their scripts. Cc'ing Michael Kerrisk btw, who might give us a fresh
userspace perspective.

> I think the changelogs for both patches could afford to spend much more
> time talking about *why* we're making this change.  What problem is
> the current code causing?  This is a somewhat risky change and we
> should demonstrate good reasons for making it.  If people end up taking
> damage because of this change, they are going to be looking at that
> changelog trying to work out why we did this to them, so let's explain
> it carefully.

Fair enough, although that's really why I added the link to Robert Haas'
blog post. In my past life I did some technical support for Oracle, so I
*know* the pain such limits can cause. How does the following sound?

"Unix has historically required setting these limits for shared
memory, and Linux inherited such behavior. The consequence of this
is added complexity for users and administrators. One very common
example are Database setup/installation documents and scripts, where
users must manually calculate the values for these limits. This also
requires (some) knowledge of how the underlying memory management works,
thus causing, in many occasions, the limits to just be flat out wrong.
Disabling these limits sooner could have saved companies a lot of time,
headaches and money for support. But it's never too late, simplify users
life now."


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
