Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CAE1C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:22:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BA2520652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:22:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BA2520652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8505A6B0003; Thu,  2 May 2019 12:22:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 801906B0006; Thu,  2 May 2019 12:22:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EF216B0007; Thu,  2 May 2019 12:22:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3AC6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:22:23 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d39so2810007qtc.15
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:22:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=piOZOI0WkdbBvPWwp8eN2rAfH5PAyxWWUhDaKeynaSI=;
        b=kZ9uvtCUcU/PdRU7aXEhJtMWZsIuCW70Dmsrzvp93tOMkIjYBgvfsM8EOsmtMSoSN9
         e5sagfE/HZ2cRLU5rfNZCbLN2E8LdI3M0+oWGtZ+E8D1tTJAPAZeMFlfmAIavzGXD1tc
         eh4NyvcecJ7GxwGUzDmXfzUOuEj0R/k7edJD36t3sktrHG8pSb0KeRM09cl6PXWgMdwi
         qhwMIhBvpheo2hyJHaIS/DZP9c3w4zZ9g4iQhh4CYJZnp7WC4hIA53wtmVt0khZRj/Zc
         8+gJ/TJ0MeeQCCVS5GjlB23c1kB26uUIGSHOeq1REPhSDVVdONrWeBSSFlVJKNWtGQjP
         5nJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWLi3E/EoB/yJnbCMiWJySg9uoj/ntPLdBtsutVZXcEQ5xEitov
	PGYMQH8/hTqq2mu4UPS8G+nUFAxUc0ivOVIR4W9EML09gORnrLDRu+WGwLXQrc5NjeoYRip7NXk
	vgQWBF95OxtmHrhXgRt9UhfKEaB687u+1OjJQsS1Y4ZL2xxwt/SY6S6ahpXVFJQVeag==
X-Received: by 2002:a0c:becd:: with SMTP id f13mr3947537qvj.44.1556814143062;
        Thu, 02 May 2019 09:22:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSxUssUkHdfc1MRQPE/5fviGWvJUDgVTZ2OtKwK/zCxrzLpEisVV7RgFX6z6kLS5IaVQdE
X-Received: by 2002:a0c:becd:: with SMTP id f13mr3947475qvj.44.1556814142110;
        Thu, 02 May 2019 09:22:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556814142; cv=none;
        d=google.com; s=arc-20160816;
        b=uqi0jykbueEylTspexrJwIGl1dnwWo25ou6yGRpHiTVED44dOtbbwDzeJSv/TM4hem
         xEFKOutGEeGbzp5njB0YEFKhxSewic2OV0b11XiqKLN71d6JNFxR9h82lwjuHYAmzJAR
         8YczkaSpemBufqsj32UxRWB20JxgDJZlc+LqWxG3ZElm25igIUzR3GDNd9Rp3DLt3Ao3
         Bm5ERbMpII6bGC9ON7yhMjq0CLxVTwwA5zt2khrxxqF6+k3MGfx4Bc/nVNbdm76ASAUi
         D3PM89B5o5f+1ycdWqoz9XI1VwC8+ikzEaiI5xqoSlpCl7tWoYtjDsSyPRP12jDC7W1S
         8U0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=piOZOI0WkdbBvPWwp8eN2rAfH5PAyxWWUhDaKeynaSI=;
        b=JbVNZYTaPx68mW2OBQm8fSOGRtZyhiXSTRx1PpzgHGb9mZmwV41QMUdLGurMc1NdZI
         Sdl42V37k3dhH+RE7eZIlt4jxTFQlKcZQQl9SHykmvK2m7aCEFf7zLrGpxXrV7WeMeNi
         8UfR69zhTAK4lxqBtDkdHy09uNf4tvtJk8gOZoGk1fxvH81ZLDqydE6Gs0qBsiL+0uyo
         v7Y7upDN56sUlRFK9xUL+kplE2j3sf3C72xVNXfq7rsRQUVItThbU7NwoNzd3aok1rzG
         1hi9ZsN9LQy2atq/raMk8M9jr1izkXWTe1/sZFhyOoMj/qTaCPvllBkh5hd6i1lArpB7
         OmGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i2si123830qvd.46.2019.05.02.09.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 09:22:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 297173D95D;
	Thu,  2 May 2019 16:22:11 +0000 (UTC)
Received: from redhat.com (ovpn-120-112.rdu2.redhat.com [10.10.120.112])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 565455DA35;
	Thu,  2 May 2019 16:22:09 +0000 (UTC)
Date: Thu, 2 May 2019 12:22:07 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: add ARCH_HAS_HMM_MIRROR ARCH_HAS_HMM_DEVICE
 Kconfig
Message-ID: <20190502162206.GA13745@redhat.com>
References: <20190417211141.17580-1-jglisse@redhat.com>
 <20190501183850.GA4018@redhat.com>
 <20190501192358.GA21829@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190501192358.GA21829@roeck-us.net>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 02 May 2019 16:22:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 12:23:58PM -0700, Guenter Roeck wrote:
> On Wed, May 01, 2019 at 02:38:51PM -0400, Jerome Glisse wrote:
> > Andrew just the patch that would be nice to get in 5.2 so i can fix
> > device driver Kconfig before doing the real update to mm HMM Kconfig
> > 
> > On Wed, Apr 17, 2019 at 05:11:41PM -0400, jglisse@redhat.com wrote:
> > > From: Jérôme Glisse <jglisse@redhat.com>
> > > 
> > > This patch just add 2 new Kconfig that are _not use_ by anyone. I check
> > > that various make ARCH=somearch allmodconfig do work and do not complain.
> > > This new Kconfig need to be added first so that device driver that do
> > > depend on HMM can be updated.
> > > 
> > > Once drivers are updated then i can update the HMM Kconfig to depends
> > > on this new Kconfig in a followup patch.
> > > 
> 
> I am probably missing something, but why not submit the entire series together ?
> That might explain why XARRAY_MULTI is enabled below, and what the series is
> about. Additional comments below.
> 
> > > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > > Cc: Guenter Roeck <linux@roeck-us.net>
> > > Cc: Leon Romanovsky <leonro@mellanox.com>
> > > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > ---
> > >  mm/Kconfig | 16 ++++++++++++++++
> > >  1 file changed, 16 insertions(+)
> > > 
> > > diff --git a/mm/Kconfig b/mm/Kconfig
> > > index 25c71eb8a7db..daadc9131087 100644
> > > --- a/mm/Kconfig
> > > +++ b/mm/Kconfig
> > > @@ -676,6 +676,22 @@ config ZONE_DEVICE
> > >  
> > >  	  If FS_DAX is enabled, then say Y.
> > >  
> > > +config ARCH_HAS_HMM_MIRROR
> > > +	bool
> > > +	default y
> > > +	depends on (X86_64 || PPC64)
> > > +	depends on MMU && 64BIT
> > > +
> > > +config ARCH_HAS_HMM_DEVICE
> > > +	bool
> > > +	default y
> > > +	depends on (X86_64 || PPC64)
> > > +	depends on MEMORY_HOTPLUG
> > > +	depends on MEMORY_HOTREMOVE
> > > +	depends on SPARSEMEM_VMEMMAP
> > > +	depends on ARCH_HAS_ZONE_DEVICE
> 
> This is almost identical to ARCH_HAS_HMM except ARCH_HAS_HMM
> depends on ZONE_DEVICE and MMU && 64BIT. ARCH_HAS_HMM_MIRROR
> and ARCH_HAS_HMM_DEVICE together almost match ARCH_HAS_HMM,
> except for the ARCH_HAS_ZONE_DEVICE vs. ZONE_DEVICE dependency.
> And ZONE_DEVICE selects XARRAY_MULTI, meaning there is really
> substantial overlap.
> 
> Not really my concern, but personally I'd like to see some
> reasoning why the additional options are needed .. thus the
> question above, why not submit the series together ?
> 

There is no serie here, this is about solving Kconfig for HMM given
that device driver are going through their own tree we want to avoid
changing them from the mm tree. So plan is:

1 - Kernel release N add the new Kconfig to mm/Kconfig (this patch)
2 - Kernel release N+1 update driver to depend on new Kconfig ie
    stop using ARCH_HASH_HMM and start using ARCH_HAS_HMM_MIRROR
    and ARCH_HAS_HMM_DEVICE (one or the other or both depending
    on the driver)
3 - Kernel release N+2 remove ARCH_HASH_HMM and do final Kconfig
    update in mm/Kconfig

This has been discuss in the past and while it is bit painfull it
is the easiest solution (outside git topic branch but mm tree is
not merge as git).

Cheers,
Jérôme

