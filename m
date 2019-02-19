Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06C52C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:36:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C77C92147A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:36:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C77C92147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68CA58E0004; Tue, 19 Feb 2019 12:36:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63A028E0003; Tue, 19 Feb 2019 12:36:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52AF38E0004; Tue, 19 Feb 2019 12:36:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF7CE8E0003
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:36:25 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v1so893488eds.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:36:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QpL3NTsbAmlZhe7p1z6akf/rO4amyQ0rsiujX3+2bWU=;
        b=OOqWQZe7mFhP8GcTweB4WgK3vvbA1o5X+878pSXJq15r2lYmCO3LDNcTEv866FmCrh
         Q92Y6rZPH1aYEnrVZFrRCTOLfWSZpahJPRo2jx6QC9mXHtBehcgDaV2zDFIFZR/F+J8j
         IBP6AzTpbqAL75D5ZCGRrT0PDj49f+nFBCS4tUS4uxeBWT8ffeDXXWeCFTTrT17soREU
         ZUF/lUuRHhzh8JHzulyspczq+ZsED8z0CZAvwJH5MMAzT3lDiPbCJLBin4BOTAxvKXwK
         +AGE3N/H3xSaCmWWyn3+/7ahw1J2wC8h/8MgbiqxCKqhl1InJZvJgi5MBbbWnac1BV0b
         hLqg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuag1PS0Ld9wlB2HkxdT5EAqk9qKmUdjkSoTsXaToPZt9uMr2LSD
	k/aJ8gpuc+EkvrztY6O8U189IzM0MgSUpSRxPJx0SGRSxBhws25gyCg9yI8Ar3uz4lLnkiHSZnq
	B4rJRL8v+QBhKm4s0jijJnwkmmdWMNjhGuEWt+4kb79aOK+v7E4d0Um3u/aGXe7s=
X-Received: by 2002:a50:b3c9:: with SMTP id t9mr24335528edd.270.1550597785494;
        Tue, 19 Feb 2019 09:36:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbwZRTXUMTw6Co5/2XF8BCSHrrN41ibB3KMHj53h6LZHYzhoR6S4rL2emIzWrWUz84tYOtE
X-Received: by 2002:a50:b3c9:: with SMTP id t9mr24335476edd.270.1550597784489;
        Tue, 19 Feb 2019 09:36:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550597784; cv=none;
        d=google.com; s=arc-20160816;
        b=wFxGzjzaqo9ZuiVrXGSjggKIzhZtzYEURnnXFCsUcEQqEiFjD6/y+QWgStuESfCYu8
         RFTktHbSZG7+MqG2D0stAiY6L5H2TqqbRCOSA2nYapiJqCRasmsVXJkmRS/E73hiIJug
         V5NlD+7B8s8pGXc9pNU9EPnpE2yZrbeRhcZTTTWKNyZrm0TDBBx+8DDaiTFYdHsuAp1f
         Fg67kTi7DULPTvkIUKwDEXMxuTpQ0TMmisi6aRTlrjDUfk2z3Y81ifQkc6z7Yb2OniT/
         cDuagm6xAJJ7KLot9X38hsK01m1EI4jQOWUU9nEKL4XAjx1ClPC46X1i8tWNuoLxxOPp
         lCUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QpL3NTsbAmlZhe7p1z6akf/rO4amyQ0rsiujX3+2bWU=;
        b=NXrAR287YI/llsyeYORjc+lRXOSk4dIx5qUH3jqq8Vwa3LRnUdAGum5jNCYJ+uZigD
         h9kbO0lDDyuAziEP0En0dZqNF55oq9qjxGaMjpUNkHp2yC4JMXr+Q2V4mOev/qH2ckPV
         QLb7LfiVA8xbPpop1H1YRja/JAvuQEHy4hDpTpiu1pctp/aunP7xFuUwEFlS14Zfppf+
         Gqp5YBIIkOhIeLLvFFoWf5/aVMOX90AJSYP/7sSM5KSFfImD/v18fFCVrdtZBuJT5fsp
         yrg06PRyJwiBQfyhDDml2Dn/o8zflYgkeAdmOTw3B0QV1KAgyYcY0BS8WO1C89am0nRQ
         6o+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20si3234445ejj.209.2019.02.19.09.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:36:24 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 124A8AEC7;
	Tue, 19 Feb 2019 17:36:24 +0000 (UTC)
Date: Tue, 19 Feb 2019 18:36:22 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
Message-ID: <20190219173622.GQ4525@dhcp22.suse.cz>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
 <20190219122609.GN4525@dhcp22.suse.cz>
 <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 19-02-19 14:21:50, Cristopher Lameter wrote:
> On Tue, 19 Feb 2019, Michal Hocko wrote:
> 
> > On Tue 12-02-19 18:25:50, Cristopher Lameter wrote:
> > > 400G Infiniband will become available this year. This means that the data
> > > ingest speeds can be higher than the bandwidth of the processor
> > > interacting with its own memory.
> > >
> > > For example a single hardware thread is limited to 20Gbyte/sec whereas the
> > > network interface provides 50Gbytes/sec. These rates can only be obtained
> > > currently with pinned memory.
> > >
> > > How can we evolve the memory management subsystem to operate at higher
> > > speeds with more the comforts of paging and system calls that we are used
> > > to?
> >
> > Realistically, is there anything we _can_ do when the HW is the
> > bottleneck?
> 
> Well the hardware is one problem. The problem that a single core cannot
> handle the full memory bandwidth can be solved by spreading the
> processing of the data to multiple processors. So I think the memory
> subsystem could be aware of that? How do we load balance between cores so
> that we can handle the full bandwidth?

Isn't that something that poeple already do from userspace?

> The other is that the memory needs to be pinned and all sorts of special
> measures and tuning needs to be done to make this actually work. Is there
> any way to simplify this?
> 
> Also the need for page pinning becomes a problem since the majority of the
> memory of a system would need to be pinned. Actually the application seems
> to be doing the memory management then?

I am sorry but this still sounds too vague. There are certainly
possibilities to handle part the MM functionality in the userspace.
But why should we discuss that at the MM track. Do you envision any
in kernel changes that would be needed?
-- 
Michal Hocko
SUSE Labs

