Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B17DEC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:01:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CA0C2075E
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:01:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CA0C2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 240738E007D; Thu, 25 Jul 2019 10:01:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F0D88E0059; Thu, 25 Jul 2019 10:01:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DFDF8E007D; Thu, 25 Jul 2019 10:01:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B35118E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:01:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w25so32172546edu.11
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:01:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Me5bIV4J3Pmxf+wl0IQvsxdvVRMTSEPPLSq9SPfoy8s=;
        b=LQMsNIBh3kDxxEAYH6C0kdH39PhHbWpSyZ+8QcKm1yTo4ZNH5yCMp3P+DhjsQe55cL
         bdZhMCo5tUx0whzd5dh3g5bQfEOWC4Gx/1noA0gXplMlJQWhwZXdhFm0RHZLcaGh23d6
         3W2RUaTiEu1NG1vq5mvrdLj1oayVuc0/FNmoFvoAmPYGmKpaug2nGAaQKf88mHN9Dt8Z
         SiTs2S6ZDeUK5l2mcNkho20UY3DrKCBId2UPQ2xV4cF1mzAAiI7Qcwk79eKtETTtmvbB
         Xg9XmFpu0fOiSAtUfelYEIaGgFIj+dhgyAIQDY7mD4FHIYE1eE1SeMLAJZsCAMqjCiCG
         6MtQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXdBCFuVmfrIunEzxMG5ZLNUiAuUCpq9iOLtZpUkQl/1olfJ3rY
	w2uK1uRgRpflC1Kfu5axCer+WsPmxxv5E2N6I3x6gwde91GaGb618h29trVMczYrnFELF37Ey+S
	RqdwDCA67Vts6J8gAV6b+zpCMGu4TYxUq0mK7pqsiHdc0M+VSW4JykrPcF1CxlzM=
X-Received: by 2002:a50:982a:: with SMTP id g39mr76521127edb.88.1564063279262;
        Thu, 25 Jul 2019 07:01:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHXBs3epsmvh7eXsDVwUOREiusT/BJ9ye1//S9liFfqH7B1ne6uHcm03lf6XtzBaL5LE7d
X-Received: by 2002:a50:982a:: with SMTP id g39mr76521029edb.88.1564063278427;
        Thu, 25 Jul 2019 07:01:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564063278; cv=none;
        d=google.com; s=arc-20160816;
        b=snCfk58Ykd5c+RIATzwoprAYL7DUROkkYEJdyDz6jtGwsMfT3M3+O+rqDeKe0xt2Rq
         j+nbJ5ggxwoq1/JMdS8Kt6Bgp52k19AnDeHCXq6WI364Z/iQ2B1X7bSWSAY4m8ItRPqp
         CPFpKFeN5UbNcIxd6Qpx6N9T8mkbSDsO6oIV+5IulL5Odi1/eFI5Q+tlPZRrFDBYedBg
         AIIvvy4zJOAfZDWvUXs1knLGqGrHz9PsTyMbKCs1SPeTUHaQjlB2l7nFxwpEDGnICxeL
         JQPDnXt9+uSrNuGZMYzxT42ttf+W7/hNsFNkx9q4cWd1xzIGOsJiSKPk3qMfjFX+hdy6
         EapQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Me5bIV4J3Pmxf+wl0IQvsxdvVRMTSEPPLSq9SPfoy8s=;
        b=vggY36fk0zxeKh1nsHyV0p+0e4k8Q+LMUtX+hraEwOyo0trjoeHZbj/gxVFqBRzGEw
         4ZJCMgTal5ahNYjR2Hmgg48NV9FBRe/paN2F0IBxXGdRBImrRyZXmdvSZBx/wXTnfK4z
         cB10x1AluX79VGAbYA6hCjLtWH5MHYKHdNtxOwX39wEjABMn4JCMIAUNRbcRv6EDZjTT
         zspvVc0BIFsvg+UmhiLtpUFkHBHX6fsEw322TgWsUu0rdgRWuuzMBcJePgvi1ZT5Dva3
         ks6U1VhVBoBRIKBIjBwie+f+IkhRFfac6JkRDPByU+H4GUWpOynsoJf4nuoNJf98rrhs
         S8Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id on22si11061684ejb.30.2019.07.25.07.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 07:01:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0CE7AFF9;
	Thu, 25 Jul 2019 14:01:17 +0000 (UTC)
Date: Thu, 25 Jul 2019 16:01:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
	Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
	p.kramme@profihost.ag
Subject: Re: No memory reclaim while reaching MemoryHigh
Message-ID: <20190725140117.GC3582@dhcp22.suse.cz>
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-07-19 15:17:17, Stefan Priebe - Profihost AG wrote:
> Hello all,
> 
> i hope i added the right list and people - if i missed someone i would
> be happy to know.
> 
> While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
> varnish service.
> 
> It happens that the varnish.service cgroup reaches it's MemoryHigh value
> and stops working due to throttling.

What do you mean by "stops working"? Does it mean that the process is
stuck in the kernel doing the reclaim? /proc/<pid>/stack would tell you
what the kernel executing for the process.
 
> But i don't understand is that the process itself only consumes 40% of
> it's cgroup usage.
> 
> So the other 60% is dirty dentries and inode cache. If i issue an
> echo 3 > /proc/sys/vm/drop_caches
> 
> the varnish cgroup memory usage drops to the 50% of the pure process.
> 
> I thought that the kernel would trigger automatic memory reclaim if a
> cgroup reaches is memory high value to drop caches.

Yes, that is indeed the case and the kernel memory (e.g. inodes/dentries
and others) should be reclaim on the way. Maybe it is harder for the
reclaim to get rid of those than drop_caches. We need more data.
-- 
Michal Hocko
SUSE Labs

