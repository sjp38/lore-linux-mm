Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27092C31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:49:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECF912133F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:49:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECF912133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CEB26B0003; Mon, 17 Jun 2019 11:49:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95A0F8E0002; Mon, 17 Jun 2019 11:49:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F9498E0001; Mon, 17 Jun 2019 11:49:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 467036B0003
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:49:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so16981439edt.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:49:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ag+6C2AviwT17JDwBj+yi5yKtCvwiUp9Yt5+9aMQQLo=;
        b=uimHF+VYm89WlCcnKjAdQpw3BLQ4pv5fED/QhXYtVjc1euRwyRDL9SgO5QDIiyYD2T
         Iqa2MrAl3G79RdzNGW8mzbIj79QKxCXkwzn/UsS2vFsFRRKtcFdFEkSxSl8gxYxmJOLy
         7ZH35gnuvRQ73//bC5bzI69dvGQpwvLb2oIp2CA9qNiCnQBJxNiZAix2uBVCNDpJHE49
         USgqqb4VPjsFdo4UXM1CZLcL1hokbpa0H8Kxf3DSr0kq8XlEbfIxGBwQCLOxHEJFMs10
         rL+r09JzxSbjYaID4aCQDdYn326qiLqhLmGaas3rt/oA+A48zB9AkVc0zogNU4iCXmWb
         YfwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVykGWK9OGN/KK7RlKgnUTOiJ0ecnuczO/mGPLeKoiZd5OV6LHQ
	Y5BXrwqfxke9f2/RjszsG9Xw9kISwN4VRlPH1CPhDn98KERxB4EtSWKEQTJYHEkrg7HXC1+Z5AQ
	si/kATCgx9fOxjRRz4e2F+1LAaLuLj1G8V41WLWPPW65zVni0GpOT9z8LDx1ygyClPw==
X-Received: by 2002:a17:906:2acf:: with SMTP id m15mr95999098eje.31.1560786569848;
        Mon, 17 Jun 2019 08:49:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiSiasSKOvQ9+I4KGLWrjBKagSc130D4iybGYtcOQHjOT+s4NqTXrlXcHzP3lQNbyNCnF9
X-Received: by 2002:a17:906:2acf:: with SMTP id m15mr95999040eje.31.1560786568750;
        Mon, 17 Jun 2019 08:49:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560786568; cv=none;
        d=google.com; s=arc-20160816;
        b=MwrGD/DnI5fzGsEuKZSsrG0XbOWfudvF6KitWlAZSpCOA+SXePn/GwBCmqsizkOR+X
         4SLY1cB2JW1Qq/f6eHnTR0NXR8NzmBbklf9WzQMkgpRgGNKE2ZqJC1gmg1lQuIpOrGMp
         FpaF3jQMzUAgK/eLSrOscz0SZdMEULe1CIQAua7zrWNNBCrBLovFGwQTDugMMJNauJHz
         ALmJBM3/+RSapqrjY9j214KmuKC1cqfSeZ+q2NlFRsdxDII3KaLsVyk52xxGhAErvdJu
         I9pUMt3o0kB36mvzYOtpVvurMQFghii0A3b3ysUpV5ipPxVhGmSoaJ320vrDiBao+HKm
         IjXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ag+6C2AviwT17JDwBj+yi5yKtCvwiUp9Yt5+9aMQQLo=;
        b=iN5ml5W2+Hcsc0oYDiu1aSivp9olhLLJWsYB6Y3jb01oXrFYqJWtoLPg3hyEOi8LZZ
         Xn4OJzq4yelllsV1hEEb6Qp1RGGdk/XucLogFzUj9dwrca9Pa7B0ypzcCgRvBbCtvoyg
         Dlq9+wPTrNryuX3CSJEp6YNak8xeq7LqY7I7zaTnCPyRSA78FTMccA7HuWQZJEXMUwG9
         zjlYhI8ODGFPhjFrjU/0GPxcWvDnvfQAdp+/c/bUqQH22PUb3p6SlLQLqfhQ+krcO142
         AqxXWL61r572lcM/wLHl04aGwBVgjm794pzR70XA1zqmDbP8yrfSmBBjbWYYjDkb5oHy
         EhXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y38si7455455edd.0.2019.06.17.08.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:49:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ADE99ADEC;
	Mon, 17 Jun 2019 15:49:27 +0000 (UTC)
Date: Mon, 17 Jun 2019 17:49:23 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: 'Michal Hocko' <mhocko@kernel.org>,
	'Alastair D'Silva' <alastair@au1.ibm.com>,
	'Arun KS' <arunks@codeaurora.org>,
	'Mukesh Ojha' <mojha@codeaurora.org>,
	'Logan Gunthorpe' <logang@deltatee.com>,
	'Wei Yang' <richard.weiyang@gmail.com>,
	'Peter Zijlstra' <peterz@infradead.org>,
	'Ingo Molnar' <mingo@kernel.org>, linux-mm@kvack.org,
	'Qian Cai' <cai@lca.pw>, 'Thomas Gleixner' <tglx@linutronix.de>,
	'Andrew Morton' <akpm@linux-foundation.org>,
	'Mike Rapoport' <rppt@linux.vnet.ibm.com>,
	'Baoquan He' <bhe@redhat.com>,
	'David Hildenbrand' <david@redhat.com>,
	'Josh Poimboeuf' <jpoimboe@redhat.com>,
	'Pavel Tatashin' <pasha.tatashin@soleen.com>,
	'Juergen Gross' <jgross@suse.com>,
	'Oscar Salvador' <osalvador@suse.com>,
	'Jiri Kosina' <jkosina@suse.cz>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large
 amounts of memory
Message-ID: <20190617154923.GB2407@linux>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-5-alastair@au1.ibm.com>
 <20190617074715.GE30420@dhcp22.suse.cz>
 <068b01d524e2$4a5f5c30$df1e1490$@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <068b01d524e2$4a5f5c30$df1e1490$@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 05:57:16PM +1000, Alastair D'Silva wrote:
> I was getting stalls when removing ~1TB of memory.

Would you mind sharing one of those stalls-splats?
I am bit spectic here because as I Michal pointed out, we do cond_resched
once per section removed.

-- 
Oscar Salvador
SUSE L3

