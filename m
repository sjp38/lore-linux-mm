Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 700E9C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:48:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31226208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:48:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31226208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C333E8E0003; Wed, 31 Jul 2019 10:48:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBB9A8E0001; Wed, 31 Jul 2019 10:48:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A83F08E0003; Wed, 31 Jul 2019 10:48:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 590FA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:48:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f3so42529565edx.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:48:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9vQQqmrndsZB/Nvrr1L9YwE9OJszBUw8wKgpGOiGAcY=;
        b=CCxpO1XFsPbLAYmTl2jCL2+SZHcLZ8xy/Aujd5KOZfjimierUXgoMf6jOrsltHYj0r
         ayiLBibLF8fODFzERVr+VtF/SQyijNgHw0XcBLukFBP0s5ujSp43x0NugmiXgYvfoo+D
         EpjifIba1n24THbRE819JodCMkHg1+GqSKaKibAUT1Hoo/brImygX2t45AwNEQIfwTgK
         YvO79/jdJq2lSKy67Mpu9yyjg5lTuaPuiSYZY8GDk2yk8tgmPYs8f7Ole6nf8gEf++KV
         nanIHg4EqptiWPcVaw9VszT2eGCCFuPE+ja62Id6SV+XzsFJzFDrDgpkPz5lHVU1m2Sh
         yFhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXoYpyZEqDc6iBcA8Kg8HhHjwHqU1Nox1227JVQpCmwNPyNGv4Z
	jaVzgWbIE3xa3Et9GXindkmTIi8upe9i4klr1mAE2Vy+EXOgtjMXjVvak9+DPcjNWpuk+o3AHxe
	A51iI693TxKpilET/8aNz/Bx7SPY06f1B5aQN3C5UYn+WxIH8BQ/9XxpcPjhjukdw6g==
X-Received: by 2002:a17:906:7e4b:: with SMTP id z11mr96773204ejr.214.1564584524917;
        Wed, 31 Jul 2019 07:48:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQm2kJhUQhYg9kIawPLyUvlPgkv7aQVheFnVE1w6oBx8Axg7k2/AckjYSjvmjKiBgkh1di
X-Received: by 2002:a17:906:7e4b:: with SMTP id z11mr96773143ejr.214.1564584524106;
        Wed, 31 Jul 2019 07:48:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564584524; cv=none;
        d=google.com; s=arc-20160816;
        b=wEFgS3khvwl02rmoMpXRAXeK1b4BROfyt5c3VZ/aDJ4L4M5cBi08FD39UTqgw39+EK
         90bstlAs3/dH8A1nIKPWOizLjViOHk2+7xLsIx4bZaUg5rbV6xn2w7uxeIaKSKLwh/7M
         N1k03Z7F96ChDLS+QW+IvqZ69yWsPiHJ9sWbL53naJsve7LCyoB7p6P7eV9fh5JhoKkX
         sTYPPfHBDU3mMFG7ZyUc8jQtidVzfDqiDLFVXWtPKA/fHM0neMbSupA+IN7NhElRlEjR
         doP1+VY/U4r4ba/ddOuaz0FAkwSNAEOhAFhy3mDIycSnl+VnHrgwZ+plpzDDP4hbCTc3
         MZFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9vQQqmrndsZB/Nvrr1L9YwE9OJszBUw8wKgpGOiGAcY=;
        b=uVM9CmQXexrnZd2hVqNQe/i1sJgrXSE+LQxColNfT0bps9FTN2ITKb2p4Sa0LtwS83
         NYFUTLHGSiktM7yBnSrIwMfMLaBstUl9wFMUuzJvUUcJZLyXVqIxsHhZik4r6odppaz8
         fAOtcwTpnIJWW3K8gUF9dw4nOi+vm4ab0M4XnP5jUNDLm3PB1vsBkjnwEIk2tfWyVyxS
         VVunxBNt1KdZ72IYP8JeO0rvthLbxM1R4Gie8vorzIZpo/Srm4s2Vz+0EZe2jAA5UWJp
         tcA7wBFvP6zKuvHEqJspSoQxmccfseaQfGXZxJZzaKhecvnThTurwKqCQXtqH/d9J6sF
         SFOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id t21si19758194edw.253.2019.07.31.07.48.43
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 07:48:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4C7FD344;
	Wed, 31 Jul 2019 07:48:43 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 647DD3F694;
	Wed, 31 Jul 2019 07:48:42 -0700 (PDT)
Date: Wed, 31 Jul 2019 15:48:40 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190731144839.GA17773@arrakis.emea.arm.com>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
 <1564518157.11067.34.camel@lca.pw>
 <20190731095355.GC63307@arrakis.emea.arm.com>
 <C8EF1660-78FF-49E4-B5D7-6B27400F7306@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C8EF1660-78FF-49E4-B5D7-6B27400F7306@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 08:02:30AM -0400, Qian Cai wrote:
> On Jul 31, 2019, at 5:53 AM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Tue, Jul 30, 2019 at 04:22:37PM -0400, Qian Cai wrote:
> >> On Tue, 2019-07-30 at 12:57 -0700, Andrew Morton wrote:
> >>> On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com>
> >>>> --- a/Documentation/admin-guide/kernel-parameters.txt
> >>>> +++ b/Documentation/admin-guide/kernel-parameters.txt
> >>>> @@ -2011,6 +2011,12 @@
> >>>>  			Built with CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y,
> >>>>  			the default is off.
> >>>>  
> >>>> +	kmemleak.mempool=
> >>>> +			[KNL] Boot-time tuning of the minimum kmemleak
> >>>> +			metadata pool size.
> >>>> +			Format: <int>
> >>>> +			Default: NR_CPUS * 4
> >>>> +
> >> 
> >> Catalin, BTW, it is right now unable to handle a large size. I tried to reserve
> >> 64M (kmemleak.mempool=67108864),
[...]
> > It looks like the mempool cannot be created. 64M objects means a
> > kmalloc(512MB) for the pool array in mempool_init_node(), so that hits
> > the MAX_ORDER warning in __alloc_pages_nodemask().
> > 
> > Maybe the mempool tunable won't help much for your case if you need so
> > many objects. It's still worth having a mempool for kmemleak but we
> > could look into changing the refill logic while keeping the original
> > size constant (say 1024 objects).
> 
> Actually, kmemleak.mempool=524288 works quite well on systems I have here. This
> is more of making the code robust by error-handling a large value without the
> NULL-ptr-deref below. Maybe simply just validate the value by adding upper bound
> to not trigger that warning with MAX_ORDER.

Would it work for you with a Kconfig option, similar to
DEBUG_KMEMLEAK_EARLY_LOG_SIZE?

> >> [   16.192449][    T1] BUG: Unable to handle kernel data access at 0xffffffffffffb2aa
> > 
> > This doesn't seem kmemleak related from the trace.
> 
> This only happens when passing a large kmemleak.mempool, e.g., 64M
> 
> [   16.193126][    T1] NIP [c000000000b2a2fc] log_early+0x8/0x160
> [   16.193153][    T1] LR [c0000000003e6e48] kmem_cache_free+0x428/0x740

Ah, I missed the log_early() call here. It's a kmemleak bug where it
isn't disabled properly in case of an error and log_early() is still
called after the .text.init section was freed. I'll send a patch.

-- 
Catalin

