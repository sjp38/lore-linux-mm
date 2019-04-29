Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B797C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:55:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C97722087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:55:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C97722087B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 633A96B0005; Mon, 29 Apr 2019 07:55:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B96B6B0007; Mon, 29 Apr 2019 07:55:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AD586B0008; Mon, 29 Apr 2019 07:55:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0706B0005
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:55:43 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g6so12786677wru.3
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 04:55:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Kw4Jxdwps4q+sJBaI/+7Hi+IVwiP3jjLius7dV17GzI=;
        b=MgztBM13ZcpexXOOaKynyzNIVylacy/zKXNffzsbEinca4ftEgXGFFUqNXBUtZdk3h
         5cGGtlsSCiNsKqIJ9afsGQWTKZCn/SyUsq4mjClQHJjCUeRVaNqp1HPZMa+v1gdglxtF
         CaG/0bUwxy8bYuDsVD2rRm8GPuiKqK4MPea3wcbnpHWmlym4taQCMOrCIMV7U2nye3lf
         5F1ZIzGsCcRNVnS1lE/ERhBHs7K9ekRad/Qx8dzp7yj0i1Klcq0vTYAO5IzqChgUwpn9
         NrJIt+a15iEbRO65dS0VPAniBtFie9S3yANlLGRrk6tltEecyKega++X5MKdBB+dtK5B
         95vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVwhzLPhI+LGSmWcfrZhzghjl4/dT4zPVHtxi6jCHrF3ih8yFIO
	zfmz2g4k3dRRvRm9VG5ZYDWP3Gh7hMFZvmrVmK+HMlt35A5q/7taQFYb4GACBz0uYGJFi+b0JPu
	z+NO8w+Q23nZz9cpHboj7xi1kwe9l3zYqdUXhruUa93ZK2WFW1q4rMrlyZz7gjxrE2Q==
X-Received: by 2002:a1c:4d1a:: with SMTP id o26mr4278858wmh.133.1556538942656;
        Mon, 29 Apr 2019 04:55:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLFYnGPlLbikCDhzihtYg0voSnl6c8lyt60HAzsfW+RjozibomrzD4kY5hXeCRqyQEjWpc
X-Received: by 2002:a1c:4d1a:: with SMTP id o26mr4278825wmh.133.1556538941821;
        Mon, 29 Apr 2019 04:55:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556538941; cv=none;
        d=google.com; s=arc-20160816;
        b=L9U3dDXNsiN8T6QHUVCMXmEfiRwsUbzHl8GXVCS6vbUpAT8uUkymIw5VQXfuOgOMAa
         soS/Hy6N7CECBFH5aYIekBiP/IDZ16aeD/pqAIReGVtfOoCMQlNnAKKlcmEcC87AA+Oc
         Uxd2tN+4Ya5uAp4FqfX2qo01fynA/5zEiBuzuB25OmWp6dk/BolnSsS0bpIrob4WOJWy
         6gC6gxsXX7NxxsTcdlimj3Lp8iFzTAT/AJVlA60ympTYPUQmxnfeFYj37w72bdVkUYRB
         9KMFaoVbp9l1Yfcqgr6dsp9/e2AxuNpcRXdj6Ie+uoARp9YqZFVFn4ul2k3BFXT2HS4E
         Z35Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Kw4Jxdwps4q+sJBaI/+7Hi+IVwiP3jjLius7dV17GzI=;
        b=0gGpfUlj+ZG9KLy5onv56LXcM9kL6+9rkks/cI+dfAx/C6JWgbFuQWXU1N2r6Xf4Ov
         iotqPw4AV+mbgONGimyFDeJYFazJ1k9vCS0EH/zYXy/wjemXYAoVifTHC7luj8PAqRLK
         QGub8QLDVFJBi/fQwcWLX5B1fy2E/+bSd0FsNlnlivt9mBXeIKCZWG+Ax5oLM2XqpsBT
         W0iC7e46DMmihT+A+m+lbCSwlG23cA69eS1nz7o1wpSCheqpvAIj1+7llLnO+Fh1cpEc
         v7BFhna/LaTi26ubZ68QkAVDR5abH6xnqPTESgAwo/a9ukQTM80HtvI8J3ux27dqw5Ex
         J8Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e7si23441246wrj.109.2019.04.29.04.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 04:55:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 3039C68AFE; Mon, 29 Apr 2019 13:55:26 +0200 (CEST)
Date: Mon, 29 Apr 2019 13:55:26 +0200
From: Christoph Hellwig <hch@lst.de>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Subject: Re: two small nommu cleanups
Message-ID: <20190429115526.GA30572@lst.de>
References: <20190423163059.8820-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423163059.8820-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Any comments?  It would be nice to get this in for this merge window
to make my life simpler with the RISC-V tree next merge window..

On Tue, Apr 23, 2019 at 06:30:57PM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> these two patches avoid writing some boilerplate code for the upcoming
> RISC-V nommu support, and might also help to clean up existing nommu
> support in other architectures down the road.
---end quoted text---

