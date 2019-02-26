Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B03CDC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 03:27:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 473DE2147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 03:27:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VyTTc7Uq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 473DE2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F1A98E0003; Mon, 25 Feb 2019 22:27:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A0E38E0002; Mon, 25 Feb 2019 22:27:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7901A8E0003; Mon, 25 Feb 2019 22:27:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD368E0002
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:27:56 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g197so9412991pfb.15
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 19:27:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LwVmVyEBq/Y4O6foRX8QuspzDe+zpg/qVDA0EFY9KAY=;
        b=TwSBva3VJfcp8+kWWOXQDNC7VDDd0o3AIBTj+AuGoGs+Xy03nF+9RYRruj2XX/c2ow
         6sKpysLBml1EH6DxEX3GuZ5YQnQc57zj//uKsEwlVZFt4EtUkyZAh5CtnBOW0LnV+CFT
         +wwpSxvGcNjn3wO3YTAAx2zh2eRCOLzmW+XFHKzgE/H4xa+q4ucdrQS5iX6liKPjPS2F
         jljShpCHAbePUrj72H2IJN7msYAz/h6vOW4KT0foNYlrZ6+end7x4dW7bkI1EAmZAkej
         UOcChBL4Xm4VbKV2dQxquPFFqwtjYttPD85dNUz1hEX7Mf3N2oiZrQ4CNEwCQ1Dq4TZf
         OGAw==
X-Gm-Message-State: AHQUAubIOJ2ZuK7FdFW7LCZ0DbD7V4JLFs7qcs5ssl0ag8sxaVGgoao+
	/Wkfct/iR38EffZHCyP1ZnzGKqmOqOfX7IEwAYVB3mClc/y55ImOKVXZYl3pXEJBDCXvcBr35ZA
	x1Sedb3uBz4tRslcA0eHWvL1AGEn4B3+8r+RGn25vt3hhI6aijszy0QT9sd7xaYL38Q==
X-Received: by 2002:a17:902:33c2:: with SMTP id b60mr23798410plc.211.1551151675754;
        Mon, 25 Feb 2019 19:27:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY+2v/JYLBayPsWY7Y3WFcCkNvIB0Te5Lf4sPLKM4JdunZ9gH/+iwmBUhESUDjro7LNeeoL
X-Received: by 2002:a17:902:33c2:: with SMTP id b60mr23798351plc.211.1551151674792;
        Mon, 25 Feb 2019 19:27:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551151674; cv=none;
        d=google.com; s=arc-20160816;
        b=Tp3GdQnAYp+lTtF/KjXLr+2wDUmdY14vuFHdoZ1NRzZw867y7SsNP2xsawUfGniGbN
         JSVEfVkCLZcetbk4/01QNOJ02qd0WRNOSr1q16SWcK2qOw7q9Se+dTXKh/qh30wIah7N
         mO+11WgX1g+kEqdTJ2EOuIuDynXhD1aYVeqdnfwaXXQ90ygoyXos+5FRlNLgL819NwtJ
         YHnxQ1UuFE7kfRzt5M3SCeiqw7pZebHhMhVwvVaR7S7P8IfBQCcg2qVZiTrjxdOyfA3N
         h74nrccIt1Akxo7iRPx35531tX8KxJTzOlJTBJgBthynOblVvTKCgxAVZsgFc3ygoD/8
         Db6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LwVmVyEBq/Y4O6foRX8QuspzDe+zpg/qVDA0EFY9KAY=;
        b=WeVJTv5Ig3UHQS5zVaf1MifJV0oXkXdsRlOin7F0LiZTud8Z9XWdghDbrcC2kOCilZ
         Bla7WJF2hrRAO8oXnT8P290vvUtqbMlqJST+qMkReIS5mil0cOTUmUVjNZPaHKKF5RQC
         u7+MBuak7ewptCXqBlOyBE1lNaUa2zRYtLvGmWTngVd6IX0dqiKeYsCNXn94n1sRj7O7
         bilRKKTLf/6sXfecq+meN55XcCViNbWQn0JqJUqioKOeMZIEyFVgjs9u34YT+Jve/xtI
         8cKkKNxTAjVfTH6T22jAVMXiGLi+cVQ+efWOEzr2GJ4UNkdGrwSw1c15WHxDDg+odc71
         Wv1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VyTTc7Uq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e2si11695768pgm.568.2019.02.25.19.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 19:27:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VyTTc7Uq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LwVmVyEBq/Y4O6foRX8QuspzDe+zpg/qVDA0EFY9KAY=; b=VyTTc7Uq89bXk8Jir4e01nfQY
	LK2zucJH/iBcxt9hsmKkM9A+JVp7eXSr8IPxwlV0QHPhtLyIfzPaO0Cx1jpX/07sclASxhwQ9zIfu
	rkWxGFNNifdtwY3IGIRVCYXO3gQkrc0Qqa+ryGMpeDIK1l1jre/rCCBHnfOGODiBMkCj5GRC1RVpk
	qR+pLRccGOKg5jfzMz2VrdkyqSlnyQIYtPkVlpYutGjbwLeLIsSQrT4B/gmTWh3jVVGVx11AcHcCc
	+9L7JBR3XkSNx+HdDJpU86Ywbk3O8z+h+XDBEXwtBlFZtfq5xA380f0M2cUxTmKUoZ2CxJUquKFRP
	4bcFH5q1w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gyTP7-0006Px-6b; Tue, 26 Feb 2019 03:27:37 +0000
Date: Mon, 25 Feb 2019 19:27:37 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ming Lei <ming.lei@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226032737.GA11592@bombadil.infradead.org>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226030214.GI23020@dastard>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > Or what is the exact size of sub-page IO in xfs most of time? For
> 
> Determined by mkfs parameters. Any power of 2 between 512 bytes and
> 64kB needs to be supported. e.g:
> 
> # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> 
> will have metadata that is sector sized (512 bytes), filesystem
> block sized (1k), directory block sized (8k) and inode cluster sized
> (32k), and will use all of them in large quantities.

If XFS is going to use each of these in large quantities, then it doesn't
seem unreasonable for XFS to create a slab for each type of metadata?

