Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90D4DC04E87
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:41:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 438D02087B
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:41:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ajxoLS7u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 438D02087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6B896B0005; Thu, 16 May 2019 03:41:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1D626B0006; Thu, 16 May 2019 03:41:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0C3C6B0007; Thu, 16 May 2019 03:41:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BADF6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 03:41:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d12so1662225pfn.9
        for <linux-mm@kvack.org>; Thu, 16 May 2019 00:41:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YxyX6cGFHGzUuS+MPekODxndLWwuptJrstJIadn93Cw=;
        b=a2l0i7S7nQ3Xc+UK1/+WPqnMADmJLzzTPiwHtDumYUDxEoZImnIQ+Wa+hOFb1EO1U2
         oUVsoqVLs5kEmE0ljcGqaWKusyav+aArxkGT0uUyi6rg+GXW7E1vGZeqjSLP1NJY4M6z
         sBWkwwJhHKXgjhEldFjXYIMb7jo2o1SMa1fIypL7fDnRUchGN4fi80TK9mcG0vownemx
         e//V5BNT4pKtsmlsCmmcCY+EmgMswci2IJ6Cui+kO4VVcDdZlPWDhE6GTITJydQp/tnC
         opKRVbirqB3R+zJCfMtyxkmVhvEuYr8ja1pW/vTC9spnBbEfejiebfTbH0irXA8ZeeMo
         heDA==
X-Gm-Message-State: APjAAAVTts293ZT49qxXqJzPC+HZVegeqmHqcY4B90C4cVZT48CmxzDj
	HNruQEEd4bnXKtHcRg0IcaCS8ESMkXjxOtPfP7KpRtwa1H3/vJC4dAoCrj5XEzWQbx+7hE775Am
	YTn/ActwVvT3xchtvegF/esy9M2l4JRMRT6AqsXUXbZTitFfkgb0J2iKO5qicWpL99Q==
X-Received: by 2002:a62:d044:: with SMTP id p65mr32639883pfg.37.1557992512914;
        Thu, 16 May 2019 00:41:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHeXImY/i4OuA1CA0SJX4Mw31qr9HYDGR/Jzg+djYCkPS5KjbHE1Br676iEeQQBkYFaaCC
X-Received: by 2002:a62:d044:: with SMTP id p65mr32639826pfg.37.1557992512141;
        Thu, 16 May 2019 00:41:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557992512; cv=none;
        d=google.com; s=arc-20160816;
        b=ZL537KgwLTLcUCFJglvIeBeFPugOCkTEdzAYNgWMXwDCOJUGqLZf1US4n1r4CQt215
         x0s0Rlb5WYH07Dj9S54rlFiJ5cUsfC8ome+o1G8qqQTYnc3IXLpA0TpMQSQsaurECG0q
         zEhtkjCny/TxjvUgoTb79PlU3bkyoZLWAaDb3KAsUmpLtElXW0sX8Uomc9vuEFnAx7b+
         7qL+Twmkg+0xIY5LdpNWiRtOQXUNtXzhPh+Jcs0II93mc6DZVEnT+3BtsdYr5M/eYMDv
         jLRq1lN1ZKseQ7d9t1fU2qv0z2vxT4fZWaEVEIkQBcqpXIlipvzme30McD1/cMmxhab6
         /YCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YxyX6cGFHGzUuS+MPekODxndLWwuptJrstJIadn93Cw=;
        b=mMzY6v/n2gaSyOS+9ZBKcNj8xVOrJ1pcWOKD3QmJshqjX2T7/hO9woPfZJ4cwi4hbY
         +VIBV0FvVKgg95a8x+U2W2AYp50lOM1ZzeTT0pJam9NcJH4pyhHY5fzdiYKujc/GzXBn
         q5RCWYAZuuW8IVv5G90swCNurdLBv9teIbG6fw4Xvf1bBIPGwb07Y/KLWirqkyHANYtG
         EaYXcIwubkvjZuDxDAHWTnO1KAfmgo/QJCB3ebZPRYyazAz0/jGpkR7BYCX5gaOtVP2j
         5BX4lBKxqBR2KyMGY3cLDSyHZ6A6LgCJ39/DT1r1oluhchJ1Hf7sadjCdiuI3C560nwD
         BynA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ajxoLS7u;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e34si4359532pge.252.2019.05.16.00.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 00:41:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ajxoLS7u;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [193.47.165.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2852220862;
	Thu, 16 May 2019 07:41:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557992511;
	bh=YxyX6cGFHGzUuS+MPekODxndLWwuptJrstJIadn93Cw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ajxoLS7uh1rWobeFTo2ZiS03AbFavD9ncUtOH+zdyqFe5p7LaaNfV/Ks6syk/dl7d
	 wtaWmqleS0+KHqYQUCGsL/w+EZx3zgGGyVCQQrIQ5QIJs6lLuHEea8pw/Ta+RJdNmu
	 h1ovR2ukDmDKhxuid31DamzwvAa+Ec7+WWYwFMnc=
Date: Thu, 16 May 2019 10:41:48 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Kamal Heib <kheib@redhat.com>
Cc: Yuval Shaia <yuval.shaia@oracle.com>,
	RDMA mailing list <linux-rdma@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	Marcel Apfelbaum <marcel.apfelbaum@gmail.com>
Subject: Re: CFP: 4th RDMA Mini-Summit at LPC 2019
Message-ID: <20190516074148.GV5225@mtr-leonro.mtl.com>
References: <20190514122321.GH6425@mtr-leonro.mtl.com>
 <20190515153050.GB2356@lap1>
 <20190515163626.GO5225@mtr-leonro.mtl.com>
 <20190515181537.GA5720@lap1>
 <df639315-e13c-9a20-caf5-a66b009a8aa1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df639315-e13c-9a20-caf5-a66b009a8aa1@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 10:08:32AM +0300, Kamal Heib wrote:
>
>
> On 5/15/19 9:15 PM, Yuval Shaia wrote:
> > On Wed, May 15, 2019 at 07:36:26PM +0300, Leon Romanovsky wrote:
> >> On Wed, May 15, 2019 at 06:30:51PM +0300, Yuval Shaia wrote:
> >>> On Tue, May 14, 2019 at 03:23:21PM +0300, Leon Romanovsky wrote:
> >>>> This is a call for proposals for the 4th RDMA mini-summit at the Linux
> >>>> Plumbers Conference in Lisbon, Portugal, which will be happening on
> >>>> September 9-11h, 2019.
> >>>>
> >>>> We are looking for topics with focus on active audience discussions
> >>>> and problem solving. The preferable topic is up to 30 minutes with
> >>>> 3-5 slides maximum.
> >>>
> >>> Abstract: Expand the virtio portfolio with RDMA
> >>>
> >>> Description:
> >>> Data center backends use more and more RDMA or RoCE devices and more and
> >>> more software runs in virtualized environment.
> >>> There is a need for a standard to enable RDMA/RoCE on Virtual Machines.
> >>> Virtio is the optimal solution since is the de-facto para-virtualizaton
> >>> technology and also because the Virtio specification allows Hardware
> >>> Vendors to support Virtio protocol natively in order to achieve bare metal
> >>> performance.
> >>> This talk addresses challenges in defining the RDMA/RoCE Virtio
> >>> Specification and a look forward on possible implementation techniques.
> >>
> >> Yuval,
> >>
> >> Who is going to implement it?
> >>
> >> Thanks
> >
> > It is going to be an open source effort by an open source contributors.
> > Probably as with qemu-pvrdma it would be me and Marcel and i have an
> > unofficial approval from extra person that gave promise to join (can't say
> > his name but since he is also on this list then he welcome to raise a
> > hand).
>
> That person is me.
> Leon: Is Mellanox willing to join too?

I have no mandate to publicly commit to any future plans
on behalf of my employer.

Thanks

