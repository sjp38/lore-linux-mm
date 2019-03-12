Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62EBCC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 12:26:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ECA920883
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 12:26:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ECA920883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD67A8E0003; Tue, 12 Mar 2019 08:26:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A85B68E0002; Tue, 12 Mar 2019 08:26:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 975428E0003; Tue, 12 Mar 2019 08:26:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6939D8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:26:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id i21so2057625qtq.6
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 05:26:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2+6uXObWoAJUYg8mmzL0ZyJcTUW/fl6Rw4A1sRXN8oM=;
        b=HngZ7Es75gAOJH4NvbLnGBROYahf8/lD7tr2Xykn6B677grPmCm1FdD/q/DM6ikmHv
         pz4uQ0TI71fkKwhYI62QBXmtazSEunDoInOWtCLI0Gups9jBAXhuazd0wPXlRmO59UPP
         VP1a6SXNrpx2kdR2762qC1FE7VdRIdW/scas+R20VshNyik/ZhJWsFngTJmgZTwN3fVp
         GA6Z5e+bQCIqNunrxRgwdHTTHSogB97QUqEbFttH8ZMWz0CFMNfQH915IFr+oSSbqA9i
         w+G9K3NQa47c5cQtIfERWB3QlIVZWxf8iym35MBBpX6V8vjRKCXTQVklo0K5zu6Lxge2
         s+1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWvKOjBuGEFlYuLmfWSXm0ALmwloXPsKcLVefZ0uUNE3EUv9tNU
	B+HHiqnzGVT7y72PuLlChqxxjkINBOlMImRiqPXN+0DcCrEcg9RAQVZ3Axp6q3cE8Y2TQY8nknD
	uSoM6AdOKgzH6nZczkBS90k+WK+Uzr35ZIaLp4+9O1Qi9bfRL6w42QUOR2SHISNf/wg==
X-Received: by 2002:a0c:d0c9:: with SMTP id b9mr29576896qvh.95.1552393609251;
        Tue, 12 Mar 2019 05:26:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyURjbctIaxEGBFKqbO8P1uBQITc3N3HslZbF1t3mAIfRBh6mGt6fgUfCzK8Yc74du25/hM
X-Received: by 2002:a0c:d0c9:: with SMTP id b9mr29576842qvh.95.1552393608412;
        Tue, 12 Mar 2019 05:26:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552393608; cv=none;
        d=google.com; s=arc-20160816;
        b=olfAThLXIzqO6pJ+YtlxHtvZV92hS52PR3rH/mksCLptr7XdpGD2iv1oFgZdD8qeGZ
         lFR5cWk48DeZLniS/Sx3Cp80gP4DhzD4kTzato/ZJjr7zV+M23l5/QPI9YzM5aRNfkwz
         KtlGjwYri71rZUdiEXKXpH6UT3MRwL3vDA4bm3ZULt47hoD4ZMAEhEQHiAsGFWg/VsbQ
         q2CkR0UUBEGpmvf2b2g8ZtbpD8Is1dFbfNGLp9bFiddSHaujupGK1JxamwgpyIHh44Sv
         Vzw7BUuSnwa9+09glDDa5KozVKbLYYrRuQGIZrLy/lixjT6LjUyAw2IvpWRNKd9ErPs0
         iWXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2+6uXObWoAJUYg8mmzL0ZyJcTUW/fl6Rw4A1sRXN8oM=;
        b=VmskfnvIqJqj2X+/c0bS85JQRqgvA2OS1L8xWDa9s4ehz/QcCCRNxfdcf4mCyu+805
         CevOKUuaNLK/bwegfDoOdAEkqv770OdngE3g41lW/9TEw4YQZTg0Muox5cKHJ+epXAxh
         jhW6pHbM0YylectVQn0yV6+Mqt1+gW1XFnw0PNxAHRQhFYtHVgCuScuHxeBNgUcpQIxI
         TCmfFOiLavLzbu1LmyXN7wKzpDEQQ2c73psoNSX58h0kUoAMBaYPD+RZoxAExDXHOmjZ
         oiLYDsnbLXoHz8eKkJ6Q3RiYKU2f+ujNIv1Q208eTQ1DunrBz01g9G36k/licEb4gLjL
         EJpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z11si3391433qkz.141.2019.03.12.05.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 05:26:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6628759445;
	Tue, 12 Mar 2019 12:26:46 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 10A3A6684E;
	Tue, 12 Mar 2019 12:26:35 +0000 (UTC)
Date: Tue, 12 Mar 2019 20:26:33 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
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
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] userfaultfd/sysctl: introduce
 unprivileged_userfaultfd
Message-ID: <20190312122633.GE14108@xz-x1>
References: <20190311093701.15734-1-peterx@redhat.com>
 <20190311093701.15734-2-peterx@redhat.com>
 <20190312065830.GB9497@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190312065830.GB9497@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Mar 2019 12:26:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 08:58:30AM +0200, Mike Rapoport wrote:

[...]

> > +config USERFAULTFD_UNPRIVILEGED_DEFAULT
> > +        string "Default behavior for unprivileged userfault syscalls"
> > +        depends on USERFAULTFD
> > +        default "disabled"
> > +        help
> > +          Set this to "enabled" to allow userfaultfd syscalls from
> > +          unprivileged users.  Set this to "disabled" to forbid
> > +          userfaultfd syscalls from unprivileged users.  Set this to
> > +          "kvm" to forbid unpriviledged users but still allow users
> > +          who had enough permission to open /dev/kvm.
> 
> I'd phrase it a bit differently:
> 
> This option controls privilege level required to execute userfaultfd
                      ^
                      +---- add " the default"?

> system call.
> 
> Set this to "enabled" to allow userfaultfd system call from unprivileged
> users. 
> Set this to "disabled" to allow userfaultfd system call only for users who
> have ptrace capability.
> Set this to "kvm" to restrict userfaultfd system call usage to users with
                                                                      ^
                         add " who have ptrace capability, or" -------+

> permissions to open "/dev/kvm".

I think your version is better than mine, but I'd like to confirm
about above two extra changes before I squash them into the patch. :)

Thanks!

-- 
Peter Xu

