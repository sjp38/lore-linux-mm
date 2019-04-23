Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68B5DC282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:13:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24547208E4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:13:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24547208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADFF96B0003; Tue, 23 Apr 2019 14:13:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A66F26B0005; Tue, 23 Apr 2019 14:13:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 907B46B0007; Tue, 23 Apr 2019 14:13:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD1E6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:13:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m47so8436822edd.15
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:13:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UvBCGfx/8rnXtPz98Lh2v0HbyaM3JXjCUiL9gwcjUVY=;
        b=mYnTFTuUE7opTg7aoV3k5FDkjQBgc/Dzha4q38XdU9apUojUKW0UVgECXrjEJr0Jps
         InSMwfqKaOfWGLG2El70k1TsjTydlP+DnBvuKd5VALm3hcCA/sXSkNBymfV+s3IRFDCv
         QQfyGmVOa/oxUFSOCqvSDhrWggDZlpQNSooxCZ1sCMh0/oPLBqEP08dQcHcfzNH1j7sH
         fmmO3d/Al0Vr52aa4LL58ojukivvbksNW7RzVIQePwjmR96vZA81zcR1cpadFpo3L5gv
         OiCTVdmeU7GbBLncbnYfa9qupqk/GE96qmgrNPbi7/DKoSvXr9cB9FoD9HfiOuv/+QGY
         4dSw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAV3KjOzeJZhfmOQszXovTdIzKrR8C/3PCZzMLg180MUnEDABLT4
	8uyEAWDYTOYVU6iWBtJiEvjWQJIsG5+KwQtX97efC0530a+Zq0YSLSK4PFEMQIt1VUDWLVpkHH9
	miuTOcAMR8h04HdW1mBzzx2qtVSdDksUa20Y4n5r+OhORzibAet0yRcSP35SnKic=
X-Received: by 2002:a17:906:4d8b:: with SMTP id s11mr13121525eju.31.1556043212805;
        Tue, 23 Apr 2019 11:13:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9Y8IHLLlZR87THyMEpFWDg1xOdE41/k48Hbg59KsWpNHAjtXBcaQJgFkS3dw/Y/epfnAV
X-Received: by 2002:a17:906:4d8b:: with SMTP id s11mr13121448eju.31.1556043211732;
        Tue, 23 Apr 2019 11:13:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556043211; cv=none;
        d=google.com; s=arc-20160816;
        b=QXSd3MZqQf+3aTDomFYZWyTRQoocKJX+LAet28OlYoLO0gMDo4YiNzqM6xu0yWtDls
         kkN80Gxl75rF7m903yC9agPjNjbSxg2PzZPPOMtKONpZkQITnXY7ahkclE37xsPPlJLM
         a4oY8CH3loQG8AGJE5OzVWHoH7enXf3zUvMleDR8KN4zFveXIoI3UEC/SUqlp/cHI5Gm
         V1969VxWmQmKoXgF1Rwla09cD2tfSx8kJrCTrcFFBnKAXolcnz7k9tYh87WC2O+3EZ0q
         1LbAnICEm+VUcPLFLQ7x0puIW1Q1sqpuSqo/9Ydeq5iZPL3Cl9dzjUCEdj2Hl1GogwaQ
         +aog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=UvBCGfx/8rnXtPz98Lh2v0HbyaM3JXjCUiL9gwcjUVY=;
        b=D9gIRedLpamEcTukJLHs40li+iMZPs2ero4oq0QLjhbHmN8OEsNVkSDuSpG6PSN5vM
         0ehlXZoQ+ochjkTBdGSY7Bp87yTXxyTbeGNrru4S/IUTG3T0Kcrbttkw3826imN2BSp0
         DTmfGgLt2GFhrjz4YD7EwSefFw4+2fr+l1TdngT+h45JKIkmV1ERn8GbyBc0UxOJsePq
         U3qx76mlfOgf1syYG755kOmGglA7VY0Q6UdNZ3NA7gMArDIcvzAjVWpF8m5tLCgALJLa
         iopM7jRvgfYpJlULSLVoLOLDoclx3+y3WLDa3scBZn5EXKk5ShwfLrIbMxjhCWhPq2FO
         VuNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i11si1370640eds.276.2019.04.23.11.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 11:13:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 33DE3AEBF;
	Tue, 23 Apr 2019 18:13:30 +0000 (UTC)
Date: Tue, 23 Apr 2019 11:13:15 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org,
	mhocko@kernel.org, kirill@shutemov.name, ak@linux.intel.com,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 21/31] mm: Introduce find_vma_rcu()
Message-ID: <20190423181314.wmhy2v2siiz35yzo@linux-r8p5>
Mail-Followup-To: Peter Zijlstra <peterz@infradead.org>,
	Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org,
	mhocko@kernel.org, kirill@shutemov.name, ak@linux.intel.com,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-22-ldufour@linux.ibm.com>
 <20190423092710.GI11158@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190423092710.GI11158@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Apr 2019, Peter Zijlstra wrote:

>Also; the initial motivation was prefaulting large VMAs and the
>contention on mmap was killing things; but similarly, the contention on
>the refcount (I did try that) killed things just the same.

Right, this is just like what can happen with per-vma locking.

Thanks,
Davidlohr

