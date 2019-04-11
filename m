Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54598C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:20:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3D952146F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:20:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="aqrr9mcq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3D952146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931EF6B026C; Thu, 11 Apr 2019 12:20:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B6CD6B026D; Thu, 11 Apr 2019 12:20:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 758CB6B026E; Thu, 11 Apr 2019 12:20:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 374126B026C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:20:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f67so4552193pfh.9
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:20:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=3w9TkuZHAqslrWVxIfj/pr9QdQEYv2bicep/qG+WXX8=;
        b=gMRljEbFQg/VhcTrZ7FpqXnYocIidloB0eJdc0mV/bBs/vEw4puFhZ+loyMH7Lpspu
         VA/5WygunIwujsk0ioFq43fQQB9TpAfzzKOucTZdV/jH6XRJZu6vxCIXKn/63gjksSVX
         CendS/psgg5PeMHyUhwMZGXWi+QTV/nfMkd/dVeauKdNhia1HuUpgNcXIVX5wOohKRGs
         HyyVa7UcSNhnyaHKVsxtj/NRak3rEmZeiQLq8azPEx6Tm3lmUvGK0Fyt8wW8HRxqzASl
         GQNUTtQarkrWhlMRS3XLyss2lA4IHEpfCaMok9VJIct2Ejl3+YlNisc908SOCHkLSygU
         WZgw==
X-Gm-Message-State: APjAAAXp8Db7NpUvNY6Tb/+sMxjM2AJXoTeqTRA8Vse+c0F83ob0MZWX
	PmXKrX0NGPKkiZjaDk7SOWKkUKQTUdjvSkRFYITikhwbTFUUZVc+Rf6QCgszSk3y/ZLPeG+CIeW
	CP81hfVOraUo2Dq8G/yoXIA6No/+Jn8V5fGSRK6dhDexRkA+F/cqxFViKvBEyo62vbA==
X-Received: by 2002:a63:530e:: with SMTP id h14mr12329646pgb.136.1554999624755;
        Thu, 11 Apr 2019 09:20:24 -0700 (PDT)
X-Received: by 2002:a63:530e:: with SMTP id h14mr12329576pgb.136.1554999624019;
        Thu, 11 Apr 2019 09:20:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554999624; cv=none;
        d=google.com; s=arc-20160816;
        b=n3xR8p5TKj4pLr8P9QT1QjpOIv8Tyufh6i/B42cpirTPvP5wGNKk7VKFXNNxl8TtlC
         ykVwhopGcLjDKLdaaQ8mYu7iA/8P8A6o3MUFv44RldoYIHXK7FhBxCKvS/+Ir99PFGLs
         hu0KMZFjyexk6xuLy/DERB2c1of73toNjhwuML81g+932UErGyXQaH9ik2t4uek6BP7U
         9dR2PmKKm7AO1Ka91kk+Jz+j9DlK3YU2qdJYbKg4FzWWIcGaFIZIoVH/ncWmqB+7uWPq
         t+Aw0iFkxDVV03ObIV1lQkrSr/JtdRtBW6X6tGLVI5r1Jce6TGRkd+JhQkXSOIKquSvu
         DDUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=3w9TkuZHAqslrWVxIfj/pr9QdQEYv2bicep/qG+WXX8=;
        b=ql9zCrGZDoRGaamMjQEp/LOwBaQsVxpftZJ93TPBOZvjYpOr22Y8YlDmNwyqDGGy3U
         ASs3LcYHzC882nP+LxdoqBPQ81vZ0fc4pxVSDLo0IX2INkR8kNEQiYA/MUQPz3XS85s9
         kTP2Cl1cSw2lyoduKwiHHrFlSSuOQRjQkz9QslE0O6fdEA3IqQAsnJBM9yWbbmXoKVUW
         83fBg8NKWDQ0S3+DKteUrtlGYInR4Rju+EYgpXL8+rX7GEdHPrz7rjSHk+nSII/gA1t7
         //SsrOPCk4z/8k58s9ludgakxk/PkUjxlix1L8rrMPaqRq4lK0P5diCPpKedNxsk3diu
         II6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=aqrr9mcq;
       spf=pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j7sor39549982pfa.29.2019.04.11.09.20.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 09:20:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=aqrr9mcq;
       spf=pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@android.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=3w9TkuZHAqslrWVxIfj/pr9QdQEYv2bicep/qG+WXX8=;
        b=aqrr9mcq2AeDtB59HAIaIucdjBx2Yzk4ptZilZRNndX4ha+I/ju9YYj6Ggq9psCcEz
         hfJ+mbRqvBmAbF1f+WvsNFsFx/SGp9HVcxK7Ubjt5dpdAcTKAm0klQaEKf/Vye2SKLMP
         AmxCHFkVF6LGPtlspwIna02aLr9Ak/6fx+p9RNdrExRDBFEUxLgR40S24CZXf1g9nU/Z
         rJ9uqvU/B/pldGfMkK9jbbCAZGSt+ViBEROl5PTlZAVVNcTn9wq4FzBGrcqCqdmDTLh8
         gygeK5c51xR8R0XeR0q5qi5WCnUGLHmY5qtRS5RQy5JA0JI46557f9Co/Wvw+bBfqWnG
         kKWA==
X-Google-Smtp-Source: APXvYqzUPW5eM71ndUc6UDWTkzD31OKaYqK67v6v5VZ9SRY7hlz4748BeUborAx0SFYr/LSSK6DuEg==
X-Received: by 2002:a62:69c2:: with SMTP id e185mr50470609pfc.119.1554999623683;
        Thu, 11 Apr 2019 09:20:23 -0700 (PDT)
Received: from localhost ([2620:0:1000:1601:3fed:2d30:9d40:70a3])
        by smtp.gmail.com with ESMTPSA id c22sm42692365pfn.136.2019.04.11.09.20.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 09:20:23 -0700 (PDT)
Date: Thu, 11 Apr 2019 09:20:22 -0700
From: Sandeep Patil <sspatil@android.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org,
	rientjes@google.com, willy@infradead.org,
	yuzhoujian@didichuxing.com, jrdr.linux@gmail.com, guro@fb.com,
	hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp,
	ebiederm@xmission.com, shakeelb@google.com, christian@brauner.io,
	minchan@kernel.org, timmurray@google.com, dancol@google.com,
	joel@joelfernandes.org, jannh@google.com, linux-mm@kvack.org,
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411162022.GB124555@google.com>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411105111.GR10383@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 12:51:11PM +0200, Michal Hocko wrote:
> On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
> [...]
> > Proposed solution uses existing oom-reaper thread to increase memory
> > reclaim rate of a killed process and to make this rate more deterministic.
> > By no means the proposed solution is considered the best and was chosen
> > because it was simple to implement and allowed for test data collection.
> > The downside of this solution is that it requires additional “expedite”
> > hint for something which has to be fast in all cases. Would be great to
> > find a way that does not require additional hints.
> 
> I have to say I do not like this much. It is abusing an implementation
> detail of the OOM implementation and makes it an official API. Also
> there are some non trivial assumptions to be fullfilled to use the
> current oom_reaper. First of all all the process groups that share the
> address space have to be killed. How do you want to guarantee/implement
> that with a simply kill to a thread/process group?
> 
> > Other possible approaches include:
> > - Implementing a dedicated syscall to perform opportunistic reclaim in the
> > context of the process waiting for the victim’s death. A natural boost
> > bonus occurs if the waiting process has high or RT priority and is not
> > limited by cpuset cgroup in its CPU choices.
> > - Implement a mechanism that would perform opportunistic reclaim if it’s
> > possible unconditionally (similar to checks in task_will_free_mem()).
> > - Implement opportunistic reclaim that uses shrinker interface, PSI or
> > other memory pressure indications as a hint to engage.
> 
> I would question whether we really need this at all? Relying on the exit
> speed sounds like a fundamental design problem of anything that relies
> on it.

OTOH, we want to keep as many processes around as possible for recency. In which
case, the exit path (particularly the memory reclaim) becomes critical to
maintain interactivity for phones.

Android keeps processes around because cold starting applications is much
slower than simply bringing them up from background. This obviously presents
the problem when a background application _is_ killed, it is almost always to
address sudden spike in memory needs by something else much more important
and user visible. e.g. a foreground application or critical system process.

> Sure task exit might be slow, but async mm tear down is just a
> mere optimization this is not guaranteed to really help in speading
> things up. OOM killer uses it as a guarantee for a forward progress in a
> finite time rather than as soon as possible.

With OOM killer, things are already really bad. When lmkd[1] kills processes,
it is doing so to serve the immediate needs of the system while trying to
avoid the OOM killer.


- ssp

1] https://android.googlesource.com/platform/system/core/+/refs/heads/master/lmkd/

