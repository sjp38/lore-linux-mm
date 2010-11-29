Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 531DB6B00AA
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 06:40:57 -0500 (EST)
Date: Mon, 29 Nov 2010 12:33:57 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
Message-ID: <20101129113357.GA30657@redhat.com>
References: <20101125140253.GA29371@redhat.com> <20101125193659.GA14510@redhat.com> <20101129093803.829F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101129093803.829F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 11/29, KOSAKI Motohiro wrote:
>
> > The patch is not complete, compat_copy_strings() needs changes.
> > But, shouldn't it use get_arg_page() too? Otherwise, where do
> > we check RLIMIT_STACK?
>
> Because NOMMU doesn't have variable length argv. Instead it is still
> using MAX_ARG_STRLEN as old MMU code.
>
> 32 pages hard coded argv limitation naturally prevent this nascent mm
> issue.

Ah, I didn't mean NOMMU. I meant compat_execve()->compat_copy_strings().
If a 32bit process execs we seem to miss the RLIMIT_STACK check, no?

> > The patch asks for the cleanups. In particular, I think exec_mmap()
> > should accept bprm, not mm. But I'd prefer to do this later.
> >
> > Oleg.
>
> General request. Please consider to keep Brad's reported-by tag.

Yes, yes, sure.

> > +static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)

OK.

> Please move this function into #ifdef CONFIG_MMU. nommu code doesn't use it.

Well it does, to revert the MM_ANONPAGES counter. I'll add the empty
function for NOMMU.

> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	long diff = pages - bprm->vma_pages;
>
> I prefer to cast signed before assignment. It's safer more.

OK.

> > @@ -1003,6 +1024,7 @@ int flush_old_exec(struct linux_binprm *
> >  	/*
> >  	 * Release all of the old mmap stuff
> >  	 */
> > +	acct_arg_size(bprm, 0);
>
> Why do we need this unacct here? I mean 1) if exec_mmap() is success,
> we don't need unaccount at all

Yes, we already killed all sub-threads. But this doesn't mean nobody
else can use current->mm, think about CLONE_VM. The simplest example
is vfork().

> 2) if exec_mmap() is failure, an epilogue of
> do_execve() does unaccount thing.

Yes.

Thanks Kosaki!

I'll resend v2 today. I am still not sure about compat_copy_strings()...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
