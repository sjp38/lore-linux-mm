Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02178C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:32:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2F0E21911
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:32:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2F0E21911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C5A28E000C; Mon, 22 Jul 2019 12:32:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 576938E0001; Mon, 22 Jul 2019 12:32:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 463DD8E000C; Mon, 22 Jul 2019 12:32:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24CE68E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:32:31 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so36127135qte.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:32:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=XQ/wBxECw9eEizSYQBtcI2n0mCD6tQZBTKPGxe1wcwA=;
        b=m86XwN9G9jDbuM5jaOE3zR1ZUgGx0yESdcElcnYdCXzkKksaWbQT3FxFUo9okMUvQ9
         exqP636LOG2ZxOO7KjvUzE+SmAHPOxJk2uB7YU9zszLIf55Pn8BnJ49wCaYayDwXPRY1
         AzbRLEjpJMMg00J7NW1Yd7UxhT+/5dd1lZlnNnfymPofwYYhJfWDwujE/9jiwFaalY8f
         +/8hDlr5rZyUbrzKhiP0zdNmBG6QX4MrxxsZ7mFV/ANPxEkSlp0uOhv/lgWKZwDlhA9a
         dFpGTcUySfQRm1BB9y4kV4T1jSy6Qh8UEHqdB/fOjcocTbJYgwwTMQppNEF5PA4EMfhQ
         I7Rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX5bdnogXOh2FKPFIc2ui0YKIvI//2QBrwGapUNRT4yA8QkH8QF
	YgblC8QFbN6ZMRSjZ01Ou2jv/F8Kb7lXMHW+Dy7Icr1zlMjgL0NRlgRqQI5qFC1fusMewBDjLQi
	Se46lAw76ZOOJ4LPBTHE/cjTDAS1KzgeLWwVNBCQiydN10LN8We8jLKuANiBA6mH9vQ==
X-Received: by 2002:a05:620a:15cd:: with SMTP id o13mr46617013qkm.273.1563813150935;
        Mon, 22 Jul 2019 09:32:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMcQUoIvWC2TWaeob5KyFGyc0ITGWpvhBMrQXKhKpNt3AXpg1++SCYMJQ5fezJJTVOuY18
X-Received: by 2002:a05:620a:15cd:: with SMTP id o13mr46616993qkm.273.1563813150402;
        Mon, 22 Jul 2019 09:32:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563813150; cv=none;
        d=google.com; s=arc-20160816;
        b=OdyuUtEsQC/izTBnLry9rNNmg4N4wPmBMEEOI74c80QhHoU6t3kWLL0iTJJmMscYuL
         mu0Ds3eZHzU4/JHIE+IkNUa8mF4G1Ko4mSS6aQbcJqQP37RmsKDMDPHi8M0WvPJSUhqf
         4R6GUXF47gRn2P4/C/AV6gqYj+DfsSSdF65g3HwVRykB0rGf7ZB9zRTYcZREFRtG6A+b
         LUPldnvlqwfQSMvZCLbHy8J0BNObS00b4jWceh9EHncceRlVYtpamDE1LPLoNWi7Mmjx
         wl2u3m/AStbYCrQFIsoBlJy1pOCIT/4kwUXI2a+Qq6J4Vjn72u5KYo62zwro1Fu1qAAP
         O4SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=XQ/wBxECw9eEizSYQBtcI2n0mCD6tQZBTKPGxe1wcwA=;
        b=dH6pvVWFBFHRKqn0/fxH03NS0Oa+rllBgOz/LzkRZwrNg+Flrifzx9zoRCqyCrf4YT
         w6zZesAhXngUWc/9ruCIslP+47ETGQ84MEOVK9JSXUd4QLDx5FZ5fDnbqrz+jgj/BnPU
         3NiU7B0f4jWEav+NKHiuU9lXs3QQlG06H29sZEUmNwYa9Fily2+pByizrsdTpTGSVkSt
         7/kJLTqMO54bX2d68ZILSTRj6+zvquckgISOLUUugdgkw46OURlixmXqnmlSU92j3Nab
         jpFYX6QHCPGzRvpbmT0/ZIyBQHRshk0eHE4LrkI5Nz0qAAAcz164rHzT2t3D91mpj+ev
         z45w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e67si9814777vsc.31.2019.07.22.09.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 09:32:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 474C430821A0;
	Mon, 22 Jul 2019 16:32:29 +0000 (UTC)
Received: from redhat.com (ovpn-124-54.rdu2.redhat.com [10.10.124.54])
	by smtp.corp.redhat.com (Postfix) with SMTP id DE2DB5D9D3;
	Mon, 22 Jul 2019 16:32:18 +0000 (UTC)
Date: Mon, 22 Jul 2019 12:32:17 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Joel Fernandes <joel@joelfernandes.org>,
	Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
	akpm@linux-foundation.org, christian@brauner.io,
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
Message-ID: <20190722123016-mutt-send-email-mst@kernel.org>
References: <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722151439.GA247639@google.com>
 <20190722114612-mutt-send-email-mst@kernel.org>
 <20190722155534.GG14271@linux.ibm.com>
 <20190722120011-mutt-send-email-mst@kernel.org>
 <20190722162551.GK14271@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722162551.GK14271@linux.ibm.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 22 Jul 2019 16:32:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 09:25:51AM -0700, Paul E. McKenney wrote:
> On Mon, Jul 22, 2019 at 12:13:40PM -0400, Michael S. Tsirkin wrote:
> > On Mon, Jul 22, 2019 at 08:55:34AM -0700, Paul E. McKenney wrote:
> > > On Mon, Jul 22, 2019 at 11:47:24AM -0400, Michael S. Tsirkin wrote:
> > > > On Mon, Jul 22, 2019 at 11:14:39AM -0400, Joel Fernandes wrote:
> > > > > [snip]
> > > > > > > Would it make sense to have call_rcu() check to see if there are many
> > > > > > > outstanding requests on this CPU and if so process them before returning?
> > > > > > > That would ensure that frequent callers usually ended up doing their
> > > > > > > own processing.
> > > > > 
> > > > > Other than what Paul already mentioned about deadlocks, I am not sure if this
> > > > > would even work for all cases since call_rcu() has to wait for a grace
> > > > > period.
> > > > > 
> > > > > So, if the number of outstanding requests are higher than a certain amount,
> > > > > then you *still* have to wait for some RCU configurations for the grace
> > > > > period duration and cannot just execute the callback in-line. Did I miss
> > > > > something?
> > > > > 
> > > > > Can waiting in-line for a grace period duration be tolerated in the vhost case?
> > > > > 
> > > > > thanks,
> > > > > 
> > > > >  - Joel
> > > > 
> > > > No, but it has many other ways to recover (try again later, drop a
> > > > packet, use a slower copy to/from user).
> > > 
> > > True enough!  And your idea of taking recovery action based on the number
> > > of callbacks seems like a good one while we are getting RCU's callback
> > > scheduling improved.
> > > 
> > > By the way, was this a real problem that you could make happen on real
> > > hardware?
> > 
> > >  If not, I would suggest just letting RCU get improved over
> > > the next couple of releases.
> > 
> > So basically use kfree_rcu but add a comment saying e.g. "WARNING:
> > in the future callers of kfree_rcu might need to check that
> > not too many callbacks get queued. In that case, we can
> > disable the optimization, or recover in some other way.
> > Watch this space."
> 
> That sounds fair.
> 
> > > If it is something that you actually made happen, please let me know
> > > what (if anything) you need from me for your callback-counting EBUSY
> > > scheme.
> > > 
> > > 							Thanx, Paul
> > 
> > If you mean kfree_rcu causing OOM then no, it's all theoretical.
> > If you mean synchronize_rcu stalling to the point where guest will OOPs,
> > then yes, that's not too hard to trigger.
> 
> Is synchronize_rcu() being stalled by the userspace loop that is invoking
> your ioctl that does kfree_rcu()?  Or instead by the resulting callback
> invocation?
> 
> 							Thanx, Paul

Sorry, let me clarify.  We currently have synchronize_rcu in a userspace
loop. I have a patch replacing that with kfree_rcu.  This isn't the
first time synchronize_rcu is stalling a VM for a long while so I didn't
investigate further.

-- 
MST

