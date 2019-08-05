Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CF98C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF6EF2086D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:15:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF6EF2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68A526B0005; Mon,  5 Aug 2019 00:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66AB16B0006; Mon,  5 Aug 2019 00:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52A0F6B0007; Mon,  5 Aug 2019 00:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B8A6B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 00:15:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so50742700eda.9
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 21:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VdwyLw+veBOkKGtRWPBMkRi60eHpetnrrlf9Jcpzuvo=;
        b=WwJjouw2gP1arL5IZ50SfkmaxbmNNaHm5RQ3Dp3huYgzT/T7N6rrUiJ0PqvL8FBQt0
         luP6NUK03dBdsF9cvScsyryb3a3oAXtYv37XOOONnWPsbKfHJLQMfYYwYxpPYYCqK1Ap
         PcvkYQAMMJ84s2N2Y8XJArp1GyraJHu/7S5e3OwjLWiWEcDaI/1q5A3eYWjCrH4is2ZV
         rQEpxPVw/KCCTZGcmwg+e07r9xqkhKTJD1JLACsh0JOAhXckBRDSRHTRrHXvAKN4LiVp
         94cYJoiQVyULjafXgc3UZKpSJKj9l0JRzQQuEwvvaAlJr4MrLXne8UOnUgaEH0Kzn25X
         6Fng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAVVP6H6aZaq3Y1QyJcsam/43DktIlrw3GFSYq2U5/SpTSXB8sbt
	iNX5Kr6fDM0zBnkzYlj5dy06FVDefxL8fVLYASH74Pn+pXiirxg8pY38v6+0HK/FGOx56gcrotW
	PexMb4xBF3GlUOrHjzHUINjIM2QNePKGpCiTnU/NvacIxmIwlcUmHWtmd3uxxZXG51g==
X-Received: by 2002:a17:906:b7d8:: with SMTP id fy24mr118546524ejb.230.1564978531607;
        Sun, 04 Aug 2019 21:15:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOdLEWm90Oh32VDyEYxKRf6aZRD6CUvotjzPvLi5RQ3giuzFI4HUbX7uB89DkqvwxjKIZo
X-Received: by 2002:a17:906:b7d8:: with SMTP id fy24mr118546501ejb.230.1564978530939;
        Sun, 04 Aug 2019 21:15:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564978530; cv=none;
        d=google.com; s=arc-20160816;
        b=RuCsDQ2iv2abfkLvc0PJarlyV8g71eDX8DsYBkfH31+uw6AXLqpi9+YWHG1m73iWA5
         bSMN2bYciSjlJqcATwOv17e0UuUCmL+mQSM8FHpKb5c7JNueBBTnlEA5yzO3BAhMXw6+
         zRee113Va0Zh7+vVbztxxnjiCHHRLQnUJvkaqPflI7rTrvPir/sc/Vfk2S9c3eePkrT4
         OpUEE40SMKWh2iv+hIeJMI4W1lDxtlkLjhfhHC9W3FljDOhHQye72fc3t/0BJSzLfNiM
         cUOCu8JPk2L3wAsPIjsj81xIzlSUQ2RfilVeCGPewvaBVP7dc7JiuQQWH4LGLE0g7/u9
         BGFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VdwyLw+veBOkKGtRWPBMkRi60eHpetnrrlf9Jcpzuvo=;
        b=NDV2s6jekhpJEd4YFPbdJNBOyBh4pOo2JoRBgUeLVU2WUZuNWbGIvqppSRNdbEnWZ9
         rm8iaSmoE7BKu/zXowip6w0PkbLD/Xj0+HOt9/5sm7awJUtHjUDzqNfgs3XdgJpjTEiz
         3o4BHKknr5NH4OcBEirgIPhKYgzx7jlF+d1uJie1NISTlDolofFsh4AMP47q2r5jMnbc
         44VWKTgdBOKV4GPfW3ePHOqcnPD1q0KZiIY9skpcYWSUZgE6jqaPy/XOCAhZaSb3Dwd4
         1l6kkyV2lgFXAm3Q5ZBhewHVF7DMYMdsCiFKb/nDStuSfruXED3xpNVLREMLHV6qYCB3
         0O9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qh1si24687882ejb.11.2019.08.04.21.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 21:15:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56732ACC1;
	Mon,  5 Aug 2019 04:15:29 +0000 (UTC)
Subject: Re: [PATCH v2 20/34] xen: convert put_page() to put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: devel@driverdev.osuosl.org, Dave Chinner <david@fromorbit.com>,
 Christoph Hellwig <hch@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>, Ira Weiny <ira.weiny@intel.com>,
 x86@kernel.org, linux-mm@kvack.org, Dave Hansen
 <dave.hansen@linux.intel.com>, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
 linux-arm-kernel@lists.infradead.org, linux-rpi-kernel@lists.infradead.org,
 devel@lists.orangefs.org, xen-devel@lists.xenproject.org,
 John Hubbard <jhubbard@nvidia.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, rds-devel@oss.oracle.com,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, kvm@vger.kernel.org,
 linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
 sparclinux@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
 <20190804224915.28669-21-jhubbard@nvidia.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <82afb221-52a2-b399-46f5-0ee1f21c3417@suse.com>
Date: Mon, 5 Aug 2019 06:15:27 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190804224915.28669-21-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05.08.19 00:49, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> This also handles pages[i] == NULL cases, thanks to an approach
> that is actually written by Juergen Gross.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> 
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: xen-devel@lists.xenproject.org
> ---
> 
> Hi Juergen,
> 
> Say, this is *exactly* what you proposed in your gup.patch, so
> I've speculatively added your Signed-off-by above, but need your
> approval before that's final. Let me know please...

Yes, that's fine with me.


Juergen

