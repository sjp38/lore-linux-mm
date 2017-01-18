Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3280A6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:03:23 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 101so12494052iom.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:03:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 65si1323119itg.4.2017.01.18.03.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 03:03:22 -0800 (PST)
Date: Wed, 18 Jan 2017 12:03:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170118110317.GC6515@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
 <20170118064230.GF15084@tardis.cn.ibm.com>
 <20170118105346.GL3326@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118105346.GL3326@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Boqun Feng <boqun.feng@gmail.com>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 07:53:47PM +0900, Byungchul Park wrote:
> On Wed, Jan 18, 2017 at 02:42:30PM +0800, Boqun Feng wrote:
> > On Fri, Dec 09, 2016 at 02:12:11PM +0900, Byungchul Park wrote:
> > [...]
> > > +Example 1:
> > > +
> > > +   CONTEXT X		   CONTEXT Y
> > > +   ---------		   ---------
> > > +   mutext_lock A
> > > +			   lock_page B
> > > +   lock_page B
> > > +			   mutext_lock A /* DEADLOCK */
> > 
> > s/mutext_lock/mutex_lock
> 
> Thank you.
> 
> > > +Example 3:
> > > +
> > > +   CONTEXT X		   CONTEXT Y
> > > +   ---------		   ---------
> > > +			   mutex_lock A
> > > +   mutex_lock A
> > > +   mutex_unlock A
> > > +			   wait_for_complete B /* DEADLOCK */
> > 
> > I think this part better be:
> > 
> >    CONTEXT X		   CONTEXT Y
> >    ---------		   ---------
> >    			   mutex_lock A
> >    mutex_lock A
> >    			   wait_for_complete B /* DEADLOCK */
> >    mutex_unlock A
> > 
> > , right? Because Y triggers DEADLOCK before X could run mutex_unlock().
> 
> There's no different between two examples.

There is..

> No matter which one is chosen, mutex_lock A in CONTEXT X cannot be passed.

But your version shows it does mutex_unlock() before CONTEXT Y does
wait_for_completion().

The thing about these diagrams is that both columns are assumed to have
the same timeline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
