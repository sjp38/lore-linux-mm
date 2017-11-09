Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 006A0440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 23:45:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r18so4973702pgu.9
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 20:45:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p4sor1565306pgc.6.2017.11.08.20.45.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 20:45:52 -0800 (PST)
Date: Thu, 9 Nov 2017 13:45:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171109044548.GC775@jagdpanzerIV>
References: <20171102134515.6eef16de@gandalf.local.home>
 <201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
 <20171107014015.GA1822@jagdpanzerIV>
 <20171108051955.GA468@jagdpanzerIV>
 <20171108092951.4d677bca@gandalf.local.home>
 <20171109005635.GA775@jagdpanzerIV>
 <20171108222905.426fc73a@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108222905.426fc73a@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

On (11/08/17 22:29), Steven Rostedt wrote:
> > On (11/08/17 09:29), Steven Rostedt wrote:
> > > On Wed, 8 Nov 2017 14:19:55 +0900
> > > Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:
> > >   
> > > > the change goes further. I did express some of my concerns during the KS,
> > > > I'll just bring them to the list.
> > > > 
> > > > 
> > > > we now always shift printing from a save - scheduleable - context to
> > > > a potentially unsafe one - atomic. by example:  
> > > 
> > > And vice versa. We are now likely to go from a unscheduleable context
> > > to a schedule one, where before, that didn't exist.  
> > 
> > the existence of "and vice versa" is kinda alarming, isn't it? it's sort
> > of "yes, we can break some things, but we also can improve some things."
> 
> Not really. Because the heuristic is that what calls printk will do the
> printk.

so what we are looking at

   a) we take over printing. can be from safe context to unsafe context
      [well, bad karma]. can be from unsafe context to a safe one. or from
      safe context to another safe context... or from one unsafe context to
      another unsafe context [bad karma again]. we really never know, no
      one does.

      lots of uncertainties - "may be X, may be Y, may be Z". a bigger
      picture: we still can have the same lockup scenarios as we do
      have today.

      and we also bring busy loop with us, so the new console_sem
      owner [regardless its current context] CPU must wait until the
      current console_sem finishes its call_console_drivers(). I
      mentioned it in my another email, you seemed to jump over that
      part. was it irrelevant or wrong?

vs.

   b) we offload to printk_kthread [safe context].


why (a) is better than (b)?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
