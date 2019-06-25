Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95CE8C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:50:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6261C20659
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:50:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6261C20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8B196B0003; Tue, 25 Jun 2019 03:50:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3C198E0003; Tue, 25 Jun 2019 03:50:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2AB38E0002; Tue, 25 Jun 2019 03:50:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A98B6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:50:41 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s12so7532140wrr.23
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:50:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=A76BSyGQLPWatSbYCbtz7YLZWLf6OCtavBLswjKH5TI=;
        b=FgrBvBaLZMYVi5pKR17Zm3PISSNJ5QQdmfKHI78aaAmeD9qyamcnT4C0SEvWcpeupb
         3jjhC6tVD2ODPD2PAgaoog90XvwNVBAOlcBg13ysOG8hzZoHniFOR2j/sR6uOmm/lWTl
         UlDAg96h2VvpvIamIDZxUGAuygxAjiC9uFW25qkxKhOxsMcCklXirdx8rj1GaBRmtSwl
         bfR+mGpBzt0lsfxHy6Oj7vp97EiOfHhlOh8aqnhMOJnr22vmLMXY5QWsDZSkHocuKyYQ
         Nb3nvz9AFj2BGt4J5qUsA3CBYxt4XXOYakMQP1tiED4DBB3Lp359zLt8UKoDdHEwqYFW
         Rc7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXYrF9EK3C7JGfEwWMuyptFSgQphbdBYwYK4iwO49zSH1RpKrAf
	i94DetfHMWvsBfh1AgfL+1hXjZUgT4Ufc6Uqf+/ZnYPKMCc15QLISaA6VO0uwUMUEe+uoS3StTT
	8uoiPydruL3guLtbkCFKXF++59uUHOX/f+nMCDPgjJAjEcF2wCqXD7JH6UrIerT21+A==
X-Received: by 2002:adf:cd8c:: with SMTP id q12mr5134701wrj.103.1561449041233;
        Tue, 25 Jun 2019 00:50:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmPJ9AMtHwj92pb80kN11TSnpNwO+4oRua3WdwYcFE1fzi/y3yQDjs7kktdxPi5kQJBfmr
X-Received: by 2002:adf:cd8c:: with SMTP id q12mr5134668wrj.103.1561449040677;
        Tue, 25 Jun 2019 00:50:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561449040; cv=none;
        d=google.com; s=arc-20160816;
        b=ncQ1Zv4upxR4Mb+5gq+L51wXDjEZxTQxykRrBlvGnvUskoleRIogw0DaDFjygKwTWP
         JsjOAAuvjhZQe0a3/yh3H3Djyu3NfkG3keG84yS5HcCqHrNTq8py1gfEFQECpqYK6bi/
         84Djv/9oRBnKr3vJ53BMZlSofbAcohjbBklQJmtik6dCDBC1tRe1QCFT8a4kkF+ZheQk
         j5jAMn6h53hSTwpVmqumvCSKYNxzRAo6Co7k6rfZHUCM6aaKfXg9oXQxOFxS9UlMNjax
         nHgxIOFJlZF3X4VPq/kHAOr7HhKsWaoWg93l9ANbws+DbXSe+E3uirQ5iCpENNEDR+hg
         r9wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=A76BSyGQLPWatSbYCbtz7YLZWLf6OCtavBLswjKH5TI=;
        b=SYuNHhTcjcT6b+CdR7Sc3yecLNS+SBujAA4W5/nUTQa8fPp/bHUINoebwtWQDEdTa2
         orhD7sA8sBeZNQzzdEVUVpgabX5K00KcNmXuQTiZvsoOecf2NIz82YRr5sZSe7h4X8iV
         5F9/2PzVF9/PUoXLURh5ezxENF0h9irxva+tAasSfmUxlezINnrG81XYgbauh8EmyIlN
         citMlnJPzfOCcuJ3JYtFBePYH8zOdxzAm9PbMdb9TSrS5Wpkqxyh1VyBuI7Vy7YIvedu
         J/XMrgqrchwtvfxSeeSf/FE7MLpUASY1W9VQWlBsdaC16Mw5jseNuHcouWhpj1rBo3bn
         gMbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h2si11308331wrw.386.2019.06.25.00.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:50:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 3125C68B02; Tue, 25 Jun 2019 09:50:09 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:50:08 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 10/16] mm: rename CONFIG_HAVE_GENERIC_GUP to
 CONFIG_HAVE_FAST_GUP
Message-ID: <20190625075008.GE30815@lst.de>
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-11-hch@lst.de> <20190621142824.GP19891@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190621142824.GP19891@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 11:28:24AM -0300, Jason Gunthorpe wrote:
> On Tue, Jun 11, 2019 at 04:40:56PM +0200, Christoph Hellwig wrote:
> > We only support the generic GUP now, so rename the config option to
> > be more clear, and always use the mm/Kconfig definition of the
> > symbol and select it from the arch Kconfigs.
> 
> Looks OK to me
> 
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> 
> But could you also roll something like this in to the series? There is
> no longer any reason for the special __weak stuff that I can see -
> just follow the normal pattern for stubbing config controlled
> functions through the header file.

Something pretty similar is done later in this series.

