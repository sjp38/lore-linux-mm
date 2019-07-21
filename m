Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B4E9C76196
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 19:28:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AF3B2084C
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 19:28:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AF3B2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 900976B0005; Sun, 21 Jul 2019 15:28:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B3276B0006; Sun, 21 Jul 2019 15:28:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 779F68E0001; Sun, 21 Jul 2019 15:28:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 411CD6B0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 15:28:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 8so16885386pgl.3
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 12:28:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=XytxACT3h/Cmj73a3LQoR905Z3QXOCLFNnoQ9X9TLTE=;
        b=P4Z9XVexaqaecnCkasX8W1L/n+6Z+SQJsYHW2gVYB7pWfly91ViVAHJ3DtJW9yEneX
         pWOE24cxBBuUJ27IcLTtKhIvJ8CmS94joU+7v2yX/dZyvu9R3jLNd7HTUa/EkxZULVO1
         rqUdeu6pZGlKJGhci6Nai5IsB4Pd/6iPQCVRkrhfc8ytA3JSg5VWATFDvujOdZBkDf5G
         2daKmpKxQOYM3RuM3NurOBjlvicxGTjsL74TfPSF9XZMXyBZ2BbUYyM4IxTSD7ZC9jvh
         32Km2PUqyNJihayUXB/GtNc4+BPSU176lIT8M/AxFCH7E0K5G0j527Cd4HSCIWODqY7t
         K1yg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVpTr6xxLswR3nlD2hXnuAkqxPG/OjwCKb+e+L9fklse1T0THut
	sOJxtgJp8muBX+n6NOhhlpCm+njMKIIhWdh+TZdRs3BmX3WssLl/bUK9dfjcHocyxXuuCSBonev
	ITYu91SRKoscS3HN8ARpiIafRdO/dSVcgNH6HOnJAWBASi6fUMPDMEGzYOH5hnFg=
X-Received: by 2002:a17:90a:5288:: with SMTP id w8mr73404919pjh.61.1563737333751;
        Sun, 21 Jul 2019 12:28:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5mrZ1TLKxVzUT5nJ01PAhs/dP09BvAtVOsL3/X58K7QkUi1J26Ek/EKQ/J38YScJUgDzi
X-Received: by 2002:a17:90a:5288:: with SMTP id w8mr73404853pjh.61.1563737332671;
        Sun, 21 Jul 2019 12:28:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563737332; cv=none;
        d=google.com; s=arc-20160816;
        b=08VOYI+4vwGMYyboYVd8/okBDq3KDvJr1RkQGj+MF6jUZuTCX1kLMiVQdWVI0yLGRo
         XbvkHJ2v+UEZsEZlDIfnkwkT79iL4LEzRSJkPRai3AJEXzzpBYRNKmoxjSOT3CQvbt8G
         ferb0DwkE4BO/bzEqZ+j6pO94L2q929QNUawDu6xjc2xg/Mal3Gek/d10IrOQJ/7X76x
         iFz19o8dByt0eyze8M/tQ8Xde53SOLCurl7l5CnTD4SWtOtSZM3/+kWQYqdC39lrD0sl
         aUf5z28cI/qqL+LRnhw/gq5eNEztbR1sMz4875QGJlM/wdCx0pFDf7DU9itMkH/bpSp4
         PdeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=XytxACT3h/Cmj73a3LQoR905Z3QXOCLFNnoQ9X9TLTE=;
        b=fFcS9dwGwXHAz0pbMRw5D8sa47eSO3ueoojZSG2RO6YyTJ966CmEXoyEuQAghSa4SE
         10OZosSpT91CgSMQmf/ZH/6k1Na/SCKFZ9j/IIOYwZW/ZGWJWqEA/YopE3TJFwhbHOiS
         os+fwHC3kyoDtaORBKN/gINvpRYOVhPcvkgG4plN+2hoIdzx1uDnhYC1LFSkNTNvnr69
         4fmQcQFwvjnqDNMv/1+2KLaUEE4wo04g44N0j2vnhP7PauV5W0yLWiWcrFoGs4B7UFDh
         iMfa35MeyrHkEMbBeZMKRrCkfkRgQFY+824G3KCqp175Kii62X19smhnyoqOKpBSNj+g
         LWsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a15si6099021pgw.246.2019.07.21.12.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 12:28:52 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6LJQssT042651
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 15:28:52 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tvwv8rjrr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 15:28:51 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 21 Jul 2019 20:28:50 +0100
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
	by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 21 Jul 2019 20:28:42 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6LJSfuk38863276
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 21 Jul 2019 19:28:41 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9C33FB2064;
	Sun, 21 Jul 2019 19:28:41 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4A158B205F;
	Sun, 21 Jul 2019 19:28:41 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Sun, 21 Jul 2019 19:28:41 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 7E68716C2E3A; Sun, 21 Jul 2019 12:28:41 -0700 (PDT)
Date: Sun, 21 Jul 2019 12:28:41 -0700
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721134614-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072119-0060-0000-0000-00000363A912
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011470; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235486; UDB=6.00651094; IPR=6.01016824;
 MB=3.00027831; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-21 19:28:48
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072119-0061-0000-0000-00004A3D2E25
Message-Id: <20190721192841.GT14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-21_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907210226
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 01:53:23PM -0400, Michael S. Tsirkin wrote:
> On Sun, Jul 21, 2019 at 06:17:25AM -0700, Paul E. McKenney wrote:
> > On Sun, Jul 21, 2019 at 08:28:05AM -0400, Michael S. Tsirkin wrote:
> > > Hi Paul, others,
> > > 
> > > So it seems that vhost needs to call kfree_rcu from an ioctl. My worry
> > > is what happens if userspace starts cycling through lots of these
> > > ioctls.  Given we actually use rcu as an optimization, we could just
> > > disable the optimization temporarily - but the question would be how to
> > > detect an excessive rate without working too hard :) .
> > > 
> > > I guess we could define as excessive any rate where callback is
> > > outstanding at the time when new structure is allocated.  I have very
> > > little understanding of rcu internals - so I wanted to check that the
> > > following more or less implements this heuristic before I spend time
> > > actually testing it.
> > > 
> > > Could others pls take a look and let me know?
> > 
> > These look good as a way of seeing if there are any outstanding callbacks,
> > but in the case of Tree RCU, call_rcu_outstanding() would almost never
> > return false on a busy system.
> 
> Hmm, ok. Maybe I could rename this to e.g. call_rcu_busy
> and change the tree one to do rcu_segcblist_n_lazy_cbs > 1000?

Or the function could simply return the number of callbacks queued
on the current CPU, and let the caller decide how many is too many.

> > Here are some alternatives:
> > 
> > o	RCU uses some pieces of Rao Shoaib kfree_rcu() patches.
> > 	The idea is to make kfree_rcu() locally buffer requests into
> > 	batches of (say) 1,000, but processing smaller batches when RCU
> > 	is idle, or when some smallish amout of time has passed with
> > 	no more kfree_rcu() request from that CPU.  RCU than takes in
> > 	the batch using not call_rcu(), but rather queue_rcu_work().
> > 	The resulting batch of kfree() calls would therefore execute in
> > 	workqueue context rather than in softirq context, which should
> > 	be much easier on the system.
> > 
> > 	In theory, this would allow people to use kfree_rcu() without
> > 	worrying quite so much about overload.  It would also not be
> > 	that hard to implement.
> > 
> > o	Subsystems vulnerable to user-induced kfree_rcu() flooding use
> > 	call_rcu() instead of kfree_rcu().  Keep a count of the number
> > 	of things waiting for a grace period, and when this gets too
> > 	large, disable the optimization.  It will then drain down, at
> > 	which point the optimization can be re-enabled.
> > 
> > 	But please note that callbacks are -not- guaranteed to run on
> > 	the CPU that queued them.  So yes, you would need a per-CPU
> > 	counter, but you would need to periodically sum it up to check
> > 	against the global state.  Or keep track of the CPU that
> > 	did the call_rcu() so that you can atomically decrement in
> > 	the callback the same counter that was atomically incremented
> > 	just before the call_rcu().  Or any number of other approaches.
> 
> I'm really looking for something we can do this merge window
> and without adding too much code, and kfree_rcu is intended to
> fix a bug.
> Adding call_rcu and careful accounting is something that I'm not
> happy adding with merge window already open.

OK, then I suggest having the interface return you the number of
callbacks.  That allows you to experiment with the cutoff.

Give or take the ioctl overhead...

> > Also, the overhead is important.  For example, as far as I know,
> > current RCU gracefully handles close(open(...)) in a tight userspace
> > loop.  But there might be trouble due to tight userspace loops around
> > lighter-weight operations.
> > 
> > So an important question is "Just how fast is your ioctl?"  If it takes
> > (say) 100 microseconds to execute, there should be absolutely no problem.
> > On the other hand, if it can execute in 50 nanoseconds, this very likely
> > does need serious attention.
> > 
> > Other thoughts?
> > 
> > 							Thanx, Paul
> 
> Hmm the answer to this would be I'm not sure.
> It's setup time stuff we never tested it.

Is it possible to measure it easily?

							Thanx, Paul

> > > Thanks!
> > > 
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > 
> > > 
> > > diff --git a/kernel/rcu/tiny.c b/kernel/rcu/tiny.c
> > > index 477b4eb44af5..067909521d72 100644
> > > --- a/kernel/rcu/tiny.c
> > > +++ b/kernel/rcu/tiny.c
> > > @@ -125,6 +125,25 @@ void synchronize_rcu(void)
> > >  }
> > >  EXPORT_SYMBOL_GPL(synchronize_rcu);
> > > 
> > > +/*
> > > + * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
> > > + */
> > > +bool call_rcu_outstanding(void)
> > > +{
> > > +	unsigned long flags;
> > > +	struct rcu_data *rdp;
> > > +	bool outstanding;
> > > +
> > > +	local_irq_save(flags);
> > > +	rdp = this_cpu_ptr(&rcu_data);
> > > +	outstanding = rcu_segcblist_empty(&rdp->cblist);
> > > +	outstanding = rcu_ctrlblk.donetail != rcu_ctrlblk.curtail;
> > > +	local_irq_restore(flags);
> > > +
> > > +	return outstanding;
> > > +}
> > > +EXPORT_SYMBOL_GPL(call_rcu_outstanding);
> > > +
> > >  /*
> > >   * Post an RCU callback to be invoked after the end of an RCU grace
> > >   * period.  But since we have but one CPU, that would be after any
> > > diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
> > > index a14e5fbbea46..d4b9d61e637d 100644
> > > --- a/kernel/rcu/tree.c
> > > +++ b/kernel/rcu/tree.c
> > > @@ -2482,6 +2482,24 @@ static void rcu_leak_callback(struct rcu_head *rhp)
> > >  {
> > >  }
> > > 
> > > +/*
> > > + * Helpful for rate-limiting kfree_rcu/call_rcu callbacks.
> > > + */
> > > +bool call_rcu_outstanding(void)
> > > +{
> > > +	unsigned long flags;
> > > +	struct rcu_data *rdp;
> > > +	bool outstanding;
> > > +
> > > +	local_irq_save(flags);
> > > +	rdp = this_cpu_ptr(&rcu_data);
> > > +	outstanding = rcu_segcblist_empty(&rdp->cblist);
> > > +	local_irq_restore(flags);
> > > +
> > > +	return outstanding;
> > > +}
> > > +EXPORT_SYMBOL_GPL(call_rcu_outstanding);
> > > +
> > >  /*
> > >   * Helper function for call_rcu() and friends.  The cpu argument will
> > >   * normally be -1, indicating "currently running CPU".  It may specify
> 

