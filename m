Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8DB8C742D7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 19:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78645205C9
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 19:06:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RXHwLzeN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78645205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AA2E8E0165; Fri, 12 Jul 2019 15:06:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0339D8E0003; Fri, 12 Jul 2019 15:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3C038E0165; Fri, 12 Jul 2019 15:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC3D8E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 15:06:45 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u5so4712178wrp.10
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 12:06:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UqgOWolirnCBEsyXVWQ2fOdoQVQ8hvpvnXJbQKMux3o=;
        b=M0sbYvIcbt80hQPDLsNJh8rZ7NDmMeki9NqdNc2jueyJ8oBGpFy92Zzn/vqb7Zh7Ks
         C/hdohgw1kvZJUt8Rg0I5Qpa2Eyjcuh1h2hwKejOKtW904PCCDna1cRxUnRAxUyNRw5Z
         SbN/ZjBfCceUCpNhFOui1+uGquVKdfz82turRJhV6BjxuvEMfWk8CWl5mRr+sJs0uneh
         VXMvNBbO4GeojyX7GU3kwH+A0n3GNIxCOpCcQA6/p6GFbnkvff8G135J8GjQ4/BUpSNQ
         XVLzxvN3NL/hch+SbrvdzMB9K/Ho2ZyD3eZOE3ds/qMkpy87wGZfbcKdSNlQLaSPMXIN
         WP5A==
X-Gm-Message-State: APjAAAVJJGXjcvigzJbFgOFjbblAvTihiaJkNladxOxPHIv2ziSH9Sq6
	3yaDO9qrl5UcKEdfjleMpR4KV+IclRBRh3jcvQqWcqXtJhwgYBjtOLz+5SKPXq1XiDav4jZYLw3
	k5950qyNKUX4AFRbCTrssaLqVLwlWN654kMJnhYCTTFBa3zXahDzUAQSwNn2V27f0cg==
X-Received: by 2002:a5d:62c9:: with SMTP id o9mr12343137wrv.186.1562958404905;
        Fri, 12 Jul 2019 12:06:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzrF1a8SW0aNauRgmuKKwfrfZSCX+jO+1A3QdkAgIFlzglyBQ339dqTF1Vv9GUkMVwEwYx
X-Received: by 2002:a5d:62c9:: with SMTP id o9mr12343078wrv.186.1562958403876;
        Fri, 12 Jul 2019 12:06:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562958403; cv=none;
        d=google.com; s=arc-20160816;
        b=GG6SvvR6QQQ6DgtH5A+Saro+laGt+od8qG4SJLm8nA4KUP5VtFjPz9tmUfasChv+o7
         Cq9r5Hz14LtSTjibAT6jV37oOgUeeR1sKCoeJR3AnYgSHJAy8sV3FhcwKCzdUm4pzHB7
         69oOJkU+u9wlb4R+V7ASwSU1pv+U9aVhaVpz3vRCb8qeE9UzDFySHKxrBjK4pC/S2iSy
         jbu+uH0eZZXyI+ReqmhvivHx/V68nUapeVg6VL3s8CCqChDyfvVHKB9gxavSc+zxzrGQ
         2i1+fi1zAcJjL/+n3Ws/+03pMljqukEUPFnip+r/IPh4Oe0lOcCSwI9KOjbJ3WMawoKl
         HtKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UqgOWolirnCBEsyXVWQ2fOdoQVQ8hvpvnXJbQKMux3o=;
        b=wE1xf1uje5yNWh9OXw0uFt7fMnpyFtU/d4p0bnUruIs+3UO6KZtPqhZEiyclwL6Egm
         uF1RnGqPl1gaZXDLe+mOSbRnitbrLG/gLHjeJxl4Y1yz1Y96vOBB/NKgufB/wWlIJwRE
         fymaPoJaembQcoPpa9wBlpGlRRIyQictPtzwj4OrXhgPu/j7v46BXmi4llJ3KQrOJIVC
         iqzMY2z8n7gT9Qau0O1OtmJOQyNSZng9AtoDEPtkhzsBNl+XXyKE1XCU0YjqXBFLKq9N
         /331U3pRRR1eXQr6CGiomdrbPmyAasCtdOanwFbMdAZrLMvvwQwOh7TdB2GhSFD9y1JO
         NI6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=RXHwLzeN;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f12si8910235wru.47.2019.07.12.12.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 12:06:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=RXHwLzeN;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UqgOWolirnCBEsyXVWQ2fOdoQVQ8hvpvnXJbQKMux3o=; b=RXHwLzeNIqmDjrorcLSQiAkd/
	MUyTNzpAtlmP3XOZPMG/9cuvZT3fk71qTAQkMBMu8DBb1GOL8ivodXsj9Pt8IiM/kZ96KvDpTZjwz
	17r4zad9PKi2F9zqIK6ucOLmVegd/xcPRvcqF20wupKYw+jZXH1ZmOIXT8XEVkMMIaJ9aYLBm8DHd
	tM4G+AW5wJjB9MjVM9GB3ZJ7WHHq0ew69CWEi8qFGPNUYHfBb7crHR1YOovT0vXC2Tn+lFUpMKhTF
	P6ee4Qt7cVbAz+2p3WYU2GNhlt9XGIdlP2tdn7gLJH2PcRy4OrhWuAKvM3WgUGF/AZPd0bcmRI52p
	pvWDraWCQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hm0sB-0000J7-4g; Fri, 12 Jul 2019 19:06:23 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 1D164201D16FC; Fri, 12 Jul 2019 21:06:20 +0200 (CEST)
Date: Fri, 12 Jul 2019 21:06:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com,
	rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
	rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
Message-ID: <20190712190620.GX3419@hirez.programming.kicks-ass.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
 <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 06:37:47PM +0200, Alexandre Chartre wrote:
> On 7/12/19 5:16 PM, Thomas Gleixner wrote:

> > Right. If we decide to expose more parts of the kernel mappings then that's
> > just adding more stuff to the existing user (PTI) map mechanics.
> 
> If we expose more parts of the kernel mapping by adding them to the existing
> user (PTI) map, then we only control the mapping of kernel sensitive data but
> we don't control user mapping (with ASI, we exclude all user mappings).
> 
> How would you control the mapping of userland sensitive data and exclude them
> from the user map? Would you have the application explicitly identify sensitive
> data (like Andy suggested with a /dev/xpfo device)?

To what purpose do you want to exclude userspace from the kernel
mapping; that is, what are you mitigating against with that?

