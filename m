Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F23C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:18:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22EA620684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:18:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22EA620684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7A5F8E0004; Wed,  6 Mar 2019 17:18:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C29118E0002; Wed,  6 Mar 2019 17:18:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B19258E0004; Wed,  6 Mar 2019 17:18:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87C0D8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 17:18:36 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so11389578qkf.9
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 14:18:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=2N9aqlQ4HKUDuST4gxVpBphoZcSf8YauDOaIeVrJnFs=;
        b=DWgkdywcvkgF2dqW0UGCea671HjW5L/AvYtyeKUkFDvIdhDNPte+356Jm8SuFTVr9Z
         0R30S1mgvu4+zRTAXFbRxfX5m138u7zBpN8aCPhKjPUNpz+2qodd4bSHJPDX3AI7CM63
         0A6GwG9P7A53PK8rNUQTzWEsXJmAuySAO1EDvIvq5EJy0tRICxCd81JjpOoB6xIaqblx
         6fBW1IAzbs6qd2iM8tj/5mYwdUpm+gwiivkS/uCiAGrYe6xF+OgkQtyPPbXe6pNJ2sgo
         xow8zNGb5EJKZF8HK5wb+1FJfhvxEYhDBwNygKDo7gEQAt26WBI2fy2yhX2uft+0ztyR
         OFxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjyWBIBuS3zpi564G5fBLKt1vCnaxvCiZUKE4iatlvDFEtaiEL
	8brUhuI0TJLoWM7U9LNDKTaZ8+Kr9I9orTRlYujvel9XMbtUZn/DnR/HZCUey9CyYZo0Liv+KOw
	x2W8CmODmrrsA7LvpDPO0Z9y0jSKFGyT25Y70Z5Ik6ihEfXRR9fvLv8XqK1tD6P+7pWf3fPGoMW
	wLcMSSJhlt0wl4zLW9D4IgFSpv0yzE7r33PFMhrIID8p1KfoXFT8G5JP/4xCoKUPnWM3Lfzst56
	FAt/vITahyhlvnBVFFq8eAZKq2Wkjrn346jg6uVUgUh3u47qKQhQoyJMUa14HfZssIDKq/8Cxhy
	glr19eTX6jOEEOBt5sYlAKOPv4OAqlj/TCxdEbCjAzuLd25SN37p23jOl0dlptHMSLCKz50nlHj
	K
X-Received: by 2002:ac8:35f8:: with SMTP id l53mr7844180qtb.15.1551910716251;
        Wed, 06 Mar 2019 14:18:36 -0800 (PST)
X-Received: by 2002:ac8:35f8:: with SMTP id l53mr7844134qtb.15.1551910715388;
        Wed, 06 Mar 2019 14:18:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551910715; cv=none;
        d=google.com; s=arc-20160816;
        b=UexU5J4MuhyoGTV/dm/HNP5/cyZlpA4sCgi+xsWnlL/IYzS8a6AUHvfhx6DRX/WUfO
         J+PjhRXYS6u5bHqUMWtsqwe0E5DzBpOT44J4HtUFuzDR73nWNFBC3RIDdan1F2qIBnSx
         HC9ZcciYJCRusHUYba357E56T+fJ48r6DKxkH/PfZY5k+e3Zu0AoNsY6M55WXqhRNOG6
         ggjthzB2QTSE5HhAKICAqIZUHMAjqGqhRPd43QAY887y1k22lJ+Aluq5tjoyerDFWqqm
         o8lEav4qBj7rzxs0fNpGqDTKXoVVqQVGSpZrvbZxYXc6WWfgSh7bL3Fw0iZrr8LkzY6b
         gFlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=2N9aqlQ4HKUDuST4gxVpBphoZcSf8YauDOaIeVrJnFs=;
        b=uV9LdWR4DTofjih9wy7vKbBuaAVddEEMZmUJdWqrGot/G+O6ag4mYWmGNJC51yaBrF
         kfu9ogrML/ANzyzX7RlyGaF2LlFG97pWcTlod6WJPCUXqUfaudRDv4y569koyYJ0EGFk
         61q6k0HAOWt4qc8zGkjrd7GmkEDdiXcFJaMhpRRfGeLhitiz+lm4f+CTU8XHSp31hIn6
         CaA5EpVKccwNtD7iZtAGELG6krGbPbi68/mO17jXRrOzTb0OaEi7CgtHfbWBAGHBZdht
         hHqAyOHeLglTlSIsS9HnSEiszS+uLjpkO9yR6gnuFkRvECXfHOFbCdyu/5OVeZi61I8/
         YL8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c192sor1622014qka.132.2019.03.06.14.18.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 14:18:35 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwa7usRRktLyp0btTR2809ewmFaZN798RXEPUOi6V3KI7/AZqnpk1HZl4MAQMWfVpUmYM4Rnw==
X-Received: by 2002:a37:9c8f:: with SMTP id f137mr7487577qke.248.1551910715164;
        Wed, 06 Mar 2019 14:18:35 -0800 (PST)
Received: from redhat.com ([50.235.185.82])
        by smtp.gmail.com with ESMTPSA id o4sm1712887qke.30.2019.03.06.14.18.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 14:18:34 -0800 (PST)
Date: Wed, 6 Mar 2019 17:18:31 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190306165223-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
 <20190306133826-mutt-send-email-mst@kernel.org>
 <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com>
 <20190306140917-mutt-send-email-mst@kernel.org>
 <9ead968e-0cc6-0061-de5c-42a3cef46339@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9ead968e-0cc6-0061-de5c-42a3cef46339@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 10:40:57PM +0100, David Hildenbrand wrote:
> On 06.03.19 21:32, Michael S. Tsirkin wrote:
> > On Wed, Mar 06, 2019 at 07:59:57PM +0100, David Hildenbrand wrote:
> >> On 06.03.19 19:43, Michael S. Tsirkin wrote:
> >>> On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> >>>>>> Here are the results:
> >>>>>>
> >>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
> >>>>>> total memory of 15GB and no swap. In each of the guest, memhog is run
> >>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
> >>>>>> using Free command.
> >>>>>>
> >>>>>> Without Hinting:
> >>>>>>                  Time of execution    Host used memory
> >>>>>> Guest 1:        45 seconds            5.4 GB
> >>>>>> Guest 2:        45 seconds            10 GB
> >>>>>> Guest 3:        1  minute               15 GB
> >>>>>>
> >>>>>> With Hinting:
> >>>>>>                 Time of execution     Host used memory
> >>>>>> Guest 1:        49 seconds            2.4 GB
> >>>>>> Guest 2:        40 seconds            4.3 GB
> >>>>>> Guest 3:        50 seconds            6.3 GB
> >>>>> OK so no improvement.
> >>>> If we are looking in terms of memory we are getting back from the guest,
> >>>> then there is an improvement. However, if we are looking at the
> >>>> improvement in terms of time of execution of memhog then yes there is none.
> >>>
> >>> Yes but the way I see it you can't overcommit this unused memory
> >>> since guests can start using it at any time.  You timed it carefully
> >>> such that this does not happen, but what will cause this timing on real
> >>> guests?
> >>
> >> Whenever you overcommit you will need backup swap.
> > 
> > Right and the point of hinting is that pages can just be
> > discarded and not end up in swap.
> > 
> > 
> > Point is you should be able to see the gain.
> > 
> > Hinting patches cost some CPU so we need to know whether
> > they cost too much. How much is too much? When the cost
> > is bigger than benefit. But we can't compare CPU cycles
> > to bytes. So we need to benchmark everything in terms of
> > cycles.
> > 
> >> There is no way
> >> around it. It just makes the probability of you having to go to disk
> >> less likely.
> > 
> > 
> > Right and let's quantify this. Does this result in net gain or loss?
> 
> Yes, I am totally with you. But if it is a net benefit heavily depends
> on the setup. E.g. what kind of storage used for the swap, how fast, is
> the same disk also used for other I/O ...
> 
> Also, CPU is a totally different resource than I/O. While you might have
> plenty of CPU cycles to spare, your I/O throughput might already be
> limited. Same goes into the other direction.
> 
> So it might not be as easy as comparing two numbers. It really depends
> on the setup. Well, not completely true, with 0% CPU overhead we would
> have a clear winner with hinting ;)

I mean users need to know about this too.

Are these hinting patches a gain:
- on zram
- on ssd
- on a rotating disk
- none of the above
?

If users don't know when would they enable hinting?

Close to one is going to try all possible configurations, test
exhaustively and find an optimal default for their workload.
So it's our job to figure it out and provide guidance.

> 
> > 
> > 
> >> If you assume that all of your guests will be using all of their memory
> >> all the time, you don't have to think about overcommiting memory in the
> >> first place. But this is not what we usually have.
> > 
> > Right and swap is there to support overcommit. However it
> > was felt that hinting can be faster since it avoids IO
> > involved in swap.
> 
> Feels like it, I/O is prone to be slow.
> 
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb

OK so should be measureable.

-- 
MST

