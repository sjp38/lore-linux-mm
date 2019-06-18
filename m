Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 443EAC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:37:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAFAB20873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:37:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Br9RdI5m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAFAB20873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 694748E0006; Mon, 17 Jun 2019 20:37:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 646888E0005; Mon, 17 Jun 2019 20:37:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E69F8E0006; Mon, 17 Jun 2019 20:37:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2192A8E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:37:01 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d62so10740257qke.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:37:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DUhdu87n/RcFK2o2RKT7Xn6jZQqeitWARb0DhK6/xFo=;
        b=DjwbE0Pz/H6gZ1bWGJ13SncglarQ71vXixt7kMZO26qipPajwk1LCRXc0R3VvKIB2p
         5yRFhvK8eSh/C++A3EtkVP/yqO3oX1aTR/8hm2Bxp9FJWlpB147+N0ckj7BwvsI6fuvl
         w4f5d7DAPu6RPlfQcw2S8DGDDR6UdiU5xW7ApFlz5Sj6llI/Oax+3YbRMJWFw5hMEf6N
         hZopzaa1ANm0KsB5gyk+bBH7ivxDeWC6W0zUy1bX6uOsk9BOoir5/SZ7MnPtP+B1fSYZ
         xXhwEo9Gla39QFlhpfuFMXyXYkO+V0diAphuKMHem6RE/FFQN50/OZQFd3XhWsPqST09
         Z6KQ==
X-Gm-Message-State: APjAAAVqO9o4mH9QobjH4eWi6dfucXSmkNuktov+e1aBcN44Ko9TYERz
	aExyUrzRZ6UAB2I8xaHIOviIWizrieEZtY8v2U1RgaiJ/foQtpt6k1+srx8OvbITzszCproUeRi
	pOmi089SXvh0MEb105XUHnxGkufQdQvLqWDF3jlCuryoQygLJEcU7C+Vg6cskrtKNfg==
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr96849752qtk.67.1560818220845;
        Mon, 17 Jun 2019 17:37:00 -0700 (PDT)
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr96849724qtk.67.1560818220170;
        Mon, 17 Jun 2019 17:37:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560818220; cv=none;
        d=google.com; s=arc-20160816;
        b=GMpzYnYNiVPqzdh7CVpIrcx2LRtFMM0MJPXwkhDbI69sxFN/hWLd3Xns5xuE/kFqLx
         JeLiHfC+fnzXkAAggTkDkJzFmKhJRTyRBhE64Rz39SgXTDST3tmQnIA2U+8StMqEOUne
         8XZDZNooFMcfjXvtpXggRb648guiEZyaMeYBbzizCHA9eVZ7LxrakBenyd96/OSqnQBe
         xsYOXOX638C89lbJAXlNs6kiCWhfXDi2Fiv3JXoLKSNni+PkSTPPg8hp1s1c+2zz3C4h
         5X054uze1tMxQ/UZmRqeOf8zquY1+0aXbD+OmlttsqE9/7xCvUBli7HLE9GjYYKxAe1O
         507Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DUhdu87n/RcFK2o2RKT7Xn6jZQqeitWARb0DhK6/xFo=;
        b=CdBQsxLdwNBrLZByyJlCA4NngKWb5v0W3WrMLBQhfZSmxApk9Vyo+XpGjYlivDqKIk
         prJUgxmlzDkXqreJh0D/PE4HoMvCtrPRXgQOd31TxB3dSNmLnd0azZ/XAxQWZx9AqEdf
         zcj3HrH//bpDo5TioVxw0wQsAEwOZOLukfdxqtL/LmxwE6YNl0wTh1JM/LFye/t0t/EU
         L5SPbBcRnChldJBQVJTGlqLdWe5NxA3NKLFgCxjv+O7loxmhr/kmeUA2+xkzo/k6wqDR
         TuxxOXAxebovJDa8+adGZ2KYIsuwzFLVlMtbkcF9Rbi5u9Tl/uluHtjQNdHWNyiL7Stb
         W29Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Br9RdI5m;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x12sor10794984qvc.50.2019.06.17.17.37.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 17:37:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Br9RdI5m;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DUhdu87n/RcFK2o2RKT7Xn6jZQqeitWARb0DhK6/xFo=;
        b=Br9RdI5mPQREEmkYKTbqml22ch68dceGzZJ3NpqNGWnyOqMXHH3Vp3I8RbvWN+0dGG
         +g1j7rLYevDrJD9u1C3ny612FtpBO3tbIePe350M5ElOwdk4pjJA8/R330jcc3+vtYpn
         17S07MU/B/lrrFpSdr2NFsNSFXPEIP46dFGaUq3K6P/Gztn1b6znTuHTRL9kMCjl+OsE
         E/SXSnxqH8z94kWuui++s5M1RdL+/flIEAt9fmVVYofcAVK2jbveGcEm8QPiuUNVzG1y
         spSh4cwLvofbfJDRrinF0oVrVOFf22UKWIYy7Uyrxgd7cZ/rnvEbnjdjRkZxGdQjLAWX
         AxQw==
X-Google-Smtp-Source: APXvYqwNKmMPGfd11Aoys/ex+FCBBx8y28tJjyO+G3ezjcr0a4wUE2AKBOFyQh6LE7vtVp6hp3BWOw==
X-Received: by 2002:a0c:89a5:: with SMTP id 34mr4976222qvr.110.1560818219783;
        Mon, 17 Jun 2019 17:36:59 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 41sm9704086qtp.32.2019.06.17.17.36.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 17:36:59 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hd27O-0000jS-MT; Mon, 17 Jun 2019 21:36:58 -0300
Date: Mon, 17 Jun 2019 21:36:58 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 04/12] mm/hmm: Simplify hmm_get_or_create and make
 it reliable
Message-ID: <20190618003658.GC30762@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-5-jgg@ziepe.ca>
 <20190615141211.GD17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615141211.GD17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 07:12:11AM -0700, Christoph Hellwig wrote:
> > +	spin_lock(&mm->page_table_lock);
> > +	if (mm->hmm) {
> > +		if (kref_get_unless_zero(&mm->hmm->kref)) {
> > +			spin_unlock(&mm->page_table_lock);
> > +			return mm->hmm;
> > +		}
> > +	}
> > +	spin_unlock(&mm->page_table_lock);
> 
> This could become:
> 
> 	spin_lock(&mm->page_table_lock);
> 	hmm = mm->hmm
> 	if (hmm && kref_get_unless_zero(&hmm->kref))
> 		goto out_unlock;
> 	spin_unlock(&mm->page_table_lock);
> 
> as the last two lines of the function already drop the page_table_lock
> and then return hmm.  Or drop the "hmm = mm->hmm" asignment above and
> return mm->hmm as that should be always identical to hmm at the end
> to save another line.

Yeah, I can fuss it some more.

> > +	/*
> > +	 * The mm->hmm pointer is kept valid while notifier ops can be running
> > +	 * so they don't have to deal with a NULL mm->hmm value
> > +	 */
> 
> The comment confuses me.  How does the page_table_lock relate to
> possibly running notifiers, as I can't find that we take
> page_table_lock?  Or is it just about the fact that we only clear
> mm->hmm in the free callback, and not in hmm_free?

It was late when I wrote this fixup, the comment is faulty, and there
is no reason to delay this until the SRCU cleanup at this point in the
series.

The ops all get their struct hmm from container_of, the only thing
that refers to mm->hmm is hmm_get_or_create().

I'll revise it tomorrow, the comment will go away and the =NULL will
go to the release callback

Jason

