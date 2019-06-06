Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B5E7C28D19
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 05:29:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D12B520717
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 05:29:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D12B520717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69C236B0010; Thu,  6 Jun 2019 01:29:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64CB56B0266; Thu,  6 Jun 2019 01:29:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53B286B0269; Thu,  6 Jun 2019 01:29:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3D26B0010
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 01:29:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y22so1968860eds.14
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 22:29:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vMdPr89fQQtJkYwfZPFoj8Cdml2y0bBUTTu2jKv+xHU=;
        b=A6bpMpc0qrZLzA/ixdHE7hnoyZxxWRJe+rGAcobsBBjm0eKnw4Tvhn0fQ53/5z7Y/c
         KAo3+waYtELLFOSFs1Oy1ArVA9xw0HZ3SGrRNnqVZT6SHi17OJhUngGNZzOsLaRyGxdT
         fVKfRPKl6WFLhx/Tr1LaNkmYOuP/2DLQHD8akUh/zs3sH4bb6rKFJdqv0jWPqpJadND0
         TWzu7ZZFjUpxu34j3DNCuo2SPPm1Bsnga3UKQWNeN1AUs910J/4k42Y4CZtwynG2iOzi
         3shqU+MifrXeSMzU62kb2isCS6riSF6v5+1mBrCLxhXi4GusE8uG6KnEInwI/DVL6AHq
         w+oA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUST1LPWGrXtirsTAS6ILlJtj42LAc6ULhO/R3StvZDCLyVT2FQ
	PvIpqEjlUFcJt0oA6YQw9IQXZXPPQvkfLZGQI95kgu2eT6o4SKR9Y+8gDYrHJDNK4P/06DFprVi
	ljpWoa8WXiWsbaW6LsIcUo/mQ9ZKjZqi95jLXcLNcNRkzDElbNx8fMP78j8ELt9I=
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr38639490ejb.186.1559798976601;
        Wed, 05 Jun 2019 22:29:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcIxY3CUCzvyhIxNmwvSMAcnXuQy0/RvFZsDmIDifqANMmaKm07QUFjlh6A7yGQ8h25DA4
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr38639437ejb.186.1559798975705;
        Wed, 05 Jun 2019 22:29:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559798975; cv=none;
        d=google.com; s=arc-20160816;
        b=CkzRv2gzNoVnFqudOda3Qnwokxv9WJBcTxOfdtmVyQAP0EwhGPybmR0uvGbWk9I+bo
         7SDWpVWvL38zBSbJ+nrhKNUlhfvwLat1MUAIclPpc+dVZ0em4/AQYQryoIhZvsVFvRhh
         EM4jNl/fQ49IMwRTl15GW5yv/1D92sLCPoz12qCbds7RL2IOkCyBvcKmRvs43m0oZ6V7
         oBXm5rNLjxy/HMElowpXVH8bJysHAw7yVdPuDnSpd21GE7Aejx+QT9KiuMSnmNFKCnds
         FessaReHtO/wLXsceA/wuEYwKApHOHywvdt/yCZQXrigBNl4roui7iQdauyHbo6JeuFH
         hfhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vMdPr89fQQtJkYwfZPFoj8Cdml2y0bBUTTu2jKv+xHU=;
        b=CpJa+Qk2t+HlXZZbRSKkSWx1CXTtg4bsL03DxORIo5bv+GRE6WKBaLZyadmC4YE8qe
         X4gJXSHCIXKvDxs0rWoinfTrlJT5O/js5UuLUxn6cn8PHvvhocLh/0NmGLvUNAP77arb
         UKIWECQEU9HY7oH5Aoh4/RKjUm+jzpqhI8QXrTiCNZ+c5G0Bhgx7j2rr7zRJu+UmwTJw
         uNnTafdHkcYrZqVh7VCjOrVMvbWLdtifrcnWX5NcdfY0ATC9zJmKEjFJSQhvelh0K0Jk
         BdM1QjE5FKbgIC1k1rIBcjg51xzzBB54D2USv8YvAeoulJfaFnq4STPUNaDnEsMEDKqi
         OQ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h12si145532ede.48.2019.06.05.22.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 22:29:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D4851AE04;
	Thu,  6 Jun 2019 05:29:34 +0000 (UTC)
Date: Thu, 6 Jun 2019 07:29:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com,
	khalid.aziz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Remove VM_BUG_ON in __alloc_pages_node
Message-ID: <20190606052933.GA8575@dhcp22.suse.cz>
References: <20190605060229.GA9468@bharath12345-Inspiron-5559>
 <20190605070312.GB15685@dhcp22.suse.cz>
 <20190605130727.GA25529@bharath12345-Inspiron-5559>
 <20190605142246.GH15685@dhcp22.suse.cz>
 <20190605155501.GA5786@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605155501.GA5786@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 05-06-19 21:25:01, Bharath Vedartham wrote:
> IMO the reason why a lot of failures must not have occured in the past
> might be because the programs which use it use stuff like cpu_to_node or
> have checks for nid.
> If one day we do get a program which passes an invalid node id without
> VM_BUG_ON enabled, it might get weird.

It will blow up on a NULL NODE_DATA and it will be quite obvious what
that was so I wouldn't lose any sleep over that. I do not think we have
any directly user controlable way to provide a completely ad-hoc numa
node for an allocation.

-- 
Michal Hocko
SUSE Labs

