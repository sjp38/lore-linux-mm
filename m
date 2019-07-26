Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B116C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:31:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F56C229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:31:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F56C229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B50466B0003; Fri, 26 Jul 2019 06:31:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFFF66B0005; Fri, 26 Jul 2019 06:31:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F1978E0002; Fri, 26 Jul 2019 06:31:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F96A6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:31:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so33863715edv.16
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:31:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=q5OSh3OERl92GZLXK5ongYTq/KLDbxrfouQidJQ8hPs=;
        b=KL9Z0yzG0BljXFLLr85zpTf5HpSFKvgLCMg0bZsMyZQfTR/SqnoGfCUd1cpHUTC5BC
         Nr263IU+z87X6DNJaew00X4orWA8pW8Zbh3cZdrTQ1nDwerQeyw9LK7YM660/w534Hk4
         9eZgrhO35hEG/0WlNonuJGsiTbsLa2Dz5rcITm3slBTUfwvAgT9slmK2K1XwdAJ7Yn1k
         KBhW3h0d8GLWYqjs4zFpsEYXfJKJ9FraZr7baVREEvhZBLiXiFJSQoJ2+BrrQjjl54Ov
         KcD729gMqjXTLx/Fc1Vt7vsxdsygjX4UoiuQPz6W3qxLSwfDfx+mmDiDsABl9f366vZP
         WqPw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX58xdepLegWGDC07Gc12ZMXJoTS1ShIt//GPAmQu8uPc4INC5H
	h1vn+SgiyUC1QEmBMcjTfwm5jWlsYjgf7Uf9AGtGDThlwXoVPQxuSoVDIAaHhvih4BmKUKgo0NZ
	H7ndAV9dvRm1lgcJbW/DrdHQEVOMcvVYuVP38UbZv5pXvAIPK2QibjYoL7E0oMTI=
X-Received: by 2002:a50:fc18:: with SMTP id i24mr81342706edr.249.1564137074838;
        Fri, 26 Jul 2019 03:31:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw96ZbSeZ01p7QCtf3yVyfQpK3SMHUA7DyoQBuDkJeyPjVIKUmwitAUlH7aIVSHU4YJ7na+
X-Received: by 2002:a50:fc18:: with SMTP id i24mr81342649edr.249.1564137074087;
        Fri, 26 Jul 2019 03:31:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564137074; cv=none;
        d=google.com; s=arc-20160816;
        b=T9dUCBekaaatBEtRFkDCXLhyEYAJxCVT9lB1FW9gxLVXev3wfeeSknDN5Lag8L4l2Z
         /gFoQDG4FeMAZ7qvnZuXSCV38tnAb6BgF+NtLnp1pEo1xEWslwiiw/rWeR/CtZ5RB4Zb
         CFK/ukMt+fitak0rSJH5QMKx+UxfUI7FHzj/PApE8qLFo4xFpn4xF692zDV0D1VUFucI
         4ZzMClQdMn+RN6X43WEvtfLChy2iOyZLq/MaL00Vx+iCvkaOkvIIjOAmTq+lCj9YJTWe
         lWVefWX0nlJSAnE6i51Y8Dn6SG1hwk8C89F9EcAMpO4HH28Z26BQTXBeAtk5Oh3m53k/
         yZAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=q5OSh3OERl92GZLXK5ongYTq/KLDbxrfouQidJQ8hPs=;
        b=ZhQHSJT/+ryvjumnyh8nKWy4M0+f58vxeX7bDdQ60ImGJjqRT7tIdeAWTh9CHlkRrQ
         esRxkkAE8+/jqlqWrrEKUd230rV144Vk6cMSuMUke35lViH9O8AAxhRZmTnEwYt9X3L4
         ZeYJCWgH7VwrjDkPvgR27hIqTch1JlnejEHmKjJj8xD1RAedrGhFvo/jhActyEjphe+t
         9LGaplr18gVeVjc4FHaJ4dNaqgsMvsmwp0ZSBEbM/ho5Yj9Co4wjaCaRzMrav6Qs5zW2
         NaW0IUu/O6KxLB/3DH58rzPMpLUZRu28lHVzW8ogFEWj2caeog0BASrSUG/Gg83F98Mn
         7LCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l28si12772958edb.261.2019.07.26.03.31.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 03:31:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 58D0DAEAF;
	Fri, 26 Jul 2019 10:31:13 +0000 (UTC)
Date: Fri, 26 Jul 2019 12:31:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190726103112.GL6142@dhcp22.suse.cz>
References: <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
 <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
 <20190726075729.GG6142@dhcp22.suse.cz>
 <fd9e8495-1a93-ac47-442f-081d392ed09b@redhat.com>
 <20190726083117.GJ6142@dhcp22.suse.cz>
 <38d76051-504e-c81a-293a-0b0839e829d3@redhat.com>
 <20190726084408.GK6142@dhcp22.suse.cz>
 <45c9f942-fe67-fa60-b62f-31867f9c6e53@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45c9f942-fe67-fa60-b62f-31867f9c6e53@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-07-19 10:57:52, David Hildenbrand wrote:
> On 26.07.19 10:44, Michal Hocko wrote:
> > On Fri 26-07-19 10:36:42, David Hildenbrand wrote:
> >> On 26.07.19 10:31, Michal Hocko wrote:
> > [...]
> >>> Anyway, my dislike of the device_hotplug_lock persists. I would really
> >>> love to see it go rather than grow even more to the hotplug code. We
> >>> should be really striving for mem hotplug internal and ideally range
> >>> defined locking longterm. 
> >>
> >> Yes, and that is a different story, because it will require major
> >> changes to all add_memory() users. (esp, due to the documented race
> >> conditions). Having that said, memory hotplug locking is not ideal yet.
> > 
> > I am really happy to hear that we are on the same page here. Do we have
> > any document (I am sorry but I am lacking behind recent development in
> > this area) that describes roadblocks to remove device_hotplug_lock?
> 
> Only the core-api document I mentioned (I documented there quite some
> current conditions I identified back then).

That document doesn't describe which _data structures_ are protected by
the lock though. It documents only the current state of locking.

> I am not sure if we can remove it completely from
> add_memory()/remove_memory(): We actually create/delete devices which
> can otherwise create races with user space.

More details would be really appreciated.

> Besides that:
> - try_offline_node() needs the lock to synchronize against cpu hotplug
> - I *assume* try_online_node() needs it as well

more details on why would be great.

> Then, there is the possible race condition with user space onlining
> memory avoided by the lock. Also, currently the lock protects the
> "online_type" when onlining memory.

I do not see the race, if the user API triggered online/offline takes a
range lock on the affected physical memory range

> Then, there might be other global variables (eventually
> zone/node/section related) that might need this lock right now - no
> details known.

zones/nodes have their own locking for spans. Sections should be using
a low level locking but I am not really sure this is needed if there is
a mem hotplug lock in place (range or global)

> IOW, we have to be very carefully and it is more involved than it might
> seem.

I am not questioning that. And that is why I am asking about a todo list
for that transition.

> Locking is definitely better (and more reliably!) than one year ago, but
> there is definitely a lot to do. (unfortunately, just like in many areas
> in memory hotplug code :( - say zone handling when offlining/failing to
> online memory).

Yeah, the code is shaping up. And I am happy to see that happening. But
please try to understand that I really do not like to see some ad-hoc
locking enforcement without a clear locking model in place. This patch
is an example of it. Whoever would like to rationalize locking further
will have to stumble over this and scratch head why the hack the locking
is there and my experience tells me that people usually go along with
existing code and make further assumptions based on that so we are
unlikely to get rid of the locking...
-- 
Michal Hocko
SUSE Labs

