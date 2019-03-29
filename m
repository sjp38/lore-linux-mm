Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2381C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 12:55:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B93C1217F5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 12:55:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B93C1217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 549976B0005; Fri, 29 Mar 2019 08:55:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F93D6B0006; Fri, 29 Mar 2019 08:55:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C0E66B0010; Fri, 29 Mar 2019 08:55:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18A3B6B0005
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:55:15 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n10so2107147qtk.9
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:55:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gnl65CNHwgR2Gn1TqF5oif7rObVnKP8B6Yw8gcVz3XQ=;
        b=bKKVbzuan63v4uATliveLPQDaf6oa/iPGHnD9aZDnYTHFxwAUfnEI80cXIfRK4Ljij
         etqg+uuf94e2M0L9mrM1pLlLpIVkSdeV7GAEFBHnNsj/a5N5vOjRQT3VpiMenhpvt+Hq
         hj+yK0CBQaxEEWrfucD2k4zkBJNZKXbg679704FzdPqAbx6AX7d41MQu/6Ftv/G9HqqJ
         LqVuUuAhiHuRbFdm6SZ8AyQpoYKLgmj/Df/Id/RofaCpZ70LrMJ/Gz1lG0WOxgG2jQpl
         RDpkxduVsg6SojJrjhknu0XXV8topzKXUGv2koXbZneFbSIyecHp44ymRZH6wC33ZH7Y
         qwXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXcoFMUGQevQupVWGwMsbjmIqWEWyQl/kJkuKXqy4up3o4kF5+f
	jfS+2rtPA/4GCkguVWlhJCT6nDFKXXTB2gb3W/UQkKD8YPbqe7RNlS+6J+snFxXK+aH0WJAF8q5
	vLYdMVY9+gC2a3mEZ01Q9nMh8b8lrkq6iscGSNm+Qecc3hSINm3DHHUrDAUo220aYNg==
X-Received: by 2002:a37:70c4:: with SMTP id l187mr39544637qkc.146.1553864114750;
        Fri, 29 Mar 2019 05:55:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/rv6mGGQWUfMIzpJ09t1Zq2En+AUnhkMZyVkl+n6p1sRj3lsz/oAS01VwmKYEeQ99boS8
X-Received: by 2002:a37:70c4:: with SMTP id l187mr39544594qkc.146.1553864114012;
        Fri, 29 Mar 2019 05:55:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553864114; cv=none;
        d=google.com; s=arc-20160816;
        b=KDwt1n4GG9eNBfNVwCy2UfBl6g+517XqoLZT4b8vmuCdTDy99u064kKM8PAI/wPygg
         P0YudGGmfShvESMnMgMPum73TpNNSJrkpUgblXq6sFbAqgsdvuCRwHtWQWOCCmFRUYLd
         r3VNwqMWwuQD8F6uz3L/R9/CwZyf/ZqHjjjUrOI7512QcM/i/gnRgdLUhZzaeXa9Auy8
         jrmrPmPZpdUb2FY0Zodr/F4BXl2C3HsL2Q5XK0h3NCznf9bsWUfvSCdZGIOXhNm4m6Oi
         lvStr02x/+LPzwB6+F77iec6f92SXbiZrdVC/eq67A2Wn8ptWCUSiRrVpeCJOqLEFQvY
         N5DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gnl65CNHwgR2Gn1TqF5oif7rObVnKP8B6Yw8gcVz3XQ=;
        b=oFxQOfhRlXO35mB/UUn8vuvo1RVHhFZP9p5L4NTyrS82ERP6S785DTPJO/+1268B8L
         cDmPAlSwpdhWOBt4GX/szxjqkAKi12DLrGkzmiB88Nnj1Z6LrCRSV2lFg48TwI2cXVNK
         G8TFBH6n9SDo44zjTlscfrXgkHQqwn4x2kfV3ddFMfIykc5fghCKoMyLUDQqGdVtvNp0
         qks+ND1PeWafOc7DtWEx7JVGFFNeuozZYLJ6UL4amPtNVo4OUVJbqmsbL92RUL+X3MCR
         HbtT4ZPe+PUIxHRImKugqGl1eA1l+g4MwA89T56Yk6IK785PeSQNO672aI0GJxY6ghqu
         HDoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 58si1227696qtr.13.2019.03.29.05.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 05:55:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CA3CB80E5D;
	Fri, 29 Mar 2019 12:55:12 +0000 (UTC)
Received: from localhost (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 345D46B48A;
	Fri, 29 Mar 2019 12:55:06 +0000 (UTC)
Date: Fri, 29 Mar 2019 20:55:03 +0800
From: Baoquan He <bhe@redhat.com>
To: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, rafael@kernel.org, akpm@linux-foundation.org,
	rppt@linux.ibm.com, willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 2/2] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190329125503.GK7627@MiWiFi-R3L-srv>
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329082915.19763-2-bhe@redhat.com>
 <20190329091325.GD28616@dhcp22.suse.cz>
 <20190329093725.blpcyane33fnxvn7@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329093725.blpcyane33fnxvn7@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 29 Mar 2019 12:55:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/29/19 at 10:37am, Oscar Salvador wrote:
> On Fri, Mar 29, 2019 at 10:13:25AM +0100, Michal Hocko wrote:
> > On Fri 29-03-19 16:29:15, Baoquan He wrote:
> > > The input parameter 'phys_index' of memory_block_action() is actually
> > > the section number, but not the phys_index of memory_block. Fix it.
> > 
> > I have tried to explain that the naming is mostly a relict from the past
> > than really a misleading name http://lkml.kernel.org/r/20190326093315.GL28406@dhcp22.suse.cz
> > Maybe it would be good to reflect that in the changelog
> 
> I think that phys_device variable in remove_memory_section() is also a relict
> from the past, and it is no longer used.
> Neither node_id variable is used.
> Actually, unregister_memory_section() sets those two to 0 no matter what.
> 
> Since we are cleaning up, I wonder if we can go a bit further and we can get
> rid of that as well.

Yes, certainly. I would like to post a new one to carry this.

