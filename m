Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A044DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C5D42146E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:11:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="OexzxhmP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C5D42146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E64068E0003; Wed, 13 Feb 2019 18:11:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3B2C8E0002; Wed, 13 Feb 2019 18:11:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D29338E0003; Wed, 13 Feb 2019 18:11:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 910D18E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:11:12 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w20so2803141ply.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:11:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+hxE9i2LXNTz12oXWns34FZR2YhTG4F31i4IBVFK/io=;
        b=XCIKXJKLIM+xLu6vy7OCYPq71BkKs4tFF6Vn+PZmTC4phNe3bcJSqvsVy6jBwNu9x4
         zxglgC0hEA98RFgVGHDpKZ8NA2XodiRFzghtF7kRv7axyjIIJA8L1bF0XOf+saG9LCrg
         DD6iaRD3l71t1zcbc2P7JFN0tSF5ncal6KnjjX0s+XIwEtxRZJn0aZk9L8FcXOkn0b35
         nI6+UgktEPwph4+KE2mgLzmMSanKAkNUsrbcFM+h7TNy0QI5pI1+M8ixb8q1hkngPgNY
         tZnmF1y1seFH+Vgv0PrIwjwQshQ0TJXd5LaW1WODbPNXjbvSCMG7zvn2jzfPvlbH8Dj0
         taJQ==
X-Gm-Message-State: AHQUAuYHQ+d7hsGNo0SVoqTcuMGi0E+KoWHEBLi3IwEnPC17Jx/UC4HT
	PveJZKhobQ42oH4ePHHxkOEitwpE6nvAIn8gSvslBmRUpEG/JJQRFIM4AZ6ztQNNIDA0rMcnLed
	JZKwd7RdSn4j2xc9oImRXVXnVoZrf6blpOuxJ0KW2w6FLTS0VKy8IWJUAFZyIkiSpjfyPMjdENN
	JFV9FgFIF2dbSMT/N+iJfvIC5tHKbp7e47Rz9+dnFxCo2Gf7m0OmJLM/7fa07D0grysMU/5fvjF
	Xf3Wh5/LlYgsLge/swC4lxmOHjb+ZOX9Zv5eWeLy/Tnpc/Z24gSjSqiRtV+v/PdTjdQA+z2Jzm+
	+vDuCuLy1eNYPU/TV01/ps9Ks7Hc6WbIE13HHRGbKN0TAMGLGsy+MUtVhvZ89WzjrW4uoxw0DS2
	7
X-Received: by 2002:a17:902:2b8a:: with SMTP id l10mr697432plb.70.1550099472255;
        Wed, 13 Feb 2019 15:11:12 -0800 (PST)
X-Received: by 2002:a17:902:2b8a:: with SMTP id l10mr697382plb.70.1550099471647;
        Wed, 13 Feb 2019 15:11:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099471; cv=none;
        d=google.com; s=arc-20160816;
        b=Pta+df5pTmfmey8MQoJxBtftmz5R7OIkvb3EgtlR/XI4e80+K1gTBO41DdhjhuakV/
         rzeSv197Gmo1ngDSas82d27V0IiHIzJQvoKb3klF6NkSBR1GU1ehprr0SRE6qMX7ibgC
         i/vv8lJC4TCU5vcjD9t32kGJ/rl1HMhLuMn2RKjZ86Ba1HF3HuYfPRjK/xs9gZnRjkbn
         mkUVQBXS1hty+Z9srBV0AhgDbzww6LcgSXP44rPKex+hGm+AgBwvu6RUjEElweAKwlDc
         pmzxoHle2QFfteEyDM0HQhygJOUrWesSYbbzqhFHyrE+sYjQnX3sHt3pth+nSWXFOlBa
         IVcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+hxE9i2LXNTz12oXWns34FZR2YhTG4F31i4IBVFK/io=;
        b=LV1U4aajR3gYYRDUKv5kSJVowchQS5r0URsPWf1URSqPPJVn0I4PN2dZWws6DWhs23
         ZjyEi0Y2tkO8TDuTt4D2wVp28s6qI0Qkkwhn07CPtSYiNi9/LE+2CvxtTUj7UyxDNOk8
         FXmBiWXTt+H0jyHES0svT5kUuAbTNVLDCMS77TRrOx/T04iGqXJGXiTxAEP+QmYtmzFu
         yfpathS1cefiweQQglxe3A1pspenAl11a54+wBgVByTn3KokQ8u5dJSEqGqJ0hj0O7uD
         OWodh+lh5Lv5jMx9/ki/3vvoNs5JwXnLiQZ1PhzaSM1wcLJDKgm4KRwXbuqaz0rbbBz3
         td1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=OexzxhmP;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x11sor958235plv.55.2019.02.13.15.11.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 15:11:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=OexzxhmP;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+hxE9i2LXNTz12oXWns34FZR2YhTG4F31i4IBVFK/io=;
        b=OexzxhmPQPLB/5GuvN/TPNOSfFrVu8unoCJCiEobEFwb5nW131NFCPSWYfd/vVLTI8
         SHNqFEBZ4+taALRUNix76ejXHUUaDEd/+CY/Bj28I0B1kwcpBv6Js1Sbrrk3W4v4aWf1
         R/tYyZTipLpVfRjZotU7TujdLp+2++02/FlRJ/m+hveK25TvAkLu2d0ah9VCsfpBhuRN
         Fha7OODN6pyB7AFLepqTIIXcla9mMBZ15VLpjZDQSNkG9bxg8xCr7Yk734OaTLCKsayB
         fonuQWEEU7MzDwbOFSYSezeNszCCHXNQAL2h17IxOexjBJh5LtE91dswAolCvY7wll9A
         dWnA==
X-Google-Smtp-Source: AHgI3IaVZ6CJpbhcHZy5MaVvStomkjS8sfJXLrjGqxqqWXEAYYMbSCyOTxp692oWbQJzEybUaW9Z4A==
X-Received: by 2002:a17:902:bc3:: with SMTP id 61mr705255plr.15.1550099471348;
        Wed, 13 Feb 2019 15:11:11 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id p64sm554108pfi.56.2019.02.13.15.11.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 15:11:10 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gu3gM-0001M9-5y; Wed, 13 Feb 2019 16:11:10 -0700
Date: Wed, 13 Feb 2019 16:11:10 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: ira.weiny@intel.com
Cc: linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, linux-mm@kvack.org,
	ceph-devel@vger.kernel.org, rds-devel@oss.oracle.com,
	John Hubbard <jhubbard@nvidia.com>,
	David Hildenbrand <david@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Joerg Roedel <joro@8bytes.org>, Wu Hao <hao.wu@intel.com>,
	Alan Tull <atull@kernel.org>, Moritz Fischer <mdf@kernel.org>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	Kai =?utf-8?B?TcOka2lzYXJh?= <Kai.Makisara@kolumbus.fi>,
	"James E.J. Bottomley" <jejb@linux.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Rob Springer <rspringer@google.com>,
	Todd Poynor <toddpoynor@google.com>,
	Ben Chan <benchan@chromium.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Martin Brandenburg <martin@omnibond.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH V2 3/7] mm/gup: Change GUP fast to use flags rather than
 a write 'bool'
Message-ID: <20190213231110.GD24692@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190213230455.5605-1-ira.weiny@intel.com>
 <20190213230455.5605-4-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213230455.5605-4-ira.weiny@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 03:04:51PM -0800, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> To facilitate additional options to get_user_pages_fast() change the
> singular write parameter to be gup_flags.

So now we have:

long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
		    struct page **pages, unsigned int gup_flags);

and 

int get_user_pages_fast(unsigned long start, int nr_pages,
			unsigned int gup_flags, struct page **pages)

Does this make any sense? At least the arguments should be in the same
order, I think.

Also this comment:
/*
 * get_user_pages_unlocked() is suitable to replace the form:
 *
 *      down_read(&mm->mmap_sem);
 *      get_user_pages(tsk, mm, ..., pages, NULL);
 *      up_read(&mm->mmap_sem);
 *
 *  with:
 *
 *      get_user_pages_unlocked(tsk, mm, ..., pages);
 *
 * It is functionally equivalent to get_user_pages_fast so
 * get_user_pages_fast should be used instead if specific gup_flags
 * (e.g. FOLL_FORCE) are not required.
 */

Needs some attention as the recommendation is now nonsense.

Honestly a proper explanation of why two functions exist would be
great at this point :)

Jason

