Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9CEEC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:31:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46D41208E4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:31:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="fUaCEUhN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46D41208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B88AF8E0003; Wed, 31 Jul 2019 15:31:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B38918E0001; Wed, 31 Jul 2019 15:31:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4DA78E0003; Wed, 31 Jul 2019 15:31:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB108E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:31:00 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id o75so27634561vke.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:31:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=V4Wcp011k9h7N5iAJkWpP1Nbu9oN4M2GGvG06LvdU2U=;
        b=hkM/+utS0v05rk5t0+6gKPoFDY1c61oejpPeOSf35BLqJ3nMaVulkceZ4ZZ3eiKbMy
         C8UlNbE2bKwCN5YeIT4GUYKA6WCSrY8wxsSXA1uQduQGPgMMlVaKDXEaPrsbxl9XVEL3
         1o7Nndpp6XqNoVj3QcW0KAyo1+6xYkGBh4Ovm3mpiTft9FoOoXWp/tN5poHc7mLUvdN7
         g2AzIwQqm2C3u1oVDJRAvyd0U7Dudp3a0y5eaPF8FCE0YsIYhKa+EuVL4RVUADXG5DL5
         vxiigWNQGJ6Y/3pAl5YfGkuuUy4JrBRWGq6uMjVL7rzuRboMJHNJVq88XKVAOqXbKdht
         AqsA==
X-Gm-Message-State: APjAAAWyD7L6SRH9QmwCl6x7zgLNi0Ca9sU8KSR7s/aCQDRENIComhBa
	VVi7fhcy47gYORE1tXmVsg5/EPW7cMQnf2RJ78zBvMd+mZ+Vd9hat0gkVjjKmELCb/5ECljFqiL
	9lW5fTJZmKfV5eMUg1lo/HnV55hHmWiv3tho+bao90H/dSOAQhfO8oVZeJlBeF35xKQ==
X-Received: by 2002:ab0:7384:: with SMTP id l4mr68449538uap.8.1564601460190;
        Wed, 31 Jul 2019 12:31:00 -0700 (PDT)
X-Received: by 2002:ab0:7384:: with SMTP id l4mr68449448uap.8.1564601459305;
        Wed, 31 Jul 2019 12:30:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564601459; cv=none;
        d=google.com; s=arc-20160816;
        b=UNgL9VPHdStQpXgzbVLtP0PHiM0YgieicU04cCnzNYbDHogxB4g68ls9KTjYp5t31W
         YpptS/tTfDKMrAvpffvObOMnfjC0jbR+4POJOUF++IzK1qsWHvhY3OThUCeAfEtlDWDp
         1juX+B+P3S+z1jPw/LXfmSLCjvFkgyBF+NB9T98yMECSRYkqSbN5/DyJ55xGVekSSeHu
         vVjooOVzh0AGEluyZebKlNUuQTNSTKwRmj2W9kfvKSWBudhVw4F819R0mUSFfhvtNJ4X
         s5haylTcs15zuc3atl1WOXSalDQh0tx+rORadvAi5S8yH8X9jxfKfJDKtkh01EQh3sgw
         KyBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=V4Wcp011k9h7N5iAJkWpP1Nbu9oN4M2GGvG06LvdU2U=;
        b=ClI5drhE8i13iLh9Gz6DQZ+5VpjCmaT7BPLrN0ZnRsfNZAonGJM3N1ZwUNRHWWHQUi
         wW5cX7dJDi3zFvPEvVtmSdZxCwGitEDm5xieYgpiSTqqcS4LB+l3rjo0h8lQqkHlAq4m
         hQTeSAcyfz9ytbOWajsFq6p4BYzgpCHho8eZahQb9Corsh+T0gfYePG+s9ymXPLsN5jg
         iBvZQgj7on6NKYEBTEmGwMNFAqE+JNjJhKsVxDiPKMirvPYkObya/S/zGoOJ7iRu8nKA
         Zj8MqXuctyKGitOeZElVR/Md/DMwog38RWELwjGm6xHP0LUcAJH4dQt12nbF+BcANprS
         BbhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fUaCEUhN;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n16sor33333232uao.69.2019.07.31.12.30.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 12:30:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fUaCEUhN;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=V4Wcp011k9h7N5iAJkWpP1Nbu9oN4M2GGvG06LvdU2U=;
        b=fUaCEUhNC4Tuu1n1nF8asI51cgg70GaR9H/nMdDM2BZwKIGwYESyC+ANrzEzNbyCCK
         Oo9kAgTUGUCRJpgDkeKVwv2v7LNE0yerjxD0FFu+TlVm1wemvoI2V5qJum7RZWCsIsFu
         caZSoA1qPEKO3nEIy2wlsOXadZQb5TaaAqtNv95x4AfEvUSG01PbXA2WgagTZHsb7aMz
         DXvwhLJ2m6xnSVDL9BTKqy7XAh7eilMxSkpBweTk3v2EiycxvGfTJMtMv1lYRBGBE0MV
         Tk6sq+Q07tuHcFgS507UyAJFXfBxy4xzy4NGxxbF1CNkFe49Cf8Iq4yLVLNYGHjD92T2
         DCGg==
X-Google-Smtp-Source: APXvYqzup5DZ6q8bxH1OXHSeDiBtafoJQmznWiwBSNHtM04i2y2ha7deX2jX6U9UfYm6veI89m6bZw==
X-Received: by 2002:ab0:49b0:: with SMTP id e45mr17499877uad.120.1564601458846;
        Wed, 31 Jul 2019 12:30:58 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 10sm28842460vkl.33.2019.07.31.12.30.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 12:30:58 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hsuJN-0007XW-Lr; Wed, 31 Jul 2019 16:30:57 -0300
Date: Wed, 31 Jul 2019 16:30:57 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190731193057.GG3946@ziepe.ca>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 09:28:20PM +0800, Jason Wang wrote:
> 
> On 2019/7/31 下午8:39, Jason Gunthorpe wrote:
> > On Wed, Jul 31, 2019 at 04:46:53AM -0400, Jason Wang wrote:
> > > We used to use RCU to synchronize MMU notifier with worker. This leads
> > > calling synchronize_rcu() in invalidate_range_start(). But on a busy
> > > system, there would be many factors that may slow down the
> > > synchronize_rcu() which makes it unsuitable to be called in MMU
> > > notifier.
> > > 
> > > A solution is SRCU but its overhead is obvious with the expensive full
> > > memory barrier. Another choice is to use seqlock, but it doesn't
> > > provide a synchronization method between readers and writers. The last
> > > choice is to use vq mutex, but it need to deal with the worst case
> > > that MMU notifier must be blocked and wait for the finish of swap in.
> > > 
> > > So this patch switches use a counter to track whether or not the map
> > > was used. The counter was increased when vq try to start or finish
> > > uses the map. This means, when it was even, we're sure there's no
> > > readers and MMU notifier is synchronized. When it was odd, it means
> > > there's a reader we need to wait it to be even again then we are
> > > synchronized.
> > You just described a seqlock.
> 
> 
> Kind of, see my explanation below.
> 
> 
> > 
> > We've been talking about providing this as some core service from mmu
> > notifiers because nearly every use of this API needs it.
> 
> 
> That would be very helpful.
> 
> 
> > 
> > IMHO this gets the whole thing backwards, the common pattern is to
> > protect the 'shadow pte' data with a seqlock (usually open coded),
> > such that the mmu notififer side has the write side of that lock and
> > the read side is consumed by the thread accessing or updating the SPTE.
> 
> 
> Yes, I've considered something like that. But the problem is, mmu notifier
> (writer) need to wait for the vhost worker to finish the read before it can
> do things like setting dirty pages and unmapping page.  It looks to me
> seqlock doesn't provide things like this.  

The seqlock is usually used to prevent a 2nd thread from accessing the
VA while it is being changed by the mm. ie you use something seqlocky
instead of the ugly mmu_notifier_unregister/register cycle.

You are supposed to use something simple like a spinlock or mutex
inside the invalidate_range_start to serialized tear down of the SPTEs
with their accessors.

> write_seqcount_begin()
> 
> map = vq->map[X]
> 
> write or read through map->addr directly
> 
> write_seqcount_end()
> 
> 
> There's no rmb() in write_seqcount_begin(), so map could be read before
> write_seqcount_begin(), but it looks to me now that this doesn't harm at
> all, maybe we can try this way.

That is because it is a write side lock, not a read lock. IIRC
seqlocks have weaker barriers because the write side needs to be
serialized in some other way.

The requirement I see is you need invalidate_range_start to block
until another thread exits its critical section (ie stops accessing
the SPTEs). 

That is a spinlock/mutex.

You just can't invent a faster spinlock by open coding something with
barriers, it doesn't work.

Jason

