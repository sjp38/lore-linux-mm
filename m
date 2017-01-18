Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A393C6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:53:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so12638380pfx.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:53:57 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c23si28045285pli.184.2017.01.18.02.53.55
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 02:53:56 -0800 (PST)
Date: Wed, 18 Jan 2017 19:53:47 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20170118105346.GL3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-16-git-send-email-byungchul.park@lge.com>
 <20170118064230.GF15084@tardis.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118064230.GF15084@tardis.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 02:42:30PM +0800, Boqun Feng wrote:
> On Fri, Dec 09, 2016 at 02:12:11PM +0900, Byungchul Park wrote:
> [...]
> > +Example 1:
> > +
> > +   CONTEXT X		   CONTEXT Y
> > +   ---------		   ---------
> > +   mutext_lock A
> > +			   lock_page B
> > +   lock_page B
> > +			   mutext_lock A /* DEADLOCK */
> 
> s/mutext_lock/mutex_lock

Thank you.

> > +Example 3:
> > +
> > +   CONTEXT X		   CONTEXT Y
> > +   ---------		   ---------
> > +			   mutex_lock A
> > +   mutex_lock A
> > +   mutex_unlock A
> > +			   wait_for_complete B /* DEADLOCK */
> 
> I think this part better be:
> 
>    CONTEXT X		   CONTEXT Y
>    ---------		   ---------
>    			   mutex_lock A
>    mutex_lock A
>    			   wait_for_complete B /* DEADLOCK */
>    mutex_unlock A
> 
> , right? Because Y triggers DEADLOCK before X could run mutex_unlock().

There's no different between two examples.

No matter which one is chosen, mutex_lock A in CONTEXT X cannot be passed.

> 
> Regards,
> Boqun


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
