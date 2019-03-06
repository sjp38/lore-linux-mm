Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 189D3C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:51:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBD1D20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:51:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cm5cI6YW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBD1D20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 565FB8E0003; Tue,  5 Mar 2019 20:51:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 514F18E0001; Tue,  5 Mar 2019 20:51:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DC938E0003; Tue,  5 Mar 2019 20:51:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15A568E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 20:51:27 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k37so10107082qtb.20
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 17:51:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v6MB5vJdZeiiHNLIrZXL/NLvLcz3ucN8qXhApNV7Iiw=;
        b=YmUKiR8v6cgakwmW5t4V1J3w4u8EIucd1wtk//17IDOpzU/vHOtD3/NJQuJstESfif
         /2fZ8Z2rIXLrmc8FY0YaNB3XEBS3nsxg10SAHgEuQcBAXwUAd4e0A1wk+jO24IgAkck5
         Kj0FcuzLnd+anVpHiC4LFr76DYpCRsPKQmqkzDeSKxgLz1Hv+ztVahmP+kJ+g/THJ9zS
         pvthVQpA48ucK+x66B0KswATcE+b6c3qCz6d4oCyoAnwGu84jDgzd2K00FJS78YyV8xR
         PeQAROHL4r35UAxkQhNI+D2PiAzNqiBP3kxNOZ0hVqj4u6g1e6L4KzsUZ41tcBt4vUG0
         FRHg==
X-Gm-Message-State: APjAAAWI6WMQQ5F2jUVhGV1R81jc0Q2tqs4xsrQRNkDjWZeODZhIR6Cr
	xHW6/IRQdxHg92bkOro2+RNTEE9C1XHJlj0G8a3m/e5kbeWuO9m6PntS1LvmNJ/sH+lgQoZ3SwC
	MvwzmFGJCcS5dtlMBXiFI7y8GbY5GjYlC0DuT0tXVEJTqrd3pHp5Mv42tZBNaygvNbDXwcr8nJB
	22+73jpJpyLtL/syQn60V7Id5CSbepehBeTUinrqlXh6hs4N/2KZWGdIKjvau/7NasUkM/u9EB2
	rd+YLzqCNs7frolh7tOl2jTak/vlQcc7HfRarW3zKrMezAZtLTtzR8hDMW2u7s2wqJzQSNXNcAn
	GRbiEklKo3b3bQd0CxVVLuoD6Wx8bSxVcu1t/YpW5nFv+mej69E3wGBniHqLEbFGO7dOJsLoSUe
	i
X-Received: by 2002:ac8:2782:: with SMTP id w2mr3705783qtw.8.1551837086792;
        Tue, 05 Mar 2019 17:51:26 -0800 (PST)
X-Received: by 2002:ac8:2782:: with SMTP id w2mr3705765qtw.8.1551837086083;
        Tue, 05 Mar 2019 17:51:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551837086; cv=none;
        d=google.com; s=arc-20160816;
        b=DmE3bqK7cny/so5ZQXcvCfKsXDkAZ5Tq8Iejl39d3dA6FLrNtbxIdrFxDmwGEF5tiN
         1ywT1W1353RPMUADeIf/i5//17PNZFYAp5cSwK8TC/+zCHH8LeXq8iRsd4QP/z1ansiR
         bFNMV4OBhNzV7cFcHjo98PX3zPu/sEv8Bkf2iz6h/zAbHi64KQ6S7IihogpTvGtje2+Z
         yFLi69bTLLWmfrwK5p5mn6ydhz8arju/fqXKnlXmmwDJpO8gonHoLlor+CeU3nAG3MyO
         GOl0xhhJ6aeQ8EZfSSvdY+qJO9p8UPhDXVPGtzuaP0YcHuIUbd+0+96ETTIIanNHs/Uo
         1liQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v6MB5vJdZeiiHNLIrZXL/NLvLcz3ucN8qXhApNV7Iiw=;
        b=XkfDr63J0ig5xbBkXgOkmwSqo3FFLss9JJAddCMEwQZAxWGu293RT4GJqEkJWBuDmu
         y3B8K/GopWBMOJdIw/JkjCTAOtzqyg/nspF4DirfXvj7IxEbTF8TCPjwGx9+pPCkJ4Tg
         JbhBlDJmdJwiB2lgNXaqW8PWncBtSIVx5lIu1b11x4AAkJF/Sso0qGm2RE5WnMavnEuf
         ctNGBlhQQqEN8mo6klrRK3CHU0tvVM5wPYsUFgw8UlVw5GrYVd7NTapHzhf1wESKlVix
         Ny4fK3e2w8EdJi2nBnCaiyrsS1HQbgKhX4toSHTo1xVJzO9o63pDhqRIyJ2BEowabKEN
         0+DA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cm5cI6YW;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8sor157811qkl.128.2019.03.05.17.51.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 17:51:26 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cm5cI6YW;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=v6MB5vJdZeiiHNLIrZXL/NLvLcz3ucN8qXhApNV7Iiw=;
        b=cm5cI6YWkf7V25AX5Q095XofnBZM83Z799SR5Hj0xpHNemxsMbBYK1igTraRwwZiS0
         TKYkfSF9DxdrFVctI+T17j6+ch0QnRioMl/BB5aLn0BYxSd3fclhE1PzwI3E05UtwAgs
         bPrLwcZyF9WXp+Dmbc11iEHJUjs8UGi4B84prphbaglRGQyQkmeqU4jOtFOywmtsR/2F
         bGafNzjRVvb7Po3uLZssuOLwrOgI4siaIZO13QA6mk+7wiAqrOmQZVc2W7bD2mGlIr+U
         2T0CayC8nf1s2D+3e1SWLrgwrC55xcuciVWqghj2zIOp37dbida4iH7HIqpDOkc67vhs
         GnmQ==
X-Google-Smtp-Source: APXvYqznGQheXDfcxLaQ+k6XFcHgn8YhhBKGfvoBKRHdUuorNpm74Waut7EbJuCKvjrwi+QWbKUEnA==
X-Received: by 2002:a37:a42:: with SMTP id 63mr3997954qkk.269.1551837085787;
        Tue, 05 Mar 2019 17:51:25 -0800 (PST)
Received: from ziepe.ca ([24.137.65.181])
        by smtp.gmail.com with ESMTPSA id z140sm156227qka.81.2019.03.05.17.51.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Mar 2019 17:51:25 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h1LiN-0002Ag-QC; Tue, 05 Mar 2019 21:51:23 -0400
Date: Tue, 5 Mar 2019 21:51:23 -0400
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error
 handling paths
Message-ID: <20190306015123.GB1662@ziepe.ca>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
 <903383a6-f2c9-4a69-83c0-9be9c052d4be@mellanox.com>
 <20190306013213.GA1662@ziepe.ca>
 <74f196a1-bd27-2e94-2f9f-0cf657eb0c91@nvidia.com>
 <be6303c6-d8d2-483a-5271-b6707c21178e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be6303c6-d8d2-483a-5271-b6707c21178e@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 05, 2019 at 05:37:18PM -0800, John Hubbard wrote:
> On 3/5/19 5:34 PM, John Hubbard wrote:
> [snip]
> >>> So release_pages(&local_page_list[j+1], npages - j-1) would be correct.
> >>
> >> Someone send a fixup patch please...
> >>
> >> Jason
> > 
> > Yeah, I'm on it. Just need to double-check that this is the case. But Jason,
> > you're confirming it already, so that helps too.

I didn't look, just assuming Artemy is right since he knows this
code..

> > Patch coming shortly.
> > 
> 
> Jason, btw, do you prefer a patch that fixes the previous one, or a new 
> patch that stands alone? (I'm not sure how this tree is maintained, exactly.)

It has past the point when I should apply a fixup, rdma is general has
about an approximately 1 day period after the 'thanks applied' message
where rebase is possible

Otherwise the tree is strictly no rebase

Jason

