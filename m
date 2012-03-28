Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 54F946B0112
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 13:35:58 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mm: hung task (handle_pte_fault)
Date: Wed, 28 Mar 2012 13:35:12 -0400
Message-Id: <1332956112-5274-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
In-Reply-To: <alpine.LSU.2.00.1203272145250.5922@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 27, 2012 at 09:53:41PM -0700, Hugh Dickins wrote:
> On Wed, 28 Mar 2012, Sasha Levin wrote:
> > On Tue, Mar 27, 2012 at 1:17 AM, Andrew Morton
> > <akpm@linux-foundation.org> wrote:
> > > The task is waiting for IO to complete against a page, and it isn't
> > > happening.
> > >
> > > There are quite a lot of things which could cause this, alas. VM,
> > > readahead, scheduler, core wait/wakeup code, IO system, interrupt
> > > system (if it happens outside KVM, I guess).
> > >
> > > So.... ugh. Hopefully someone will hit this in a situation where it
> > > can be narrowed down or bisected.
> > 
> > I've only managed to reproduce it once, and was unable to get anything
> > useful out of it due to technical reasons.
> > 
> > The good part is that I've managed to hit something similar (although
> > I'm not 100% sure it's the same problem as the one in the original
> > mail).
> 
> I don't think this one has anything to do with the first you posted,
> but it does look like a good catch against current linux-next, where
> pagemap_pte_range() appears to do a spin_lock(&walk->mm->page_table_lock)
> which should have been removed by "thp: optimize away unnecessary page
> table locking".  Some kind of mismerge perhaps: Horiguchi-san added to Cc.

Thanks for reporting.
This spin_lock() also exists in mainline, so we need a fix on it.
I'll post later for -stable tree.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
