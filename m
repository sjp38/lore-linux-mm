Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF0CFC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 23:01:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C46B206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 23:01:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ZqOvaIKn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C46B206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 397728E0003; Wed, 31 Jul 2019 19:01:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34F168E0001; Wed, 31 Jul 2019 19:01:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20D508E0003; Wed, 31 Jul 2019 19:01:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 011CC8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:01:01 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k125so59323504qkc.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 16:01:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=his7K/u+JOrtxUOs2Ekh5bM+KWEwFmVBgmJqXbtUu9E=;
        b=ZpocwTtpN9LKeYY8C/L+0XRMp8QLV0N7EESF3tuvpkznpcKJ50JJXvIUANXofvmSwQ
         UCiWDFL3mQxwvcFLdDo1XYjaZMWwxy3ZIDYzNE1EuRlGA2vN1p3ML0EI25lI3Vlqohc9
         wkza9BsDPJYHqzseVCAZiTwOSSqyeo3eA7t7fCPC6W2Lr7UmrrxdfLvR3j9+IdBwvRe3
         JTUNpR0y//Px97CuWogEEIEn+udLazkgHwfEYrQEQt+gvb43+Dt/+tu+T4esYX3rbBAe
         JF5J0ngLJYiTKQfglA2AqaikAnKBA5yEJxukP28V/8kCSb5F9ELgVo4N6fG7CGqV+ZjY
         JSaA==
X-Gm-Message-State: APjAAAWTrSTF6QdIuXuLOoPOUq9ntdvb3N3N1/EMLcOAD0OdIHlAoaFf
	c+P0bSFfq0zRwdZFEKWEansIZsKySXmDYcsyzxmCsTx6dCGiavZwL7Z9I7ifW3CYmad7HBMAuzt
	2LK+qJCVY+EHrRHTW68dgBJCC5S1+Q9ZGNiN42zTlvOwZ9KggtyeqHy1qeNFkVXcM4Q==
X-Received: by 2002:a37:9c81:: with SMTP id f123mr79935274qke.135.1564614060743;
        Wed, 31 Jul 2019 16:01:00 -0700 (PDT)
X-Received: by 2002:a37:9c81:: with SMTP id f123mr79935202qke.135.1564614059808;
        Wed, 31 Jul 2019 16:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564614059; cv=none;
        d=google.com; s=arc-20160816;
        b=OIuF9FXjpJXRuPbAupYuQqcd1I+VgDj2AUYse4Bo7w9m432Sl4g4NOkXCA2+HKACa/
         cwdcISVmXmv79tRBogtpmT8LNtzvkLFdh90HcrC0SznCeEi+L4XY9WzGClp3l2fhJw3a
         WR5Mixu5KdOcWwdZwhtYrH1T9vrkTQFVqA7pP1vITuwnEVtNrfI9TN4yiHAFE9cAYKud
         L/vRH3IPF1A7yxOjcHLb7Tg+cDMMKYtacKKqFTcnvV9h96uTxmB/OJptP2cE7qP6+3ga
         iUi2Zi9Ga15nuQJBJ15zPb33F9rx2UIo/ePNy2VOyClSd8Pq9dfEjbIMsOk+j705S9Vf
         0oCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=his7K/u+JOrtxUOs2Ekh5bM+KWEwFmVBgmJqXbtUu9E=;
        b=r+uJDqRxoxzmgJWKhQobAnpo3bK550n4sKybCnEDHaSik2C1tReEFQ40c9Zr/5o6Uh
         NbiNxElaZI/pjlldanaHxIPqdVJkiP1tj5lGiY2K1irDFBMOt3wgk3A+wFYeWJS4dEz4
         YYwUn3LFHE4fI+f+95c/M6nO8bA4bcPS8CqR9y8zJwV06/jMuz1olSCzN+lYZHGuwf3C
         oKI/5ePjzH6jRmd4x4h63CxEonpxUhXVp3/AZTChCPD2fKeyY1pHo2WsqalVG69OG0cn
         fBjPmvJxyy+0GW+uw9ZXCcd5Ql7QNtGap4btZzDyYyNNHtWAIJcHiGJORWF8I/pYs+0M
         Fbdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZqOvaIKn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8sor91148335qtm.63.2019.07.31.16.00.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 16:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ZqOvaIKn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=his7K/u+JOrtxUOs2Ekh5bM+KWEwFmVBgmJqXbtUu9E=;
        b=ZqOvaIKn5gpXMKF0lFuPBJqJcfbMtb3MPGVVmN3aQsXXr9MSvDSwnBIoLdfs4Cduzu
         QRA8c1QAxNjNjf8z0l9WF9x2Kw8+F1laR/NQxc3pyjTGetdSmplJvdURFUqnq6fIi7Y5
         JS4Uvm5qizwTDtKpRb8KoH2QzFqssZQiMkXG494iOUBy1xVC1xhi6b5WNlWd0gIvaub2
         W1XaQLBaV1YKYGli71I0JUa9mD2l2THlCEAFuHc01L/n1KcqIaj1oCEo7xdECmJqx39w
         8DGqiJA1GV5ZIbSfFrgl6Pwwxp6UZXG3UZ0N0Nuntbj6x+BE/tlQ9FyXqpoxRRJYgrFQ
         ADTw==
X-Google-Smtp-Source: APXvYqwJPf0PqUhqgGpVR2IzxGvlfGykM1M7nRsba5YS0Ne3y5wjASuoEvOh6D7uIAmXvcUuYYR1nQ==
X-Received: by 2002:ac8:688:: with SMTP id f8mr11797584qth.130.1564614059446;
        Wed, 31 Jul 2019 16:00:59 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id n18sm29218512qtr.28.2019.07.31.16.00.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 16:00:58 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hsxab-00009Y-B9; Wed, 31 Jul 2019 20:00:57 -0300
Date: Wed, 31 Jul 2019 20:00:57 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190731230057.GA32346@ziepe.ca>
References: <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
 <20190729045127-mutt-send-email-mst@kernel.org>
 <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
 <20190729104028-mutt-send-email-mst@kernel.org>
 <96b1d67c-3a8d-1224-e9f0-5f7725a3dc10@redhat.com>
 <20190730110633-mutt-send-email-mst@kernel.org>
 <421a1af6-df06-e4a6-b34f-526ac123bc4a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <421a1af6-df06-e4a6-b34f-526ac123bc4a@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 04:49:32PM +0800, Jason Wang wrote:
> Yes, looking at the synchronization implemented by other MMU notifiers.
> Vhost is even the simplest.

I think that is only because it calls gup under a spinlock, which is,
IMHO, not great.

Jason

