Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74470C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:37:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FCB220C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 13:37:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FCB220C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE5F76B0006; Tue,  6 Aug 2019 09:37:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A97F66B0007; Tue,  6 Aug 2019 09:37:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ACE76B0008; Tue,  6 Aug 2019 09:37:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9116B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 09:37:07 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e22so13221228qtp.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 06:37:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=+EmwYezlru/6l1RGke6OfmjMerhgmwmHntHPbq6+2AE=;
        b=Tj40dNRlLPBkoZd6eK/AzLM/hyv26a5uGg9zb7hkRlYCBwstexnbHnCx9uoqKX6td1
         zgXvqR/29C+CR9fMyFzZi3eHIsduCMkSJeGNx/XMm2Z18gCbQ8beXjSI+aOZD0FrhT6N
         m8B+jHskHG1nlgTb8bW7ZLj2Qw+mj5EqsETfyH35BiVyOpn2ljL3uisBaerLijGY7bHn
         mJWFfo9qh/A5zLkajqE73iaBLFhrWgicfKybEeLrWAHBywgTeRa5l+GgiDSQXaNNdRAU
         v7jCmLkFj8P3lc66oQy9DQIxLij3kEPdLjV+MHhwxV4i0y8X3m8tC7nOGx2yt6lKInts
         NpOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhNBo+zQ099XHGbUJQrYi+PEkGDRChZPQVSpIG0zAZTEWLP4e6
	MEwSh82vVhDEHFfpn75ng0tTz90VAyj4y70LcMIfiDHJ3yBlVejDgjs7pqkFxMPcLjRoVFCvUk5
	j591n2hvPW6ImMnTZQL4qbCUXZp4nO29ZjgeaGB1B/JnqeyNfHKtK6DgS8dyP8J3OPg==
X-Received: by 2002:a0c:f78d:: with SMTP id s13mr2927231qvn.156.1565098627296;
        Tue, 06 Aug 2019 06:37:07 -0700 (PDT)
X-Received: by 2002:a0c:f78d:: with SMTP id s13mr2927187qvn.156.1565098626690;
        Tue, 06 Aug 2019 06:37:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565098626; cv=none;
        d=google.com; s=arc-20160816;
        b=B1Jt4GmOT0W9yVYothchQfQyzBjZrV+pWwlvJZSD8ZBucAVwfnbLnBuMQ/sPEMYzjC
         PT0uVYrja1bW0WGIy+bg5/Vu65azqEVb7OVSsExjsVbTMzOjg4W7ELhdWyzdCxDnJbKE
         0wMd6VPSsjx/V+Y2eMRDN52aXpj7rpTp2nIfWxl++GBbJiUYNq7rFYWVyy7yJEwHynkx
         ew2MfSMmVipOQw5JwFAWD6czTrL7maUnmWEie5MddeVeIeylpde4XrDSYJgc0WDfE9ir
         l1d9axnCLLcz8UDlj6urEA+39dfn4z4GeO7ECyAeKVfe7AXnWzWxjQ/EAD0KXLIH9vta
         dSsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=+EmwYezlru/6l1RGke6OfmjMerhgmwmHntHPbq6+2AE=;
        b=NG/ttjnKCwCB7/gq79CJbCONHEf2rJgjB52oCLShUr36ibxDxNBku29ZuAw5SBp1n+
         2i8jDBvOGtYHG+gBfORU9iKzrr+ulKrXQWkm8G/zR7zpGR9J+eUHyJ0ur+x5QrU8vLzY
         zeCIdAFmiPZO/RZhbUj9J+q8JTq2xjyjBn1LNR0s4vK+hPdPH6jeiU3rWSsO2KtKElG2
         FMBsxYNKPgFaVk+Hd6nVGf2mNExSuH84hzD4DfF7d7atsl3cJWNKJHJ6b2KtA82TyJBx
         y0E/7WpExAFk/WMFGQpjYXYz0mp3v7YkuMXgWMn2oEdZT6btjw+HYPCgT6fjAGRKUWdh
         NHvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u62sor47142418qkf.94.2019.08.06.06.37.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 06:37:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwQogResfBtEcBuAcFTuCtTWGzeNFF/0eeIOxkxJPkA8JpnI8WBDTcUIzFbb3AvBDILVnFfYQ==
X-Received: by 2002:ae9:efc6:: with SMTP id d189mr2946499qkg.323.1565098625407;
        Tue, 06 Aug 2019 06:37:05 -0700 (PDT)
Received: from redhat.com ([147.234.38.1])
        by smtp.gmail.com with ESMTPSA id q73sm24068906qke.90.2019.08.06.06.37.01
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 06:37:04 -0700 (PDT)
Date: Tue, 6 Aug 2019 09:36:58 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190806093633-mutt-send-email-mst@kernel.org>
References: <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <20190802172418.GB11245@ziepe.ca>
 <20190803172944-mutt-send-email-mst@kernel.org>
 <20190804001400.GA25543@ziepe.ca>
 <20190804040034-mutt-send-email-mst@kernel.org>
 <20190806115317.GA11627@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806115317.GA11627@ziepe.ca>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:53:17AM -0300, Jason Gunthorpe wrote:
> On Sun, Aug 04, 2019 at 04:07:17AM -0400, Michael S. Tsirkin wrote:
> > > > > Also, why can't this just permanently GUP the pages? In fact, where
> > > > > does it put_page them anyhow? Worrying that 7f466 adds a get_user page
> > > > > but does not add a put_page??
> > > 
> > > You didn't answer this.. Why not just use GUP?
> > > 
> > > Jason
> > 
> > Sorry I misunderstood the question. Permanent GUP breaks lots of
> > functionality we need such as THP and numa balancing.
> 
> Really? It doesn't look like that many pages are involved..
> 
> Jason

Yea. But they just might happen to be heavily accessed ones....

-- 
MST

