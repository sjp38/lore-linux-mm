Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id F297B6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 07:13:59 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u128so24204562qkd.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 04:13:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g48si1692505qtc.98.2016.07.04.04.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 04:13:59 -0700 (PDT)
Date: Mon, 4 Jul 2016 13:13:53 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run()
 failure check.
Message-ID: <20160704111353.GA3964@redhat.com>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
 <20160703124246.GA23902@redhat.com>
 <201607040103.DEB48914.HQFFJFOOOVtSLM@I-love.SAKURA.ne.jp>
 <20160703171022.GA31065@redhat.com>
 <201607040653.DJB81254.FFOOSHFOQMtJLV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607040653.DJB81254.FFOOSHFOQMtJLV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

I guess we misunderstood each other,

On 07/04, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > On 07/04, Tetsuo Handa wrote:
> > >
> > > Oleg Nesterov wrote:
> > > > On 07/03, Tetsuo Handa wrote:
> > > > >
> > > > > If kthread_run() in oom_init() fails due to reasons other than OOM
> > > > > (e.g. no free pid is available), userspace processes won't be able to
> > > > > start as well.
> > > >
> > > > Why?
> > > >
> > > > The kernel will boot with or without your change, but

and yes, I probably confused you. I tried to say that in theory nothing
prevents the kernel from booting even if oom_init() fails.

> > IOW, this patch doesn't look correct without other changes?
>
> If you think that global init can successfully start after kthread_run()
> in oom_init() failed.

No, I think you are right. If kthread_run() fails at this stage than something
is seriously wrong anyway. And yes, for example hung_task_init() doesn't bother
to check the value returned by kthread_run().

I meant that this just looks wrong (and proc_dohung_task_timeout_secs() too).
And the warning can help to identify the problem.

In any case I agree, we should remove "oom_reaper_th",

>  static int __init oom_init(void)
>  {
> -	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> -	if (IS_ERR(oom_reaper_th)) {
> -		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> -				PTR_ERR(oom_reaper_th));
> -		oom_reaper_th = NULL;
> -	}
> +	struct task_struct *p = kthread_run(oom_reaper, NULL, "oom_reaper");
> +
> +	BUG_ON(IS_ERR(p));
>  	return 0;

Yes, do_initcall_level() ignores the error returned by fn(), so we need BUG()
or panic().

This is off-topic, but perhaps we should audit all initcalls and fix those
who return the error for no reason, say, bts_init(). And then change
do_one_initcall() to panic or at least WARN() if a non-modular initcall fails.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
