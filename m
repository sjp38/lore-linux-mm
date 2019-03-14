Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E785C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:43:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4335D2087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:43:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4335D2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D224E8E0004; Thu, 14 Mar 2019 12:43:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA92E8E0001; Thu, 14 Mar 2019 12:43:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4B728E0004; Thu, 14 Mar 2019 12:43:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8F18E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:43:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o12so2074672edv.21
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:43:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=j3+cSXtcbpwvKI0AIoJ3mZijnYhBZ0fSqG5Jodf821I=;
        b=sfB9D6+LAJOfj51PV0afp0SUnm7MvDH25GQKGyeJkpFOCxvJX6SnGuKjM2wMGHBWAr
         pMni4lQgdg2HOFCAVIHLRb6PvHaj3oymjf4b8/iKX6A19dLcfcmPq4/6CIxCaWK5r9EJ
         jMAkV7KJVX9FcMrSUzp2PUTObH/nI3dyWIzqGecOC3Jqo7b+l+uDzmGuIy6nzOUN0cW7
         4iUmVVzZ2+WFMlzF6VR0nt1hWEl6zMGMjgOWGjJrpUUumbOru0J5PnvJXd8ljLUD1kWN
         dGXagRrGC4qn3675/lr/QBq172VaWeBOoQFUPvk9a6p5QLeOSYdj6E67ys0nUA5oHOyK
         xgrw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAUZdQWX1F40hXAwdyf/FrP/8k/omFvpUko6KfsGboxzcWuIqlD8
	zytastHqGOAoG8nhiq5U3qaUTZqNszl5WRV1F2sqK0akXPfWcDE98IODV4oMG+Bvml+MC1ReecG
	Ng7lhjr9hO3XvDw7lbBD8d1x7PqPcrOedlRXiLJOOpCbHg0zidY0vhKjeJJAhC3M=
X-Received: by 2002:a50:b1d8:: with SMTP id n24mr11974828edd.137.1552581830957;
        Thu, 14 Mar 2019 09:43:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8VwB/ORjpc+jyqC3UgFvh4Us/akr0wdT1Y3gz6Ui+r0e6aRJMwzWZ6G5cvaSVL1Xr1t3v
X-Received: by 2002:a50:b1d8:: with SMTP id n24mr11974778edd.137.1552581830072;
        Thu, 14 Mar 2019 09:43:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552581830; cv=none;
        d=google.com; s=arc-20160816;
        b=E1ycL2b4GYDS4WN9pnLbT9z+Nm3kHgTZz9c56079p+I8JJJXcHMdhD+5Ggq/Key66c
         WGMQkPs6Pw38R5XoRIS7Vtk3y4SL/tsVeCxtALH4HCAjkgGl7Wh8OZGFKiQLeSAnecd0
         0a++P5n9FEAlq98b3aUWF3FOlbp7kIjNxVH6yarr7CbLcalzUIpAIl49kX5Yju5JLfK7
         jTl2Hlhiu7gq5Vbo6VNK86ZhNZHGgN3Af2tNCOnob0xqZlHMo9YXJzYYgRoTqSXGH2Yd
         CGeaAZGtyMWXYKeSSmMK/Ajlj0T4uOk27Z0VEzFhk1WU/kXz6aHYtEONmwKmhsPRnzhg
         u3pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=j3+cSXtcbpwvKI0AIoJ3mZijnYhBZ0fSqG5Jodf821I=;
        b=Tiu5p9iC1IXuZuvCS/BUIHe0mwpkoGwJnscFBmWeWJUZYtswAtEb+LfDmWcSFAtVo2
         DGjpncy9e+9F51oXzEmYzN78sLTfI9Erz9UBIKzVssLtaVoKaJs2VNPrsjhCazpzDRGb
         sCrjKJTeYQOKYVTmT305uA5AT9Bde9Yufm4TOVSHFujRg8q1PBGyiiaWTHzlt6QvuVTs
         Thn6s0U19fcUZ/hwvgLbocYTQLgQRNPm8mWQR7FibQAynteZcUAvoAFrnVehYMUS2sti
         esOomEXuf6sG/uMXxzA8fmGMHPd0rWIXA66MkuPTqy4H2yDrrVVTROjyJQ/ndTFSADsR
         Wcbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gl20si1940439ejb.218.2019.03.14.09.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:43:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4C784AD78;
	Thu, 14 Mar 2019 16:43:49 +0000 (UTC)
Date: Thu, 14 Mar 2019 09:43:43 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Using XArray to manage the VMA
Message-ID: <20190314164343.owsgnldxk7qr363q@linux-r8p5>
Mail-Followup-To: Matthew Wilcox <willy@infradead.org>,
	Laurent Dufour <ldufour@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org
References: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
 <20190313210603.fguuxu3otj5epk3q@linux-r8p5>
 <20190314023910.GL19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190314023910.GL19508@bombadil.infradead.org>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000040, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Mar 2019, Matthew Wilcox wrote:

>It's probably worth listing the advantages of the Maple Tree over the
>rbtree.

I'm not familiar with maple trees, are they referred to by another name?
(is this some sort of B-tree?). Google just shows me real trees.

>
> - Shallower tree.  A 1000-entry rbtree is 10 levels deep.  A 1000-entry
>   Maple Tree is 5 levels deep (I did a more detailed analysis in an
>   earlier email thread with Laurent and I can present it if needed).

I'd be interested in reading on that.

> - O(1) prev/next
> - Lookups under the RCU lock
>
>There're some second-order effects too; by using externally allocated
>nodes, we avoid disturbing other VMAs when inserting/deleting, and we
>avoid bouncing cachelines around (eg the VMA which happens to end up
>at the head of the tree is accessed by every lookup in the tree because
>it's on the way to every other node).

How would maple trees deal with the augmented vma tree (vma gaps) trick
we use to optimize get_unmapped_area?

Thanks,
Davidlohr

