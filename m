Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1AD6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:35:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 939E72190A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:35:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 939E72190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 260D46B0007; Thu, 21 Mar 2019 06:35:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E89F6B0008; Thu, 21 Mar 2019 06:35:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08AEF6B000A; Thu, 21 Mar 2019 06:35:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB3E26B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:35:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x29so2031323edb.17
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 03:35:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fzOsMeHaWBsruDsnLAEQHTdUyCuvA4uT0hMcHvsGVYw=;
        b=nyQIpjtpxsBuKFl3gtvXZSQQHgNzZnlM0KYiXDKgFJ9/M4Vq8/JiRLsDe0lg1WoqXj
         9i42viBG67yzClWbp72h72w2nnMp4F6v5mv0UfIr6fNbDp3Utc5aYfihP6U+h4nnUNXG
         J25KV379xw48sUI7Sf1PNxbrWsEsAt05ecrDZZCnKd7YyjcxQl/11TL0L7DRr57aHAK1
         BqAeAKXzIGGztsStTuI7MJAW+O9SqnBQMjDHxJcu7Ltg7RPfi4YLgnkFWoI9lKRu51Ak
         8AkeQO/gTRczvNaJvTJyerXtPXEk1f/v9rG8QtfDXAV16b+rojHji+xZZfoywVgftBfx
         wzDA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVnhey0SKjOdB4RP8dMCO1esyT4oo/qI0L2NHc0qAEnI6Tm83Jw
	un13AliWHtWRY01c54gls38atc+b/W335dqFQOmvKDTovTAS4Opct3NClENY7iqW5rAzqi3nWNi
	YkblqAHfnSeXUf03Z8MPlHWXK+2pFA9teySKloNwoB9Evn12g4gnSpRLhs2xHBYY=
X-Received: by 2002:a17:906:289b:: with SMTP id o27mr1866753ejd.161.1553164524288;
        Thu, 21 Mar 2019 03:35:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHO0sPbUmiOkbas1uWFIu1Fmbfo0otGey+OA8owXH5VyJ4TugZ1p2i4GB2I8S6Mc+KKg73
X-Received: by 2002:a17:906:289b:: with SMTP id o27mr1866721ejd.161.1553164523541;
        Thu, 21 Mar 2019 03:35:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553164523; cv=none;
        d=google.com; s=arc-20160816;
        b=hhDMQ+fL3k17P5iqr8sg0zRMywk8BD7FyqWSDd0l/QYSays9qk0CFbNUXa70sYNNIZ
         TLoRITzJHd5ayajIxWwRR4Ixhc8kNZ+uKPGVP7ICHRVuDMNv3xyNsMoYNdGpMsEMlG0G
         wdz2oDI4Rsahfubv8aIfcsHhNn+7YfeSPLqLPiPLa8vS8L9KxcflZ+SsPEJoTWYVgcag
         9//ut1SC9iTq0mY/OgNvhjkmp3I0r7yCnjmYN2bnxfQtTopnY0y0W9ysQMl1Ss7Rt7Mg
         IUUhLHNvoKdaHho+//E3iU2vS3sgYC4oh5q3LRq3Oqy7sX8xrvywYgd9WJe0Jwpc5jNI
         ZyzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fzOsMeHaWBsruDsnLAEQHTdUyCuvA4uT0hMcHvsGVYw=;
        b=dlfU/dEAGgVhlu0vHMJNyz+/Ten/DD7SFB6gmAWSySN3s8cCIBXNMgKZLOlyNHVSEd
         BkqzbrRJhIkIlr7mUJsYCyX1X0lexEshqMgl99UeyYkfiATxuRnzZfMYrG7dXYmQM2It
         cXqiZxpQxgkdDZsDrtsJe+V1c5iqqZwSf4I8hgz7Cl2BHdek7u/+CZA8fwoHWtJJLwM7
         JusClMi8HAt99cRrxvDJ7P9r0gCnJPdo70p9ds7mfWcOR78HJMDNJjtrokZ64sXuv8Ng
         NubwqwQ6QWkN3CsIy2xcQphtmbMT40c0p1IAFKqJGkVFjfg9LtqFvClwhGtJMxD5oF0L
         a2ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m17si1559449ejb.31.2019.03.21.03.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 03:35:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8482ADFF;
	Thu, 21 Mar 2019 10:35:22 +0000 (UTC)
Date: Thu, 21 Mar 2019 11:35:21 +0100
From: Michal Hocko <mhocko@kernel.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Baoquan He <bhe@redhat.com>, Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190321103521.GO8696@dhcp22.suse.cz>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
 <20190320123658.GF13626@rapoport-lnx>
 <20190320125843.GY19508@bombadil.infradead.org>
 <20190321064029.GW18740@MiWiFi-R3L-srv>
 <20190321092138.GY18740@MiWiFi-R3L-srv>
 <3FFF0A5F-AD27-4F31-8ECF-3B72135CF560@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3FFF0A5F-AD27-4F31-8ECF-3B72135CF560@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-03-19 04:24:35, William Kucharski wrote:
> 
> 
> > On Mar 21, 2019, at 3:21 AM, Baoquan He <bhe@redhat.com> wrote:
> 
> It appears as is so often the case that the usage has far outpaced the
> documentation and -EEXIST may be the proper code to return.
> 
> The correct answer here may be to modify the documentation to note the
> additional semantic, though if the usage is solely within the kernel it
> may be sufficient to explain its use in the header comment for the
> routine (in this case sparse_add_one_section()).

Is this really worth? It is a well known problem that errno codes are
far from sufficient to describe error codes we need. Yet we are stuck
with them more or less. I really do not see any point changing this
particular path, nor spend a lot of time whether one inappropriate
code is any better than another one. The code works as intended AFAICS.

I would stick with all good rule of thumb. It works, do not touch it too
much.

I am sorry to be snarky but hasn't this generated way much more email
traffic than it really deserves? A simply and trivial clean up in the
beginning that was it, right?
-- 
Michal Hocko
SUSE Labs

