Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 926DBC76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D0E121019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:24:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D0E121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FCAB6B0005; Thu, 18 Jul 2019 16:24:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 887936B0006; Thu, 18 Jul 2019 16:24:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74D388E0001; Thu, 18 Jul 2019 16:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB176B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:24:32 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id b188so7289392vsc.21
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=IdKHwD3+fzZHJzKH8iBAJ9Rql6fpvbcqu643id2COtQ=;
        b=Gv713+y7OVNMZqcfscPMkm4tJrtp6/lMJfQOpPgv+36aF8lM8ta42BsemeDUG0cyHt
         /uAxVvzXdztaXKXeT/THPyhjninpurw3STQ9WSx/Kw0wTXpjyTflB7F2muPbo/miVbof
         issm2wqB9Jbf40B2V1juEMM1XAvZ8a+9cGRdKGy4TEpHhJ6Grd5A7O1LslCKvJH2qkMy
         3o1rDlZ6/3a353YnAEjVZsFfVlqpAJwjYwsTyFaA/8L4jMvYGd0ATc+g9akk1lPPFWzQ
         cGxhGM+tZYq8Y4qRtMfOZ1aD/51EbiuZvbMQkzo3rirrBzrpZnShoFNWPlvYRDd943hW
         /2oQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXAlfQ++3XABhfM+VNs2D+YUlW0oBBYTaqx56QgNd7ueCiW9YhF
	GSd9u35VyU1KiKVqSby3M+GpxLonB+3j7E6G08qVxkHvQ866ctXBVLmdgf5LynDFuWiRPCM0DCl
	CfrmUAyer2erkDOWsesbfoHMKTE8vcZJOoR0/HM/f5wmCMq0M4X1bA3g6A/5+LsPSLw==
X-Received: by 2002:a1f:be51:: with SMTP id o78mr19601596vkf.66.1563481471865;
        Thu, 18 Jul 2019 13:24:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuUHyEcMTzmALdMqx/SfNqGNlDzGBUwwoA+ig713dKziww9fNcDRKXIEFnA1ygRwok/IMd
X-Received: by 2002:a1f:be51:: with SMTP id o78mr19601508vkf.66.1563481470935;
        Thu, 18 Jul 2019 13:24:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563481470; cv=none;
        d=google.com; s=arc-20160816;
        b=SwhipdIaOSFw9GyKg+iz5X/+YU0f0K1izUDfGQI53wk6q3jtlqf+C/GRwwRIcUgZLY
         ZNTpx3TcDVM7Y45vgqPHVtJ6O3Pydxw/QtJD885CI9ugebZxtcAEqNF4mQ/CtfqGW1iF
         9FZjesoFWwgpF9zj/ORIp+VsyeLkFWEAYZXuybDCTJxfuYed/HGSdFd7l/MeUufkKKWY
         KjSR8LJ531vJNsT8byeqYitDrQSlNX3qM8rcbVw8Bc6uK5EbvV4HncuDPiadHpz/4BAq
         2RUAWek+o/e7OVGY33kahZzI1j5DjK8clvOyz52MYsDJ14EbrvvkL/bI39PTrntl4VjK
         4Zdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=IdKHwD3+fzZHJzKH8iBAJ9Rql6fpvbcqu643id2COtQ=;
        b=Tq67VGTzyRVlJEZU85HPDpPV4c+Gs0sQ+joV7Hn55skgyLHe7uN+eh24v6nYUvdptp
         NitLmaqDbU//5SitHxj/SOouLxn/WlnswTXIXvRYLKi57N469lC0dO0WOujIEB5ylt1u
         UowqGUXnAiTxWl3vEl83NIwng7+8x/rO52gF7w8+cMrMIzV2xTJzKqrsbVBJecNtCBT6
         mqwgAwy0gKf2BVr0CFLg/ZmoxhAnx7L9SUtyOU5npPaNV/D198dvE4EegHU040eS93ud
         GCHdCV43CjHvJl3N8FVMFBb4quUc2HvGqObGTiCcyKlw2p6kGhibCDufxZsMf8wS0pP9
         cXKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e11si7123369vsj.313.2019.07.18.13.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:24:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DEE297FDF5;
	Thu, 18 Jul 2019 20:24:29 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id A0D7919D70;
	Thu, 18 Jul 2019 20:24:16 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:24:15 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, wei.w.wang@intel.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190718162040-mutt-send-email-mst@kernel.org>
References: <20190716055017-mutt-send-email-mst@kernel.org>
 <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
 <20190716115535-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org>
 <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org>
 <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org>
 <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 18 Jul 2019 20:24:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 08:34:37AM -0700, Alexander Duyck wrote:
> > > > For example we allocate pages until shrinker kicks in.
> > > > Fair enough but in fact many it would be better to
> > > > do the reverse: trigger shrinker and then send as many
> > > > free pages as we can to host.
> > >
> > > I'm not sure I understand this last part.
> >
> > Oh basically what I am saying is this: one of the reasons to use page
> > hinting is when host is short on memory.  In that case, why don't we use
> > shrinker to ask kernel drivers to free up memory? Any memory freed could
> > then be reported to host.
> 
> Didn't the balloon driver already have a feature like that where it
> could start shrinking memory if the host was under memory pressure? If
> so how would adding another one add much value.

Well fundamentally the basic balloon inflate kind of does this, yes :)

The difference with what I am suggesting is that balloon inflate tries
to aggressively achieve a specific goal of freed memory. We could have a
weaker "free as much as you can" that is still stronger than free page
hint which as you point out below does not try to free at all, just
hints what is already free.


> The idea here is if the memory is free we just mark it as such. As
> long as we can do so with no noticeable overhead on the guest or host
> why not just do it?

