Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 663C16B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 14:57:01 -0400 (EDT)
Received: by oibi136 with SMTP id i136so30256508oib.3
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:57:01 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id rr7si8100210oeb.53.2015.09.10.11.57.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Sep 2015 11:57:00 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 10 Sep 2015 12:56:59 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 41C1D1FF002D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:48:04 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8AIus2X51183774
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:56:54 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8AIushj015532
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:56:54 -0600
Date: Thu, 10 Sep 2015 11:56:53 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Message-ID: <20150910185653.GL4029@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
 <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
 <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
 <20150910171333.GD4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509101301010.10131@east.gentwo.org>
 <CACT4Y+Y7hjhbhDoDC-gJaqQcaw0jACjvaaqjFeemvWPV=RjPRw@mail.gmail.com>
 <alpine.DEB.2.11.1509101312470.10226@east.gentwo.org>
 <CACT4Y+ZN=wPWtXOSKanWpL9OtRUd8Bd8r5_o3GJ92YHYgoT01g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZN=wPWtXOSKanWpL9OtRUd8Bd8r5_o3GJ92YHYgoT01g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, Sep 10, 2015 at 08:26:59PM +0200, Dmitry Vyukov wrote:
> On Thu, Sep 10, 2015 at 8:13 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Thu, 10 Sep 2015, Dmitry Vyukov wrote:
> >
> >> On Thu, Sep 10, 2015 at 8:01 PM, Christoph Lameter <cl@linux.com> wrote:
> >> > On Thu, 10 Sep 2015, Paul E. McKenney wrote:
> >> >
> >> >> The reason we poked at this was to see if any of SLxB touched the
> >> >> memory being freed.  If none of them touched the memory being freed,
> >> >> and if that was a policy, then the idiom above would be legal.  However,
> >> >> one of them does touch the memory being freed, so, yes, the above code
> >> >> needs to be fixed.
> >> >
> >> > The one that touches the object has a barrier() before it touches the
> >> > memory.
> >>
> >> It does not change anything, right?
> >
> > It changes the first word of the object after the barrier. The first word
> > is used in SLUB as the pointer to the next free object.
> 
> User can also write to this object after it is reallocated. It is
> equivalent to kmalloc writing to the object.
> And barrier is not the kind of barrier that would make it correct.
> So I do not see how it is relevant.

I believe that the two of you are talking past each other.  It sounds
to me that Christoph is arguing that SL*B is correctly implemented,
and that Dmitry is arguing that the use case is broken.

>From what I can see, both are correct.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
