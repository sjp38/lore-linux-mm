Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4108EC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04A0B21902
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:34:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04A0B21902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72EB98E0003; Mon, 18 Feb 2019 22:34:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B51F8E0002; Mon, 18 Feb 2019 22:34:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52DD88E0003; Mon, 18 Feb 2019 22:34:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 219178E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:34:06 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c84so16554640qkb.13
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 19:34:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=2qXAXDL9aCrq0FY6ABLJ09ttXcLo14HgxmJ7UzFuA2o=;
        b=N8C5HfUWlqBPxKjVnOs4NwsVHsA2FlD+xZb6kQdzr4yq002Vv29k0wnxhSSOnBClsp
         8YJnkKW5EIayYlJ+8dr6sRIFcBl0SuiiFuNjuNbjAjlMYju/G80cuIIfPHv8RG803c4n
         hbxjFKXIgErBecNPwy28KeY34WO1KfEEhurTTgnPdgRvEZ2S+6cEiou79kq1OWNJbHlp
         /0TJ9cXaU+j22jZpXUbs8ablgZRTFIR7NKgG6R/HI3rULpaewWwnSgRp7zise1YUJtW8
         osDwkhkrgMPluCou/aBUh9UbbJKUVfBtQyjE7Upit65MskI/D2j8Q0UHTDqShLb9zohw
         2VZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubaPRK+nxqKwZ/6Ao8MKdheOrH5oA9PmoFIJtslFPEbpIlQPdWW
	YVArRsNraz9t76nJlD2X7+wyvSZD+NMxM4PcJORSXUMxWtuaYpnpqTFbURUZaVszC1NjK9vvhXY
	SyuaqcBOiCvbLYoa9/V5z8dYM800//UWB8PRo+nWSaDzUlgeqMt4inIUbooqvayCfSw==
X-Received: by 2002:a37:73c1:: with SMTP id o184mr19214773qkc.130.1550547245885;
        Mon, 18 Feb 2019 19:34:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia99PdmNi516EiLt1esQaRTc4vY4kQKqcaMw08vpyjeZ4SNVbNTuekpVocqbkJDSx/D1ful
X-Received: by 2002:a37:73c1:: with SMTP id o184mr19214756qkc.130.1550547245168;
        Mon, 18 Feb 2019 19:34:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550547245; cv=none;
        d=google.com; s=arc-20160816;
        b=swA0PxAJnHsvB/Krt3aDxUPVNjZYVjlVA2rUqad1jkSGFsxsQXxOvHngr0dXejln2g
         lC0I41aLsLepaUQ5hgkrcw40uuTkiB8YFJhCsm0LlUvPUIwPvP2B+70lPYzJAMp/xV3X
         nHpaUCHOKCwVXZxuhMizlqlBmcfqNGeW/vf/8U9UkysBJnGWGsgjHLvPM3YL5vV+hRQl
         71BIzdUthA4wOnfObF5V85XmB/8U9/Z85p5QH7N5M2n8UBfxdQRmQxh8wsYVPjQD83Ma
         mfuYHMKz91AQEtJAqYpAw5DYb4OexcVPZ1maUUWWpkVwubkHK/UBkfhNC2ceZF29ArMH
         9RDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=2qXAXDL9aCrq0FY6ABLJ09ttXcLo14HgxmJ7UzFuA2o=;
        b=z75pkRrhI/tAVGV57wOEPsGn9aF7PSlUrF750SChg5Hw+MdXUk1UxQt87SsDRX56NG
         94QgOWdfiA+dI0a9KRm6EDagR3YnxuG0gwwPXj5qjuVWgfDxafr7DhwMzH2df5Ryw4Wl
         eI+w/cSSb4hriTlzCd0cp40zT47+AsgvFzRRfNi5V0drHGKa1XoTaLY4tKLJ04jGIS68
         OEswjnHQFstVx56VDSTblHANyL2+7VP9eblB8sPcKfBI5yzmvxhXeM6RrnxyTOf3uhhw
         RpTEo2xFYIz7NqmiY0j9yW6SgBykL8E2igJtzODEhFnG0MapX2WSotWyz2B4BtJEie78
         Da9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f76si1437703qke.63.2019.02.18.19.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 19:34:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 32520C007327;
	Tue, 19 Feb 2019 03:34:04 +0000 (UTC)
Received: from redhat.com (ovpn-121-82.rdu2.redhat.com [10.10.121.82])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 831FE5C1B2;
	Tue, 19 Feb 2019 03:34:00 +0000 (UTC)
Date: Mon, 18 Feb 2019 22:33:58 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] Restore change_pte optimization to its former
 glory
Message-ID: <20190219033358.GB8311@redhat.com>
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
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 19 Feb 2019 03:34:04 +0000 (UTC)
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
> 
> > Should we still restore change_pte() ? It does not hurt, but it does
> > not seems to help in anyway. Maybe you have a better benchmark i could
> > run ?
> 
> We could also try a microbenchmark based on
> ltp/testcases/kernel/mem/ksm/ksm02.c that already should trigger a
> merge flood and a COW flood during its internal processing.

So using that and the checksum test removed there is an improvement,
roughly 7%~8% on time spends in the kernel:

before  mean  {real: 675.460632, user: 857.771423, sys: 215.929657, npages: 4773.066895}
before  stdev {real:  37.035435, user:   4.395942, sys:   3.976172, npages:  675.352783}
after   mean  {real: 672.515503, user: 855.817322, sys: 200.902710, npages: 4899.000000}
after   stdev {real:  37.340954, user:   4.051633, sys:   3.894153, npages:  742.413452}

I am guessing for kernel build this get lost in the noise and that
KSM changes do not have that much of an impact. So i will reposting
the mmu notifier changes shortly in hope to get them in 5.1 and i
will post the KVM part separatly shortly there after.

If there is any more testing you wish me to do let me know.

Cheers,
Jérôme

