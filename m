Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D298C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:15:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3364321955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:15:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3364321955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B01B68E0006; Mon, 22 Jul 2019 12:15:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB2568E0001; Mon, 22 Jul 2019 12:15:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97A7A8E0006; Mon, 22 Jul 2019 12:15:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74F9B8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:15:34 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id o75so16032144vke.3
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:15:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=LdqkyHpKkqiaZG1vIoVqE78fkRppClVgXicTtgP30fk=;
        b=hOQfGSVsRhfBtqWnMurNW76kfp91pt4EplVX+SxowBAYYzjQTlG0ifc27VeaS2KuzP
         HN2o1FWrjiGxdrj2lqDajmNdtJUbxtJm07FjnpcStMDJdeT89orjZ3mUdV6k8UYxfjE2
         1Lp805hhmZW2CHrtOQFX08rCErM8Hp+GXM6U8uzECA3oM81MCur0Is0FfJxHcmCOo7N1
         9zfNpN3iHP8gaFtUc6EEu7kFfR8xprOtWLZUfp7WqeQ7pjz9MKLyfUHDRt9RBUC8BrHO
         sHcp9pC4rWQFPVN1ALqi4YrgTyEM8tLGBR89EjCCQAQJ6dG5fHtqpXAMvnixhjOwDO+4
         tOcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXD9WDTe2ouBtRSBcbapF2xvu9uX9rYx5PnOSwQFGEs5Lc06sl2
	6At6UP6aVZy8bzSO6HEM2PFOqNVCZ3Dv6FzN8pu/lPf+9GWmDW6xU96hKN+slSjjvSqabuaczOD
	QbS4Nv4OHojY0mo3jnuyWDQMHSAyLXHJoUapErcw88+1odMu4W79LgdBEWsUnMLXaHA==
X-Received: by 2002:a1f:7383:: with SMTP id o125mr26709427vkc.6.1563812134223;
        Mon, 22 Jul 2019 09:15:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHUk8vya6R133KERNGIscQ1D5Zj8DwuwWdwYxGYZeTw/XwepCyEptKKrn7Hy09AMvQZHHz
X-Received: by 2002:a1f:7383:: with SMTP id o125mr26709390vkc.6.1563812133764;
        Mon, 22 Jul 2019 09:15:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563812133; cv=none;
        d=google.com; s=arc-20160816;
        b=0yBZkabt9Ybh9YXPxKmdAZWgDENhXsUEfdIo9rS43Qs07gQwPkjYng+xkGaoWSbFSI
         74oPlHV+Cd6WXYlYrxUugEwDwjLym/LPFcdA0qOMVynAyx7WpwgYzkB2o/jDIOASfr1l
         /sYkfO514Br7pptfz9UGfbHmTLmYVVA6qB/Q1FcMeTLCtOS2yl/oXHTjGh01ziIMo1Sb
         HjtZMMbtuK1gSM8iwj0jIzLq6xwgYhb5CDo4Mnt6GjARkGCmyYuOOITs3GrA+6Gr1PI/
         yzt56ex1DPmSrTHZvXrn8FKhv/WwxsEZxff3ZZa8JKT/NaRvWJ4kGxkUJoDkgI/mWvSa
         BmCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=LdqkyHpKkqiaZG1vIoVqE78fkRppClVgXicTtgP30fk=;
        b=AXV1TBM5+B/7mWaIZ4wKd3sf/Ucshl1hgVdrzYSUj1zD51H9PRt/izPHLiRzjRAxsx
         nzkPX8DPb+L7FoLiGoPm1IoLYkt09DQVGLEY2KquZPeZ9YfHvL4rrruz+++4vk7STXYu
         QYw9kfCCwajnt1iIeO16mSV5UsRFsNUWpIcsUIjFTdeDTynRz2G97AJgrSogoSZpj+Vk
         fRI+dVrGy35Fav/DQk/Gj7sdtBPHAHwxRaYoxF1X1l6TT9ngj35eiuWhrMZy/y9rf9bQ
         HWfUDQ7bdTdExRwliwtDDOzc2lDPpETIfzPtKCllo4+JeCA/GXJEqd1em3BoUerh2ibW
         /naA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s26si9942394vsm.30.2019.07.22.09.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 09:15:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8B3EEC057F88;
	Mon, 22 Jul 2019 16:15:32 +0000 (UTC)
Received: from redhat.com (ovpn-124-54.rdu2.redhat.com [10.10.124.54])
	by smtp.corp.redhat.com (Postfix) with SMTP id E40705D9D3;
	Mon, 22 Jul 2019 16:15:23 +0000 (UTC)
Date: Mon, 22 Jul 2019 12:15:22 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: "Paul E. McKenney" <paulmck@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
	akpm@linux-foundation.org, christian@brauner.io,
	davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Message-ID: <20190722121441-mutt-send-email-mst@kernel.org>
References: <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722035042-mutt-send-email-mst@kernel.org>
 <20190722115149.GY14271@linux.ibm.com>
 <20190722134152.GA13013@ziepe.ca>
 <20190722155235.GF14271@linux.ibm.com>
 <20190722160448.GH7607@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722160448.GH7607@ziepe.ca>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 22 Jul 2019 16:15:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 01:04:48PM -0300, Jason Gunthorpe wrote:
> On Mon, Jul 22, 2019 at 08:52:35AM -0700, Paul E. McKenney wrote:
> > So why then is there a problem?
> 
> I'm not sure there is a real problem, I thought Michael was just
> asking how to design with RCU in the case where the user controls the
> kfree_rcu??


Right it's all based on documentation saying we should worry :)

> Sounds like the answer is "don't worry about it" ?
> 
> Thanks,
> Jason

