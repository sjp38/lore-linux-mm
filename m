Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 627AFC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 13:41:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29E8A216C8
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 13:41:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ctSiEsOE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29E8A216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B00788E0001; Mon, 22 Jul 2019 09:41:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A89406B0008; Mon, 22 Jul 2019 09:41:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9295E8E0001; Mon, 22 Jul 2019 09:41:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6446B0006
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:41:55 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t196so33674559qke.0
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 06:41:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=r7jurWEbcB87wkHM6FBIF/d6ZCsIeD3qrag1BaWvzr0=;
        b=QR2B0i5mhMJ8Kp3QmIH+N0SbAhSErxaI4+W4PWT6z1e8ruSHOCP0ig8I4bbra+LUbM
         q9Ge85gsA0NWmX7V43GXDC0TV6wS8tnmsXMv6Vc/UHCR3y69LUcLifboAKdTMUU+JqqH
         g/SPPIsAoL5LZWkVqDLC1BPuF4HE6okZcs5O1s04GE5PxeVkC7dV/u6r7H14VeVEH+LX
         i1efEDGXV1tYTqCY2RGyKIcTuFpHZURsk8pRh0tQZrCDg8oofmOraeGleBmrZKK55XxM
         6Qg0+n5S+tAi3fmdi3tLbi6qTdPkTYIWNO2t5SDC4ZFDRW64MVI/pFpIXIyANct7PBF7
         FDew==
X-Gm-Message-State: APjAAAXllJJLcJIIdw01PsX6tOY48/YcaUUcuAAYHGBotXInEqaC7dxS
	q3eD9+A+jzI6G51M9VQ06wfxyZnR9+qEP1GcYYeQN+chn/z8xCYSTxGP//scjaKnoxTYh9vA+kF
	Ig36KEWhfm2L8lg7AGBdYkr1S34iGGyzUbhCGstrmo4eG3IwF7UZmryv9znB+xc8+fQ==
X-Received: by 2002:a0c:86e8:: with SMTP id 37mr52211932qvg.77.1563802915168;
        Mon, 22 Jul 2019 06:41:55 -0700 (PDT)
X-Received: by 2002:a0c:86e8:: with SMTP id 37mr52211884qvg.77.1563802914377;
        Mon, 22 Jul 2019 06:41:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563802914; cv=none;
        d=google.com; s=arc-20160816;
        b=kPkaYIHxci3xWYPI4ZFR2ox5jKvNJw605EQAMEPVuWJciWOhTZu44mdoBiO1cnWeVi
         JS9FDzuW4Jh3eKJOst/UbLcrd5sYD8s6SmNNPc6IWLIDmLVFMFLBdJ7ChsZqdxdtYhEx
         d4NTxrNRnDU8sDT13e86N8baLdYBhNZxRysJzt/WyietRiyFHh6HdOtlpQxjBs0NkNnS
         DwCJUmTspBw4A7dlV6O2J74jpKWABh6sTL0c0s0T34ZMRgDveMkP1mAmJa+aiejwJhBu
         8FoO9Le9dWGLXl/z8gBYHyoQi0N2We6b2HdA6UHHeQqegioMMJRJ+U+jnlRxgv4Jbr5q
         jVdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=r7jurWEbcB87wkHM6FBIF/d6ZCsIeD3qrag1BaWvzr0=;
        b=lcTJ/I0DjA63qTW7oXMLWN8mwnryFxCJF1QuoZ14vCxNt5l8az6fbeDDO0L9E6QU6x
         MNmAuMNPpcWyj18doCchwUaaYhLzMXGypmya6p2MYZLom//G4vn/cKAy7DLeAOGD0WnK
         l3hnmP1uERYrsmVz/TOMNe9lPdp2V4s7NuImFiljSBLVyeANrwhDrH79gdU/21qrr3bm
         /6eM0sye8BwzgzQke2oDON3XSvgQcFE3fMwJ73HU2oTYw46wB0yOFv5sYXEyE+Ox8TyZ
         llUTPlaMVY4yQWZGZuo0g0r7wWWQauRE6Wj6Lao/sYxJggqZ6nGCmgPIhPOJ/gIjcmfI
         ovVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ctSiEsOE;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r125sor22764679qkd.29.2019.07.22.06.41.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 06:41:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ctSiEsOE;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=r7jurWEbcB87wkHM6FBIF/d6ZCsIeD3qrag1BaWvzr0=;
        b=ctSiEsOEiyiwu0n3CEQABL3/Tosruh5w/+6uzF92xLW34JmyfhThCGBMfVUaYt9dcx
         eW2R16GiG0XcoxTfHQmNNe2NbtDmD4V4zDlbn3sIafmR+axGp5w7q8jG/t+N5A5vd1+2
         T8limk/5bxxJguypRZGjOMgCVjJ3UuJ440SlT4VBiuew99yPu+wjBAGDyiX6h7A0CwOA
         dwL0M70N/ZKBJ7e/9dDovVWnU15MNgA7ZpwwgLu6rerH2A7rFP/VNIWBW0CDFkWJkGIk
         02tVH4RCMUcpMeH+V7LrZ4lwFpUMFWob0uRUx2w20StfeAVPWAbvrasBs/AM3w8QAsz1
         Qvkg==
X-Google-Smtp-Source: APXvYqxGgJ5n0Ggl2+5KtjzE7HLyY29aRN+3J2KTmJj1bDyPcTuyXmhCmMkJ3yMp7O1QI/DGhNTc3w==
X-Received: by 2002:a37:a6d8:: with SMTP id p207mr42748278qke.387.1563802913858;
        Mon, 22 Jul 2019 06:41:53 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id x8sm17451291qkl.27.2019.07.22.06.41.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Jul 2019 06:41:52 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hpYZc-0003Vr-7E; Mon, 22 Jul 2019 10:41:52 -0300
Date: Mon, 22 Jul 2019 10:41:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
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
Message-ID: <20190722134152.GA13013@ziepe.ca>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722035042-mutt-send-email-mst@kernel.org>
 <20190722115149.GY14271@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722115149.GY14271@linux.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 04:51:49AM -0700, Paul E. McKenney wrote:

> > > > Would it make sense to have call_rcu() check to see if there are many
> > > > outstanding requests on this CPU and if so process them before returning?
> > > > That would ensure that frequent callers usually ended up doing their
> > > > own processing.
> > > 
> > > Unfortunately, no.  Here is a code fragment illustrating why:

That is only true in the general case though, kfree_rcu() doesn't have
this problem since we know what the callback is doing. In general a
caller of kfree_rcu() should not need to hold any locks while calling
it.

We could apply the same idea more generally and have some
'call_immediate_or_rcu()' which has restrictions on the caller's
context.

I think if we have some kind of problem here it would be better to
handle it inside the core code and only require that callers use the
correct RCU API.

I can think of many places where kfree_rcu() is being used under user
control..

Jason

