Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A09806B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:49:48 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 194so15194036pgd.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:49:48 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b65si150137pfb.138.2017.01.18.04.49.46
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 04:49:47 -0800 (PST)
From: "byungchul.park" <byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com> <1481260331-360-16-git-send-email-byungchul.park@lge.com> <20170118064230.GF15084@tardis.cn.ibm.com> <20170118105346.GL3326@X58A-UD3R> <20170118110317.GC6515@twins.programming.kicks-ass.net> <20170118115428.GM3326@X58A-UD3R> <20170118120757.GD6515@twins.programming.kicks-ass.net> 
In-Reply-To: 
Subject: RE: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Date: Wed, 18 Jan 2017 21:49:44 +0900
Message-ID: <008201d27189$5811de70$08359b50$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Peter Zijlstra' <peterz@infradead.org>
Cc: 'Boqun Feng' <boqun.feng@gmail.com>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

> -----Original Message-----
> From: byungchul.park [mailto:byungchul.park@lge.com]
> Sent: Wednesday, January 18, 2017 9:15 PM
> To: 'Peter Zijlstra'
> Cc: 'Boqun Feng'; 'mingo@kernel.org'; 'tglx@linutronix.de';
> 'walken@google.com'; 'kirill@shutemov.name'; 'linux-
> kernel@vger.kernel.org'; 'linux-mm@kvack.org'; 'iamjoonsoo.kim@lge.com';
> 'akpm@linux-foundation.org'; 'npiggin@gmail.com'
> Subject: RE: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
> 
> > -----Original Message-----
> > From: Peter Zijlstra [mailto:peterz@infradead.org]
> > Sent: Wednesday, January 18, 2017 9:08 PM
> > To: Byungchul Park
> > Cc: Boqun Feng; mingo@kernel.org; tglx@linutronix.de; walken@google.com;
> > kirill@shutemov.name; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> > iamjoonsoo.kim@lge.com; akpm@linux-foundation.org; npiggin@gmail.com
> > Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature
> documentation
> >
> > On Wed, Jan 18, 2017 at 08:54:28PM +0900, Byungchul Park wrote:
> > > On Wed, Jan 18, 2017 at 12:03:17PM +0100, Peter Zijlstra wrote:
> > > > On Wed, Jan 18, 2017 at 07:53:47PM +0900, Byungchul Park wrote:
> > > > > On Wed, Jan 18, 2017 at 02:42:30PM +0800, Boqun Feng wrote:
> > > > > > On Fri, Dec 09, 2016 at 02:12:11PM +0900, Byungchul Park wrote:
> > > > > > [...]
> > > > > > > +Example 1:
> > > > > > > +
> > > > > > > +   CONTEXT X		   CONTEXT Y
> > > > > > > +   ---------		   ---------
> > > > > > > +   mutext_lock A
> > > > > > > +			   lock_page B
> > > > > > > +   lock_page B
> > > > > > > +			   mutext_lock A /* DEADLOCK */
> > > > > >
> > > > > > s/mutext_lock/mutex_lock
> > > > >
> > > > > Thank you.
> > > > >
> > > > > > > +Example 3:
> > > > > > > +
> > > > > > > +   CONTEXT X		   CONTEXT Y
> > > > > > > +   ---------		   ---------
> > > > > > > +			   mutex_lock A
> > > > > > > +   mutex_lock A
> > > > > > > +   mutex_unlock A
> > > > > > > +			   wait_for_complete B /* DEADLOCK */
> > > > > >
> > > > > > I think this part better be:
> > > > > >
> > > > > >    CONTEXT X		   CONTEXT Y
> > > > > >    ---------		   ---------
> > > > > >    			   mutex_lock A
> > > > > >    mutex_lock A
> > > > > >    			   wait_for_complete B /* DEADLOCK */
> > > > > >    mutex_unlock A
> > > > > >
> > > > > > , right? Because Y triggers DEADLOCK before X could run
> > mutex_unlock().
> > > > >
> > > > > There's no different between two examples.
> > > >
> > > > There is..
> > > >
> > > > > No matter which one is chosen, mutex_lock A in CONTEXT X cannot be
> > passed.
> > > >
> > > > But your version shows it does mutex_unlock() before CONTEXT Y does
> > > > wait_for_completion().
> > > >
> > > > The thing about these diagrams is that both columns are assumed to
> > have
> > > > the same timeline.
> > >
> > > X cannot acquire mutex A because Y already acquired it.
> > >
> > > In order words, all statements below mutex_lock A in X cannot run.
> >
> > But your timeline shows it does, which is the error that Boqun pointed
> > out.
> 
> I am sorry for not understanding what you are talking about.
> 
> Do you mean that I should remove all statements below mutex_lock A in X?
> 
> Or should I move mutex_unlock as Boqun said? What will change?

Anyway, I will change it as he said even though I don't understand what is
different between them. :/ But I am just curious. It would be appreciated
if you answer my question.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
