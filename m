Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1762CC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:47:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C936020843
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:47:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Bo0OHQoT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C936020843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70A1C6B0007; Tue, 23 Apr 2019 04:47:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B7A66B0008; Tue, 23 Apr 2019 04:47:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D1316B000A; Tue, 23 Apr 2019 04:47:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B38F6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:47:28 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id t196so12609559ita.7
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:47:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=dynh9I705ZiILXgmyOl+SyaOHisQmGgJs3EbSjjJDvE=;
        b=t3z0gZyp3i18oMawDlPPTYIlOLC7jZkdWDmKcYl6KEEb8cU71VN22plYfAiQ2Jxl50
         IdOmKKSVuIIy4FsrcQSDLu6eCXVhmE15YCMv4iH6HPOUcYr3LWytDzPuGulSTqGZvz79
         KodLPb3yEOM7DdkhYPAfAn1gjsmBsnoWuWbj7yuG9PphdIvJiK3MY9hLx0oAGMMLKuid
         8KG9LaarBqZ3xZgRUeiRFRkBeRHNV6lurBMbfSYcTLXNTDprtz1tL4wM+Uv99xBo2Ahp
         2dcxfbrnfgQELT5UFUtMEFbLc1rHOA3UixO4gLpP4oUgVNkRJ27sFLXI7VKab+TAvnaU
         istQ==
X-Gm-Message-State: APjAAAU3XUlW52vIUxE6tqEcIi7DOWoqTFZjcO2xT6LsbIy8Z0hW4l1c
	Pcl6l11MJcBtWJpEZFZJZHM6HP/gkGasgLm8ZH/6LGFod/8yXyjPsKLtirUWqz1cN8fSIjuaxTl
	Zh95tNCkYzewCYGSbU15l6RVnSChgmxfEOP38JNxqkj+Z3n7IP9khJ6tNbufyFQR35A==
X-Received: by 2002:a02:2b1d:: with SMTP id h29mr16418844jaa.76.1556009248056;
        Tue, 23 Apr 2019 01:47:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyA3cUpY4bz6lCSN3vHw+fNFeIx3ZTBuHjHgBpAbNRkq44XL5BTazRH/uwrZMYhogDCrl13
X-Received: by 2002:a02:2b1d:: with SMTP id h29mr16418818jaa.76.1556009247433;
        Tue, 23 Apr 2019 01:47:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556009247; cv=none;
        d=google.com; s=arc-20160816;
        b=OjX80BtSBGmmTKIoAzrnnEpg76PGx6oB04RD/XD5L/qozEzYRWndOZm4WtEQYFu8Lf
         x0ZF2JobFab9YRg+XWBbkOa+LbThbgNNyfFNGK8RJo5b+42HiHDujYhPqQDSJhr7aVm1
         RWxKfnK0nhfFmGMbiFxIao/TiDQ89WbqvZ2goELJoOmo/WhgpqZUbSAOKbX4/SmP55Xz
         1NFjWb3DuiAPzXnef9+mYkMKvgnmgElZRJWXYdq2WG0K5z0QTK4jH7D3bXnTPii1CtZE
         Yx6IQ2drw04Ud4DVrt1LmXOI2N1hnBxy16fUKNZKlb5OzUHQqmYmxAUaPd02g6gKpr1s
         W4fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=dynh9I705ZiILXgmyOl+SyaOHisQmGgJs3EbSjjJDvE=;
        b=RAik2+IuFRGQuvbALxQijH2Ehwl3FvRfV7159Ppc5tol0aDvanY3TaKNloSJ6loR29
         M5RZhavXzYlBcHYADF/+WbkhF7BX52ApYjW+NYdVy0UJxkMi4ocv0DUT7ghivhhzWtVd
         Rk6pO5o9QAkiuAqpalv+5onnpMVL1JBAA6Lz8ImI2lKokRD1wR5RpIYnhva+Qwdc/HCu
         wi3hELSP11SeFc5gCllzyMKEnCOQjcGEhaI6w2ygN1asAHYLssTn4qPdE2z2A0evb7UM
         6+Jz+f601avefcbwqMJAkClcXP8ZvSn8mcFZ0zx632YFt9W5ebjwG82L6LRGDusNYhj9
         QVxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Bo0OHQoT;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b13si9845394itb.143.2019.04.23.01.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 01:47:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Bo0OHQoT;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=dynh9I705ZiILXgmyOl+SyaOHisQmGgJs3EbSjjJDvE=; b=Bo0OHQoTLJzkglO2o5oz0h0Bbl
	x+cYSL2ncm4+gW92HkUi/vFcT8Ephg6JndFeHZ4jepBHL1I/i5XJzaHKyHRRWn74a4zMEY1JO1Xmg
	LygsMQDvpnE0rv9DJI0VZylMSzcLlLlMLL/KivEnDeY2tjAPbHSBGmMCyIltB/AL4PckF1ZIEC4iO
	LUPkxoyinn88R4YyIbdTmtRbcnnrGprnEWBMgq0jNfGn4UsWhyo1/ZeoR1w5TyzEx+qpdTZvknd44
	btwBiylEjC2zRgoOEzthn8/ITQy5MpT8ovFl+YZiigLRlg/fF/rxDc5BMrg8kFo2o+ZtAtkrYK/YF
	DMGv5OdQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIr5H-0001FZ-M5; Tue, 23 Apr 2019 08:47:24 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7277729B47DC9; Tue, 23 Apr 2019 10:47:22 +0200 (CEST)
Date: Tue, 23 Apr 2019 10:47:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 1/5] numa: introduce per-cgroup numa balancing
 locality, statistic
Message-ID: <20190423084722.GD11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c0ec8861-2387-e73b-e450-2d636557a3dd@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:11:24AM +0800, 王贇 wrote:
> +	p->numa_faults_locality[mem_node == numa_node_id() ? 4 : 3] += pages;

Possibly: 3 + !!(mem_node = numa_node_id()), generates better code.

