Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C7CE4900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 13:57:57 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so2441692wib.1
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:57:57 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id v9si3030169wjv.117.2014.10.28.10.57.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 10:57:56 -0700 (PDT)
Date: Tue, 28 Oct 2014 18:57:46 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 05/12] x86, mpx: on-demand kernel allocation of bounds
 tables
In-Reply-To: <544FD5D4.4090404@intel.com>
Message-ID: <alpine.DEB.2.11.1410281851390.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241257300.5308@nanos> <544FD5D4.4090404@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Tue, 28 Oct 2014, Dave Hansen wrote:

> On 10/24/2014 05:08 AM, Thomas Gleixner wrote:
> > On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> >> +	/*
> >> +	 * Go poke the address of the new bounds table in to the
> >> +	 * bounds directory entry out in userspace memory.  Note:
> >> +	 * we may race with another CPU instantiating the same table.
> >> +	 * In that case the cmpxchg will see an unexpected
> >> +	 * 'actual_old_val'.
> >> +	 */
> >> +	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
> >> +					   expected_old_val, bt_addr);
> > 
> > This is fully preemptible non-atomic context, right?
> > 
> > So this wants a proper comment, why using
> > user_atomic_cmpxchg_inatomic() is the right thing to do here.
> 
> Hey Thomas,
> 
> How's this for a new comment?  Does this cover the points you think need
> clarified?
> 
> ====
> 
> The kernel has allocated a bounds table and needs to point the
> (userspace-allocated) directory to it.  The directory entry is the
> *only* place we track that this table was allocated, so we essentially
> use it instead of an kernel data structure for synchronization.  A
> copy_to_user()-style function would not give us the atomicity that we need.
> 
> If two threads race to instantiate a table, the cmpxchg ensures we know
> which one lost the race and that the loser frees the table that they
> just allocated.

Yup. That explains the cmpxchg.

The other thing which puzzled me was that it calls
user_atomic_cmpxchg_inatomic() but the context is not atomic at
all. Its fully preemptible and actually we want it to be able to
handle the fault. The implementation does that, just the function
itself suggest something different.
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
