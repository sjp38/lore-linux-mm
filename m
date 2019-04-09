Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2F42C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:27:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99C5A2084F
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:27:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99C5A2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D2986B0008; Tue,  9 Apr 2019 08:27:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 182346B0010; Tue,  9 Apr 2019 08:27:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 072F66B0266; Tue,  9 Apr 2019 08:27:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D54DE6B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 08:27:37 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id k28so9852355otf.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 05:27:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=z/trgQiJ5D0wolVVcdbJRsKAhdLxgTEUNygK62iDo80=;
        b=WvAEVZNZ3ojF0GNCUNkpmUUoJie4nPe0I9sKXMBJUqGJ0IcjhdDR1phFkcHenYYhzP
         XbvpMRcvG2fZq+v7xO9//KBqUBsESPnjzpc/1jFTcxQu0jT/ReOs0Mx0Qr4/8dQXf+or
         PamhaqDxh2FV3rnhLgqe6EML8LOhvx90ETlZxeoVsuHW7mI0AIR6i8Ad3IWL4Y7TMigE
         bEefKW9Yz20BIlxac2G9sMhXZsmEnHNWyIvG19bfruTmD9aWiA/QPr5cVdBmR/uH/awl
         2MkPS8zpM9n4ZfkxvctOkHxIqpEZ+gyrM72YHhUiQw4UdRRDJaqCVkMNcPQm3wfO5RkL
         865Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVZriwm1HPabSlOazGqSDGri5UG9Vb/sE9pJVTh2XMVvxubK9Qr
	ad03wzwrRlLBZch4FaEwJpXvC/O7b1s09xepJVYsj6GI4xq/A5wh99ZnYQ8ObU+rBE3B2N7TBXB
	97MznTbwCOW/nG9MVzgh30xq35l5nyHT0BbfqwzJRVJqhlIWvczfzHxdKhMBlUdTgWA==
X-Received: by 2002:aca:4987:: with SMTP id w129mr19457973oia.33.1554812857434;
        Tue, 09 Apr 2019 05:27:37 -0700 (PDT)
X-Received: by 2002:aca:4987:: with SMTP id w129mr19457936oia.33.1554812856667;
        Tue, 09 Apr 2019 05:27:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554812856; cv=none;
        d=google.com; s=arc-20160816;
        b=y4uybqCQWckMemoso7JeYZB6JWgrop7xDhzDsuu64oojVxQAD91X5bZxZQn1o+DONq
         wWNFnHSbasWyHlsTh67ccZP8sug9fvFaw7V8asjjG+ZXMY2sqOJNN8jAI9XCnt7M0MzC
         pKYqpqd+Z0FcyL5ovH4p5dwllE69rG3rFu8NVHWhaqai21cuK8SwKK4+5PZEiyom+v/Q
         ZplHu2TcmXYkVuYzXzId/F8/NQSKt1bdFflsijWB//H+XJRyopSvnjr4JrhXFBe/YLNf
         zwj0yHizvQyvy3HMKhwVRbKOYIw0LzizvSt9t5dH0OE0IdrZqeB0t+mBXY6G5cQyqTOZ
         H6Aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=z/trgQiJ5D0wolVVcdbJRsKAhdLxgTEUNygK62iDo80=;
        b=ERPOx4oqNZEkuqJbg7TbGf7tJyjbmT5OXU8vwScaP+a7HcC8hDwCCQ1+dcQft6eKjU
         bxBTjcc1JeUfgNl3x6UBbv6KmBA/prIVY/g/BzuSILqE6xr8z64Rr0cyN/gwg+Uu+VAh
         /64uqpGCrHfTeDT65pZblh+3sx4ijPWVS2ms9vQkQC2GLU3eays59Q9WvDm8t36qDatC
         HOzNiRXmorQ8k44G2QBAw0KFG6j+x79idOKYzpAqLQpBB6N6OpBYfvcmwLENdd6KdiyN
         jNgwa1CJM6N2xmMtdAXYx4A3jHMJgXgegw/v1NRcZxOaHZTgzeVippd//TDiuaGgOC0r
         okBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p4sor18242918otk.185.2019.04.09.05.27.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 05:27:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxRkNBis9kJov7vODTzte23h9mG5xtLuhpJGipOgzqSo/aswf6p88ymfgByWoZzTo2EibkGP01+RTjwIlBzdfQ=
X-Received: by 2002:a05:6830:128c:: with SMTP id z12mr24617786otp.101.1554812856369;
 Tue, 09 Apr 2019 05:27:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190321131304.21618-1-agruenba@redhat.com> <20190328165104.GA21552@lst.de>
 <CAHc6FU49oBdo8mAq7hb1greR+B1C_Fpy5JU7RBHfRYACt1S4wA@mail.gmail.com>
 <20190407073213.GA9509@lst.de> <CAHc6FU7kgm4OyrY-KRb8H2w6LDrWDSJ2p=UgZeeJ8YrHynKU2w@mail.gmail.com>
 <20190408134405.GA15023@quack2.suse.cz> <20190409121508.GA9532@lst.de>
In-Reply-To: <20190409121508.GA9532@lst.de>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 9 Apr 2019 14:27:25 +0200
Message-ID: <CAHc6FU7gq4JkZHPqW5LT1k7ARVJX611kZPQ3QFxiuYv4Jbvzrw@mail.gmail.com>
Subject: Re: gfs2 iomap dealock, IOMAP_F_UNBALANCED
To: Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>, cluster-devel <cluster-devel@redhat.com>, 
	Dave Chinner <david@fromorbit.com>, Ross Lagerwall <ross.lagerwall@citrix.com>, 
	Mark Syms <Mark.Syms@citrix.com>, =?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Apr 2019 at 14:15, Christoph Hellwig <hch@lst.de> wrote:
> On Mon, Apr 08, 2019 at 03:44:05PM +0200, Jan Kara wrote:
> > > We won't be able to do a log flush while another transaction is
> > > active, but that's what's needed to clean dirty pages. iomap doesn't
> > > allow us to put the block allocation into a separate transaction from
> > > the page writes; for that, the opposite to the page_done hook would
> > > probably be needed.
> >
> > I agree that a ->page_prepare() hook would be probably the cleanest
> > solution for this.
>
> That doesn't sound too bad to me.

Okay, I'll see how the code for that will turn out.

Thanks,
Andreas

