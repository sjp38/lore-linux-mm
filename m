Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10CA1C606A1
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 09:21:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0DA720645
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 09:21:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0DA720645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 166F68E000E; Mon,  8 Jul 2019 05:21:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 135458E0002; Mon,  8 Jul 2019 05:21:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF7858E000E; Mon,  8 Jul 2019 05:21:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9184D8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 05:21:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l14so11069313edw.20
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 02:21:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WvW/NSggBqzmlABKQPk0ULjtxrQFcvNT8INnANETZsI=;
        b=rkIE6o79bSL5S0ZRjuYRwotGckP7LSB2HFmk+s6PQ3Abk1P5wVX0ILK3fRPPzjtoi6
         aON2CfdHrRU8m4MRb15/erPlzCd2a+c0rMgB1dEiIxykqnFVhSNFwFmmjpl4Af1Mpq4W
         X5mZ/W0kchHxH6z+C0rndOpBBJeu6lza1IsNR2EXnMXAKuVw3lD6Ehx9oVtK3Ra3q9Et
         ukQDi1AbsSUy2DWXaHgsJw6xNmpO+hMU93Vo9zQL6Zsa7WdoOxHb/NBN8ZmfTC0nHbl3
         Qt3BO5sBLgiOKxWOvrEpcKYI9PvSrcjiSk9hxM22cf9UhAvixaX6R18fEJ7F4p01jPy8
         9qlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAW7ytIbEdpMG7Oa0rdHkjOFGbMtEKdJZldKKwe4yQ//9lxU4MI2
	MvJTAj31KPT/tSkMtoNUS/j4IhpcXfPOfSMoM4ftC7/Wh1XaRc04jk8LbvGP2jm+uspweRnAJa7
	Ct+sveAvOdl9B8xeJC7yEi7KxGpRNNSFTV0wMCcUQnNY9JGZAGijQHbpdkOMCIOwfzg==
X-Received: by 2002:a17:906:154f:: with SMTP id c15mr10917811ejd.268.1562577661159;
        Mon, 08 Jul 2019 02:21:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBXhlBgTK+p1IA0gi8myLRvuiyCnwnkUBmea58z+ll8fWx3bLYr1GV9F65qAWwQSFEPJDC
X-Received: by 2002:a17:906:154f:: with SMTP id c15mr10917718ejd.268.1562577659956;
        Mon, 08 Jul 2019 02:20:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562577659; cv=none;
        d=google.com; s=arc-20160816;
        b=XqY7FBL2f79EzoGVgfIx+D50PkMTlUOEYpRbrAAOQkJT7R6UmplcFDEG1I7T+tRboC
         t+HUm8XDthe9jprJDUOy80bOzFE+n2W7FiQNXUYESzYvBfiVUrT7Jx+LXHA1eHCHTriT
         XQlQ9aS3/YdAnlu6rL//emDX+w/2F6RtZB75kdkbYDKTn4shiE3yIIhBVV/UOWKit9de
         p4YCKZvhBUriZKVBKyI6luwQ/i6qqmNKAWYU3geTbA0kmdQC+o8bKO8DEeeyimTM7G7+
         xxJuLqtk+q90gtWgVppoz3HbTuI83mjPiv7tn5c5CcD5PZl4/+pEH+uIthjPt87Lf1Wg
         RQ/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WvW/NSggBqzmlABKQPk0ULjtxrQFcvNT8INnANETZsI=;
        b=eIJh1BvLUU4heyo9Jr1QFwuyCQYdNCXrEGfmDR2emu+dbz0WtGhc04I/UaKQZIFjxd
         hxaaHYUz8X2HZhBEAKWZrSreSLRGv19yZuthYJnkk+kaKLgX1oBmEgk42RQQfbYGJe5f
         SqEpoS4iMQtivUpwpnOC6t6cO5ImcR66s0sQnvkxNF9huDYH5r2PMWjT6+mN2v5VSJ7E
         W+Vo8gnpWQNsq41uRDR8yWCcMBUIWpBEGkj3VXv5W1pJoQZWLQtk5OfDBzRNiRllW21a
         KYNJtSMKNhXW0A1AHWzJOyUWS93fEBhBkrfJP9WTFYlO1WW5ytf+ABRtj7ixknP4W/J5
         VjYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2si13607618edn.283.2019.07.08.02.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 02:20:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B150DAE82;
	Mon,  8 Jul 2019 09:20:57 +0000 (UTC)
Date: Mon, 8 Jul 2019 11:20:45 +0200
From: Michal Hocko <mhocko@suse.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, anshuman.khandual@arm.com, mst@redhat.com,
	linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: redefine the MAP_SHARED_VALIDATE to other value
Message-ID: <20190708092045.GA20617@dhcp22.suse.cz>
References: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Dan]

On Mon 08-07-19 16:05:41, zhong jiang wrote:
> As the mman manual says, mmap should return fails when we assign
> the flags to MAP_SHARED | MAP_PRIVATE.
> 
> But In fact, We run the code successfully and unexpected.

What is the code that you are running and what is the code version.

> It is because MAP_SHARED_VALIDATE is introduced and equal to
> MAP_SHARED | MAP_PRIVATE.

This was a deliberate decision IIRC. Have a look at 1c9725974074 ("mm:
introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap
flags").

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  include/uapi/linux/mman.h                          | 2 +-
>  tools/include/uapi/asm-generic/mman-common-tools.h | 2 +-
>  tools/include/uapi/linux/mman.h                    | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
> index fc1a64c..1d3098e 100644
> --- a/include/uapi/linux/mman.h
> +++ b/include/uapi/linux/mman.h
> @@ -14,7 +14,7 @@
>  
>  #define MAP_SHARED	0x01		/* Share changes */
>  #define MAP_PRIVATE	0x02		/* Changes are private */
> -#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
> +#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
>  
>  /*
>   * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> diff --git a/tools/include/uapi/asm-generic/mman-common-tools.h b/tools/include/uapi/asm-generic/mman-common-tools.h
> index af7d0d3..4fc44d2 100644
> --- a/tools/include/uapi/asm-generic/mman-common-tools.h
> +++ b/tools/include/uapi/asm-generic/mman-common-tools.h
> @@ -18,6 +18,6 @@
>  #ifndef MAP_SHARED
>  #define MAP_SHARED	0x01		/* Share changes */
>  #define MAP_PRIVATE	0x02		/* Changes are private */
> -#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
> +#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
>  #endif
>  #endif // __ASM_GENERIC_MMAN_COMMON_TOOLS_ONLY_H
> diff --git a/tools/include/uapi/linux/mman.h b/tools/include/uapi/linux/mman.h
> index fc1a64c..1d3098e 100644
> --- a/tools/include/uapi/linux/mman.h
> +++ b/tools/include/uapi/linux/mman.h
> @@ -14,7 +14,7 @@
>  
>  #define MAP_SHARED	0x01		/* Share changes */
>  #define MAP_PRIVATE	0x02		/* Changes are private */
> -#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
> +#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
>  
>  /*
>   * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
> -- 
> 1.7.12.4

-- 
Michal Hocko
SUSE Labs

