Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D52CC742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 19:48:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17E16205C9
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 19:48:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17E16205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A4578E0167; Fri, 12 Jul 2019 15:48:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 654D38E0003; Fri, 12 Jul 2019 15:48:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56A338E0167; Fri, 12 Jul 2019 15:48:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 072E88E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 15:48:48 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j10so1766227wre.18
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 12:48:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=jABvRKoWALhXYjFDAf1DmRmFdR0kn3l+wTT81rhGhWY=;
        b=eqWIiirFH8nFfLJ0+Mr6JOj6tXLJDfbpOWAsZ7FE4zWUPa1w+SBhENHNbDRRwNbpdH
         2+YWFko8qxam+EtLJH8S5c8gh6XNC/hm2PbUdhn+bXlBBqQ1Y1Z+fZLE3unfmD5lH0vG
         wn+oN13mIV+Xbz9oTO/0AX2EAU8JiKFtDTRzFhhSkJtBc9pu6ie2gOiTZm9pQZNtr9w5
         Y+8G7uqy05kn7GsPJI5DB32jUOC7JtNJpkY95yUt07tKJyADV89Ou1TgYSC4O77QD85r
         FJ9L2wefwIMf9QaxgI45POvlI7h+ovo6rk93PKxKjs2+LBsqwQzNEGQ4r/FAKf9YmD5v
         ehBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWTZYvx8Vvfhmd6rLKwJ6g9vJgY7sEhkB0xs+sdkZwwi6qS4uiI
	XK6YjCysOW0EXaQF1icJwigqFWpADN6hM3LKJStbKF3m2tKupGp3EVZHj93+g8TALjEMLIctt+B
	rxr+MUfeePf1nHUkSPHKq+7knXD5qsPRmiNOo+orUelK11tLBsDoIMaRvNeMnGRMp+w==
X-Received: by 2002:a7b:c4d0:: with SMTP id g16mr11228374wmk.88.1562960927515;
        Fri, 12 Jul 2019 12:48:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxAchf8Fi+rDHBAZWH+nBeQZn6tHAPJxyBTyx+USqEm7ZO5vHfMe7QNH3uSBzXvzrP8fHk
X-Received: by 2002:a7b:c4d0:: with SMTP id g16mr11228344wmk.88.1562960926432;
        Fri, 12 Jul 2019 12:48:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562960926; cv=none;
        d=google.com; s=arc-20160816;
        b=GjCZnKngLKF6zbo92vaX6pbmvoC00xtAUe197rsj/oX0X4Lp8zsYNjlFgCwYh72lnT
         TYNu2wz33XXXDiAgH3F4RGbhYt/L0yANeKaXlL6BJINqX0WkCnPTIGNOKH984Ynd3jBU
         7p+rvTBEXKuSdGp9lJkZKVlWHWQQ7pn0UBgHvi+ZU42ENKTR6GSU6Upnz2D/4qiGjo7J
         KJULDd6wjbz2UKbImaPHoN25QspG64+qsupqQi3f1AVslL+ocKP7zRUbqOhhRX5k2Xaf
         P/m5avp7T4qLc4BKmUz8YQW+QiCuRiWmqEw+TdX3rANOAD6/K5psLqhq+PNI3d9MEZGV
         gl2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=jABvRKoWALhXYjFDAf1DmRmFdR0kn3l+wTT81rhGhWY=;
        b=QS/RvFJHea9Wh3sBxpb3hnOgC+2QPZTiE/h2z7Vmxzuq/fY5i3hmAtt5cEGPocp+HD
         JNxN41cq2oC9Y33GZkPxaYfj0ZC39zGaZJxrXriHOQNbXHDOu2Pd1YzzhMgeO2kruiVH
         P/J/FZuyjK9Et9nSQspJU2IAjVPha+IwindMgn8WJp0FCCJaSVUzJZUI17Kf60FoVQT5
         vuTqxyGxXa19csBmqsUNyN1WiifJ3UkDio0tKO8/sNMtk8EliXSNAI76cEsqeGAzzYdE
         7BLhNLXOCKI5qYHC8UpYaWceqf/VRcVqshwybzdJX+X5+mpperRmd0AeIklYweRjNByA
         B/WA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id j4si7758125wmb.100.2019.07.12.12.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jul 2019 12:48:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hm1Ws-0007gn-OD; Fri, 12 Jul 2019 21:48:26 +0200
Date: Fri, 12 Jul 2019 21:48:20 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, 
    pbonzini@redhat.com, rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, 
    hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, 
    kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, konrad.wilk@oracle.com, 
    jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com, 
    graf@amazon.de, rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
In-Reply-To: <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
Message-ID: <alpine.DEB.2.21.1907122059430.1669@nanos.tec.linutronix.de>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de> <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net> <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de> <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jul 2019, Alexandre Chartre wrote:
> On 7/12/19 5:16 PM, Thomas Gleixner wrote:
> > On Fri, 12 Jul 2019, Peter Zijlstra wrote:
> > > On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
> > > And then we've fully replaced PTI.
> > > 
> > > So no, they're not orthogonal.
> > 
> > Right. If we decide to expose more parts of the kernel mappings then that's
> > just adding more stuff to the existing user (PTI) map mechanics.
>  
> If we expose more parts of the kernel mapping by adding them to the existing
> user (PTI) map, then we only control the mapping of kernel sensitive data but
> we don't control user mapping (with ASI, we exclude all user mappings).

What prevents you from adding functionality to do so to the PTI
implementation? Nothing.

Again, the underlying concept is exactly the same:

  1) Create a restricted mapping from an existing mapping

  2) Switch to the restricted mapping when entering a particular execution
     context

  3) Switch to the unrestricted mapping when leaving that execution context

  4) Keep track of the state

The restriction scope is different, but that's conceptually completely
irrelevant. It's a detail which needs to be handled at the implementation
level.

What matters here is the concept and because the concept is the same, this
needs to share the infrastructure for #1 - #4.

It's obvious that this requires changes to the way PTI works today, but
anything which creates a parallel implementation of any part of the above
#1 - #4 is not going anywhere.

This stuff is way too sensitive and has pretty well understood limitations
and corner cases. So it needs to be designed from ground up to handle these
proper. Which also means, that the possible use cases are going to be
limited.

As I said before, come up with a list of possible usage scenarios and
protection scopes first and please take all the ideas other people have
with this into account. This includes PTI of course.

Once we have that we need to figure out whether these things can actually
coexist and do not contradict each other at the semantical level and
whether the outcome justifies the resulting complexity.

After that we can talk about implementation details.

This problem is not going to be solved with handwaving and an ad hoc
implementation which creates more problems than it solves.

Thanks,

	tglx

