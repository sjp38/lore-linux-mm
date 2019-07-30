Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96EB5C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:26:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42F242067D
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:26:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="g49i2KTA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42F242067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E40058E0003; Tue, 30 Jul 2019 16:26:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E16298E0001; Tue, 30 Jul 2019 16:26:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D05B08E0003; Tue, 30 Jul 2019 16:26:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9932A8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:26:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so35987776plo.10
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:26:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yqx4UYcjP6KlxvhuVNhLTr763MCblrOaB2wNSqF59LA=;
        b=ALNO2Z4sPSDUW0iup/nAuVM+TBwDXyZz1gAe1uYxi+9yBIBYUT90QSm1J6HoSBL5AG
         6Mq7idykR/Cd6Qpec6wzx2Fkuc4G2tmRQDZaZsO6Atok6t3RREXkQO9z18g48RFLvIpX
         9FigFqTxbsfWM3p4cJOGQqKjRI5o/ia0DVr3nd6d5xr4btThe5xz5XEjd2VHpgehPjoD
         aAyd8mD9GSsjjwHOWxfXrOQtoNP8B2Bv4g3pqBZEHwno4+8Mz2b81n2xl8/7SETl3Tay
         0YnseBm5T76IG7XEZa9cKg68/0AESMLQ/ZF93zzgUxO2EnYYi537qleCIxpvNuPgRUBG
         5tSg==
X-Gm-Message-State: APjAAAWpO9BKL5jZdYQNhxe4lrqoAOgOn6MFPemAI8x8H1TzvqjrUZDJ
	wdai9pu85YFBLQfIgPDt3OhRMKK/lfU/Nx7W5tnhhVslgOOcUBxS1Dfy7QZvjLs/2JkZ8k2e0H3
	nnopz14Xq+gneVkiQmbCbQ1CFajzrmSkW+Dd6ti/KwXwjGsN+5VC+k1hacsvJm/F5vQ==
X-Received: by 2002:a63:6888:: with SMTP id d130mr37745642pgc.197.1564518401132;
        Tue, 30 Jul 2019 13:26:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiMrOv9yP7XJ7D5c1TGGcU5yvRdJ41n0uUxv1h3ESDXhh729PgOgLmCNCIZDIw6E2xBpr4
X-Received: by 2002:a63:6888:: with SMTP id d130mr37745612pgc.197.1564518400451;
        Tue, 30 Jul 2019 13:26:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564518400; cv=none;
        d=google.com; s=arc-20160816;
        b=PoC6IIPdmhGg4wFVy3FCkMGhF0EjhEDy9hAjoxeMUIyvXYmFBke+4CP//lFrvBONy7
         ao2n/mlheJcL1m8OaL/iksVtleMsq7dl2M+p7aL5HR9/920ZmATHal+j+Lyg8MsNr/LX
         XE7SLr7SeUVYKwOWD19aMPZPrY+wevPVZdpxzsV8KpS2TRIKcmzlJzmVH0zWBZ/eR8NW
         M0gAtKFf+RTefOc/KczoZVgwhmbIlhgcjdKMqqtLtnlRoqK6am+G99L5Gv7O8MQrr+XO
         KaD3obvkyZChUZWQJzaMov0zQoae3iNvDcdD8P/pKOuhHVnNeaIcjPxjHLyL0Z1A8uki
         KPDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yqx4UYcjP6KlxvhuVNhLTr763MCblrOaB2wNSqF59LA=;
        b=WphpK+w9PY3FldGTS+SmEtTEVS6qLSr+uhC1ATa65LotsZ+d7GXS+Zt4tUTA0KkNfY
         hx60Ag8/3dg/7qWxELu0d5LUH9ArYdvEr38jswWXWoZPA3e1tM/qdkk09x0zJLcdvZ/2
         zAlnlU8nQ+cllK7piXcooh2VWYMzbFZu0PoUAiUa/74mRZgrlRzxP9T6iOIAHI9A2Brb
         oeYtcb4rjVedlFR5XyhzhtM43i9a+NAGlrICvVo50ctzQ1YVZKe6Mn0bM0NMRdOersBM
         HrgAVYeK3cFywqPpWAFOL+459me6ch0aOFUlLmKYbbX+GzagVFNQgTo44Bl1Cu1Ing0g
         chWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=g49i2KTA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w9si26742607pjv.67.2019.07.30.13.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 13:26:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=g49i2KTA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=yqx4UYcjP6KlxvhuVNhLTr763MCblrOaB2wNSqF59LA=; b=g49i2KTA4OHx/jCep6CF+UE9r
	FbNyMT6OL8WRSVCeidN56yT/Vcnr+AIESkseue6yVojwTnY1UR6PAJOxrBy4sr3HDTIRi+l9RDcGZ
	Zxkd90nko/NbaQWkWDn1KJTe1YrvC5tPRSqTEL2yj0XQOjPGZK7BVOdEj87Vmp+2lX6MvhTbp2gET
	McL2AVgDCkepYA4b+iNLOwOlBdSNVKtbfMVECMhhIBptp6Wfm6X2YfqHJMbVmPSdwK1M4z4s0NiKW
	tYKLicwNq6x63QmsrSVzSQjOyV9rbb9TTgkWuZ/RRylZgKeHw6tNJ+ovZ6o/IRhIPQeicMutGLcmb
	JEcyzV84w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hsYhc-0007hT-DO; Tue, 30 Jul 2019 20:26:32 +0000
Date: Tue, 30 Jul 2019 13:26:32 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Song Liu <songliubraving@fb.com>
Cc: William Kucharski <william.kucharski@oracle.com>,
	"ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
	"linux-afs@lists.infradead.org" <linux-afs@lists.infradead.org>,
	"linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Networking <netdev@vger.kernel.org>, Chris Mason <clm@fb.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Sterba <dsterba@suse.com>, Josef Bacik <josef@toxicpanda.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>, Dave Airlie <airlied@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Keith Busch <keith.busch@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Steve Capper <steve.capper@arm.com>,
	Dave Chinner <dchinner@redhat.com>,
	Sean Christopherson <sean.j.christopherson@intel.com>,
	Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Amir Goldstein <amir73il@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Michal Hocko <mhocko@suse.com>, Jann Horn <jannh@google.com>,
	David Howells <dhowells@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	Jan Kara <jack@suse.cz>, Andrey Konovalov <andreyknvl@google.com>,
	Arun KS <arunks@codeaurora.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Jeff Layton <jlayton@kernel.org>,
	Yangtao Li <tiny.windzz@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	David Rientjes <rientjes@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Yafang Shao <laoar.shao@gmail.com>,
	Huang Shijie <sjhuang@iluvatar.ai>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Sage Weil <sage@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Gao Xiang <hsiangkao@aol.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Ross Zwisler <zwisler@google.com>,
	kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 1/2] mm: Allow the page cache to allocate large pages
Message-ID: <20190730202632.GC4700@bombadil.infradead.org>
References: <20190729210933.18674-1-william.kucharski@oracle.com>
 <20190729210933.18674-2-william.kucharski@oracle.com>
 <443BA74D-9A8E-479B-9E63-4ACD6D6C0AF9@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <443BA74D-9A8E-479B-9E63-4ACD6D6C0AF9@fb.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 10:03:40PM +0000, Song Liu wrote:
> > +/* If you add more flags, increment FGP_ORDER_SHIFT */
> > +#define	FGP_ORDER_SHIFT		7
> > +#define	FGP_PMD			((PMD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
> > +#define	FGP_PUD			((PUD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
> > +#define	fgp_get_order(fgp)	((fgp) >> FGP_ORDER_SHIFT)
> 
> This looks like we want support order up to 25 (32 - 7). I guess we don't 
> need that many. How about we specify the highest order to support here? 

We can support all the way up to order 64 with just 6 bits, leaving 32 -
6 - 7 = 19 bits free.  We haven't been adding FGP flags very quickly,
so I doubt we'll need anything larger.

> Also, fgp_flags is signed int, so we need to make sure fgp_flags is not
> negative. 

If we ever get there, I expect people to convert the parameter from signed
int to unsigned long.

