Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 349D9C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:24:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEBC72087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:24:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Bqm8lPIQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEBC72087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 633C96B0005; Fri,  2 Aug 2019 13:24:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E5276B0006; Fri,  2 Aug 2019 13:24:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D37B6B000D; Fri,  2 Aug 2019 13:24:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 319A56B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 13:24:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e22so2904196qtp.9
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 10:24:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=b/ZbdcC0DDz1oNoCfSGh30lpnC4X+0hWOBfmleHyzyg=;
        b=lv6KfmPMACRnvvecQ+qsXnCGS9BlsSZnB9AphF6UsNTx1mtHTD8UkaLI27B0/D8COo
         WlsdyWBpcU3yjMBAdFc+GOb2M1aD8KvqDEjdWnrWHpkaRyfcqxBdVg9Lrorg+Ix9TV05
         8nTakwpxhjazf8Dy5Atck4f1Yr8cbjqiZHAPVYENaTlu1Q8JLBCObujNMOkV0S3dpwqw
         CLBdRT1SKaMBpHJlRF842lMjzzGOXHz76Cqtjg0G86ssGU3Q1AN0a179jaEIR+z17/kQ
         39xcb/CmJ4PI4xLHuRfCfnvouiQm6/XH/fA2PtDRuNUj/nQuEvDJ8nJQwQPH81N44Z3I
         2mpQ==
X-Gm-Message-State: APjAAAUOgLj0qPhgyFWvqpJhzoldZiEeEnYssJ4U9VGvS5ZsoWSS2ceN
	nFwvtbshr6C7hvD+iHK1Tuo/SGqPfuJXoz/fNkkPXZ/gsdY2YFKESIrKvmuQHU7Vb5Gc+vRw4m+
	EIJ+9xYBb46SCWwWsHxUoi+NneK+gynNjYTjS0uUto6s7QACyAHXBM3dWgy2Jf05c1Q==
X-Received: by 2002:ac8:f8c:: with SMTP id b12mr98570728qtk.381.1564766660941;
        Fri, 02 Aug 2019 10:24:20 -0700 (PDT)
X-Received: by 2002:ac8:f8c:: with SMTP id b12mr98570666qtk.381.1564766660119;
        Fri, 02 Aug 2019 10:24:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564766660; cv=none;
        d=google.com; s=arc-20160816;
        b=Q66E4njJtqaEfzPMNzH5ww+t9+PNcUwdCU3vcTxjSm6ESBxVa4SwZKYknTAhKZ2d7R
         B3K3iDooKQ0FA23mWFAIQj/u8WGalrAypY8SQlm/WXEY+MUtYHSkjlNM9pvde6OnN7SO
         XXIuw4lQEEUcCxJDquokdaW0MjXg3Fm3Z80DgTEQ1yaaBHqAUJh/IFh5Y822aJSV0msh
         6grMZcnYCMWHhcquOCaptEyMP4SQHOpUZApglMb9wPh4rJ56poydUHlDu+Xrdd3X5/CE
         gR8ps2nB+DtcF7EsOoQoDsDWI+R5DYFNGxfe+GllMHT2Ru8tGIs4WEizrXidYE6G8xx9
         DHHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=b/ZbdcC0DDz1oNoCfSGh30lpnC4X+0hWOBfmleHyzyg=;
        b=0J34Zyd+sEmE16vOirtr1FeEOGZTgnOHNcPu+clnnj7iwr3Hso5eEw+x3G+YFssD4i
         +7M64JdNWcgwZavjscWouZw4EyZGcioIkpfLd3MRXk+SXImDZMo2r5bX7kEMVJSEySBn
         8p/PPfQAP5L/9amaMJCyjbvhhwFPIwH+13/UmLYGYXjsCeT4dgAQmq9/bFjjR2r6U5E+
         lF5QhDufvVUdJO42CUedaAY+DPJwfM+dKDqSnAYSzPadK8PHzalXCLQ/HFemoYxZiFYF
         Yh5uGwHZ9tkw+7vLXWNNyXBh//H7E1aWjzpdmYl8TqoZSkxAGwgERNjvw9JWh+BlCQao
         6eDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Bqm8lPIQ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor41986162qke.93.2019.08.02.10.24.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 10:24:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Bqm8lPIQ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=b/ZbdcC0DDz1oNoCfSGh30lpnC4X+0hWOBfmleHyzyg=;
        b=Bqm8lPIQh1rFwvAVca4MuGFlAzmCDYu5Rh+vK2o/lwsywYkM8FWq8PDerS1S494YUd
         YdRlqN86V3V07Ubkc9+u0LPC85tI9+nhfhgXLNTvG0jKt+2qsbDduSumpl+pf4RQrgiu
         /morBoV3u7YQ2MvhfXY3yuO815LwFDOzG+OPNzn+Yxd+d20QcyXCyAmyX/G2jnPicg8x
         ZmDxd4z0b8rzujaHcU5/9PkhjFkbO6/CdZXCXw4gkaClngdJY4k8vFwKphG0uzps+6rr
         fSkdfl5lEpvi8p/j3nr2rpHVff4rM27uBG1YJZnrHv0lUAHajWA+r+eYkDKDxwpzjfU8
         74YA==
X-Google-Smtp-Source: APXvYqz3bf1RYWu6U39GeHZIQdaItvlh7ks4r7TbDlC8NTybQtBARJwkp1RvWALo25T9mXOBSdzKwA==
X-Received: by 2002:a37:9d96:: with SMTP id g144mr92937157qke.288.1564766659730;
        Fri, 02 Aug 2019 10:24:19 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l19sm41977618qtb.6.2019.08.02.10.24.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Aug 2019 10:24:19 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1htbHu-0005z3-NQ; Fri, 02 Aug 2019 14:24:18 -0300
Date: Fri, 2 Aug 2019 14:24:18 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190802172418.GB11245@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802100414-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 10:27:21AM -0400, Michael S. Tsirkin wrote:
> On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
> > On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > > This must be a proper barrier, like a spinlock, mutex, or
> > > > synchronize_rcu.
> > > 
> > > 
> > > I start with synchronize_rcu() but both you and Michael raise some
> > > concern.
> > 
> > I've also idly wondered if calling synchronize_rcu() under the various
> > mm locks is a deadlock situation.
> > 
> > > Then I try spinlock and mutex:
> > > 
> > > 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> > > improvement.
> > 
> > I think the topic here is correctness not performance improvement
> 
> The topic is whether we should revert
> commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
> 
> or keep it in. The only reason to keep it is performance.

Yikes, I'm not sure you can ever win against copy_from_user using
mmu_notifiers?  The synchronization requirements are likely always
more expensive unless large and scattered copies are being done..

The rcu is about the only simple approach that could be less
expensive, and that gets back to the question if you can block an
invalidate_start_range in synchronize_rcu or not..

So, frankly, I'd revert it until someone could prove the rcu solution is
OK..

BTW, how do you get copy_from_user to work outside a syscall?

Also, why can't this just permanently GUP the pages? In fact, where
does it put_page them anyhow? Worrying that 7f466 adds a get_user page
but does not add a put_page??

Jason

