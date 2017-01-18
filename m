Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3256B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:54:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so13863155pfb.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:54:39 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 16si29997pfw.94.2017.01.18.03.54.37
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 03:54:38 -0800 (PST)
Date: Wed, 18 Jan 2017 20:54:28 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170118115428.GM3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
 <20170118064230.GF15084@tardis.cn.ibm.com>
 <20170118105346.GL3326@X58A-UD3R>
 <20170118110317.GC6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118110317.GC6515@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Boqun Feng <boqun.feng@gmail.com>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 12:03:17PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 18, 2017 at 07:53:47PM +0900, Byungchul Park wrote:
> > On Wed, Jan 18, 2017 at 02:42:30PM +0800, Boqun Feng wrote:
> > > On Fri, Dec 09, 2016 at 02:12:11PM +0900, Byungchul Park wrote:
> > > [...]
> > > > +Example 1:
> > > > +
> > > > +   CONTEXT X		   CONTEXT Y
> > > > +   ---------		   ---------
> > > > +   mutext_lock A
> > > > +			   lock_page B
> > > > +   lock_page B
> > > > +			   mutext_lock A /* DEADLOCK */
> > > 
> > > s/mutext_lock/mutex_lock
> > 
> > Thank you.
> > 
> > > > +Example 3:
> > > > +
> > > > +   CONTEXT X		   CONTEXT Y
> > > > +   ---------		   ---------
> > > > +			   mutex_lock A
> > > > +   mutex_lock A
> > > > +   mutex_unlock A
> > > > +			   wait_for_complete B /* DEADLOCK */
> > > 
> > > I think this part better be:
> > > 
> > >    CONTEXT X		   CONTEXT Y
> > >    ---------		   ---------
> > >    			   mutex_lock A
> > >    mutex_lock A
> > >    			   wait_for_complete B /* DEADLOCK */
> > >    mutex_unlock A
> > > 
> > > , right? Because Y triggers DEADLOCK before X could run mutex_unlock().
> > 
> > There's no different between two examples.
> 
> There is..
> 
> > No matter which one is chosen, mutex_lock A in CONTEXT X cannot be passed.
> 
> But your version shows it does mutex_unlock() before CONTEXT Y does
> wait_for_completion().
> 
> The thing about these diagrams is that both columns are assumed to have
> the same timeline.

X cannot acquire mutex A because Y already acquired it.

In order words, all statements below mutex_lock A in X cannot run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
