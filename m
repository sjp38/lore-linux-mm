Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 679DDC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:55:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 251CC2082F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:55:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="INsI1v2h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 251CC2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C61A38E0003; Tue, 12 Feb 2019 11:55:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C12558E0001; Tue, 12 Feb 2019 11:55:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B27288E0003; Tue, 12 Feb 2019 11:55:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8418E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:55:22 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q17so3262730qta.17
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:55:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=u5yVrmcqLQyUPSMbbYCxR9JAtuOplVrqP6Ol1t45LIw=;
        b=UcX5856q0UJ557S7CSQBgJdRs0UuuEedS7RJ2Fi8iuZP7R3F8Z/3Q2yaNqNpkZZSgF
         5ji3lVV0SZO8CB2u/X1N4Tq2fSsobLVcdEovIMkWgubhw/4rEdFnYhH+is89wOegYDVL
         QWNjcBCzrZfBodvFogzIzdrXOrNTVRZX8qmT5qkzRjZVgt+cqg4M/bliWnj/wyj3WCVf
         VvRFqCLY4/KFLNgp1AuDJmjGp0fRsVFOrZLs7wMDWJIkXlWNzNO9mn/Id2FXgMq+DUoc
         v8B91idQq8Xz2AtniWZOafkrIqjXuMjS/8Nv3J07cqhwVrhSuyKRE5N6hDK7jj/jaRCF
         hLZw==
X-Gm-Message-State: AHQUAuZcKpiyHRZyU/K4Ayk9wUqjgD1Er7GzChkMenLfr9eymx7u2UGr
	0GEanZyiBf1YohKqFflcLZ8qE/T88e6xROpMLUenU8nrNSgVotSzF2qlBGaG9F+t+B3MjU139tZ
	WuSmZWIDDj3FDDXnWH3i8UTVBasyLW23GePZNLtABS46ry687C/TcdT06lGGp0Js=
X-Received: by 2002:a37:6e43:: with SMTP id j64mr3144314qkc.278.1549990522339;
        Tue, 12 Feb 2019 08:55:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbdfxglUXphA1KDOrqaWNW57X/TFMqlX3TxxxuQ4pFeZlW6ruw6SSOVcX+Dx+iqthdJVf4r
X-Received: by 2002:a37:6e43:: with SMTP id j64mr3144284qkc.278.1549990521640;
        Tue, 12 Feb 2019 08:55:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990521; cv=none;
        d=google.com; s=arc-20160816;
        b=fxAmbfCkP7DHWZ5JKQLxV9+ww2VQy0kJuEb53tDnqB9g75AmsTrgVq3CSwVfz3C7RX
         /dH+dJIqJMmhucUdj4OmMrX8kXmI9F2S6KcRoms2ER8mzaE3PveIMRirMql8aIzIZjwQ
         bfKR1W1jDMbdGmR8zxmHNOpQTc3I+xGQZ+U3Is58CkfqslxUTYMN7SqiCbgpjb8wPnrf
         gniEK0g0YWuolR0sxv0gfR+UT8HNwt1+tfZswSklUB6UkyiQA+uYnixKjgcbfP+y5PoX
         aguT8DYC2ZTqyBBvGiQ2CpoHvaXLXkFcW6cnBABx8u4V2U9CD5YVQf5cDeWBeNTaYBSz
         NViA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=u5yVrmcqLQyUPSMbbYCxR9JAtuOplVrqP6Ol1t45LIw=;
        b=ZxpbDB4TgWCP0QX51w3NkCY+bQW/FRWPXSQFJMI+aeIyeqkfX027c1Ui/wQ7gKaMfY
         iqN7trpjqMfwn6ThIg6Qa1AqbA35n0Hn3eAmazmJn97WTkAQFcmXRXHABkURXn0GAGVE
         /a4wWOLksir7aq6zRQCW/YSWJBdY08I4UBi5fMM5EBQxryUJ839FBB58EqG9W4WZz7S9
         POQbxsKzPhzBCGvg67nhYhPwI6zyAQeapr0+95SmsE4pqJSJUzdxwNEokEwmEF3syz7U
         tofZHXZHZtDv/0aZYRPIhOVNHoLlqbUy7JO3GO5BrCfTaX5KH6MGbp5ng5OB+d543JPe
         XSGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=INsI1v2h;
       spf=pass (google.com: domain of 01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@amazonses.com
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id o93si4446111qte.276.2019.02.12.08.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Feb 2019 08:55:21 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@amazonses.com designates 54.240.9.114 as permitted sender) client-ip=54.240.9.114;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=INsI1v2h;
       spf=pass (google.com: domain of 01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549990521;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=u5yVrmcqLQyUPSMbbYCxR9JAtuOplVrqP6Ol1t45LIw=;
	b=INsI1v2hT/d5BvFY22/rKInWGEM2LiJkNygvZpkBu6ryWwFKRqJgI4wiS4zAJvBQ
	pxoemWBqjEnQ9ioE+c19sSEi5BeZDpwlK6at4cUE8PHAEONO79kt2g9H0sQ3O9WvTyP
	YQuOEbq5MeRa1glMsh/ceEMpmDICdDL7CngAipak=
Date: Tue, 12 Feb 2019 16:55:21 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Jan Kara <jack@suse.cz>
cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, 
    Matthew Wilcox <willy@infradead.org>, Ira Weiny <ira.weiny@intel.com>, 
    Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>, 
    lsf-pc@lists.linux-foundation.org, linux-rdma <linux-rdma@vger.kernel.org>, 
    Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190212163433.GD19076@quack2.suse.cz>
Message-ID: <01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@email.amazonses.com>
References: <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com> <20190211180654.GB24692@ziepe.ca> <20190211181921.GA5526@iweiny-DESK2.sc.intel.com> <20190211182649.GD24692@ziepe.ca>
 <20190211184040.GF12668@bombadil.infradead.org> <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com> <20190211204945.GF24692@ziepe.ca> <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com> <20190211210956.GG24692@ziepe.ca>
 <20190212163433.GD19076@quack2.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.12-54.240.9.114
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019, Jan Kara wrote:

> > Isn't that already racy? If the mmap user is fast enough can't it
> > prevent the page from becoming freed in the first place today?
>
> No, it cannot. We block page faulting for the file (via a lock), tear down
> page tables, free pages and blocks. Then we resume faults and return
> SIGBUS (if the page ends up being after the new end of file in case of
> truncate) or do new page fault and fresh block allocation (which can end
> with SIGBUS if the filesystem cannot allocate new block to back the page).

Well that is already pretty inconsistent behavior. Under what conditions
is the SIGBUS occurring without the new fault attempt?

If a new fault is attempted then we have resource constraints that could
have caused a SIGBUS independently of the truncate. So that case is not
really something special to be considered for truncation.

So the only concern left is to figure out under what conditions SIGBUS
occurs with a racing truncate (if at all) if there are sufficient
resources to complete the page fault.


