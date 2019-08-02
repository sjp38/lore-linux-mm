Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B323DC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:04:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5754521726
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:04:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5754521726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEA096B0003; Fri,  2 Aug 2019 10:03:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9AFD6B0005; Fri,  2 Aug 2019 10:03:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 989076B0006; Fri,  2 Aug 2019 10:03:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 794806B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:03:59 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d9so64428723qko.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:03:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=WV2Ae/gfauZPjPhFYOLLqagCyB4HyL2HjQauKn3bqsM=;
        b=huDExcTIGs4lTph/BQkDOC+rAujwV7bWHdJYDxP34XuBu8AAmXizTmb5M1zpLOeOLM
         0VaUe+YYYRAdsaCqlxlHe/YgCLF211GE1r1wxXLr4MR3z0ceoK0d929CLWinwRz+RTR1
         B99sGDeQES1E5JkTj303QO+WgLV5JLL77peV2AzqDt7r0V4md+cbBzgDyLj2nGM83q3S
         AkyqxwVxflxQosPxpg11CeVQtWlT5WUX94Dnw9d7JS4S7EmGmstTV7plYsaqiomtsaCN
         J9eSliVtQU1V+/5Bq+jn8pzL4sGheCA+jM9+7M/DNfK8TcoXCEbOlEUKwOOmzQ37Iw7e
         N0pA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRo4/EtH00rLbwZ0gZ4+jfaDScKu3mIqgI8STkDry+5m0+Xcv5
	D8iP/PCppWkr4DayjPk9yElbXAscSHMhLImYG8ZjzEmEwENKwJKgYcIGEHO76ywWqsuWx2oAZXI
	3DTNs0regtNYRr9z7/XJm1QAE2llN9I+8AwgQoOA+/JVhi/ry54VphT6X3Ibw4KH2EQ==
X-Received: by 2002:ac8:4697:: with SMTP id g23mr71459726qto.285.1564754639086;
        Fri, 02 Aug 2019 07:03:59 -0700 (PDT)
X-Received: by 2002:ac8:4697:: with SMTP id g23mr71459660qto.285.1564754638381;
        Fri, 02 Aug 2019 07:03:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564754638; cv=none;
        d=google.com; s=arc-20160816;
        b=a54rZ7vWz2l4H1j3YOBMRj+p1L8jNyqFoVYGhfhzYIzPvtD3Ndho+dNK4xV74RYR29
         e16PB4fS0Spu1VtkWSAZVaQpIgbPY1Jyirm9Hk3wxqQujQxYkakT75k/OHJqoZXNF/ig
         UEWIZGtMj+Ksimz6K/7F/M6C9J4//zDw/KZWB3G6OhWwNEUpBaY2JS0p/0eK+XZnncfL
         xWUU9pQuOM0fMVw12kQxsnWfdTPNzp14JTEXhU9/QYdrckPB1vLM8cBt+pJjuMHLPPQK
         SFHyeAX7+I8Q6yQn4nW1TLlyel/nisru7RMe/tNMaoQ5XvzEAK3cxQHAYB+eOt5zEuXm
         8tkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=WV2Ae/gfauZPjPhFYOLLqagCyB4HyL2HjQauKn3bqsM=;
        b=J9KFsv3rwM375rfuyFg/9d9NC4pJo5pR67lfuyuozdWkVZGjYgk/B5dPcFR/rZuKzE
         8JuXzsqYHI6RIXzthfplJrbtRxAY9iWgqU6Y4bGDBQ0hwqTnv3kDCF0Q1sy4wY1TtN1i
         HTF9lLACz5ypY5UZEUGZjdTqF6BqPcaKffm4ddJd+iufUKHETU6/dhAABddJp30jcobi
         Fg77yYjBgB3c+yp6omeF37aY+fUxcFcSQTueMeUQaaAvlb/QZyBK7MBdzfRyyOyxa6LA
         GnuuDIOQ/NU4XtTTTfuLQEbObh0FQL2U7IJxGbtiho/+9lT1ULhDP/Mi9gucscaa19Uo
         QbQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m6sor97821512qtq.2.2019.08.02.07.03.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 07:03:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxqWV5TMaysY1q7/YjNkaoGeUmT+T8Aja0Ppx3ngtfg+CGh7SDzsuYF2FJmZ32u93WwxfAAKw==
X-Received: by 2002:ac8:2b49:: with SMTP id 9mr99459163qtv.343.1564754637929;
        Fri, 02 Aug 2019 07:03:57 -0700 (PDT)
Received: from redhat.com ([147.234.38.1])
        by smtp.gmail.com with ESMTPSA id v4sm30651268qtq.15.2019.08.02.07.03.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 07:03:56 -0700 (PDT)
Date: Fri, 2 Aug 2019 10:03:49 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190802094331-mutt-send-email-mst@kernel.org>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> Btw, I come up another idea, that is to disable preemption when vhost thread
> need to access the memory. Then register preempt notifier and if vhost
> thread is preempted, we're sure no one will access the memory and can do the
> cleanup.

Great, more notifiers :(

Maybe can live with
1- disable preemption while using the cached pointer
2- teach vhost to recover from memory access failures,
   by switching to regular from/to user path

So if you want to try that, fine since it's a step in
the right direction.

But I think fundamentally it's not what we want to do long term.

It's always been a fundamental problem with this patch series that only
metadata is accessed through a direct pointer.

The difference in ways you handle metadata and data is what is
now coming and messing everything up.

So if continuing the direct map approach,
what is needed is a cache of mapped VM memory, then on a cache miss
we'd queue work along the lines of 1-2 above.

That's one direction to take. Another one is to give up on that and
write our own version of uaccess macros.  Add a "high security" flag to
the vhost module and if not active use these for userspace memory
access.


-- 
MST

