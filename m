Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89F1AC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:23:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 510A720882
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:23:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 510A720882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEDC86B0003; Fri, 10 May 2019 12:23:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D76BA6B0005; Fri, 10 May 2019 12:23:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3EFB6B0006; Fri, 10 May 2019 12:23:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB516B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:23:28 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n21so6721364qtp.15
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:23:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :from:in-reply-to:references:to:cc:subject:mime-version:content-id
         :date:message-id;
        bh=0V6ssH/ZsWY6BA9FaRBVW8yCxaXZ0hWMnRzrL8jpJ9k=;
        b=Z+wFdRLW7N7pYcINNMWRIcY/RTwC9aJMwCS9Bgl90B2GsPrA1UbuSscOixxVC6MG/w
         4nTj/amuRCyLW6cq6uTlGrjH5BIitEp3tqqfL5Fnt8ta0UGSKrei7h1BOzDn18M08wmb
         lsk2ElQxMtAMratYT4VoeKoDZpLY9Sy6zqCbZE3AN9lv1Qx/aYQA+6ShrdjOBglP52eS
         P/3F0idVgtki0lBwDH551LcZAiKvc/2KKzv4wVim11pFZQdaL7twDWQ1HYRjPuFjATmU
         DfJED5pD1EA00P13vGwfdn8YZpDBg/G8ThpL9Uj8RMVdNcoWWBxK6xq1f21SQKt7kxKu
         r39g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWckZDkVSW8EnhHXpHHVASsnlwBvXoqRSY0vJ29WKWbf9juvG7o
	vGBEI0xzV+UEuTv6uapTHGk17iEsTUXaNPlhARunsnoBJpGT4zVtWU7bGz98H68gHrAWf6kiLYc
	DlG1VrcrMq+5o6rs9Wxe6ZcRNkrIYN0IRRxbPSuUP/S0RwHhxZ+ysdYqBvMNjugfGaA==
X-Received: by 2002:a0c:e583:: with SMTP id t3mr9997559qvm.74.1557505408434;
        Fri, 10 May 2019 09:23:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsC0FpzLjaKYPZLVj5dB5J5erMpO3ZdZ3UeEmtIqTg69/nCnYiNg8gR4rkrfMrcXJgGveZ
X-Received: by 2002:a0c:e583:: with SMTP id t3mr9997522qvm.74.1557505407870;
        Fri, 10 May 2019 09:23:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557505407; cv=none;
        d=google.com; s=arc-20160816;
        b=GcKw+Ektx8TlZRONKpbfv1e3E/bY7q9uFsXLuX7Qn3STQ7AG9Faclp1i9K9mBbVTHU
         iIZl5es3VXf9l+x8Rcb9+UzFnTHFM256u4GFLanF444rLXsOyCAJteBaxbOpgEJrYMnS
         VcWjRnr1GbrFbOKGCbcPC09ucO7LneMgjzzcNOA9a4jF+ElS3l720nVOE7ZCoDG6mAZU
         LSwe0RNeva24GLzK2zV3S1Q1MRs2hqlF7Tztx3Roc+l+vLYAgQXVnSI9kvdJUeo18ohM
         3Af6Oel+5oT7aPp5XvMGy8bNGhu3QIKt1KwdzDUClnczFEb2oyr0JiwvYOMh1OhcAc0b
         vb0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-id:mime-version:subject:cc:to:references
         :in-reply-to:from:organization;
        bh=0V6ssH/ZsWY6BA9FaRBVW8yCxaXZ0hWMnRzrL8jpJ9k=;
        b=tm6xK1x8SvLaadFgqfmE9igDUhMJOumAdclHz0kW+P3R5pTK3fDh/0njemV60xRrSG
         5ELbcwPWjU8VBhOP98NGNoUE1wu1Fhya529Q2HVxIzdPlRNQnRxvn9snoIojPvmgDAsv
         ypCZF9TMcs58KEVbZLDEhJjzdNXMS7dkMFqAaJLVjKx10uTWRDKbZaissIXOF2tuT0+s
         SuTCEFxeMW7p+ROjoJYk22XlOu4zt5VkbTECs+z7NJ64OT7AQ9amNY+jXcnZPJPKsR/y
         sAN62FhBrJLApmHfVJApw2242G2GmE8rPYXoaHoqzAPvOww8qM16wd4PoWA5mLB2Ek4/
         OKDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si847095qvd.18.2019.05.10.09.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 09:23:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 31B92309264F;
	Fri, 10 May 2019 16:23:27 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-120-61.rdu2.redhat.com [10.10.120.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 274125ED33;
	Fri, 10 May 2019 16:23:23 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20190510135031.1e8908fd@carbon>
References: <20190510135031.1e8908fd@carbon> <14647.1557415738@warthog.procyon.org.uk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: dhowells@redhat.com, Christoph Lameter <cl@linux.com>,
    Andrew Morton <akpm@linux-foundation.org>,
    linux-mm <linux-mm@kvack.org>
Subject: Re: Bulk kmalloc
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3260.1557505403.1@warthog.procyon.org.uk>
Date: Fri, 10 May 2019 17:23:23 +0100
Message-ID: <3261.1557505403@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 10 May 2019 16:23:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > Is it possible to use kmem_cache_alloc_bulk() with kmalloc slabs to
> > effect a bulk kmalloc?
> 
> Well, we have kfree_bulk() which is a simple wrapper around
> kmem_cache_free_bulk() (as Christoph make me handle that case).
> 
> We/I didn't code the kmalloc_bulk() variant.
> 
> What is you use case?

afs_do_lookup() allocates an array of file status records and an array of
callback records:

	/* Need space for examining all the selected files */
	inode = ERR_PTR(-ENOMEM);
	cookie->statuses = kcalloc(cookie->nr_fids, sizeof(struct afs_file_status),
				   GFP_KERNEL);
	if (!cookie->statuses)
		goto out;

	cookie->callbacks = kcalloc(cookie->nr_fids, sizeof(struct afs_callback),
				    GFP_KERNEL);
	if (!cookie->callbacks)
		goto out_s;

These, however, may go to order-1 allocations or higher if nr_fids > 39, say,
and it may be as many as 50 for AFS3 or 1024 for YFS.

Also, I'd like to combine the afs_file_status record with the afs_callback
record inside another struct so that I can pass these around in more places
and fix the locking over applying them to the relevant inodes.

So what I want to do is to allocate an array of pointers to {status,callback}
records and then bulk allocate those records.  As it happens, the tuple is
just shy of 128 bytes, so they should fit into that slab very nicely.

Note also that the records are transient - they're freed at the end of the
operation.

David

