Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11413C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:47:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF8DA20862
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:47:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF8DA20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69BA86B0005; Thu, 16 May 2019 03:47:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625736B0006; Thu, 16 May 2019 03:47:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C7006B0007; Thu, 16 May 2019 03:47:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF0986B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 03:47:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n23so4015702edv.9
        for <linux-mm@kvack.org>; Thu, 16 May 2019 00:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kX6DfuMYO4jwXeegWvMirJJDqARTD8MbTOQ6OLXIkto=;
        b=kduN2xxMiNU51bSOyvJNhC5jQpv6G1FXHIeIG7WOw5smxtTbP5XTEiQVyVQyXZR619
         jlCekJ18lXksoRw0pxqS1RInfwJ4pFpxO9b04E8ihwkO16f7x7evSGyow27VdRZGns3t
         6HFwpuekGeNZNZM+t2+aY04/zFcrbVeZqnlEAd3ItAdF4oZt3X5x7nIx9ASAhr70cj/f
         sBGGkxTj6U8wjz9SyHTkA9r19agg7Dqkht7U9k++V9q08pPQhCVUYJsUrBdQ+Wmp9aoe
         ri8dUIjzZXkJfuFxdEKRQGKpICcuP4ipPgDwmmSdcbicKBFo8Z0ifDe12C1WrM0RPR4u
         qPPw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXrcLSlViUyt9zy5yvVTsLkCU6bNgnRD2FqseLZozXKthd/k2TL
	DHrfQNsMe0rNvQEKhhmzYPDuCeiHQtVVrZMDIovXUzwD4ihuCPpFub6pFpBgbJ7HLj5UlE9qtA/
	3SF2Fzf5UTKs9Hb2c1IquDfSwXxrfYMbafcjFknMpmIqF64NIx6Tv8XIUXyAtBPQ=
X-Received: by 2002:a50:b78b:: with SMTP id h11mr47776369ede.134.1557992835467;
        Thu, 16 May 2019 00:47:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKg5LdAqS6Ve4PTMatwYXOdhzgWmNdtzwp/MjnOHsrR1yxHzGyEen3zTln3p6+wJHXAPth
X-Received: by 2002:a50:b78b:: with SMTP id h11mr47776309ede.134.1557992834765;
        Thu, 16 May 2019 00:47:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557992834; cv=none;
        d=google.com; s=arc-20160816;
        b=xwFJY0DgeoSXfEvqa6f2LFTt0Ndh1NAUQOZtK4jrGr2KqP1ugSJ4xAW3/IAc/3ULz+
         dbVxHNGDAEJkL8W++3JE8om8cAsqYhyKN5ZG1zBEUW3l/eQlQMVf2vjuI3gXYwLr0r5J
         kzGufxnfGfH30CuM3uDO8Hy+MHo3UPFwdWPF8QohxBVohfof8f7nQPHUXbWpAqRd2XbS
         6zymbdJ3ZBl/CwrOvWTcdCEnsJyaru4W5LqGY7Psmmk1yKc4ZuSdNLZmmaIqq+JhUx/O
         39MKunextGXmZlaVo0/bqm29d0oLRPveNGS0HiaeYEJOQRqsGQSUnyLWLfOj8IpxS79w
         Vdfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kX6DfuMYO4jwXeegWvMirJJDqARTD8MbTOQ6OLXIkto=;
        b=CtXb6xCBsveK6IX622QKvrhjQ+gxqLmanAvfcX/7MQ1tIRNthwthJPZLWX9hbxKurS
         mbBI9+ny8hiR8fqmY1w3P8SCaYnmYpocIcn3X2vSC1Xhoj4ZuVVkEc3m4bVB3ASoQLK7
         leBwWeq3jzssQr4GdqJR0TFegn1UrvKkXkEmH7QO2r/uzUBDkL2bdHL5HOXWXSWpczAR
         8rEF1R10sVrz6HwBNaOLAhElTOy3wyNqxQ7zxbfooKwTnmlRqcYy8QiUEjTmbCkfT2kZ
         Lt4hJu1xrDYn91OLp+pf5QPm+yzDib9pID/5hQYIXBtzPTlgJx4QsLcvWU438Pxk+MBY
         KpkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si2967137eju.75.2019.05.16.00.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 00:47:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CECF8ADCB;
	Thu, 16 May 2019 07:47:13 +0000 (UTC)
Date: Thu, 16 May 2019 09:47:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Greg KH <greg@kroah.com>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190516074713.GK16651@dhcp22.suse.cz>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
 <20190515145151.GG16651@dhcp22.suse.cz>
 <20190515151557.GA23969@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515151557.GA23969@kroah.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 17:15:57, Greg KH wrote:
> On Wed, May 15, 2019 at 04:51:51PM +0200, Michal Hocko wrote:
> > [Cc Suren and Minchan - the email thread starts here 20190514131654.25463-1-oleksandr@redhat.com]
> > 
> > On Wed 15-05-19 08:53:11, Michal Hocko wrote:
> > [...]
> > > I will try to comment on the interface itself later. But I have to say
> > > that I am not impressed. Abusing sysfs for per process features is quite
> > > gross to be honest.
> > 
> > I have already commented on this in other email. I consider sysfs an
> > unsuitable interface for per-process API.
> 
> Wait, what?  A new sysfs file/directory per process?  That's crazy, no
> one must have benchmarked it :)

Just to clarify, that was not a per process file but rather per process API.
Essentially echo $PID > $SYSFS_SPECIAL_FILE

-- 
Michal Hocko
SUSE Labs

