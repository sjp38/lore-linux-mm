Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85DFBC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:27:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5862220673
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:27:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5862220673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA8C96B0277; Thu,  6 Jun 2019 10:27:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C597D6B027A; Thu,  6 Jun 2019 10:27:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B498D6B027B; Thu,  6 Jun 2019 10:27:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC856B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:27:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p15so2196968qti.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:27:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=v+2aGC29dOXqeqogePFsVGSQXA564DmGGAvNVLJ/Fco=;
        b=SM55L09/L69SOxFSa77J0iZ39bH5hgi+5kViej7VgcyeSJKuNvwyBjsxLcI8hh5Ean
         317XlJw9KIFYZ/5WUY9BQWcQYP1D1IqJLRvVGFPJ5HhNTul7ClarwOCE5spelYv/g59F
         N8UL/tyHFb6ADjuIeKQFNXjwFrlrAC6BgCJ1EpKWAEdFfNa0b5GlQlmSfDDGoKdwGfd5
         HarXvUc52aaC9QYlxXaR/K08JEkxfSi3V06kkEECEEaOoMCo2Gu78lqabA/NdlT+BAUH
         4rhC17qLGVRrygPtEexRwpKOxdw+77lEd2aThdMHPW7inawzQ/5E9qM8IBxTwKxIUZoi
         jPaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUiFdgfy8Kovi9FpgxU72wuZ3eD+Cn/tRn1fIpoE5OGWyuROwVJ
	Y1Lg6fswFAxsxP30Sb4u+m1CPQYT9KOA9VdE2WOlV31JnHYbng9pGRJNRoSmsSie1/c79Y73vCQ
	9Pq2lzfaDoUQEtz5l0bCHoSp5DDGYkpND05UjLVVIYhmcNrfsf7KFzXh7vIzuD/j8ow==
X-Received: by 2002:ac8:2f7b:: with SMTP id k56mr30813901qta.376.1559831276371;
        Thu, 06 Jun 2019 07:27:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoSqj8b2LZ7EoI54Br8L85V2FmhrzHGYIKlUmBZtoEYz/4PEII7xB3H9FkMrgEDqMeZszc
X-Received: by 2002:ac8:2f7b:: with SMTP id k56mr30813864qta.376.1559831275854;
        Thu, 06 Jun 2019 07:27:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559831275; cv=none;
        d=google.com; s=arc-20160816;
        b=OkR3Gqfs8BdxlWPD3YG8aAeNd3th3BCg+k+fK5CIzIx0nu2Ocbf36V8O7mXn2qMYAW
         cNpdyixuiSl/2yGTboG8odVStdbmKxQ6KVTvvYrL+cqgEsVZKdHkxVuieiNvDYYLrgJG
         Rd+hJ6ZfmbfLexajlIh8RdZrQIPE9Cql2KqnntrVcvVa50yiCTWDJaIXV/ErLt+Fo+Ee
         6kndqGhz3Bnol9cWmbulfIQOBIx8y1mG95p2xerTv9wImwftqcIpWR3EVGOQj+ofjNF/
         HevCcsCYzJ0fXyPm8/zEkL6OOOqJRJ/NEDFIzkiqEVLl17iQq+QX1aQUOPO1WI0zXgJY
         0LMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=v+2aGC29dOXqeqogePFsVGSQXA564DmGGAvNVLJ/Fco=;
        b=gnCkrzFzEgaicbK8JVJTm3tnwMU5gNyABJmST3Zi3KdqRZhGbIyYC/0HX5gxKrg6u5
         Jm5CuncuaoMbLBJxzCkMyY9eRRy39rHq2e3IbwyvoovLLczUvy9qaGqXSbDm8yuCq9hk
         H8w/PTjKPgS8BMIxM+FZ3pCmwITQhH5qG91DkYf2H86EriwKnMO+eRi6uZA7gyw+/bui
         zOTvcDmSFAuMPtfPwBeuYRsg9K/aBrBMojp2XPG7JBekaV59W2NVR8craQEH1NAPF1V9
         T0RRAnNXsfiQLLOLN2QinYUgfXXByEvwzbzzIrkY6Pz7iuMQQW0QaXEP8nCm5chbe2Y7
         Icig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f18si2126916qte.190.2019.06.06.07.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 07:27:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E1AEF30BC595;
	Thu,  6 Jun 2019 14:27:49 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E6F125F7D8;
	Thu,  6 Jun 2019 14:27:44 +0000 (UTC)
Date: Thu, 6 Jun 2019 10:27:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: rcampbell@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
Message-ID: <20190606142743.GA8053@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-3-rcampbell@nvidia.com>
 <20190606141644.GA2876@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190606141644.GA2876@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 06 Jun 2019 14:27:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 11:16:44AM -0300, Jason Gunthorpe wrote:
> On Mon, May 06, 2019 at 04:29:39PM -0700, rcampbell@nvidia.com wrote:
> > From: Ralph Campbell <rcampbell@nvidia.com>
> > 
> > There are no functional changes, just some coding style clean ups and
> > minor comment changes.
> > 
> > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: Balbir Singh <bsingharora@gmail.com>
> > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> >  include/linux/hmm.h | 71 +++++++++++++++++++++++----------------------
> >  mm/hmm.c            | 51 ++++++++++++++++----------------
> >  2 files changed, 62 insertions(+), 60 deletions(-)
> 
> Applied to hmm.git, thanks

Can you hold off, i was already collecting patches and we will
be stepping on each other toe ... for instance i had

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.3

But i have been working on more collection.

Cheers,
Jérôme

