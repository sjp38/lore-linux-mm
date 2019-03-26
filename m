Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AA4FC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 01:31:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3BDC2084D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 01:31:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3BDC2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 488426B0003; Mon, 25 Mar 2019 21:31:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 438DB6B0006; Mon, 25 Mar 2019 21:31:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 326B66B0007; Mon, 25 Mar 2019 21:31:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E64586B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 21:31:03 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id go14so1074899plb.0
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:31:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sZqLRqWMeYF5y023Ld6aeuaPrAHZCn/f20mtUfF9AQU=;
        b=AnGrr1LeZXSGjitJEjFBYQpk7ViTI1p1DZfUSVuUpG2HL/01yWmlsatL0JAGeGmzj9
         DnFJLHboeKN8oS86w+zspjkCJ1mqXOUfJHd7DdLdu6tBDnzu8rLRofgEbgCnGMgd5EdT
         GMQMQT8WnSd1fUteWDlZ+rrdxmThOwls8/6bRuJcQA+bwHVCnzASwurf54X97rr47l56
         LSKhS8DeT980+6bBYxy9cxMYShF09WuCw/4hFDioIl+IS4/vDX7MkGaHowWczLFzNZtU
         PKUzw0YPWq0VOpVnhMgY+9zGigb2qEHfcvqLDW0j9VYAtOTphUJmcCo3V1tBJL5WA64c
         J+aQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVeaaPZ8joNf59K8R/WnozL1EfdQ4uUbXs/lhyiM3WCvTmGgB99
	dBXxOxJapp4K0Emm670l84FcI6sPOVx4oaxSjC+zAD6qYRC/2dDTflOE7LA6x/GepVve7JAlaHA
	5KFWenK0Y7Rt2B2vmPxaxIypzKdCIS2acfKCcFJcOaQy6DSMCn7cUCsVmaBNpoliG4g==
X-Received: by 2002:a63:6c41:: with SMTP id h62mr25848228pgc.371.1553563863448;
        Mon, 25 Mar 2019 18:31:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwX4g38mfLW040X8PZBh/doE8aO3YFP/EAkabR2Qln4EQIOjtsNGopXX6/97+yPyUNx4a0R
X-Received: by 2002:a63:6c41:: with SMTP id h62mr25848165pgc.371.1553563862505;
        Mon, 25 Mar 2019 18:31:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553563862; cv=none;
        d=google.com; s=arc-20160816;
        b=sgjkB3S07NG26aUJdEm5oV9rIMpWnJTVBWEFcZjAhxX6qLZrZQAUr8Pd4majnvC+WJ
         T9mBa0PcX+jcszsHg+eqrQuh3QAPz5TSJw/9C4KWqR5KP82DE2H4eFgWILQG8NKgVNRf
         /BPjTQaHZ42FQRPedXsiojAuuMgJt7giDZXc+XpiEfDiUDPl/kErtKOWogYZSXU9Jumd
         IxZPkY/MGbKGZuo3x5DjdR9gBteyg3pf1v6lLApO7THhZlWF2+b4TeO0P6WHzk5AdALK
         vCP80mWqsDzP9enrBKHg01XVNmu4ydBZbUFBGqJLRt75B1qu4d7PBj4/bt2ulwv1shAh
         3pIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sZqLRqWMeYF5y023Ld6aeuaPrAHZCn/f20mtUfF9AQU=;
        b=JMpGsLbGf35pUP2TBVayazjpwBSghRfoAwbpQbfaWy2DFVC+9+qlBkc87/AP+kdpfF
         hhCnQMdBNgKcq3TyTyr1p4rsmAl4yDjtW9yqTO0vk4jJBGstAs+UkmInpGd8rfOyOiX0
         Fy1aT1kkFsBfSl17yMg13Oe5Lg8wetCXgt5NIg/+m1QrpvIzr+RIqPUWxes0DAvQ5L4E
         ctge0cxUHELeY7eWqcMK8K6aCk/IozU+Offpy48z32OGAHCKUfnCjNaG6fQdkO0bYJbL
         KuFWosuXv95t55oHd9ctmvghiHo6tKm1tLN6eHiV1j8XdIfTkjegGWzsJZKTVwUZMsB/
         RCag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s79si14738851pgs.245.2019.03.25.18.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 18:31:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 18:31:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,270,1549958400"; 
   d="scan'208";a="137252173"
Received: from zliu7-mobl2.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.212.116])
  by orsmga003.jf.intel.com with ESMTP; 25 Mar 2019 18:30:59 -0700
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1h8ava-0007nx-GU; Tue, 26 Mar 2019 09:30:58 +0800
Date: Tue, 26 Mar 2019 09:30:58 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Mark Salyzyn <salyzyn@android.com>
Cc: Martin Liu <liumartin@google.com>, akpm@linux-foundation.org,
	axboe@kernel.dk, dchinner@redhat.com, jenhaochen@google.com,
	salyzyn@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC PATCH] mm: readahead: add readahead_shift into backing
 device
Message-ID: <20190326013058.ykdwxbfkk3x3pvtu@wfg-t540p.sh.intel.com>
References: <20190322154610.164564-1-liumartin@google.com>
 <20190325121628.zxlogz52go6k36on@wfg-t540p.sh.intel.com>
 <9b194e61-f2d0-82cb-30ac-95afb493b894@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <9b194e61-f2d0-82cb-30ac-95afb493b894@android.com>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 09:59:31AM -0700, Mark Salyzyn wrote:
>On 03/25/2019 05:16 AM, Fengguang Wu wrote:
>> Martin,
>>
>> On Fri, Mar 22, 2019 at 11:46:11PM +0800, Martin Liu wrote:
>>> As the discussion https://lore.kernel.org/patchwork/patch/334982/
>>> We know an open file's ra_pages might run out of sync from
>>> bdi.ra_pages since sequential, random or error read. Current design
>>> is we have to ask users to reopen the file or use fdavise system
>>> call to get it sync. However, we might have some cases to change
>>> system wide file ra_pages to enhance system performance such as
>>> enhance the boot time by increasing the ra_pages or decrease it to
>>
>> Do you have examples that some distro making use of larger ra_pages
>> for boot time optimization?
>
>Android (if you are willing to squint and look at android-common AOSP
>kernels as a Distro).

OK. I wonder how exactly Android makes use of it. Since phones are not
using hard disks, so should benefit less from large ra_pages.  Would
you kindly point me to the code?

>> Suppose N read streams with equal read speed. The thrash-free memory
>> requirement would be (N * 2 * ra_pages).
>>
>> If N=1000 and ra_pages=1MB, it'd require 2GB memory. Which looks
>> affordable in mainstream servers.
>That is 50% of the memory on a high end Android device ...

Yeah but I'm obviously not talking Android device here. Will a phone
serve 1000 concurrent read streams?

>> Sorry but it sounds like introducing an unnecessarily twisted new
>> interface. I'm afraid it fixes the pain for 0.001% users while
>> bringing more puzzle to the majority others.
> >2B Android devices on the planet is 0.001%?

Nope. Sorry I didn't know about the Android usage.
Actually nobody mentioned it in the past discussions.

>I am not defending the proposed interface though, if there is something
>better that can be used, then looking into:
>>
>> Then let fadvise() and shrink_readahead_size_eio() adjust that
>> per-file ra_pages_shift.
>Sounds like this would require a lot from init to globally audit and
>reduce the read-ahead for all open files?

It depends. In theory it should be possible to create a standalone
kernel module to dump the page cache and get the current snapshot of
all cached file pages. It'd be a one-shot action and don't require
continuous auditing.

[RFC] kernel facilities for cache prefetching
https://lwn.net/Articles/182128

This tool may also work. It's quick to get the list of opened files by
walking /proc/*/fd/, however not as easy to get the list of cached
file names.

https://github.com/tobert/pcstat

Perhaps we can do a simplified /proc/filecache that only dumps the
list of cached file names. Then let mincore() based tools take care
of the rest work.

Regards,
Fengguang

