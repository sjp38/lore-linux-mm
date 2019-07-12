Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE299C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:54:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 868AC208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:54:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 868AC208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3193E8E014F; Fri, 12 Jul 2019 09:54:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C9618E00DB; Fri, 12 Jul 2019 09:54:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16AE98E014F; Fri, 12 Jul 2019 09:54:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D17CC8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:54:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 191so5562574pfy.20
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:54:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=40SXDbZebqW9Fo5hkse7YNgiYamCVd5peTsubRzyArE=;
        b=RcQMHXKEIbvWv7hl3BT63UKf6l95iUggHaaSN3YoaBTKZvEDb2AkK4f/mFD3pD+pK/
         XZrxKUrccOVMKIKLOLinsabz+x4JsnY0yeRSy5wzLN6BhxXsPmQMy413ep34SxCZqKn1
         n81t5kSv7d6WInqgBJXSODBWuj6j8r24VcXittuhsTHU2ED58Rhxg5omof8bC7UU7Oni
         jrPBsNkbNuonSLkA2CN8Njk3u2dwOYGJV77v4RkmixkH3BG8hfmp812LtHdd7EhKt5Gz
         GukvirReNBdbBK9lnWhPaBER3KF4ONxwwwXdH5gzJg1Z1fB4XWG1jyNl4Y+IbZgD6+nw
         a8UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUmeHW5igqUPn5zJSLXTu49tEGsWlrph5FbBpsrXAWqiHu6CkQG
	qIyT05M04xAXUVjuKp7pE0jI7oQZEf3ZX8WpfImFNePznHrdoVC0hYPcjc6E/kFHHNl1DmGYcry
	qfSsdEvuWsT4LV0zeSLKM8zLJpSddvh5vtjQ5yTRIiP5ORu0uDj32+xmebdyNG6CopQ==
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr11990187pjn.95.1562939665554;
        Fri, 12 Jul 2019 06:54:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzx5IPOUs9QrPcKwSP04HQhvKG0ZUQn0aSOv1Enfb48f3C2/ERhjgyYxDwGT8JQh6CE98TW
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr11990132pjn.95.1562939665003;
        Fri, 12 Jul 2019 06:54:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562939664; cv=none;
        d=google.com; s=arc-20160816;
        b=lGlJubkMQTFXqRAWYFEccUijnjDSekVfRqJ+kJ42/wJGoE4Omica7hxz+2WQTNvl81
         YxykQQyP7+2v8+vAkVogbpq0PjWqnHdZgwR82tgdwE38ldMTRVBL2pNDhH8Kgh0h53pj
         wk25W6oZH6xrGjJJy+LZuUnvX3mkRFkOPV/1fvH+B/ji2RKAwWj8lYgs541y7Nyajo8g
         AQBM2swdxyeFeJxL6sjEsro0tuj+NtbEjOBZVjjimI9cfVeEbXeOcEtCkQxRETe9+yKA
         WERBdbZWpFWwqFHvXxq6/UXhH9vfuc5WBsDKZ2ZqO3xOq3FJ0qJ0VCiz8OD8EjSPlcRi
         baDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=40SXDbZebqW9Fo5hkse7YNgiYamCVd5peTsubRzyArE=;
        b=CvfD1kPTZpF9AoUtTbekolesQq9UNwWS2eEkrLm546OVZqfID00bTMxEsz3iIfJrOq
         k5Z+PPeVQ4PXdZxmEJX9+TjFmV13n9FcLf6weAAJ2Tl365JJrMmbRw9c6flbiV3lPfSJ
         OXipksL4zhe3zt9KF4BkAprtv5f6hPtfKFC3mh59jXrwavrjBL3/goJbqu66aH0ueSqh
         ycjB+x145iePBwGepOy1vv13wiSzTwC3h4mBpxC1gw7P21U4uTj8HPYXGE+PaSywdXVn
         AphJ90lTYID6ZZYJWWgSUJo8HYU9avTG8obaw+mVMVXXLNMxTzjkXV2Cwk72UoAgBAgH
         sQgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g9si7694522pgs.364.2019.07.12.06.54.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 06:54:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jul 2019 06:54:24 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,482,1557212400"; 
   d="scan'208";a="166683884"
Received: from smatond1-mobl1.amr.corp.intel.com (HELO [10.252.143.186]) ([10.252.143.186])
  by fmsmga008.fm.intel.com with ESMTP; 12 Jul 2019 06:54:22 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Peter Zijlstra <peterz@infradead.org>,
 Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, pbonzini@redhat.com,
 rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
 x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
 jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
 Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <3626998c-509f-b434-1f66-9db2c09c47d4@intel.com>
Date: Fri, 12 Jul 2019 06:54:22 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190712125059.GP3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/12/19 5:50 AM, Peter Zijlstra wrote:
> PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
> ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
> 
> See how very similar they are?

That's an interesting point.

I'd add that PTI maps a part of kernel space that partially overlaps
with what ASI wants.

> But looking at it that way, it makes no sense to retain 3 address
> spaces, namely:
> 
>   user / kernel exposed / kernel private.
> 
> Specifically, it makes no sense to expose part of the kernel through MDS
> but not through Meltdown. Therefore we can merge the user and kernel
> exposed address spaces.
> 
> And then we've fully replaced PTI.

So, in one address space (PTI/user or ASI), we say, "screw it" and all
the data mapped is exposed to speculation attacks.  We have to be very
careful about what we map and expose here.

The other (full kernel) address space we are more careful about what we
*do* instead of what we map.  We map everything but have to add
mitigations to ensure that we don't leak anything back to the exposed
address space.

So, maybe we're not replacing PTI as much as we're growing PTI so that
we can run more kernel code with the (now inappropriately named) user
page tables.

