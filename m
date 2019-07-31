Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5358AC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:54:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4890208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:54:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jj/3Q/u2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4890208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E8EB8E0003; Wed, 31 Jul 2019 10:54:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79A5E8E0001; Wed, 31 Jul 2019 10:54:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 660738E0003; Wed, 31 Jul 2019 10:54:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43D4C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:54:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 41so55887882qtm.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:54:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=SBLkQ5l7iqgRc/LZwzrYfujT+xXRrB58EoMCQ+Ui3VI=;
        b=iLZ1Da3h5JvsRL3h6oRmlUNPP5Xax2auhpYRPZB4TSSSLpi/Qpu1zsM0aMjZOZ9L3o
         R/8OxlIlj/xQIWZQOdc2NXEXLHRk6Vwa2eQE8PJYx3B4zoOs3fXVP87F7SPmbSCvWUEf
         ps4XghRGBuqo8uqbYZCYX6nw7t9LROJ7Mm5byxCLX/rq/ZMgErUpX0cwFb8lxxVGqSR7
         gXZ3U4JLdOFw2Hve4qbzKEsWerJPGJtspBfJGYjsXwQ4uR8crbkj0QWgUhAdYIsd1RlF
         2saC/ZhOwJk8cygZrW8QzJA5wYvytxCoLH3XrSHjOMl9vbbc4EKEBmp1OSeHEsIbO/bp
         gLdw==
X-Gm-Message-State: APjAAAXIOJ4D4YoZLK8Y5l3M9FqzonRA8xoqKMfhRBStJ9+EkyRl5efB
	ZENGiDDzRhPJDlmec2Otkm33M/dXuPhyCnVDDjxpb/P+JA+9Nqqod0P/DRqPJjxam82sh9DuUux
	PqMem6aDWn6uRY3WIIPAh6DcTFRdI+4/EnAmdLglqEm/OQgjLeQIaGGlsS72+uMs35g==
X-Received: by 2002:ac8:23c5:: with SMTP id r5mr88198936qtr.319.1564584846963;
        Wed, 31 Jul 2019 07:54:06 -0700 (PDT)
X-Received: by 2002:ac8:23c5:: with SMTP id r5mr88198899qtr.319.1564584846357;
        Wed, 31 Jul 2019 07:54:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564584846; cv=none;
        d=google.com; s=arc-20160816;
        b=itDOT+oen7NAWB7FGYgtSJ3MfLDWXUReZcGfUMjns6+iap15WaSxk4bn6+oMnpUAF/
         quilkwtLEqgEfy7UVhKr5/ReVsGeVLWl/8g50yIEsD3Y2RPZ8kCm8TIDt089QK7RJIgX
         8MvJuw6cJ2yqGmvNdYkwQt2cHrYm5KOJtUpM85xfW8U8MllzRWuKHOFKbYrJVUnJn7sU
         fGXi50cdUzjqzggHPc6HsJVU3xh0aCAE0rrnPdEoLwTrjizkX9V0E7+sbv8E1r6nCuE3
         vLAg32LPJ2NjvbdErsHd7rbQ71oANSHxYjd/H7hm2Gj0nZxCAFAh6/C9oH21ByXDgiNJ
         L1Ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=SBLkQ5l7iqgRc/LZwzrYfujT+xXRrB58EoMCQ+Ui3VI=;
        b=WClUlfUorRf2NswIIDanuqn+UiUB/wwjCkLhqv0TWNIEcaKWR701v+IJEJMrgjVczE
         7EvQGACR52KGWjciJp3p7Fd0E+4WMlT/WkDYI2fq8ILek7ZurmmHq5BCBP+zzWOqLFOh
         wPUkUpjQWl3SW2S8PFVJHwbbkNM403EpUunrwrRznhtwANb3t6udZcquJ9KoLhPZIs6g
         sNc/4oAYlVL7woF5nAdYaxMroqsASqwLHKqd7e8y/vBmM8qXLAdRoj/hr0Nn/f98wtR0
         Db3f7VN+GI3qnDjmAqzHTrukZYyb9MOD/lOmGWvaZOEk5chKITU58ptCuWp0YyA6D3x0
         NMmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="jj/3Q/u2";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s137sor38621321qke.124.2019.07.31.07.54.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 07:54:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="jj/3Q/u2";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SBLkQ5l7iqgRc/LZwzrYfujT+xXRrB58EoMCQ+Ui3VI=;
        b=jj/3Q/u2Xs29S6NlOoXNsCj1Bdc9Lbm5pq/+4qEzjuzz6zrOeGZvCnVobVV48T76Yt
         lhP6QIqCfTSMgdyUuA8id7soMBu8FVTcgqq9tZkC8bybvzKhlT1/O1NoAvtkmqU+uHA/
         lN1qKLKZH/ymKs8cGGKkcqZ3FoyRQ/dIjGPYuLoFcTfL5+v5B/AA0IQmqZYwaGdHN0ae
         QltUoH5udPdvBV4l2P47Aa9/cHVXXNY3jkrKsbxvYm5v9s3yN8pZAKC4v+LvOm3Nksx3
         DjtDb18xe32fUbpBwV9L8znF6djoInMDHvfKACmRHmqQuRp0qh6rvxjwq3ppdlNuSADi
         NdzA==
X-Google-Smtp-Source: APXvYqx+aQWLkT4Ece9S/qLSNvLPSnE6+9CTFSY4EuJdjy+FS1QE9EH891iVIapc59W/IB+tXlTypA==
X-Received: by 2002:ae9:ebc3:: with SMTP id b186mr82269098qkg.222.1564584845939;
        Wed, 31 Jul 2019 07:54:05 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id n27sm23088492qkk.35.2019.07.31.07.54.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:54:05 -0700 (PDT)
Message-ID: <1564584843.11067.36.camel@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM
 <linux-mm@kvack.org>,  linux-kernel@vger.kernel.org, Michal Hocko
 <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Date: Wed, 31 Jul 2019 10:54:03 -0400
In-Reply-To: <20190731144839.GA17773@arrakis.emea.arm.com>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
	 <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
	 <1564518157.11067.34.camel@lca.pw>
	 <20190731095355.GC63307@arrakis.emea.arm.com>
	 <C8EF1660-78FF-49E4-B5D7-6B27400F7306@lca.pw>
	 <20190731144839.GA17773@arrakis.emea.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-31 at 15:48 +0100, Catalin Marinas wrote:
> On Wed, Jul 31, 2019 at 08:02:30AM -0400, Qian Cai wrote:
> > On Jul 31, 2019, at 5:53 AM, Catalin Marinas <catalin.marinas@arm.com>
> > wrote:
> > > On Tue, Jul 30, 2019 at 04:22:37PM -0400, Qian Cai wrote:
> > > > On Tue, 2019-07-30 at 12:57 -0700, Andrew Morton wrote:
> > > > > On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@ar
> > > > > m.com>
> > > > > > --- a/Documentation/admin-guide/kernel-parameters.txt
> > > > > > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > > > > > @@ -2011,6 +2011,12 @@
> > > > > >  			Built with
> > > > > > CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y,
> > > > > >  			the default is off.
> > > > > >  
> > > > > > +	kmemleak.mempool=
> > > > > > +			[KNL] Boot-time tuning of the minimum
> > > > > > kmemleak
> > > > > > +			metadata pool size.
> > > > > > +			Format: <int>
> > > > > > +			Default: NR_CPUS * 4
> > > > > > +
> > > > 
> > > > Catalin, BTW, it is right now unable to handle a large size. I tried to
> > > > reserve
> > > > 64M (kmemleak.mempool=67108864),
> 
> [...]
> > > It looks like the mempool cannot be created. 64M objects means a
> > > kmalloc(512MB) for the pool array in mempool_init_node(), so that hits
> > > the MAX_ORDER warning in __alloc_pages_nodemask().
> > > 
> > > Maybe the mempool tunable won't help much for your case if you need so
> > > many objects. It's still worth having a mempool for kmemleak but we
> > > could look into changing the refill logic while keeping the original
> > > size constant (say 1024 objects).
> > 
> > Actually, kmemleak.mempool=524288 works quite well on systems I have here.
> > This
> > is more of making the code robust by error-handling a large value without
> > the
> > NULL-ptr-deref below. Maybe simply just validate the value by adding upper
> > bound
> > to not trigger that warning with MAX_ORDER.
> 
> Would it work for you with a Kconfig option, similar to
> DEBUG_KMEMLEAK_EARLY_LOG_SIZE?

Yes, it should be fine.

> 
> > > > [   16.192449][    T1] BUG: Unable to handle kernel data access at
> > > > 0xffffffffffffb2aa
> > > 
> > > This doesn't seem kmemleak related from the trace.
> > 
> > This only happens when passing a large kmemleak.mempool, e.g., 64M
> > 
> > [   16.193126][    T1] NIP [c000000000b2a2fc] log_early+0x8/0x160
> > [   16.193153][    T1] LR [c0000000003e6e48] kmem_cache_free+0x428/0x740
> 
> Ah, I missed the log_early() call here. It's a kmemleak bug where it
> isn't disabled properly in case of an error and log_early() is still
> called after the .text.init section was freed. I'll send a patch.
> 

