Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A685BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 12:43:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49C92214D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 12:43:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49C92214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3ADE8E0003; Tue, 12 Mar 2019 08:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE9A98E0002; Tue, 12 Mar 2019 08:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD9EF8E0003; Tue, 12 Mar 2019 08:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F52B8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:43:18 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w134so2007175qka.6
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 05:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BhWZHxPxGZsha+8zRZW2ApEt0Kl/l75vzWU37yn+piU=;
        b=gslhUb3ZhAOtBQoF+zLcLQMQDeZWqwKhh7iS/7K9pgldKBszWWjEOf6pdxdg7jlAQx
         gBUGMxOxHDQLuO2QR3i/CRTGd4RTMewVyhl9E1dHbyzm0bQ7glYgbgXjOdPizJPz35jv
         oQ2DvkH/ex+Ti4hQYu3uKTZ/UhRmWIrZ247dFeqvj/dSU53lCoAK2U64aSYQyMwSComI
         eDPaUV1cV4KfCroNzxBngPZqjOPmGvU7g4cDMXFSK1lzfdlGVZxs/aVDpjLo9f9n6GUr
         8FAetS4Q8LYbAF6csORx5D93yKSaPPL4C0nfX4PKJ9Wq06NKFBXHnGlPPXmW5tQo+Iz0
         p5GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXpagdQqMNeflK7tMl4Mm4dYVq39E5F5HX6sWDYFbxiQl+Lr9ax
	qAFW3ulaxBsa66kNGUJAa2QbIDEpFC8jUbluXc98GkytBJ0kk3ASo3I912su7XX4b/Ew0kGBB+t
	llGd0oIt4Bg33pMYXwpzwog7AzMcCl1QRgP43f4LosssPM4ZE1VecxCyQ1vb007Sryw==
X-Received: by 2002:a05:620a:12e1:: with SMTP id f1mr10284280qkl.151.1552394598345;
        Tue, 12 Mar 2019 05:43:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykEVK0LmY13Bsu+Gd40LOj7tsdQ8KsezGfRiMHs38boTSUTkFzfB7sVEAO12Os7+QWIuwI
X-Received: by 2002:a05:620a:12e1:: with SMTP id f1mr10284251qkl.151.1552394597689;
        Tue, 12 Mar 2019 05:43:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552394597; cv=none;
        d=google.com; s=arc-20160816;
        b=WOd1/Y4UdL5SyRdRlXBTjkigMFLxhT4MR07m1FKNIF1J1j8cinX2dUuj0yUwsajB5x
         OR0DECJdXqaWfUg5SEV3w2gAZfaqDjdRf/ahtgd/ze8ZBi+YQzc+U5XqDnYtJaQOiKCs
         9OHKG/w3zI8SNeO+OLIUmsnKHTDfjD9XlTIUwxV3UqzCCqI9MjbBWa4nQTr0/YgI2Gmx
         EYlU1hRcnU6byfeUYrvM98dtndfTXH3mux9vjw4ZgSGYgYL7AxBTIe79uCAhIrC/rUoA
         tXKVPXTEoAzwaWRCZ2iXnYI64jVNq+5wohiPN8G8b0jd8BmvcNnnzFWWsgs9bOTU6f++
         oBUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BhWZHxPxGZsha+8zRZW2ApEt0Kl/l75vzWU37yn+piU=;
        b=Z8Dvw7lVjTTHh6v3vsD4qZsVrSkhg6w583mlqr6Z9RiOX8T5aRDiP5xuVYBf8euJEM
         +dNbrFtBatSQcZh1KC3BWy0S8CuYVBO+nqxXlKuZSQHO3BNK2hu+qxQYjjAu4AfEwpmy
         7qLgvbFBogv6JmRrkGbMZBu6ZU+9mw4VAz2TB+W4D1Xx9k08vhP+8xtQh22PIN9JfrKO
         fTuWa1Qi62JYeQfhyPdhM1IPLPmfSQ7lvfb170Ee6TkopWCXNQVDrjt+xRlAoeB+z0co
         YwXLUBjRF2Uy9ou8rQk91dvRJp3t8+tCrRlVSoqGO86VWfI8IrDQb2LBu/Mh0gpGLwgI
         jz5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x12si4138258qkh.253.2019.03.12.05.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 05:43:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 78BAF30842CD;
	Tue, 12 Mar 2019 12:43:16 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 45797648C2;
	Tue, 12 Mar 2019 12:43:05 +0000 (UTC)
Date: Tue, 12 Mar 2019 20:43:02 +0800
From: Peter Xu <peterx@redhat.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-api@vger.kernel.org
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190312124302.GA2433@xz-x1>
References: <20190311093701.15734-1-peterx@redhat.com>
 <20190312074951.i2md3npcjcceywqj@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190312074951.i2md3npcjcceywqj@kshutemo-mobl1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 12 Mar 2019 12:43:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Kirill,

On Tue, Mar 12, 2019 at 10:49:51AM +0300, Kirill A. Shutemov wrote:
> On Mon, Mar 11, 2019 at 05:36:58PM +0800, Peter Xu wrote:
> > Hi,
> > 
> > (The idea comes from Andrea, and following discussions with Mike and
> >  other people)
> > 
> > This patchset introduces a new sysctl flag to allow the admin to
> > forbid users from using userfaultfd:
> > 
> >   $ cat /proc/sys/vm/unprivileged_userfaultfd
> >   [disabled] enabled kvm
> 
> CC linux-api@
> 
> This is unusual way to return current value for sysctl. Does it work fine
> with sysctl tool?

It can work, though it displays the same as "cat":

$ sysctl vm.unprivileged_userfaultfd
vm.unprivileged_userfaultfd = disabled enabled [kvm] 

> 
> Have you considered to place the switch into /sys/kernel/mm instead?
> I doubt it's the last tunable for userfaultfd. Maybe we should have an
> directory for it under /sys/kernel/mm?

I haven't thought about sysfs, if that's preferred I can consider to
switch to that.  And yes I think creating a directory should be a good
idea.

Thanks,

-- 
Peter Xu

