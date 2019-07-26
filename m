Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5601C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:44:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9261E22BEF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:44:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9261E22BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22AC46B0003; Fri, 26 Jul 2019 04:44:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B50F6B0005; Fri, 26 Jul 2019 04:44:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A33B8E0002; Fri, 26 Jul 2019 04:44:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD1356B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:44:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so33677626edx.12
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:44:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cR9cZCL/gkGw9AWPWUbBA52BHOxnTMVlBaN1kJygVbU=;
        b=YjIlKQ13Raq0yPNQvA6r1+6a0Tq2Ricpv6xUg5t5DDOUM4ddmqn8KMjjWirqGt34gT
         pU+EHyVUHIiT8E02EXG4ZhILwO6e3DXLZQ7Aww29TQa4S8l1NtktDRAEoWq2+iRXw9Oy
         X6YzKLaVxpSCZkq0vvHgL2N4xqZkjTxCHAghTIUfEHUa7MSHFCKeXzRXWL9Id2FaWK75
         XA+Arjj//dtHwMhj/MbMnCXuAenKEYYAwtwxleL/f51t8tnSD+kMbEDGzP7MZ1eIxkUu
         M/Lru2NlOtr05gi0EFJblfiYyBoyOU0n0/1d24mooez4/Y/2lfjARFUNm3GnyPL+TRxH
         LYkQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU4Xjf1O28qcVnSG7TfiIloFjILpg4HbWaxcem5neamzgVtWc/9
	FbShNtELH7bt53/+fFa0xvGo6FwwX/7wj+zBxCZZMjfPpog+qwFBdj1NUZ+SVbvnH7MBNPKTigU
	J7SOyedHGayCEzBvxfOAw9RZiRR78fcNzT0uhvANFOraGN2HFnFMQRm5hMz7kuaM=
X-Received: by 2002:a17:906:6a54:: with SMTP id n20mr72847073ejs.232.1564130650282;
        Fri, 26 Jul 2019 01:44:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0cDdOp2f5XHoUKVYB+23lQU6Vv0gLswSFmmdovnlv8ggxnNbIDg67t+dAHOqWjDZEDFSu
X-Received: by 2002:a17:906:6a54:: with SMTP id n20mr72847041ejs.232.1564130649685;
        Fri, 26 Jul 2019 01:44:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564130649; cv=none;
        d=google.com; s=arc-20160816;
        b=Zg4XRvBcAeE47U34jfTxx9igcPFGvScj2URHGpvRE0qw3JsjT7fLcz9kIJCF+LGxGo
         w4t1rLUmFMakB09WtX7ycAkQyH0RC+IgoAUMxh7vc31mumOTfocjR48zB4kLMp8vvLEF
         8lRLJgoHkcm/HjfugdydajGCbMmyt2dnSFaUd0PPVDHih6JtH6VIwnVL2R0i6iQkVPKI
         rvFGyzWvQh9ZwO0b2q4o3O3YzOppKkuyIVIh9G8f1BthuarBFYn1d2l5/wmIJ953UMI4
         Ju4TjSN8UYQhDRaQ3g5n48G+vdjx+x/YpTRhgqd6VuvzgR2YeX7Icj9Al1ZOqVy4+P+E
         6vUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cR9cZCL/gkGw9AWPWUbBA52BHOxnTMVlBaN1kJygVbU=;
        b=gv8aYxVq/78nLEgVp6YPpKkEyE6XUl51qINOL7mCcqq+/awiK2NLG2j+g8p4ds99KM
         ZEzW8ZaJ8FDlcVwq21orvwZB4dCJsvEn5CVSoYt7vBKlU3UPthMgQh0wZfT48xh1co29
         gw1IeeTikDSVenYOnN5mNvp4MOLpIsUPHD25fZtjhkEb+NGfa340MvzmpQ6t0slv2+wb
         8mK2hvZHWVAqzaBad0qjrQsjWgK7dLqMljQQn3n3b/QH7+lbnwnSc1pdALnUoNDV7Faz
         9CAJ1h0JHFshQn2Eqp4Ig3OHu1NYObfjOwMsk9EIqyHPprzfXIGWL7rAhGRX7FDWocC0
         hh9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a17si11085826ejt.123.2019.07.26.01.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:44:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 40DBAAD5E;
	Fri, 26 Jul 2019 08:44:09 +0000 (UTC)
Date: Fri, 26 Jul 2019 10:44:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190726084408.GK6142@dhcp22.suse.cz>
References: <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
 <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
 <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
 <20190726075729.GG6142@dhcp22.suse.cz>
 <fd9e8495-1a93-ac47-442f-081d392ed09b@redhat.com>
 <20190726083117.GJ6142@dhcp22.suse.cz>
 <38d76051-504e-c81a-293a-0b0839e829d3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <38d76051-504e-c81a-293a-0b0839e829d3@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-07-19 10:36:42, David Hildenbrand wrote:
> On 26.07.19 10:31, Michal Hocko wrote:
[...]
> > Anyway, my dislike of the device_hotplug_lock persists. I would really
> > love to see it go rather than grow even more to the hotplug code. We
> > should be really striving for mem hotplug internal and ideally range
> > defined locking longterm. 
> 
> Yes, and that is a different story, because it will require major
> changes to all add_memory() users. (esp, due to the documented race
> conditions). Having that said, memory hotplug locking is not ideal yet.

I am really happy to hear that we are on the same page here. Do we have
any document (I am sorry but I am lacking behind recent development in
this area) that describes roadblocks to remove device_hotplug_lock?
-- 
Michal Hocko
SUSE Labs

