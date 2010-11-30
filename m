Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EEFF86B0085
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 19:06:44 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU06gwp029209
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Nov 2010 09:06:42 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F270645DE5C
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:06:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C0A4E45DE59
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:06:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A9C951DB803C
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:06:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 560641DB8043
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:06:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
In-Reply-To: <20101129113357.GA30657@redhat.com>
References: <20101129093803.829F.A69D9226@jp.fujitsu.com> <20101129113357.GA30657@redhat.com>
Message-Id: <20101130085254.82CF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Nov 2010 09:06:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

> On 11/29, KOSAKI Motohiro wrote:
> >
> > > The patch is not complete, compat_copy_strings() needs changes.
> > > But, shouldn't it use get_arg_page() too? Otherwise, where do
> > > we check RLIMIT_STACK?
> >
> > Because NOMMU doesn't have variable length argv. Instead it is still
> > using MAX_ARG_STRLEN as old MMU code.
> >
> > 32 pages hard coded argv limitation naturally prevent this nascent mm
> > issue.
> 
> Ah, I didn't mean NOMMU. I meant compat_execve()->compat_copy_strings().
> If a 32bit process execs we seem to miss the RLIMIT_STACK check, no?

Ah, yes. that's bug. You have found more serious issue ;)



> > > The patch asks for the cleanups. In particular, I think exec_mmap()
> > > should accept bprm, not mm. But I'd prefer to do this later.
> > >
> > > Oleg.
> >
> > General request. Please consider to keep Brad's reported-by tag.
> 
> Yes, yes, sure.
> 
> > > +static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)
> 
> OK.
> 
> > Please move this function into #ifdef CONFIG_MMU. nommu code doesn't use it.
> 
> Well it does, to revert the MM_ANONPAGES counter. I'll add the empty
> function for NOMMU.
> 
> > > +{
> > > +	struct mm_struct *mm = current->mm;
> > > +	long diff = pages - bprm->vma_pages;
> >
> > I prefer to cast signed before assignment. It's safer more.
> 
> OK.
> 
> > > @@ -1003,6 +1024,7 @@ int flush_old_exec(struct linux_binprm *
> > >  	/*
> > >  	 * Release all of the old mmap stuff
> > >  	 */
> > > +	acct_arg_size(bprm, 0);
> >
> > Why do we need this unacct here? I mean 1) if exec_mmap() is success,
> > we don't need unaccount at all
> 
> Yes, we already killed all sub-threads. But this doesn't mean nobody
> else can use current->mm, think about CLONE_VM. The simplest example
> is vfork().

Right you are.


> > 2) if exec_mmap() is failure, an epilogue of
> > do_execve() does unaccount thing.
> 
> Yes.
> 
> Thanks Kosaki!
> 
> I'll resend v2 today. I am still not sure about compat_copy_strings()...
> 
> Oleg.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
