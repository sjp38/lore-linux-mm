Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B8C7C10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:20:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9B042146E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:20:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9B042146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76AFB8E0005; Mon, 18 Feb 2019 13:20:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71BE78E0002; Mon, 18 Feb 2019 13:20:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60C6C8E0005; Mon, 18 Feb 2019 13:20:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 375968E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:20:32 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id a65so15544848qkf.19
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:20:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=XYhCdaRsobAyr1YQNmdqqfI6DqZjGWBF6zNtGe5tfPM=;
        b=SR24vufVMNX5oe7FBIX0XsqLUbYQ56+5XujBHxSlt592TGb6S/K3MQn+vY5brp2EfC
         Zsaop9vI6y1mUxzR+oEf4XXe96F0AfW/tqh4Y15MdOATnlG9XgY/3TB4i0Ny56YA+fq+
         foz3zop5oX+uyJFYVvvl6JSiTftPFUz01zbuklDVAhTTLZdp0u/epkagPnf+YRCxZc+t
         ACTcGP/W35sS2YS/q48EitfZhdt1bb2YXRDkeNNb9Ehu0dGrzh0Lv0v4yjXenTePZJh/
         nC0wLzjwoGiLLrXnVPNU+yN9jWBetguKTjdTxrHuiw1B9Gkry13of6yDmLMdV149MJG1
         flLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubMZnY8/pGO/3/Snj5S9NvK/jVD2vWtrH1AXQ6gPSXVVEMXYc0X
	xaQ9OR8dcZKhMIg2g35ILXrWImokiMnSRSyaW7h9vQf52pfeKOcxCCRfl+HI9fOhODfM+Rm5TpJ
	kwYTcaAeetv3FERELLNyB2AYL7GgM+ExtY+jFntFq37Yf0wwMkrWhFBjrjAhsBqq9ag==
X-Received: by 2002:ae9:ec0f:: with SMTP id h15mr18306290qkg.100.1550514031994;
        Mon, 18 Feb 2019 10:20:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafmaQ/w5M4BJ1qicCEhAYIEgHZZWrNiC7SPCoJ3OjpNLsOcxE0rnJRb9mLcaTKzuXDRgV/
X-Received: by 2002:ae9:ec0f:: with SMTP id h15mr18306246qkg.100.1550514031320;
        Mon, 18 Feb 2019 10:20:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550514031; cv=none;
        d=google.com; s=arc-20160816;
        b=w8pjIcE3yQ4Sm/GT2gBL8T5Yeeb4avIJXNVRdQt+vXCdkGlDgpzbAwkcGWMSy1C3yg
         oM6/+JB8HoqTaBK0ICnst/xr5/JKPR9ltDhvnpHod31YfcB8JdaHvt0tqi5SxTuJP74T
         HruMCznN3Gdn1ay1Dl7M/nE8GV8pYpfV3axRkM8pjB5vlMbV9/mLvbGub8WPS2LBm9xi
         QTE8bAdP0UCHLvRPTqcFd9gOKTC3ELQlMIeABTOz8g3kqVUekkC6/AND5BK5cNRm2X4Z
         mdO2V5eef0Msdn+5RakqxKS4BpSsAqR8QdLYnjojLSruSn1tvkLQ2VE2dxaunjN4qghL
         9HUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=XYhCdaRsobAyr1YQNmdqqfI6DqZjGWBF6zNtGe5tfPM=;
        b=Bl7noE2Xo06MN5sbbguGQZStEZbQMm5YIXW5dJ1tKSQpKW8zK5nbR0wTE0cCxPCWaw
         6raoSNIf1jyh4I3PU6a8/qF5lydybLdiUi7Y0ZCGYDDNAjtQwX4ONtsjt21NtwK5WEXk
         CNnj+rW0Uplx+5R4YAKcodw8uT38GNhiX142F6GqCoCrfyJQxmYo8kw+6MLQDELeSkXL
         rYS9IhN6aespy9Y0AyE9uUHHC3CCf1w4GNxtTOP519Xg7SSXBO1ytX3KS8Ms8CtqdfnU
         jecdiJDK6TGztCRUdxF+uDaj8A+On0rY5lll1gLn+WO4z+zNGihIl02O9m+3Bonv2j7V
         TBzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w27si2283168qth.1.2019.02.18.10.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:20:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 684C810F85;
	Mon, 18 Feb 2019 18:20:30 +0000 (UTC)
Received: from redhat.com (ovpn-121-173.rdu2.redhat.com [10.10.121.173])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 88BDF5D706;
	Mon, 18 Feb 2019 18:20:28 +0000 (UTC)
Date: Mon, 18 Feb 2019 13:20:25 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
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
Message-ID: <20190218182025.GA3470@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
 <20190211190931.GA3908@redhat.com>
 <20190211200200.GA30128@redhat.com>
 <20190218160411.GA3142@redhat.com>
 <20190218174505.GD30645@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190218174505.GD30645@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 18 Feb 2019 18:20:30 +0000 (UTC)
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

No but i have increase the pages_to_scan to 10000 and during the kernel
build i see the number of page that are shared increase steadily so it
is definitly merging thing.

> 
> It would also help to remove the checksum check from mm/ksm.c:
> 
> -	if (rmap_item->oldchecksum != checksum) {
> -		rmap_item->oldchecksum = checksum;
> -		return;
> -	}

Will try with that.

> 
> One way or another, /sys/kernel/mm/ksm/pages_shared and/or
> pages_sharing need to change significantly to be sure we're exercising
> the COW/merging code that uses change_pte. KSM is smart enough to
> merge only not frequently changing pages, and with the default KSM
> code this probably works too well for a kernel build.
> 
> > Should we still restore change_pte() ? It does not hurt, but it does
> > not seems to help in anyway. Maybe you have a better benchmark i could
> > run ?
> 
> We could also try a microbenchmark based on
> ltp/testcases/kernel/mem/ksm/ksm02.c that already should trigger a
> merge flood and a COW flood during its internal processing.

Will try that.

Cheers,
Jérôme

