Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02A60C00319
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 02:43:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEFF220663
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 02:43:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEFF220663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4468B8E0004; Mon, 18 Feb 2019 21:43:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F47C8E0002; Mon, 18 Feb 2019 21:43:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E4FD8E0004; Mon, 18 Feb 2019 21:43:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 024AF8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:43:56 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a11so16357959qkk.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 18:43:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7nuzjGEN3Ckz2/FpGK6XDH+gQvj44RMZdAbtLfHihNg=;
        b=aTKVy2szuqleW9b7UQu7RIbeqveLCStRvjKhj5rsxI5Zf/36TXxMjVqBudRaRWWpOa
         zx0QLBybOWYZKEeyXParISQ5RuBdLfV04U4YrBxjEuILkeWDZEr6fy9o1kMqMmjnA+ST
         uRc5XFOGi2zXEGpDjNkPtJCr3Pa5cwnbpukp7oKkWuZNPiMAn+85/MTZZ4xtsL8yvKMb
         Ztz/2dJxkpSvJzl2p6LV4s12g0nA+ggGhl4JOfiVqkXoPUsSuXSYZ9W/wNYfl26owh/I
         UOinTLx686bGhueQw67jQe1gzSFKPwZ3MyV/VarLTiUrpU9LeBB8kSIVdnKCFjcWU8ma
         JSpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubYM5CTj+9BJehlRc12/dndeoTOKnXahgg8rsyPr8bB6C45QmMc
	VcFw027bTG6F7qjoE3pcNU4HGkK+hvTH830lAa1z6ewpSAevWG6v1aNQaPIemM8O6hEnCHoxPgh
	dpIk7/biBHIJBoia369uoJArcDn2cLs9vnLV3LYU6kJyXYdJFGwElmBhs2f0HWPsaog==
X-Received: by 2002:a37:96c3:: with SMTP id y186mr18268792qkd.166.1550544235668;
        Mon, 18 Feb 2019 18:43:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZCfzz5UwqmEKaXGaqjpPwXlmIke8lNBwd9l1k2y1GBdElxfg4YSY5aXoo72xpb/3SQPhdo
X-Received: by 2002:a37:96c3:: with SMTP id y186mr18268767qkd.166.1550544235017;
        Mon, 18 Feb 2019 18:43:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550544235; cv=none;
        d=google.com; s=arc-20160816;
        b=W4ld53V0F0BYwnPekT98j+07hV9PoYEHK+P0GRVAriY/ZMi9dwMV+iOVF7+ixyhVC1
         Q5VSMUwL+mDmSYc9pbzq9mSUbOLY6wA44+JtprG5ZcmWLv4cH4mlIZA9uUwoeYVFgSmS
         cd84LDkQUzi7RNbZRM9Jhtbo65Xv8JvMtQovH/FRnvZHQi2FN1hUY+rk7nvvU6J4mcI7
         wug+fHrmSviwHKm4ObbTf3lByu7oneeJhlkZe6OSVtiKrtbQR91IQ+mWrdCbJPjyZv5u
         WlMwdbCyUc2/FwpwnU1dnuWG4tWjnnu9czS70c6xub5RzePRPYtH9NSqWRIuDRKIJ7iF
         /7sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7nuzjGEN3Ckz2/FpGK6XDH+gQvj44RMZdAbtLfHihNg=;
        b=n8YLURIu7eZFRirYPRjpZilyXcC3DIY8gN/SVKLnIVM3FJnxh6pKCO9lqmwPL7McBB
         qIjsHKu9QejlwLWHjg1ooOXTzpP8H1OGm6o2QLU/d+CoEETexbk1lcd04xuChF6mmjnY
         V5Yk43aSVq5q7GLaxwIpHjhLbcDYQQ1+MBPmDyBi5fRo+2IzV+BK8NjlCCtQoVj6cFMk
         slpLY0Wmn9ROsK1OetFkK1q7R6UogHueC0fiyTMNnz1RbrNmSnrR1cPSOQzQK7CZ4uZM
         VT17g/N4cjR5wHlZenfoYXUZT07lts1Do7FtutHnvYwoEtDp9H+f7URtpD8g8NVVKqFR
         lQ8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si3292597qve.14.2019.02.18.18.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 18:43:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EEEEC804F2;
	Tue, 19 Feb 2019 02:43:53 +0000 (UTC)
Received: from redhat.com (ovpn-121-82.rdu2.redhat.com [10.10.121.82])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3F2991024909;
	Tue, 19 Feb 2019 02:43:49 +0000 (UTC)
Date: Mon, 18 Feb 2019 21:43:47 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] Restore change_pte optimization to its former
 glory
Message-ID: <20190219024347.GA8311@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
 <20190211190931.GA3908@redhat.com>
 <20190211200200.GA30128@redhat.com>
 <20190218160411.GA3142@redhat.com>
 <20190218174505.GD30645@redhat.com>
 <20190219023701.GA3223@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190219023701.GA3223@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 19 Feb 2019 02:43:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 10:37:01AM +0800, Peter Xu wrote:
> On Mon, Feb 18, 2019 at 12:45:05PM -0500, Andrea Arcangeli wrote:
> > On Mon, Feb 18, 2019 at 11:04:13AM -0500, Jerome Glisse wrote:
> > > So i run 2 exact same VMs side by side (copy of same COW image) and
> > > built the same kernel tree inside each (that is the only important
> > > workload that exist ;)) but the change_pte did not have any impact:
> > > 
> > > before  mean  {real: 1358.250977, user: 16650.880859, sys: 839.199524, npages: 76855.390625}
> > > before  stdev {real:    6.744010, user:   108.863762, sys:   6.840437, npages:  1868.071899}
> > > after   mean  {real: 1357.833740, user: 16685.849609, sys: 839.646973, npages: 76210.601562}
> > > after   stdev {real:    5.124797, user:    78.469360, sys:   7.009164, npages:  2468.017578}
> > > without mean  {real: 1358.501343, user: 16674.478516, sys: 837.791992, npages: 76225.203125}
> > > without stdev {real:    5.541104, user:    97.998367, sys:   6.715869, npages:  1682.392578}
> > > 
> > > Above is time taken by make inside each VM for all yes config. npages
> > > is the number of page shared reported on the host at the end of the
> > > build.
> > 
> > Did you set /sys/kernel/mm/ksm/sleep_millisecs to 0?
> > 
> > It would also help to remove the checksum check from mm/ksm.c:
> > 
> > -	if (rmap_item->oldchecksum != checksum) {
> > -		rmap_item->oldchecksum = checksum;
> > -		return;
> > -	}
> > 
> > One way or another, /sys/kernel/mm/ksm/pages_shared and/or
> > pages_sharing need to change significantly to be sure we're exercising
> > the COW/merging code that uses change_pte. KSM is smart enough to
> > merge only not frequently changing pages, and with the default KSM
> > code this probably works too well for a kernel build.
> 
> Would it also make sense to track how many pages are really affected
> by change_pte (say, in kvm_set_pte_rmapp, count avaliable SPTEs that
> are correctly rebuilt)?  I'm thinking even if many pages are merged by
> KSM it's still possible that these pages are not actively shadowed by
> KVM MMU, meanwhile change_pte should only affect actively shadowed
> SPTEs.  In other words, IMHO we might not be able to observe obvious
> performance differeneces if the pages we are accessing are not merged
> by KSM.  In our case (building the kernel), IIUC the mostly possible
> shared pages are system image pages, however when building the kernel
> I'm thinking whether these pages will be frequently accesses, and
> whether this could lead to similar performance numbers.

I checked that, if no KVM is running KSM never merge anything (after
bumping KSM page to scan to 10000 and sleep to 0). It starts merging
once i start KVM. Then i wait a bit for KSM to stabilize (ie to merge
the stock KVM pages). It is only once KSM count is somewhat stable
that i run the test and check that KSM count goes up significantly
while test is running.

KSM will definitly go through the change_pte path for KVM so i am
definitly testing the change_pte path.

I have been running the micro benchmark and on that i do see a perf
improvement i will report shortly once i am done gathering enough
data.

Cheers,
Jérôme

