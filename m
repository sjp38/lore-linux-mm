Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2315C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:41:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E29A21726
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:41:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E29A21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E78D26B0010; Fri,  2 Aug 2019 10:41:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E28D16B0266; Fri,  2 Aug 2019 10:41:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D17746B0269; Fri,  2 Aug 2019 10:41:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 80DA26B0010
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:41:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so47119694eda.3
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:41:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=gil8uetZrKjo605/YBjtpRXF9Iz9NiLbIUSWWG0FpWE=;
        b=uN+5fcm1ipHZcP8j+cPgR5aUGUf1G4f5biDjvpJxxKu0QTm9AeJdfrNEfq+ZMbZVe7
         VKQodriYzAchDw02RPx8YoehdNoBaWpAmEYs3NqG3JMcJ+BzGri1g/f7hQ+931siMivP
         gAL0jy5Pt4vLerv8Y22+nfOw+rop+QiEkOGjwTQhO3xjC2xNPADPorJBQMKgNturYdDv
         x5gw3WJ+QeKmHm1gqg9xeC2NihkOy8CbHkpTiNYApbESVDQTBqM6ifqsKufo6C1bTcBt
         P4XTyo+4grC81vw7brfNChUQMMuzy8Jcb3Ytpv6rrraW0/4E0gLTd5W6PHLmZw7/Xkq4
         ms4Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW/Ove0o1/V8EwDrhgch5fiFuzdc9GR2A5MncaA9IZz4pL+I2uE
	Z3XBV6QXqQumlkH8ZADcxJIIHgzgrkbOkr0Au9vRusYj45gonSDYr1GoPK+y7b/yS4XpK4KP/C4
	Ji1f5nvEagkHkxohbcsNL52Njodse5Nn7jY2ltiEI+i76XkB+uFfWYWCysPNUoek=
X-Received: by 2002:a50:95b0:: with SMTP id w45mr120567523eda.12.1564756874105;
        Fri, 02 Aug 2019 07:41:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ37jM+sS35LhSB22diuQvqZ/ovdM7sX75AUEPMRCbf4uTm6cedFSCb9MU0cFNf+3IrdmE
X-Received: by 2002:a50:95b0:: with SMTP id w45mr120567446eda.12.1564756873410;
        Fri, 02 Aug 2019 07:41:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564756873; cv=none;
        d=google.com; s=arc-20160816;
        b=bWEfG0FEIsat4NV1rPZaEO03+EScmvLrEB/FtHfFpSnLWUTyg7gGdCtxSCpFe2r/6Y
         stqAgPqzWPaqY+r/t+HKprtQFotIERDlAksGynLj6XqOC3be76H0sewMXfFAdRpaodON
         SP7W5+ucE7ZWHj3x5a/abAzkToHNtPYUy7ZTRP7vhCQxqj4CYXcwpGIKQ4qdFCnbhVpO
         /vfn5UOEnyb4GlTuJbDoQvYTKdClPWOSuFIMfi3ezgx5IKnY87gDRd5NSprlbV8RD3dS
         DO5BAjKJvVaEu7LW9zBCDSiBF9bsBguiBz26viaI6eg1ZcFG1gxYil9GJzHJgFI+dAtn
         1Psg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=gil8uetZrKjo605/YBjtpRXF9Iz9NiLbIUSWWG0FpWE=;
        b=H0eh1AD+Wa4O4r/fs+yUOUf5mGp3I1WUhVqTEo5dZKHWhHM+QJI7BSCH4afo+6vPlE
         Or+xMn000X/M9gOwK3xDYQdNUO5QMV1sGcOTIxgoh+v8jOZqvFJwT7Qwa8UaBaFaumyn
         D2/XrjCketwGksx9Wyu/Ck27pfZSgrGvsSd+zIMoFrBtxgONeO3u3Yvz+lU6w0xVSyym
         xdlmT0lIv+5pYgMIM7eAS8eDnRIGb/ljREOAwtSiWHUCZH8+nP/2Qw5AHa2CKy/sGIWI
         7fkifWCGQVnBRaDrdKvV24nkpQY26k7g9btvZ2rRsOPEleZJBVIDt6ivxCqfYsrAZYOE
         tW0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf13si21770274ejb.228.2019.08.02.07.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 07:41:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B63D5B60A;
	Fri,  2 Aug 2019 14:41:12 +0000 (UTC)
Date: Fri, 2 Aug 2019 16:41:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Masoud Sharbiani <msharbiani@apple.com>
Cc: gregkh@linuxfoundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190802144110.GL6461@dhcp22.suse.cz>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 07:18:17, Masoud Sharbiani wrote:
>  
> 
> > On Aug 2, 2019, at 12:40 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Thu 01-08-19 11:04:14, Masoud Sharbiani wrote:
> >> Hey folks,
> >> I’ve come across an issue that affects most of 4.19, 4.20 and 5.2 linux-stable kernels that has only been fixed in 5.3-rc1.
> >> It was introduced by
> >> 
> >> 29ef680 memcg, oom: move out_of_memory back to the charge path 
> > 
> > This commit shouldn't really change the OOM behavior for your particular
> > test case. It would have changed MAP_POPULATE behavior but your usage is
> > triggering the standard page fault path. The only difference with
> > 29ef680 is that the OOM killer is invoked during the charge path rather
> > than on the way out of the page fault.
> > 
> > Anyway, I tried to run your test case in a loop and leaker always ends
> > up being killed as expected with 5.2. See the below oom report. There
> > must be something else going on. How much swap do you have on your
> > system?
> 
> I do not have swap defined. 

OK, I have retested with swap disabled and again everything seems to be
working as expected. The oom happens earlier because I do not have to
wait for the swap to get full.

Which fs do you use to write the file that you mmap? Or could you try to
simplify your test even further? E.g. does everything work as expected
when doing anonymous mmap rather than file backed one?
-- 
Michal Hocko
SUSE Labs

