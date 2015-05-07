Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 634C86B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 05:48:26 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so9525260wic.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 02:48:25 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id h6si2408366wjy.71.2015.05.07.02.48.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 02:48:24 -0700 (PDT)
Received: by wgic8 with SMTP id c8so11300912wgi.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 02:48:23 -0700 (PDT)
Date: Thu, 7 May 2015 11:48:19 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH RFC 00/15] decouple pagefault_disable() from
 preempt_disable()
Message-ID: <20150507094819.GC4734@gmail.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
 <20150506150158.0a927470007e8ea5f3278956@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506150158.0a927470007e8ea5f3278956@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <dahi@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed,  6 May 2015 19:50:24 +0200 David Hildenbrand <dahi@linux.vnet.ibm.com> wrote:
> 
> > As Peter asked me to also do the decoupling in one shot, this is
> > the new series.
> > 
> > I recently discovered that might_fault() doesn't call might_sleep()
> > anymore. Therefore bugs like:
> > 
> >   spin_lock(&lock);
> >   rc = copy_to_user(...);
> >   spin_unlock(&lock);
> > 
> > would not be detected with CONFIG_DEBUG_ATOMIC_SLEEP. The code was
> > changed to disable false positives for code like:
> > 
> >   pagefault_disable();
> >   rc = copy_to_user(...);
> >   pagefault_enable();
> > 
> > Whereby the caller wants do deal with failures.
> 
> hm, that was a significant screwup.  I wonder how many bugs we
> subsequently added.

So I'm wondering what the motivation was to allow things like:

   pagefault_disable();
   rc = copy_to_user(...);
   pagefault_enable();

and to declare it a false positive?

AFAICS most uses are indeed atomic:

        pagefault_disable();
        ret = futex_atomic_cmpxchg_inatomic(curval, uaddr, uval, newval);
        pagefault_enable();

so why not make it explicitly atomic again?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
