Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49743C468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:17:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1038720665
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:17:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AezT+tTA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1038720665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9480F6B0008; Fri,  7 Jun 2019 08:17:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F91C6B000C; Fri,  7 Jun 2019 08:17:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E72C6B0266; Fri,  7 Jun 2019 08:17:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7DF6B0008
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 08:17:31 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id b7so1418778qkk.3
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 05:17:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gtVg7214Fw18jFmO0/trZn1VfZgS9o74gz+vruFWYvs=;
        b=Z6WPWK2seA+aZU+QrBPXg0i3KUrpkVigOGckrHV0P6N6/fpPaY/p23qxKoNc9JfTVz
         FtwoAXuUb/KYdZ32Mu2QIZ1Ju2a4vEeDHo2Cdg/FRzc0BlwB6ZnxGi3po1wN9yo+mVc9
         IH74u1eFQfogcnJ3HexjFNIIVfcVIilT7SrO5c4sFa5f/Jko9S9mNLzCDkoUT8J8C7ev
         Svp5beocLhQI11uff4+9k7I7RlB2Y8kFe7Jo/7eeJ32bMq3OPaky9C9YkSStG2dpRIeu
         4DqnRHY11FspxIci+iOTaBdwnS80jdNrNdLH5MHmdT5axtC0Eaa/ABoaRoLtADi6YSp8
         xc2w==
X-Gm-Message-State: APjAAAXC3a/98xHnjPSbIhuN54tZ6xTuA4IStXWFHHmVcZ66LYme71kK
	e4Nj6E2FcEHxYnO0EMEHP6TnYeAGEaEIX0pPwsHpL9zdWeBBViJr5aOMhWaEpddZXrV5YfdyFF5
	AhUv7RB/RvPbT/oSxvA+mrhUOq31h1rziNNk71Uz5ybRat1sswx9uK5wl9Ja3pCtwKw==
X-Received: by 2002:a37:895:: with SMTP id 143mr10675360qki.38.1559909851138;
        Fri, 07 Jun 2019 05:17:31 -0700 (PDT)
X-Received: by 2002:a37:895:: with SMTP id 143mr10675321qki.38.1559909850505;
        Fri, 07 Jun 2019 05:17:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559909850; cv=none;
        d=google.com; s=arc-20160816;
        b=iAsLtmz6SL8ncDJSoZSiK4QuV+bA13Z8C0E6Wi5LbqORQEtxP1IrFXM6waaUBy0oE8
         QuPpcBsQb6G1YM2b+xemLv/n/gWsE0uhFTH/h7g/m3KUEIlOMM9BxwgTHfazfZC5RhX7
         kvrxNklbcpaByN+Jag+8Td4Y7qpQkp2RXyEzmE3/CVT/cHikO0mKogE0DTdzAX/Q52Fx
         eHJegDe1cMbg20iznZhoSNU4oul7spT2O3sL+giuBa0mQflPEmb4nTcfkIZrXQ8+F+bb
         Uxj8/1RWqrAAQJefW0XXrILYzWJJLK8YJE/wZmEdwYIMjE9M8mmXM/wzdi+3WW6nQxm4
         pm3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gtVg7214Fw18jFmO0/trZn1VfZgS9o74gz+vruFWYvs=;
        b=w/aQogbqi7A4uYtQj3826vBGeYjKCLAxoRflW104l9E8JPoBpcsj4Itksv5v0X0W7N
         KDOmcQPyAzPhUn5ETa9uWtsmOemet9F3Tpej3Bzslyrn2FkZsDZ9rNjA/jYd3MMlfez5
         x6wB4mVL551bPgZBOnoLvBj8W5Y1hUlpbqaCGVIJMjK/U2Z7PE+QiDlsJA9vHG6dR1cM
         ln/Hj8qOZc0x5ycCBJBfY9QaqkByCQ/tMNLinXVrqg8Tfkyu7PJ+UB++bFjrV4s7vbCq
         GCUQsp7TTbXuB8nrZVqbthhq7jm/x/gBpAcxOkcFRI950wID+06LH8w1P9IwyUXG3Wt4
         Iu8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AezT+tTA;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x13sor1517431qvn.49.2019.06.07.05.17.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 05:17:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AezT+tTA;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=gtVg7214Fw18jFmO0/trZn1VfZgS9o74gz+vruFWYvs=;
        b=AezT+tTAIxGyfB0KOhiZ4wlOnDCwDvYEe2UFeaP+bHsiFFJQ3quqmXBE4VmSizAzTs
         J5ODOdrIQHOFjGLrQ2kl8pD0ejEenWX2TUZIYKB59qg474XzKIZuOVjBRq+lQLrWj4M2
         iVSmY6vOHff8NwVO3HpVwZnoQ1jkfupA0SSt6+/EDEdGIfd2MHTCCINUJtnZE6aguk0H
         Rq46XtTgO8/RXptKjB7wYR1vu5zDzIPtlBUqsEOtO9gMF69yTuBc5m8Ime/ZPUvcZqrt
         ymNopsF+fiDS/oX9NSWKDQK6uJaybIPNjnDHpwGv1pap4mgqjUGIkS+C+1a2HU66vv8B
         gi3g==
X-Google-Smtp-Source: APXvYqwfuT8J8aHz9GDeVxlPBNadLwnaumAWGxao4r/2OtwvxxCdhCQDklOSjsDrPDzMrdJee4yNzw==
X-Received: by 2002:a0c:8a69:: with SMTP id 38mr24854894qvu.116.1559909850154;
        Fri, 07 Jun 2019 05:17:30 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q36sm1286394qtc.12.2019.06.07.05.17.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 05:17:29 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZDoH-0006pJ-3U; Fri, 07 Jun 2019 09:17:29 -0300
Date: Fri, 7 Jun 2019 09:17:29 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jan Kara <jack@suse.cz>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190607121729.GA14802@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607103636.GA12765@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 12:36:36PM +0200, Jan Kara wrote:

> Because the pins would be invisible to sysadmin from that point on. 

It is not invisible, it just shows up in a rdma specific kernel
interface. You have to use rdma netlink to see the kernel object
holding this pin.

If this visibility is the main sticking point I suggest just enhancing
the existing MR reporting to include the file info for current GUP
pins and teaching lsof to collect information from there as well so it
is easy to use.

If the ownership of the lease transfers to the MR, and we report that
ownership to userspace in a way lsof can find, then I think all the
concerns that have been raised are met, right?

> ugly to live so we have to come up with something better. The best I can
> currently come up with is to have a method associated with the lease that
> would invalidate the RDMA context that holds the pins in the same way that
> a file close would do it.

This is back to requiring all RDMA HW to have some new behavior they
currently don't have..

The main objection to the current ODP & DAX solution is that very
little HW can actually implement it, having the alternative still
require HW support doesn't seem like progress.

I think we will eventually start seein some HW be able to do this
invalidation, but it won't be universal, and I'd rather leave it
optional, for recovery from truely catastrophic errors (ie my DAX is
on fire, I need to unplug it).

Jason

