Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id A82AD6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 13:34:43 -0400 (EDT)
Received: by qgev79 with SMTP id v79so41515977qge.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 10:34:43 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id h12si14164253qhc.71.2015.09.10.10.34.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Sep 2015 10:34:42 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 10 Sep 2015 11:31:49 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C72A21FF0054
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:22:50 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8AHUYWp43188372
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 10:30:34 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8AHVeWS029598
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:31:41 -0600
Date: Thu, 10 Sep 2015 10:21:14 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Message-ID: <20150910172114.GA28296@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
 <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
 <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
 <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
 <20150910171333.GD4029@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150910171333.GD4029@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, Sep 10, 2015 at 10:13:33AM -0700, Paul E. McKenney wrote:
> On Thu, Sep 10, 2015 at 11:55:35AM +0200, Dmitry Vyukov wrote:
> > On Thu, Sep 10, 2015 at 1:31 AM, Christoph Lameter <cl@linux.com> wrote:
> > > On Wed, 9 Sep 2015, Paul E. McKenney wrote:

[ . . . ]

> > There are memory allocator implementations that do reads and writes of
> > the object, and there are memory allocator implementations that do not
> > do any barriers on fast paths. From this follows that objects must be
> > passed in quiescent state to kfree.
> > Now, kernel memory model says "A load-load control dependency requires
> > a full read memory barrier".
> > >From this follows that the following code is broken:
> > 
> > // kernel/pid.c
> >          if ((atomic_read(&pid->count) == 1) ||
> >               atomic_dec_and_test(&pid->count)) {
> >                  kmem_cache_free(ns->pid_cachep, pid);
> >                  put_pid_ns(ns);
> >          }
> > 
> > and it should be:
> > 
> > // kernel/pid.c
> >          if ((smp_load_acquire(&pid->count) == 1) ||
> 
> If Will Deacon's patch providing generic support for relaxed atomics
> made it in, we want:
> 
> 	  if ((atomic_read_acquire(&pid->count) == 1) ||
> 
> Otherwise, we need an explicit barrier.

And atomic_read_acquire() is in fact now in mainline, so it is the
best choice here.

							Thanx, Paul

> >               atomic_dec_and_test(&pid->count)) {
> >                  kmem_cache_free(ns->pid_cachep, pid);
> >                  put_pid_ns(ns);
> >          }
> > 
> > 
> > 
> > -- 
> > Dmitry Vyukov, Software Engineer, dvyukov@google.com
> > Google Germany GmbH, Dienerstrasse 12, 80331, Munchen
> > Geschaftsfuhrer: Graham Law, Christine Elizabeth Flores
> > Registergericht und -nummer: Hamburg, HRB 86891
> > Sitz der Gesellschaft: Hamburg
> > Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat
> > sind, leiten Sie diese bitte nicht weiter, informieren Sie den
> > Absender und loschen Sie die E-Mail und alle Anhange. Vielen Dank.
> > This e-mail is confidential. If you are not the right addressee please
> > do not forward it, please inform the sender, and please erase this
> > e-mail including any attachments. Thanks.
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
