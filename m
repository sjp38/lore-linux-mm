Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CBD4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 02:37:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35B0E2085A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 02:37:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35B0E2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B77078E0003; Mon, 18 Feb 2019 21:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B25CD8E0002; Mon, 18 Feb 2019 21:37:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A14D88E0003; Mon, 18 Feb 2019 21:37:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75A848E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:37:10 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v67so16189033qkl.22
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 18:37:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8g77xX5XEbc9w1ZQ+UBUoak3MQ0n9Lq3RW4jOi+9K7s=;
        b=JbNZK+nJlCFRqdXs539HWyuI9ThnI/0gY6o6cmK2ozKrqCoSngpkgnixx9vk4HAct5
         Xsv8KCif9zzYJWon0wrkVGv+ZWkLaBzUO9/wUoOZd6h3XdpUMj9zNjn/bvaAKzvWxASq
         zMBsY/QmaUwMQJAFXPWIVrSPu/0NXTXom4CxCtU8n9VLTQ6T7qgkwmiwS6h7ARfvMyAe
         94gTobcZTJdblS735baeAbM6xfUFpLG0gydEeVtiOh5GQCDuW8d/x/8Q9rw6VGtGgmt7
         nXvhPemsWnK3yPKGzzZHsSX0HK5ScfQsYWt3nIuoBZRfY+6m8eMKKRcNYlDNZZMJHtIt
         XP/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ8knYDTqQPCMzBvLqZYWSeNvkUfeMT6dKrGXKvwDShnfeTYiOY
	S6HXdoV3a4VvrLHF9/+btKHXNeb3Q78CUGxXdaWyMuX1fRtC3GZnZ+mLOCbljZLM+XXXFd0rvpn
	DmJYscJahKPVVMaEU8P2pRf7t0gN2v8pmXSJ/69x4QlaHfW/8O9NA+dHUtIdLENhb2w==
X-Received: by 2002:a0c:941b:: with SMTP id h27mr19667138qvh.8.1550543830213;
        Mon, 18 Feb 2019 18:37:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8k3U0OGupbdkqgHlNYxJk3RfN+eg7qIH3mMx3l+nZE9Ls2+/fOB2YFocptWlgpf0V80tB
X-Received: by 2002:a0c:941b:: with SMTP id h27mr19667111qvh.8.1550543829455;
        Mon, 18 Feb 2019 18:37:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550543829; cv=none;
        d=google.com; s=arc-20160816;
        b=H/asJarZ0AFVk4QOTYAalKP3jDqd/L3zfjVtGmyw1Fubakm50xkErRvBRCspuQLZZV
         8bql1XFxHdtVyV0Hg4MjZh14uJh5rWh1yfuxY81gDtruxanVFZ1K0PCi2/PBeVpogDcZ
         bxu23x9urCSI8BUs94tgHJYn+RldBXeMZ6cUbXXwijh8RQDoEktmND57yum73M+GBqGN
         +CM1juHh1tz5XfZdivdbtcIbSoe6inTAfcK8xGE9/svTL4597OZFE4nd5+Uun86fMtw5
         Cb4eYmAULX0o4URxiiKXzkkDdqq9oRwXVpnBxJ/Xzs0uhr4289GBd2e94TN1x9m1sx2l
         4SSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8g77xX5XEbc9w1ZQ+UBUoak3MQ0n9Lq3RW4jOi+9K7s=;
        b=ybXEgK/K0Hntoq1/reUF7yADjy9CM48rfQVes86bAiax88zmm3vyUnkJENxnZNaWx8
         IWDSczq4bIDa0yewoD0hghKmn9oN8Ofb8YxYHVTeWdmyhWF65xyDEi3eqflF7j2s0QHT
         2TXPyrfIsXGAkFVuoXfMONNxsnXyucYYxYGmN3k5jRifObrzF0homM/qM0SrGQ2c9Oc4
         2bjWtJLppiGEFLwQUDOMtneMUn8lQ+A3oP1mK/eGdu45MuoP5gb8LvBwJlLvbH1ebrK1
         DVE+FUqTkFGePwraL5l5ckOtpFfH4WWQLIhjqKMYHsGPe50NF9iPJ+KCFzG8DoiOFzVV
         2ZOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r22si2753530qtp.273.2019.02.18.18.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 18:37:09 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 572CBBDFA;
	Tue, 19 Feb 2019 02:37:08 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6C3515D706;
	Tue, 19 Feb 2019 02:37:03 +0000 (UTC)
Date: Tue, 19 Feb 2019 10:37:01 +0800
From: Peter Xu <peterx@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
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
Message-ID: <20190219023701.GA3223@xz-x1>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
 <20190211190931.GA3908@redhat.com>
 <20190211200200.GA30128@redhat.com>
 <20190218160411.GA3142@redhat.com>
 <20190218174505.GD30645@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190218174505.GD30645@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 19 Feb 2019 02:37:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 12:45:05PM -0500, Andrea Arcangeli wrote:
> On Mon, Feb 18, 2019 at 11:04:13AM -0500, Jerome Glisse wrote:
> > So i run 2 exact same VMs side by side (copy of same COW image) and
> > built the same kernel tree inside each (that is the only important
> > workload that exist ;)) but the change_pte did not have any impact:
> > 
> > before  mean  {real: 1358.250977, user: 16650.880859, sys: 839.199524, npages: 76855.390625}
> > before  stdev {real:    6.744010, user:   108.863762, sys:   6.840437, npages:  1868.071899}
> > after   mean  {real: 1357.833740, user: 16685.849609, sys: 839.646973, npages: 76210.601562}
> > after   stdev {real:    5.124797, user:    78.469360, sys:   7.009164, npages:  2468.017578}
> > without mean  {real: 1358.501343, user: 16674.478516, sys: 837.791992, npages: 76225.203125}
> > without stdev {real:    5.541104, user:    97.998367, sys:   6.715869, npages:  1682.392578}
> > 
> > Above is time taken by make inside each VM for all yes config. npages
> > is the number of page shared reported on the host at the end of the
> > build.
> 
> Did you set /sys/kernel/mm/ksm/sleep_millisecs to 0?
> 
> It would also help to remove the checksum check from mm/ksm.c:
> 
> -	if (rmap_item->oldchecksum != checksum) {
> -		rmap_item->oldchecksum = checksum;
> -		return;
> -	}
> 
> One way or another, /sys/kernel/mm/ksm/pages_shared and/or
> pages_sharing need to change significantly to be sure we're exercising
> the COW/merging code that uses change_pte. KSM is smart enough to
> merge only not frequently changing pages, and with the default KSM
> code this probably works too well for a kernel build.

Would it also make sense to track how many pages are really affected
by change_pte (say, in kvm_set_pte_rmapp, count avaliable SPTEs that
are correctly rebuilt)?  I'm thinking even if many pages are merged by
KSM it's still possible that these pages are not actively shadowed by
KVM MMU, meanwhile change_pte should only affect actively shadowed
SPTEs.  In other words, IMHO we might not be able to observe obvious
performance differeneces if the pages we are accessing are not merged
by KSM.  In our case (building the kernel), IIUC the mostly possible
shared pages are system image pages, however when building the kernel
I'm thinking whether these pages will be frequently accesses, and
whether this could lead to similar performance numbers.

Thanks,

-- 
Peter Xu

