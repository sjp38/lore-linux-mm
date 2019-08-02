Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DF02C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 13:40:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E4BC21726
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 13:40:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E4BC21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF4E36B0006; Fri,  2 Aug 2019 09:40:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA4AF6B0008; Fri,  2 Aug 2019 09:40:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6CF96B000A; Fri,  2 Aug 2019 09:40:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86DAC6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 09:40:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e9so35850087edv.18
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 06:40:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zjM66guOuT/ZN5QwNTtl6V3oo1Cfuh7qK6kclgkyjT4=;
        b=VEcocVfOwUQFNJw0+V27BRpoaN7yFW4CWPgl3ZyEhLLUqe+4J9Duyq1BQrMjql0Eyp
         eoeVkevATmQCBztLGpl2O1ZrEMhrDA4KHhNrJPy7etjffJ/eA6u0xBE7hFsV2Y769KiV
         wtcgfZx5QDXzYWkkApPg1Kea71SilzhdcJGLOEJCyiS7BbbjVU8QdEtnIRVoWXRa4tOj
         e++L6oYOdSBiyWPCGlvDFoCikOeThgapbP82hE/SH4HjclruPpu8t44uHEoV3ePlToVV
         hPYwJkIdwOIQEBn+VQKH0Aox+GXAexcS/5YL5JWaXOqDks9zl1OOhImQAgkQ/8OpwlDq
         ZYrw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVcYLmKCEOW3ijQAyZRKQ5m1URchtsjw41J/S9b5pniTC6WNtbD
	AAQdvhKPjs8U9/tczI2wcp2Ct+iQMZiPbWX4MhhnFE0yap6R1UG+haFvzCQQN+ZwrmVkLrJhLOg
	LD3J83EuJW7+R335CxOE5VvsQ3XlOMK3rPH0XeKclZ9+IiuFli16y48Mom4mcjS4=
X-Received: by 2002:a50:eb4d:: with SMTP id z13mr119870177edp.271.1564753226094;
        Fri, 02 Aug 2019 06:40:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzscvaJzUyaYmrISxIhiDNaWiQlXt3Y8ZGz7Slglm/dr9TQHa2SAiTa0llOnlYwPZnT3w02
X-Received: by 2002:a50:eb4d:: with SMTP id z13mr119870096edp.271.1564753225137;
        Fri, 02 Aug 2019 06:40:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564753225; cv=none;
        d=google.com; s=arc-20160816;
        b=paRNXMX/GG5jfXYB+4NjfJUSsJ3Pd54Vim0jhAO+6QwgKDHz1dRbICgPxY6J1nQsSf
         CvamBZn8Z6chrrrsS5kfIyrJ0Pjgr8ehGAjYtXaAEY1jUXPMGWEvnTUiXWK/mrVoGgfr
         2SSIpisP8EJTKqkAqydsLy+mw5PQECDtIqn3sEJ6HEgHnecwsO/6rpkfKWXq3u87En8W
         zeizeoA4vhmwHImeVMQJP4is5DvsXOUjK4981F/1bKw9VJdD0+5zEOqcIIRy/U7OLL6o
         xtV6yZxTCELhsA0EpxLpKPypssSkg9TIpJTaM5c8sqjhAfwuID5qjk81ubDGKGgBZoxq
         i8JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zjM66guOuT/ZN5QwNTtl6V3oo1Cfuh7qK6kclgkyjT4=;
        b=utJeDd3286TL7K87DHJxZFisksntNwP86e935dR6KGt0mSczAzV9X3T1nU6BTFZE94
         +nDgXMt1FUSecdcE3aC0muz5xF9xWaibDrysz+UIajtPMFJ/JyFOAXyVkrI6O2Sbw2vm
         lctMyvffL4WNLTO/MaMcrpHjmpYWBRFfBlpIWEFHQRtOJKkDGYukXDJwQ0WSOn9c7qRy
         945JeJWyLjpQkFQ6isOjLZMexkOCTxiUPwT1vdEVTamKg687YNxpVOU8RUKnsA6t1153
         7poVz+l/NFElX7LdGwuyQwbmjKGGcl1cIVH/JVugW0CU2jx17UGPWutpZCNV2FUVGlZ/
         6Ecg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si26028093eda.145.2019.08.02.06.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 06:40:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8D6C3B62C;
	Fri,  2 Aug 2019 13:40:24 +0000 (UTC)
Date: Fri, 2 Aug 2019 15:40:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Masoud Sharbiani <msharbiani@apple.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190802134021.GJ6461@dhcp22.suse.cz>
References: <20190802121059.13192-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802121059.13192-1-hdanton@sina.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 20:10:58, Hillf Danton wrote:
> 
> On Fri, 2 Aug 2019 16:18:40 +0800 Michal Hocko wrote:
[...]
> > Huh, what? You are effectively saying that we should fail the charge
> > when the requested nr_pages would fit in. This doesn't make much sense
> > to me. What are you trying to achive here?
> 
> The report looks like the result of a tight loop.
> I want to break it and make the end result of do_page_fault unsuccessful
> if nr_retries rounds of page reclaiming fail to get work done. What made
> me a bit over stretched is how to determine if the chargee is a memhog
> in memcg's vocabulary.
> What I prefer here is that do_page_fault succeeds, even if the chargee
> exhausts its memory quota/budget granted, as long as more than nr_pages
> can be reclaimed _within_ nr_retries rounds. IOW the deadline for memhog
> is nr_retries, and no more.

No, this really doesn't really make sense because it leads to pre-mature
charge failures. The charge path is funadamentally not different from
the page allocator path. We do try to reclaim and retry the allocation.
We keep retrying for ever for non-costly order requests in both cases
(modulo some corner cases like oom victims etc.).
-- 
Michal Hocko
SUSE Labs

