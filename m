Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3A28C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:56:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B4C721BE6
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:56:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B4C721BE6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A18B6B0008; Mon, 22 Jul 2019 03:56:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 154728E0003; Mon, 22 Jul 2019 03:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 012D66B000C; Mon, 22 Jul 2019 03:56:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D71A76B0008
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 03:56:33 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d11so32921088qkb.20
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:56:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=YkK+f5QGLc4KZe09cFgOK74AALWRPZbHhmFWCI9QB0o=;
        b=PaDPP1dqmaOxt8NzbeSI5ahejMhh8ndrSTFcVHpCOgfLwGCKT1J8ukbj5egMAnLFXi
         g0ioP04qboGu6tbNsSjxsmsZj/5n8QVTBP6WMcHcRZsJa0d6bMNTysZqYo2XfFVGrUqw
         WSXhfrJd7uDRotA/qnSlcwQ8L/xlzgCfangTKkgdZpAC1Df0qHsX11mfS2N8Avqw++qZ
         Vi/CzVkoxI9gqF82XgYFBjI0wdpxIVThjk885GSNF7hBq5CLmy4bak8mx/8AkIbXoFCr
         /6GC917cMlbezC83wKfR+2XO7l7tEoyxFG8kytyuBh1o5uQJ4e+rGsSEr16kToa+K2MP
         IyPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXYoWDCIA+CbaMykz9MiQ+kT9QZIJkd8KFb76xLxUvzZG1djV5X
	dGxUqEdSZiq1kaUOStXR7vsExRWXi8L6UNt2icrhyv74oKsj5NU2XOcSSMAiyPHWOwhCJBlXpgb
	WZJqsjP255HJc3f4ZKGa+NPJ13C1A7v+4yzXdScXW6L39/KSkGP2RpvQXaqNtz/+ZUQ==
X-Received: by 2002:a0c:93a3:: with SMTP id f32mr49583565qvf.14.1563782193626;
        Mon, 22 Jul 2019 00:56:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAijwOWZv3PwGMP5uAGWgleeEosu9n/TOajTwGiuQg+Xd1OJPmuUCYASTDPwOx/EFjFSZH
X-Received: by 2002:a0c:93a3:: with SMTP id f32mr49583519qvf.14.1563782192821;
        Mon, 22 Jul 2019 00:56:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563782192; cv=none;
        d=google.com; s=arc-20160816;
        b=kiISZHzmYlus3/Cywp7N55Ezsh7kOYRxUPMzoFU0jzb6leHTW7Ko2UAEWJsZS8nKgH
         VBFnkAgpdghVH/oOjr4Zm3Pc8LHJldxLrQXiHnEHU/woVmCR4ZHWyJ4ew5gCSybMJAl+
         ATpB3M1g0vC8kyugrIiis4MLEsUsdMXPLowjzPXromQx71dvZtN5zoKnQ/aiaiUuBfIA
         N0sEzTgymwFqERVUZsOl0cs7O3137KCFCMPq6f+Cq4Y3ugKSUSTCvMfTPuEIF7E1WNF9
         roXOa+I5KfWWdFeH+0G9yrJDEMTDKm8GZc5c9dEZc8hHMcWoynrK8OquhcHUvha0PisC
         KU0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=YkK+f5QGLc4KZe09cFgOK74AALWRPZbHhmFWCI9QB0o=;
        b=hQn3fkmNs1pVv66XkuGBn0t2CBH8+inb2ImXavydfvOfqXRY1lp29ro1uDSgTT8a1+
         gHYfinGncxZu8boqnpY0V8GiQ3JtTShoF/o4d17Or6RQPyxw9qHo0t+FcuL/7MB7rZ1G
         9XUbZySyqIM0+9f5Luyd4mUTsPFc0L2nj/WsS7U+SMWfJUfT8yzn/l9ohRDtw37ITS2P
         79+dx6+3u599HVvd5TWuqAdVlsAiwZUauUmimzE/yq7NSFmhyVVgvAY0/dchsVwjT4aM
         mgGYK9ri2KyofZsvP2mQeoXTkbZVSakFLR045fPrF+BewztUeZOH1LRnYd6FO/Sk78Ib
         iSbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n21si23416485qvd.29.2019.07.22.00.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 00:56:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C52CD3083363;
	Mon, 22 Jul 2019 07:56:31 +0000 (UTC)
Received: from redhat.com (ovpn-120-233.rdu2.redhat.com [10.10.120.233])
	by smtp.corp.redhat.com (Postfix) with SMTP id 9E2225D704;
	Mon, 22 Jul 2019 07:56:23 +0000 (UTC)
Date: Mon, 22 Jul 2019 03:56:22 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
	davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Message-ID: <20190722035236-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721134614-mutt-send-email-mst@kernel.org>
 <20190721192841.GT14271@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721192841.GT14271@linux.ibm.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 22 Jul 2019 07:56:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 12:28:41PM -0700, Paul E. McKenney wrote:
> On Sun, Jul 21, 2019 at 01:53:23PM -0400, Michael S. Tsirkin wrote:
> > On Sun, Jul 21, 2019 at 06:17:25AM -0700, Paul E. McKenney wrote:
> > > On Sun, Jul 21, 2019 at 08:28:05AM -0400, Michael S. Tsirkin wrote:
> > > > Hi Paul, others,
> > > > 
> > > > So it seems that vhost needs to call kfree_rcu from an ioctl. My worry
> > > > is what happens if userspace starts cycling through lots of these
> > > > ioctls.  Given we actually use rcu as an optimization, we could just
> > > > disable the optimization temporarily - but the question would be how to
> > > > detect an excessive rate without working too hard :) .
> > > > 
> > > > I guess we could define as excessive any rate where callback is
> > > > outstanding at the time when new structure is allocated.  I have very
> > > > little understanding of rcu internals - so I wanted to check that the
> > > > following more or less implements this heuristic before I spend time
> > > > actually testing it.
> > > > 
> > > > Could others pls take a look and let me know?
> > > 
> > > These look good as a way of seeing if there are any outstanding callbacks,
> > > but in the case of Tree RCU, call_rcu_outstanding() would almost never
> > > return false on a busy system.
> > 
> > Hmm, ok. Maybe I could rename this to e.g. call_rcu_busy
> > and change the tree one to do rcu_segcblist_n_lazy_cbs > 1000?
> 
> Or the function could simply return the number of callbacks queued
> on the current CPU, and let the caller decide how many is too many.
> 
> > > Here are some alternatives:
> > > 
> > > o	RCU uses some pieces of Rao Shoaib kfree_rcu() patches.
> > > 	The idea is to make kfree_rcu() locally buffer requests into
> > > 	batches of (say) 1,000, but processing smaller batches when RCU
> > > 	is idle, or when some smallish amout of time has passed with
> > > 	no more kfree_rcu() request from that CPU.  RCU than takes in
> > > 	the batch using not call_rcu(), but rather queue_rcu_work().
> > > 	The resulting batch of kfree() calls would therefore execute in
> > > 	workqueue context rather than in softirq context, which should
> > > 	be much easier on the system.
> > > 
> > > 	In theory, this would allow people to use kfree_rcu() without
> > > 	worrying quite so much about overload.  It would also not be
> > > 	that hard to implement.
> > > 
> > > o	Subsystems vulnerable to user-induced kfree_rcu() flooding use
> > > 	call_rcu() instead of kfree_rcu().  Keep a count of the number
> > > 	of things waiting for a grace period, and when this gets too
> > > 	large, disable the optimization.  It will then drain down, at
> > > 	which point the optimization can be re-enabled.
> > > 
> > > 	But please note that callbacks are -not- guaranteed to run on
> > > 	the CPU that queued them.  So yes, you would need a per-CPU
> > > 	counter, but you would need to periodically sum it up to check
> > > 	against the global state.  Or keep track of the CPU that
> > > 	did the call_rcu() so that you can atomically decrement in
> > > 	the callback the same counter that was atomically incremented
> > > 	just before the call_rcu().  Or any number of other approaches.
> > 
> > I'm really looking for something we can do this merge window
> > and without adding too much code, and kfree_rcu is intended to
> > fix a bug.
> > Adding call_rcu and careful accounting is something that I'm not
> > happy adding with merge window already open.
> 
> OK, then I suggest having the interface return you the number of
> callbacks.  That allows you to experiment with the cutoff.
> 
> Give or take the ioctl overhead...

OK - and for tiny just assume 1 is too much?


> > > Also, the overhead is important.  For example, as far as I know,
> > > current RCU gracefully handles close(open(...)) in a tight userspace
> > > loop.  But there might be trouble due to tight userspace loops around
> > > lighter-weight operations.
> > > 
> > > So an important question is "Just how fast is your ioctl?"  If it takes
> > > (say) 100 microseconds to execute, there should be absolutely no problem.
> > > On the other hand, if it can execute in 50 nanoseconds, this very likely
> > > does need serious attention.
> > > 
> > > Other thoughts?
> > > 
> > > 							Thanx, Paul
> > 
> > Hmm the answer to this would be I'm not sure.
> > It's setup time stuff we never tested it.
> 
> Is it possible to measure it easily?
> 
> 							Thanx, Paul
> 
> > > > Thanks!
> > > > 
> > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > 
> > > > 
> > > > diff --git a/kernel/rcu/tiny.c b/kernel/rcu/tiny.c
> > > > index 477b4eb44af5..067909521d72 100644
> > > > --- a/kernel/rcu/tiny.c
> > > > +++ b/kernel/rcu/tiny.c
> > > > @@ -125,6 +125,25 @@ void synchronize_rcu(void)
> > > >  }
> > > >  EXPORT_SYMBOL_GPL(synchronize_rcu);
> > > > 
> > > > +/*
> > > > + * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
> > > > + */
> > > > +bool call_rcu_outstanding(void)
> > > > +{
> > > > +	unsigned long flags;
> > > > +	struct rcu_data *rdp;
> > > > +	bool outstanding;
> > > > +
> > > > +	local_irq_save(flags);
> > > > +	rdp = this_cpu_ptr(&rcu_data);
> > > > +	outstanding = rcu_segcblist_empty(&rdp->cblist);
> > > > +	outstanding = rcu_ctrlblk.donetail != rcu_ctrlblk.curtail;
> > > > +	local_irq_restore(flags);
> > > > +
> > > > +	return outstanding;
> > > > +}
> > > > +EXPORT_SYMBOL_GPL(call_rcu_outstanding);
> > > > +
> > > >  /*
> > > >   * Post an RCU callback to be invoked after the end of an RCU grace
> > > >   * period.  But since we have but one CPU, that would be after any
> > > > diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
> > > > index a14e5fbbea46..d4b9d61e637d 100644
> > > > --- a/kernel/rcu/tree.c
> > > > +++ b/kernel/rcu/tree.c
> > > > @@ -2482,6 +2482,24 @@ static void rcu_leak_callback(struct rcu_head *rhp)
> > > >  {
> > > >  }
> > > > 
> > > > +/*
> > > > + * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
> > > > + */
> > > > +bool call_rcu_outstanding(void)
> > > > +{
> > > > +	unsigned long flags;
> > > > +	struct rcu_data *rdp;
> > > > +	bool outstanding;
> > > > +
> > > > +	local_irq_save(flags);
> > > > +	rdp = this_cpu_ptr(&rcu_data);
> > > > +	outstanding = rcu_segcblist_empty(&rdp->cblist);
> > > > +	local_irq_restore(flags);
> > > > +
> > > > +	return outstanding;
> > > > +}
> > > > +EXPORT_SYMBOL_GPL(call_rcu_outstanding);
> > > > +
> > > >  /*
> > > >   * Helper function for call_rcu() and friends.  The cpu argument will
> > > >   * normally be -1, indicating "currently running CPU".  It may specify
> > 

