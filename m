Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F7BFC04AA7
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 06:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 087E02084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 06:53:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 087E02084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EC246B0007; Wed, 15 May 2019 02:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99E1F6B0008; Wed, 15 May 2019 02:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B3566B000A; Wed, 15 May 2019 02:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF1B6B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 02:53:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h2so2356074edi.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 23:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LuZSh4Peo/xsdMugN/gZy/se25mAY9+SzlEqGTEhuyM=;
        b=AWCXCI5DcNIT+GY2oJklkvhYIzZfJT3AK5sFXZih9FQNYpNlfrGxS3NU/xIrjkfhZM
         ZHrdwwtRQvo19wggY9P0gKgmfIGTm90ORk6RGzWG1VWHtvbTEJC/l3ynwH1kNuTJ/oH/
         Ov+enafLFwJ5yPIRZ7iRfQGoG0lfOuULLFcMGRitxrP/IOU0R0ZRycsdIWkSE3JwIgqE
         /l6d+7L7kiOuQSuFlAW2kSqXqqb7/jfiIIoX/z/zbup7Jbc4ITEWcWtAuoYL7mHjNTOu
         I1mudiQmkXwkZB+qcB5cOB3wuAyWSY0A0u2Hp08ejWA4+VDWsErvCHzvx4r/685lwlp0
         pxGQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUxQqG6xG7TRp6x7WiOkwEuzgL2+5KRE48D+gatUn6qYs49nAkj
	xmKsQLDCedqx7B46re/UuxEfGo3UC97w0UP01jUrGN+HXnuIw3K8g7PqMHho5Jlta2+dd9F1JoK
	iwGciAFLsdrKXGB0U6/GnqAdfGJAgBAHlGqriTz4sew7CGpX2bSIIHp+Nu8dgkIc=
X-Received: by 2002:a50:a5fb:: with SMTP id b56mr41128796edc.262.1557903197815;
        Tue, 14 May 2019 23:53:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzALS/qHBe43xbPgIA0EQ2fl5Cvrl7BVHoaHjxyjIj2VZ9HslhrgWfchIxfZKV2/36wbEXL
X-Received: by 2002:a50:a5fb:: with SMTP id b56mr41128749edc.262.1557903197082;
        Tue, 14 May 2019 23:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557903197; cv=none;
        d=google.com; s=arc-20160816;
        b=BgbboseJI0a2G6AiC8Ufmc2YlnkusISlO47MmjkTdfwWvTxLpZ82L6hUOKKd/OR0wx
         u2zkuWlvYL8w4JhtWyOQFi6GDi2mSExjZEpRwnO9uP6OKsnwpWaAUvm4taSUtZlrl7H4
         6IlwgtS0LIxcRdAyYJFk2eEig5FinCfqOK5aaES0m9fNKjtR0BPvra7gbUxqRJVRXd6A
         qdNqB8bWxWw1YbN+rXTNZ2INjZD13YJXEu04dYlojBy15PmCKXGWyBpoYJBXB8QFCN+D
         Ae6H2Za3en3+zKLEZfTRI13Le4Jx3Jn7qXT1lvbZbr++w+es17NbUCg42RoTeUBdDvUE
         pKxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LuZSh4Peo/xsdMugN/gZy/se25mAY9+SzlEqGTEhuyM=;
        b=khAy1UGvEXPc+kGtVg7X45I6P4XFMfdALYJYwz0pXAfqi2anNFuFiojBHmOcKimcXV
         nRNQhvQ/iS5+R0PTL0y/M4n+1UtZohoZwiXM/BSJM2jt2oL3MqMU9npQv9QUDTu9GV8w
         +2XMTqVXtYktlswj3d92Nb+Dlu+xprWKmbKzvi7d7Q6/kmROFYZQfDVZorASMoLA4ffu
         GXUm2G0up71GwfSdiRtcLsCJgyXp38+KraQu9DQfoLvX6FDyXCVhb1VEngOHn27Dq7f9
         mUffyBTi9ghu9AuS3vbU5qAt4/qewDMLKy0XhuglgYGCAK4+Opvtf4FF2hoGndDA+HmE
         qlkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si30361ejb.370.2019.05.14.23.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 23:53:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 15111AE5D;
	Wed, 15 May 2019 06:53:16 +0000 (UTC)
Date: Wed, 15 May 2019 08:53:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515065311.GB16651@dhcp22.suse.cz>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 08:25:23, Oleksandr Natalenko wrote:
[...]
> > > Please make sure to describe a usecase that warrants adding a new
> > > interface we have to maintain for ever.
> 
> I think of two major consumers of this interface:
> 
> 1) hosts, that run containers, especially similar ones and especially in
> a trusted environment;
> 
> 2) heavy applications, that can be run in multiple instances, not
> limited to opensource ones like Firefox, but also those that cannot be
> modified.

This is way too generic. Please provide something more specific. Ideally
with numbers. Why those usecases cannot use an existing interfaces.
Remember you are trying to add a new user interface which we will have
to maintain for ever.

I will try to comment on the interface itself later. But I have to say
that I am not impressed. Abusing sysfs for per process features is quite
gross to be honest.

-- 
Michal Hocko
SUSE Labs

