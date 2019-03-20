Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9988FC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:09:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4152C2175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:09:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="YIJXGBHE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4152C2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E32F76B0003; Tue, 19 Mar 2019 21:09:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB9616B0006; Tue, 19 Mar 2019 21:09:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C81B96B0007; Tue, 19 Mar 2019 21:09:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A41A76B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:09:40 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x58so815297qtc.1
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:09:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=2byeS3WCr+btrSUwYqnvKhC8fnHDpT8ZecHD+X/26GU=;
        b=B39n+Pp/Gxo6kSuHqVtVWfEtwflu3YcnHLgG2XIyzPUakFE4gbrumtIpk/v59nn7BM
         UPEQamdxsfuPik89k3Jz7TCQKbb7OEIbBx8UahuXPutwhAmhVtj9mDnLC4rA+3exQ91s
         MBxtaOtBN8K3DL1r11X6y+k6ejAonL8yBFA34pXaz1RfJ8S9Owd6NT/dYE/CikxWk/DL
         KfouhynY1ceKqdgWJidn9tnp9DvLlIprIVHRlZD5AZoUkAVjALeLAiALy7w6w1vTDWj9
         EpdhlXpdLTDNexbqGomUyTiS4lSjI6MsV1JyCEHpVwr1qDSqAdJR9zISEi+GADAx+qyH
         i16g==
X-Gm-Message-State: APjAAAVw83QvRaN3yVW43vidmhhctaytWhBY0tSnU0wpP1eVGpG0Ki10
	HUriTzvlkJktt8lPL2RMuHSRstVb0kgEwIxr9vDAzdhTK2ErrYUCyk5uOnqmiwOmyFwfH+N9Zmg
	xHP0ssm80rya1NGAsV1JGJ6J71buZ784oL29Fr+DcsNTbcr0rtb80Ka3AmldZdig=
X-Received: by 2002:a0c:9e2d:: with SMTP id p45mr4341234qve.28.1553044180407;
        Tue, 19 Mar 2019 18:09:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypwNabwVvf5L09HOw62pUjRrA3CRFVqLfgwkEBTYxmw6MSX8Ruow3GTbfz6znHrr57TvaK
X-Received: by 2002:a0c:9e2d:: with SMTP id p45mr4341189qve.28.1553044179558;
        Tue, 19 Mar 2019 18:09:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553044179; cv=none;
        d=google.com; s=arc-20160816;
        b=m5+yiAsOzNtUc88ZQlKCxD/tctywpekdWS8Nnng9noSSfm6yxltPs+rELeIJYa/nxn
         Wh3eHwAuYQ9808+6T+V5JcQBybeJC5Q/MKJF8SoXx6lGZyl1lI53BlusV1sn+VVdK0VH
         ltXGy5hoc3jEYWq5nW2vJwBlKqVqC+ppFdEPBlkAD6OGa1qmz0F5aRQQXNI4iRUKFSUE
         8CSOLPg55JJp2tkgt1rdcbmb5ntMkFyxomdpD5fHVVxHDB+iptZyS7O9xUdyQrE/F7ZB
         qPgtg1q+K412pNIiRrPfJLOqvL4HvadOSEc4TkrZcTQ8zv8erbUQVzMl3wNvNXoBln4e
         zlTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=2byeS3WCr+btrSUwYqnvKhC8fnHDpT8ZecHD+X/26GU=;
        b=AOszunUlq4W9A3qRcYskZ0CVnERHjNukp2RI7FX18pFjXxp5/XHfF+L+mcvDfuFeZb
         ewIO/MxyCRElA25izPImu8Snq92MxZXHQ4uZ1Lgw1DWsrZtXlX2bfZ6XNqfAIWSa7hlv
         jhM39nJ90+C+JiLOnAKteK/CO0jrZ44oHwT/Sjs12Y/I4r2qOzcgXTzx+NK7Ry6mAvve
         OHnrIIHPpDq+wpSuMmgHuKSA/oRYrY8hfZT18uFfIDHnCyugAA8r43E3/MV0Npd/Fm/w
         jEkKVCynLObwUYZZ24+LmtTQ0Lo1D5+bs1tiLf8uL6UHki+VU3aFwQErbPl/xEmpETdH
         o1Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=YIJXGBHE;
       spf=pass (google.com: domain of 0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@amazonses.com
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id t185si59655qkc.177.2019.03.19.18.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 18:09:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@amazonses.com designates 54.240.9.112 as permitted sender) client-ip=54.240.9.112;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=YIJXGBHE;
       spf=pass (google.com: domain of 0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553044179;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=2byeS3WCr+btrSUwYqnvKhC8fnHDpT8ZecHD+X/26GU=;
	b=YIJXGBHET20uNbnGy0egbHo5NK5RPHfpoU6AfPZ8VR/bYpninCGqgP5TH2S2ePwO
	ufNsxU89P74S/v2CgrI2CILsOLvA2lpgaBD241/1GXfOwWWYbH0WjTAe/46HZv8KGoS
	QVjhQNEuZqupqrQxvqeQM0YQxZ+TrbawGkH1sabQ=
Date: Wed, 20 Mar 2019 01:09:38 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: John Hubbard <jhubbard@nvidia.com>
cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v4 0/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <dc2499a6-4475-bea3-605a-7778ffcf76fc@nvidia.com>
Message-ID: <0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@email.amazonses.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com> <01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@email.amazonses.com> <dc2499a6-4475-bea3-605a-7778ffcf76fc@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.20-54.240.9.112
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Mar 2019, John Hubbard wrote:

> >
> > My concerns do not affect this patchset which just marks the get/put for
> > the pagecache. The problem was that the description was making claims that
> > were a bit misleading and seemed to prescribe a solution.
> >
> > So lets get this merged. Whatever the solution will be, we will need this
> > markup.
> >
>
> Sounds good. Do you care to promote that thought into a formal ACK for me? :)

Reviewed-by: Christoph Lameter <cl@linux.com>

