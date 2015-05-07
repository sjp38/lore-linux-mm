Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B0CAB6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 07:08:34 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so39817219wgy.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:08:34 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id jt5si2738467wjc.48.2015.05.07.04.08.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 04:08:33 -0700 (PDT)
Received: by wgic8 with SMTP id c8so13275442wgi.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:08:32 -0700 (PDT)
Date: Thu, 7 May 2015 13:08:28 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH RFC 00/15] decouple pagefault_disable() from
 preempt_disable()
Message-ID: <20150507110828.GA15284@gmail.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
 <20150506150158.0a927470007e8ea5f3278956@linux-foundation.org>
 <20150507094819.GC4734@gmail.com>
 <554B43AA.1050605@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <554B43AA.1050605@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org


* Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> Am 07.05.2015 um 11:48 schrieb Ingo Molnar:
> > 
> > * Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> >> On Wed,  6 May 2015 19:50:24 +0200 David Hildenbrand <dahi@linux.vnet.ibm.com> wrote:
> >>
> >>> As Peter asked me to also do the decoupling in one shot, this is
> >>> the new series.
> >>>
> >>> I recently discovered that might_fault() doesn't call might_sleep()
> >>> anymore. Therefore bugs like:
> >>>
> >>>   spin_lock(&lock);
> >>>   rc = copy_to_user(...);
> >>>   spin_unlock(&lock);
> >>>
> >>> would not be detected with CONFIG_DEBUG_ATOMIC_SLEEP. The code was
> >>> changed to disable false positives for code like:
> >>>
> >>>   pagefault_disable();
> >>>   rc = copy_to_user(...);
> >>>   pagefault_enable();
> >>>
> >>> Whereby the caller wants do deal with failures.
> >>
> >> hm, that was a significant screwup.  I wonder how many bugs we
> >> subsequently added.
> > 
> > So I'm wondering what the motivation was to allow things like:
> > 
> >    pagefault_disable();
> >    rc = copy_to_user(...);
> >    pagefault_enable();
> > 
> > and to declare it a false positive?
> > 
> > AFAICS most uses are indeed atomic:
> > 
> >         pagefault_disable();
> >         ret = futex_atomic_cmpxchg_inatomic(curval, uaddr, uval, newval);
> >         pagefault_enable();
> > 
> > so why not make it explicitly atomic again?
> 
> Hmm, I am probably misreading that, but it sound as you suggest to go back
> to Davids first proposal
> https://lkml.org/lkml/2014/11/25/436
> which makes might_fault to also contain might_sleep. Correct?

Yes, but I'm wondering what I'm missing: is there any deep reason for 
making pagefaults-disabled sections non-atomic?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
