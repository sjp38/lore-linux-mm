Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44F69C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 11:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA9D020449
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 11:58:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA9D020449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88D976B0007; Mon, 22 Jul 2019 07:58:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83F8C6B0008; Mon, 22 Jul 2019 07:58:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7063D8E0001; Mon, 22 Jul 2019 07:58:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33B6A6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:58:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x10so23698834pfa.23
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:58:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=ZWGH4X3zSAIxpewm1H0uaR9euXF4n/385F5NKSzpAWY=;
        b=uO+mVZHOaXiF7vJbnjx2LW6AwbcSxRdgMKi+1c3Xrsr1chRCqaNn6/C/DeafizKm71
         3vNBzZRpd3ns36ozAf3c1HGPTzlD7OHejxY2W2z8VOYDX7jPJzz9aqaccRA2CTCcLqOL
         VlESwMJ/H8LG1udoXK/mi5ekoC9LqaIodrvera200l6C7phOg8BCpDZsCn6YAEa8xLGH
         4nxZFF7uFySOE56m8vobJxk/7H7Ba4MWT6f7JimnC2GN6M4EsT74QXZ60l6cv0imuRWb
         VO6bYt80LgR4QX4ERkBTctdvqxs2eyxmFh8wClpryIrSe41mkZ5Ga4iJR1uunwgPdsVj
         i1NQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX45RDQXnsWJDx/fsGr/yw6bTQkgFd8Qvyd0L31pvBkX2uGQF9F
	w1q07kOzQv9G4AzTNR39t4ghVSiUnarr/7S8ZU66lnl1hjtInNMSnVIJK0FuP0YjwZGu02G9E0g
	NHbTFwGjqmo+RVl+lLARN6Uf8Ev31XUnY9iObj948EXgC5dCsTQzwp1JVwvoiAsc=
X-Received: by 2002:a17:90a:71ca:: with SMTP id m10mr22674076pjs.27.1563796730745;
        Mon, 22 Jul 2019 04:58:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwlQiLlXbIk3yedyrFS6U7rLZeuZZjh9pSHwMwV5CiF5Bf97P1ec3dovv/DUenp5bQ7oFR
X-Received: by 2002:a17:90a:71ca:: with SMTP id m10mr22674013pjs.27.1563796729716;
        Mon, 22 Jul 2019 04:58:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563796729; cv=none;
        d=google.com; s=arc-20160816;
        b=ion2DGY4Esywcgp7PJIARe/tN3R+O+iP2BElTWlTte3CtQ/trDfDJz4pUPpeQoo92Z
         vGuXGa0uLV3OmInu5mvhkktuHRBnBW2TUreHWDwU6nM35seRazteL+Mn+jEwq8Tz+Yc+
         oExrVsq1oLu5l5/lhVPq/F3ZkeTZ545Ot22dDoXDgxYTaVFCvUuTSb8iv6CFi6PPDVxd
         1K8GK3DuIxtJLmsbkbzyAvhPW6i8vWyplVBu5hmDamaUIM2MiM6PemXtuK5FDpKhIfr9
         gV5AbIhh/inr9pFCJ+agX8KOHEkBxoH94EkfG5UJjNRqifJISp339t9GuNzC8tReC9eu
         nDqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=ZWGH4X3zSAIxpewm1H0uaR9euXF4n/385F5NKSzpAWY=;
        b=aZzTwW2EQF+jaFsogblLUqoxvDcyXEaMsDg0ukkdVXz12RVJwnXWw5xP92kdPIYRZd
         yZhsun9c4T5e+HY267rdKdiBVV/8RrTyCH/AOb0dLiTw2j+SAnnH2mq3an8MZyvKv4TM
         l1dfK0cQ5gVnxTfw8OuyVtMkk2cifRezvfuNELMCFZHxit+DFgTPTBLqcBlmazm2FrzB
         J5z2+WdXxrOIAKkODVzJC5zuMsQDGY6OlktSotZOuYgjChfXWC9qCtcGkGOn5V/eG0fU
         qSWNy8TtY7T3JMggGJOZ3HVOjwTLbc9j+BiHXSXYPC6BkujC3/S1PdDyxS3OmkXIV5Q1
         LyuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g1si9234586pfh.47.2019.07.22.04.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 04:58:49 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6MBwk6l037228
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:58:49 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2twbf3ux6j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:58:48 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 22 Jul 2019 12:57:52 +0100
Received: from b01cxnp23034.gho.pok.ibm.com (9.57.198.29)
	by e16.ny.us.ibm.com (146.89.104.203) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 22 Jul 2019 12:57:45 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6MBvi2649021204
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 11:57:44 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 69C32B205F;
	Mon, 22 Jul 2019 11:57:44 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 17EC0B2064;
	Mon, 22 Jul 2019 11:57:44 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 22 Jul 2019 11:57:44 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 5A71716C0EDF; Mon, 22 Jul 2019 04:57:45 -0700 (PDT)
Date: Mon, 22 Jul 2019 04:57:45 -0700
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
        davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
        guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
        jasowang@redhat.com, jglisse@redhat.com, keescook@chromium.org,
        ldv@altlinux.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-parisc@vger.kernel.org, luto@amacapital.net, mhocko@suse.com,
        mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
        syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
        wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Reply-To: paulmck@linux.ibm.com
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721134614-mutt-send-email-mst@kernel.org>
 <20190721192841.GT14271@linux.ibm.com>
 <20190722035236-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722035236-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072211-0072-0000-0000-0000044BDA8E
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011474; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235800; UDB=6.00651289; IPR=6.01017150;
 MB=3.00027836; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-22 11:57:51
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072211-0073-0000-0000-00004CBC34F7
Message-Id: <20190722115745.GZ14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-22_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907220143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 03:56:22AM -0400, Michael S. Tsirkin wrote:
> On Sun, Jul 21, 2019 at 12:28:41PM -0700, Paul E. McKenney wrote:
> > On Sun, Jul 21, 2019 at 01:53:23PM -0400, Michael S. Tsirkin wrote:
> > > On Sun, Jul 21, 2019 at 06:17:25AM -0700, Paul E. McKenney wrote:
> > > > On Sun, Jul 21, 2019 at 08:28:05AM -0400, Michael S. Tsirkin wrote:
> > > > > Hi Paul, others,
> > > > > 
> > > > > So it seems that vhost needs to call kfree_rcu from an ioctl. My worry
> > > > > is what happens if userspace starts cycling through lots of these
> > > > > ioctls.  Given we actually use rcu as an optimization, we could just
> > > > > disable the optimization temporarily - but the question would be how to
> > > > > detect an excessive rate without working too hard :) .
> > > > > 
> > > > > I guess we could define as excessive any rate where callback is
> > > > > outstanding at the time when new structure is allocated.  I have very
> > > > > little understanding of rcu internals - so I wanted to check that the
> > > > > following more or less implements this heuristic before I spend time
> > > > > actually testing it.
> > > > > 
> > > > > Could others pls take a look and let me know?
> > > > 
> > > > These look good as a way of seeing if there are any outstanding callbacks,
> > > > but in the case of Tree RCU, call_rcu_outstanding() would almost never
> > > > return false on a busy system.
> > > 
> > > Hmm, ok. Maybe I could rename this to e.g. call_rcu_busy
> > > and change the tree one to do rcu_segcblist_n_lazy_cbs > 1000?
> > 
> > Or the function could simply return the number of callbacks queued
> > on the current CPU, and let the caller decide how many is too many.
> > 
> > > > Here are some alternatives:
> > > > 
> > > > o	RCU uses some pieces of Rao Shoaib kfree_rcu() patches.
> > > > 	The idea is to make kfree_rcu() locally buffer requests into
> > > > 	batches of (say) 1,000, but processing smaller batches when RCU
> > > > 	is idle, or when some smallish amout of time has passed with
> > > > 	no more kfree_rcu() request from that CPU.  RCU than takes in
> > > > 	the batch using not call_rcu(), but rather queue_rcu_work().
> > > > 	The resulting batch of kfree() calls would therefore execute in
> > > > 	workqueue context rather than in softirq context, which should
> > > > 	be much easier on the system.
> > > > 
> > > > 	In theory, this would allow people to use kfree_rcu() without
> > > > 	worrying quite so much about overload.  It would also not be
> > > > 	that hard to implement.
> > > > 
> > > > o	Subsystems vulnerable to user-induced kfree_rcu() flooding use
> > > > 	call_rcu() instead of kfree_rcu().  Keep a count of the number
> > > > 	of things waiting for a grace period, and when this gets too
> > > > 	large, disable the optimization.  It will then drain down, at
> > > > 	which point the optimization can be re-enabled.
> > > > 
> > > > 	But please note that callbacks are -not- guaranteed to run on
> > > > 	the CPU that queued them.  So yes, you would need a per-CPU
> > > > 	counter, but you would need to periodically sum it up to check
> > > > 	against the global state.  Or keep track of the CPU that
> > > > 	did the call_rcu() so that you can atomically decrement in
> > > > 	the callback the same counter that was atomically incremented
> > > > 	just before the call_rcu().  Or any number of other approaches.
> > > 
> > > I'm really looking for something we can do this merge window
> > > and without adding too much code, and kfree_rcu is intended to
> > > fix a bug.
> > > Adding call_rcu and careful accounting is something that I'm not
> > > happy adding with merge window already open.
> > 
> > OK, then I suggest having the interface return you the number of
> > callbacks.  That allows you to experiment with the cutoff.
> > 
> > Give or take the ioctl overhead...
> 
> OK - and for tiny just assume 1 is too much?

I bet that for tiny you won't need to rate-limit at all.  The reason
is that grace periods are quite short.

In fact, for TINY (that is, !SMP && !PREEMPT), synchronize_rcu() is a
no-op.  So in TINY, given that your ioctl is executing at process level,
you could just invoke synchronize_rcu() and then kfree():

#ifdef CONFIG_TINY_RCU
	synchronize_rcu();  /* No other CPUs, so a QS is a GP! */
	kfree(whatever);
	return; /* Or whatever control flow is appropriate. */
#endif
	/* More complicated stuff for !TINY. */

							Thanx, Paul

> > > > Also, the overhead is important.  For example, as far as I know,
> > > > current RCU gracefully handles close(open(...)) in a tight userspace
> > > > loop.  But there might be trouble due to tight userspace loops around
> > > > lighter-weight operations.
> > > > 
> > > > So an important question is "Just how fast is your ioctl?"  If it takes
> > > > (say) 100 microseconds to execute, there should be absolutely no problem.
> > > > On the other hand, if it can execute in 50 nanoseconds, this very likely
> > > > does need serious attention.
> > > > 
> > > > Other thoughts?
> > > > 
> > > > 							Thanx, Paul
> > > 
> > > Hmm the answer to this would be I'm not sure.
> > > It's setup time stuff we never tested it.
> > 
> > Is it possible to measure it easily?
> > 
> > 							Thanx, Paul
> > 
> > > > > Thanks!
> > > > > 
> > > > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > > > 
> > > > > 
> > > > > diff --git a/kernel/rcu/tiny.c b/kernel/rcu/tiny.c
> > > > > index 477b4eb44af5..067909521d72 100644
> > > > > --- a/kernel/rcu/tiny.c
> > > > > +++ b/kernel/rcu/tiny.c
> > > > > @@ -125,6 +125,25 @@ void synchronize_rcu(void)
> > > > >  }
> > > > >  EXPORT_SYMBOL_GPL(synchronize_rcu);
> > > > > 
> > > > > +/*
> > > > > + * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
> > > > > + */
> > > > > +bool call_rcu_outstanding(void)
> > > > > +{
> > > > > +	unsigned long flags;
> > > > > +	struct rcu_data *rdp;
> > > > > +	bool outstanding;
> > > > > +
> > > > > +	local_irq_save(flags);
> > > > > +	rdp = this_cpu_ptr(&rcu_data);
> > > > > +	outstanding = rcu_segcblist_empty(&rdp->cblist);
> > > > > +	outstanding = rcu_ctrlblk.donetail != rcu_ctrlblk.curtail;
> > > > > +	local_irq_restore(flags);
> > > > > +
> > > > > +	return outstanding;
> > > > > +}
> > > > > +EXPORT_SYMBOL_GPL(call_rcu_outstanding);
> > > > > +
> > > > >  /*
> > > > >   * Post an RCU callback to be invoked after the end of an RCU grace
> > > > >   * period.  But since we have but one CPU, that would be after any
> > > > > diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
> > > > > index a14e5fbbea46..d4b9d61e637d 100644
> > > > > --- a/kernel/rcu/tree.c
> > > > > +++ b/kernel/rcu/tree.c
> > > > > @@ -2482,6 +2482,24 @@ static void rcu_leak_callback(struct rcu_head *rhp)
> > > > >  {
> > > > >  }
> > > > > 
> > > > > +/*
> > > > > + * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
> > > > > + */
> > > > > +bool call_rcu_outstanding(void)
> > > > > +{
> > > > > +	unsigned long flags;
> > > > > +	struct rcu_data *rdp;
> > > > > +	bool outstanding;
> > > > > +
> > > > > +	local_irq_save(flags);
> > > > > +	rdp = this_cpu_ptr(&rcu_data);
> > > > > +	outstanding = rcu_segcblist_empty(&rdp->cblist);
> > > > > +	local_irq_restore(flags);
> > > > > +
> > > > > +	return outstanding;
> > > > > +}
> > > > > +EXPORT_SYMBOL_GPL(call_rcu_outstanding);
> > > > > +
> > > > >  /*
> > > > >   * Helper function for call_rcu() and friends.  The cpu argument will
> > > > >   * normally be -1, indicating "currently running CPU".  It may specify
> > > 
> 

