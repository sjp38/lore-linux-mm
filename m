Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BB2AC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:46:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ED08208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:46:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ED08208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3D1E8E0005; Wed, 26 Jun 2019 01:46:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EC118E0002; Wed, 26 Jun 2019 01:46:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DAEE8E0005; Wed, 26 Jun 2019 01:46:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7C18E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:46:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s5so1488038eda.10
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:46:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ggyO5OjqYaJ2cndgae2J9x6mnWJLd9zq3cWr+kB+pXc=;
        b=F64wPhkWLNDasj3LMQkhdaGNN4VPceRCoRkSLXKqtAVdxOJMfP+dnFlLmO5T+lHzko
         qaa3qJrYtxnEKU3Y9xEDlClp2c5qSs8ejnzP86szF4p/sfXuowFrktwwrt6AWuW6dv6w
         qhEaVmNuiAvryw7IUUMQqcqbFjZ8iS+IcpImhGYg7WnzBAGBlHBvc0mg6ENJ/Yci9Xi1
         FLuO4HisrLpWY/tK06W+QvOulOlXLIYILVi40FxNHsl/f5mj2R756OlZ3zXQJ9O7hZCD
         irKEGJ9RIRddNW1S+zmMl3rRafOCxHknL5t4Yo6l4xwSr6kxn6Mtn+N3qcc3qkFbtS6M
         Dp1w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXPtJMCMtGZG8SUI6tB5vf2W2zAPvZhmbcKxcOENJF5hKlMe+xI
	TlEQ2L0laf0q/QcjwKuHZlqYTQB6C4oQI7YYAJElLX5DDYMnZr0zA570EbhiboHyPJBGVVC66NY
	R/9UJ2lYuod20GdTW+tXiJYF0nyJhJdBDoRdg+DXQcY7qgti392bKPJS3/iKYQDw=
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr2245622ejc.91.1561528007815;
        Tue, 25 Jun 2019 22:46:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh3PlYbEnmKh6xU3BVj3hHpoaUkZJMizKKGrpjFJvzdIPXQ0Wdpo735wn8jfOeeNmx470f
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr2245581ejc.91.1561528007168;
        Tue, 25 Jun 2019 22:46:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561528007; cv=none;
        d=google.com; s=arc-20160816;
        b=qo4cboD5irSqqn0zMW8o3fLkcRBW23LvGlqzCgnl2TpLxcngRfXzGTOkzlZgvT8lIc
         zrc5kLCAXjANXPyKHNH1eJbnKI7AOW+GPnqLOU5BXhLNbb9x0GSzM+9CQPeB5Zh2PnR/
         dqBeLD8UBcpfscNLKj85FUSy5320G2GoSM9jwniJH5Wyb+HlIoMPLdQ0AqKI472o+qMi
         QhGRCn3YTAPt8PoqU6GawDW7VFB4s5BmGVSiWnn9Tcpb8huCBBK6rSAhyKUGiOTlqz+y
         paUPtyGXJlXn4kA5wtpsSe/BY3J5yHpddZOXx608rmUfy8p6r5vj6k2Bothz9gsf95zF
         LmMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ggyO5OjqYaJ2cndgae2J9x6mnWJLd9zq3cWr+kB+pXc=;
        b=dS7KfN+q5eC6RO0vVF4T9HXC35Y84LCC9Eu4gXk2YX0tGT5ZsjhL3/Huxyd2gse0Ov
         Np/kyetZ17rRo5VhkBLR59MW3QBX3wKhN8RXHunsWs0vcqpggNlNXcMpTaRX0CHR2IZz
         YX4cQFjpdjTGQ/JvA2MaovpGveRTnwji/Ov4r/R/OzqejMjFh9ybizn9Zwm///pPs5kU
         VtMll/gioM1wTH645v3UQYdBDVfJn41hqlrdb7+tNn9nmMYftIUXEIesWonYudBeplc1
         APUWXQkqh/LHGGShhjFqmL23WCEMv3dVwH70SpB1Tgci0TTw2vMPxbCnmiEYuojvFjqy
         gAQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i38si2546860ede.163.2019.06.25.22.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 22:46:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B5BEDAF03;
	Wed, 26 Jun 2019 05:46:46 +0000 (UTC)
Date: Wed, 26 Jun 2019 07:46:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
Message-ID: <20190626054645.GB17798@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz>
 <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
 <20190625072317.GC30350@lst.de>
 <20190625150053.GJ11400@dhcp22.suse.cz>
 <CAPcyv4j1e5dbBHnc+wmtsNUyFbMK_98WxHNwuD_Vxo4dX9Ce=Q@mail.gmail.com>
 <20190625190038.GK11400@dhcp22.suse.cz>
 <CAPcyv4hU13v7dSQpF0WTQTxQM3L3UsHMUhsFMVz7i4UGLoM89g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hU13v7dSQpF0WTQTxQM3L3UsHMUhsFMVz7i4UGLoM89g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 25-06-19 12:52:18, Dan Williams wrote:
[...]
> > Documentation/process/stable-api-nonsense.rst
> 
> That document has failed to preclude symbol export fights in the past
> and there is a reasonable argument to try not to retract functionality
> that had been previously exported regardless of that document.

Can you point me to any specific example where this would be the case
for the core kernel symbols please?
-- 
Michal Hocko
SUSE Labs

