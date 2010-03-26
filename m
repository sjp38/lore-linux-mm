Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F22F6B01C8
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 18:35:40 -0400 (EDT)
Date: Fri, 26 Mar 2010 23:33:56 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100326223356.GA20833@redhat.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100326150805.f5853d1c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anfei Zhou <anfei.zhou@gmail.com>, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/26, Andrew Morton wrote:
>
> On Thu, 25 Mar 2010 00:25:05 +0800
> Anfei Zhou <anfei.zhou@gmail.com> wrote:
>
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -381,6 +381,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> >   */
> >  static void __oom_kill_task(struct task_struct *p, int verbose)
> >  {
> > +	struct task_struct *t;
> > +
> >  	if (is_global_init(p)) {
> >  		WARN_ON(1);
> >  		printk(KERN_WARNING "tried to kill init!\n");
> > @@ -412,6 +414,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> >  	 */
> >  	p->rt.time_slice = HZ;
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> > +	for (t = next_thread(p); t != p; t = next_thread(t))
> > +		set_tsk_thread_flag(t, TIF_MEMDIE);
> >
> >  	force_sig(SIGKILL, p);
>
> Don't we need some sort of locking while walking that ring?

This should be always called under tasklist_lock, I think.
At least this seems to be true in Linus's tree.

I'd suggest to do

	- set_tsk_thread_flag(p, TIF_MEMDIE);
	+ t = p;
	+ do {
	+	 set_tsk_thread_flag(t, TIF_MEMDIE);
	+ } while_each_thread(p, t);

but this is matter of taste.

Off-topic, but we shouldn't use force_sig(), SIGKILL doesn't
need "force" semantics.

I'd wish I could understand the changelog ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
