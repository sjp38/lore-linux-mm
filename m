Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5045C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:43:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 804A22087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:43:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 804A22087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 193856B0007; Wed, 27 Mar 2019 08:43:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 143E46B0008; Wed, 27 Mar 2019 08:43:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 031F96B000A; Wed, 27 Mar 2019 08:43:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7BA46B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 08:43:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d10so13999722pgv.23
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 05:43:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=424Xw6WjTQ8R5+agmVp6DdmUW0Ytxf7ZEapbxiXMf7w=;
        b=EMR0mospHcJ3XBAJPDOcx4s4jqfazXcXO2Brx3bTluS3fowF8C/fGpE1X0DuMCO4qA
         17fToLTwenREDgRWmaPdeBC0D+3VgkpJKLcgLajOXMkF3y2bb05bR7gRaYPUZUXyv0Ik
         /XfC1QAHz8uOawV7GM+ZON6cu4N1kzlGZa9s4x32kXS1DS5o+fViefqTQOXWnrUFDQ0a
         dvo1mkCu1TvaxLfYBCzvw5Q+hElQUX9zoBwiUK/y4QxIw5FuoDyn9mxSvcgZZC8EIeKu
         3GWhP49Y9waV+M12kW2gQDyld9Pmg/XcaVr7dbBzIYwttsAKLQxuBzLjdeO7wutf0rPA
         DNYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUEfD3bklonn9366SAArvnSUPEPiOI31skQIJLc5c0izKdttkvS
	z5cizRd38Ax2lV1tF1Oaf0xYUjm3VtRXyD7xWbe49eU9X+LQRZjRQrFlw2iRBirnvVEW55tWTD9
	f9QLtFqQqCI6a+efzCYHMcfsoPDjIoF5+RTLj5n4xRPQMfj+hhNqmofiBBV/bN3XUZw==
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr29045096plo.298.1553690599320;
        Wed, 27 Mar 2019 05:43:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyijLoMRdciuTkJCmkZxTHFCo55joxt+Vfamv7pKevaEufruBjMh8vdNneQRwCuKVw1S90B
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr29045021plo.298.1553690598392;
        Wed, 27 Mar 2019 05:43:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553690598; cv=none;
        d=google.com; s=arc-20160816;
        b=xVj+V+fXC7ThDXmlshtiFjECJ2wdYLF8N8IETH44AMiBjJCeyjK87+yEM7+pNaog4M
         jBHhgFVFvnZ5E9318vMgB6rA06XjZbHw8taROYlSNkJL6vVtpABqvVTdhDUkZLkmYrcI
         c22/VVTh7oOGuS8YT6RoWW423O63ertaC+SBd1+FaL+/p9Cj2qprzQpkiW6wTGGoewjm
         Z7Sise93qZ1aqoN2VG3cZ3IAf77p52XrCOgPtEyUKmMCQ9/bhwldVklWX3pS2FEIQm4P
         /q6ByOT//EbPjusLjPHYOcLOO/+DodfzR/PPDTlrabf9yhgpwPJ7LUjGEHElLoi61ZDx
         uTIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=424Xw6WjTQ8R5+agmVp6DdmUW0Ytxf7ZEapbxiXMf7w=;
        b=L1RHiTKDezALbXqFV0rpw6kjGYGusEWsWORfZQ8aZJu+LiYMG80DBMzbPX9pPpEnyM
         /4pA/0NqtA3sajDh++K/xYcvEYG5pGQOU3wm29JjCCof2MvCw3Pm9geB6u6sbgZ645uw
         u/2XhDPQkbsFv0dZTvOiOSfA4XHeZ38swTEZhy+UtdGe07T8apNhxi6ggnRmpkSxlgFW
         Z1CBHUbVzuyqjiwlZ023kdC4QNH7NC7TyMZ4tFiq+5TQTgt3BbBiCr4iHtWdWMIXe9kJ
         yw/N1CZG5CM5uf4KFVVyBRsEXNoy7yFdbUH48JrbSYcr+rp0AQP5NFVtHoWPcswpELlc
         R2KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id t16si7198356plr.63.2019.03.27.05.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 05:43:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Mar 2019 05:43:17 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,276,1549958400"; 
   d="scan'208";a="144302466"
Received: from zliu7-mobl2.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.212.116])
  by FMSMGA003.fm.intel.com with ESMTP; 27 Mar 2019 05:43:15 -0700
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1h97tj-0002p1-6D; Wed, 27 Mar 2019 20:43:15 +0800
Date: Wed, 27 Mar 2019 20:43:15 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Martin Liu <liumartin@google.com>
Cc: Mark Salyzyn <salyzyn@android.com>, akpm@linux-foundation.org,
	axboe@kernel.dk, dchinner@redhat.com, jenhaochen@google.com,
	salyzyn@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC PATCH] mm: readahead: add readahead_shift into backing
 device
Message-ID: <20190327124315.eounujow5rvqaaq2@wfg-t540p.sh.intel.com>
References: <20190322154610.164564-1-liumartin@google.com>
 <20190325121628.zxlogz52go6k36on@wfg-t540p.sh.intel.com>
 <9b194e61-f2d0-82cb-30ac-95afb493b894@android.com>
 <20190326013058.ykdwxbfkk3x3pvtu@wfg-t540p.sh.intel.com>
 <20190326081233.GA175058@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190326081233.GA175058@google.com>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 04:12:33PM +0800, Martin Liu wrote:
>On Tue, Mar 26, 2019 at 09:30:58AM +0800, Fengguang Wu wrote:
>> On Mon, Mar 25, 2019 at 09:59:31AM -0700, Mark Salyzyn wrote:
>> > On 03/25/2019 05:16 AM, Fengguang Wu wrote:
>> > > Martin,
>> > >
>> > > On Fri, Mar 22, 2019 at 11:46:11PM +0800, Martin Liu wrote:
>> > > > As the discussion https://lore.kernel.org/patchwork/patch/334982/
>> > > > We know an open file's ra_pages might run out of sync from
>> > > > bdi.ra_pages since sequential, random or error read. Current design
>> > > > is we have to ask users to reopen the file or use fdavise system
>> > > > call to get it sync. However, we might have some cases to change
>> > > > system wide file ra_pages to enhance system performance such as
>> > > > enhance the boot time by increasing the ra_pages or decrease it to
>> > >
>> > > Do you have examples that some distro making use of larger ra_pages
>> > > for boot time optimization?
>> >
>> > Android (if you are willing to squint and look at android-common AOSP
>> > kernels as a Distro).
>>
>> OK. I wonder how exactly Android makes use of it. Since phones are not
>> using hard disks, so should benefit less from large ra_pages.  Would
>> you kindly point me to the code?
>>
>Yes, one of the example is as below.
>https://source.android.com/devices/tech/perf/boot-times#optimizing-i-o-efficiency

Thanks. It says

        on late-fs
            write /sys/block/sda/queue/read_ahead_kb 2048

        on property:sys.boot_completed=1
            # end boot time fs tune
            write /sys/block/sda/queue/read_ahead_kb 512

I tried fio randread test on Sandisk A1 SD card with cmdline

% fio --name=randread --rw=randread --direct=1 --ioengine=libaio --bs=8k --numjobs=1 --size=1G --runtime=60 --group_reporting

And find results to be

          8k   READ: bw=16.2MiB/s 
        128k   READ: bw=64.5MiB/s 
        512k   READ: bw=83.4MiB/s  <==
          1M   READ: bw=87.5MiB/s 
          2M   READ: bw=89.8MiB/s  <==
          4M   READ: bw=91.5MiB/s 
          8M   READ: bw=91.9MiB/s 

Here bs=512k looks good enough for I/O performance.
bs=2M just adds ~8% performance. Though this is measured on
my SD card. Different phones may have varied numbers.

>> > > Suppose N read streams with equal read speed. The thrash-free memory
>> > > requirement would be (N * 2 * ra_pages).
>> > >
>> > > If N=1000 and ra_pages=1MB, it'd require 2GB memory. Which looks
>> > > affordable in mainstream servers.
>> > That is 50% of the memory on a high end Android device ...
>>
>> Yeah but I'm obviously not talking Android device here. Will a phone
>> serve 1000 concurrent read streams?
>>
>For Android, some important, persistent services and native HALs might
>hold fd for a long time unless request a restart action and then would
>impact overall user experience(guess more than 100). For some low end
>devices which is a big portion of Android devices, their memory size
>might be even smaller. Thus, when the device is under memory pressure,
>this might bring more overhead to impact the performance. As current
>design, we don't have a way to shrink readahead immediately. This
>interface gives the flexibility to an adiminstrator to decide how
>readahed to participate the mitigation level base on the metric it has.

Understand.

>> > > Sorry but it sounds like introducing an unnecessarily twisted new
>> > > interface. I'm afraid it fixes the pain for 0.001% users while
>> > > bringing more puzzle to the majority others.
>> > >2B Android devices on the planet is 0.001%?
>>
>> Nope. Sorry I didn't know about the Android usage.
>> Actually nobody mentioned it in the past discussions.
>>
>> > I am not defending the proposed interface though, if there is something
>> > better that can be used, then looking into:
>> > >
>> > > Then let fadvise() and shrink_readahead_size_eio() adjust that
>> > > per-file ra_pages_shift.
>> > Sounds like this would require a lot from init to globally audit and
>> > reduce the read-ahead for all open files?
>>
>> It depends. In theory it should be possible to create a standalone
>> kernel module to dump the page cache and get the current snapshot of
>> all cached file pages. It'd be a one-shot action and don't require
>> continuous auditing.
>>
>> [RFC] kernel facilities for cache prefetching
>> https://lwn.net/Articles/182128
>>
>> This tool may also work. It's quick to get the list of opened files by
>> walking /proc/*/fd/, however not as easy to get the list of cached
>> file names.
>>
>> https://github.com/tobert/pcstat
>>
>> Perhaps we can do a simplified /proc/filecache that only dumps the
>> list of cached file names. Then let mincore() based tools take care
>> of the rest work.
>>
>Thanks for the information, they are very useful. For Android, it would
>keep updating pretty frequently and the lists might need to be updated
>as the end users install apps, runtime optimization or get new OTA.
>Therefore, this might request pretty much effort to maintain this.
>Please kindly correct me if any misunderstanding. Thanks.

We don't need to keep track of all the system updates.
This should be enough.

on each boot:

        load file_and_page.list
        readahead the files/pages
        wait for boot_completed
        query kernel to get the cached files and _referenced_ pages
        save to new file_and_page.list for next boot time readahead

When there are new apps installed, they may not be immediately
reflected in the next boot, but next next boot will be able to
do proper readahead for them.

Thanks,
Fengguang

