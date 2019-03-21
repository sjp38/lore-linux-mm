Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDEEFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 06:40:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 773E6218AE
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 06:40:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 773E6218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6DC36B0003; Thu, 21 Mar 2019 02:40:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF4EA6B0006; Thu, 21 Mar 2019 02:40:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBFC16B0007; Thu, 21 Mar 2019 02:40:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC8C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 02:40:41 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n64so23287311qkb.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 23:40:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QaLhh/3OuZaX+FKb+DW2jMDXLiQw+/brcwP91+Z0wbM=;
        b=eATXwY0pA78Zp0oeR0CMbV1xip7TXexZjpN6hMDZzER4mVSQCBkwM1TrNxBoyUwMLP
         67N4zYBRMpK7c9WVmiM0wgFNXRTH4/G9JFKPdKs5jr21LqQ8r4sBQuMPt+/XpM3+PflV
         Qw7UW5F4en65si7iIpEp47tz39FDi9mL+T4yb5PRDr+VboTb6BfaFWWSBa2N0QVJKQI+
         ItE6sZFTpHMR5xGG+IqpF3oA6g/aSeZIOFpAEyDKI+4ziBziWdepW1iUVk4y3el5Dy/T
         ON6M4g9c6DOxlI9FXcBIL5igG9/HpHUwCvJM896yba/GXugf2BTwGFnFHfhjQI+kPj0Y
         Z3Aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUMYVL6UVUz+xSjYSNfm5HI3sQnQSNNHHyeGR6Q++y6CF3CE9w1
	YzYXt7250RHnjejWFmWmk/G+Eio5xgJ6U5CjYja0VEpLLNrmQY2mjWEaBQLSPK2PNkzYYnl5AQb
	UOkmhDLDV+mgwc2VLVo6TrxMFlFi7kp/e1cxyDEWL3zRmvee2zwTauFrg5usbIZaaAw==
X-Received: by 2002:a0c:8693:: with SMTP id 19mr1750415qvf.73.1553150441354;
        Wed, 20 Mar 2019 23:40:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdG62kGwJCm+kP5CKlWJ/2NxaRE7NjN9BMUqzAcprcSq38lEBaf1HbufYzGd0ncPMhp37U
X-Received: by 2002:a0c:8693:: with SMTP id 19mr1750381qvf.73.1553150440307;
        Wed, 20 Mar 2019 23:40:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553150440; cv=none;
        d=google.com; s=arc-20160816;
        b=rrDhANhyyOtzK50JlcV51AwaDmssX95ziSBG2ldIT7byS8wP2FTpRj8h6P0urWzPAT
         2mo3bjqDUX5pu6+EqGIiPdZgZSR/QrpewPOv3bLE28G8kazhmRHJ3pnIcn76NmXqALKZ
         OA0+dYJCr1MU8Fff8F9Ocn+2PHwQQ2lzvYQEvD+jl7uUJ5CeCT1/vGI7R6D/rL0JsneH
         +oFbfoIVXv3KQb4f/ScENFCqKjJo8+oLi8n66EBwuT1qDJMAKAZBwMwg/2yCAOZKC6Io
         PcK99GyIMqVX0FfrlYaLZjs/+JjMEErwDVmY37Ka4iVKXS2gD0Y20cRmMZqonH76V8Mx
         QcWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QaLhh/3OuZaX+FKb+DW2jMDXLiQw+/brcwP91+Z0wbM=;
        b=zWted7NRfaj7AKrQr/g9mRaMYeHqNH67A+w9SCZIow51C6DuuqjLA3Y8+Q1Pa9+3yJ
         APhTz6Qm/9jf/RKn3iLwbLp254R+aJsxRt62WzKLSWJ4u/GooZJo5UK7BmJzAz1YyCRv
         5oisbWrEtMX5fkAmj3Do8GdONP4IisNmbzlx30HQmviaD47ma5BXrUMx2FYYylBpOPs/
         0YY4G3K5Woux6FoF8HtAGksqnKrg+UvAtd6+22P9ks9XDU0lEhCnGzYxCFz2HM4b9m9L
         F4HY4HS2ekHcT2pP9DfMNgaNP+hW80/oKOcJN3gJO+k6l3nKMNRprmVD1JGtKpx9H8BS
         r5yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y17si1672968qvo.161.2019.03.20.23.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 23:40:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5C03C20269;
	Thu, 21 Mar 2019 06:40:39 +0000 (UTC)
Received: from localhost (ovpn-12-72.pek2.redhat.com [10.72.12.72])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2CBDA600C1;
	Thu, 21 Mar 2019 06:40:31 +0000 (UTC)
Date: Thu, 21 Mar 2019 14:40:29 +0800
From: Baoquan He <bhe@redhat.com>
To: Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190321064029.GW18740@MiWiFi-R3L-srv>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
 <20190320123658.GF13626@rapoport-lnx>
 <20190320125843.GY19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320125843.GY19508@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 21 Mar 2019 06:40:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

On 03/20/19 at 05:58am, Matthew Wilcox wrote:
> On Wed, Mar 20, 2019 at 02:36:58PM +0200, Mike Rapoport wrote:
> > There are more than a thousand -EEXIST in the kernel, I really doubt all of
> > them mean "File exists" ;-)
> 
> And yet that's what the user will see if it's ever printed with perror()
> or similar.  We're pretty bad at choosing errnos; look how abused
> ENOSPC is:

When I tried to change -EEXIST to -EBUSY, seems the returned value will
return back over the whole path. And -EEXIST is checked explicitly
several times during the path. 

acpi_memory_enable_device -> __add_pages .. -> __add_section -> sparse_add_one_section

Only look into hotplug path triggered by ACPI event, there are also
device memory and ballon memory paths I haven't checked carefully
because not familiar with them.

So from the checking, I tend to agree with Oscar and Mike. There have
been so many places to use '-EEXIST' to indicate that stuffs checked have
been existing. We can't deny it's inconsistent with term explanation
text. While the defense is that -EEXIST is more precise to indicate a
static instance has been present when we want to create it, but -EBUSY
is a little blizarre. I would rather see -EBUSY is used on a device.
When want to stop it or destroy it, need check if it's busy or not.

#define EBUSY           16      /* Device or resource busy */
#define EEXIST          17      /* File exists */

Obviously saying resource busy or not, it violates semanics in any
language. So many people use EEXIST instead, isn't it the obsolete
text's fault?

Personal opinion.

Thanks
Baoquan
> 
> $ errno ENOSPC
> ENOSPC 28 No space left on device
> 
> net/sunrpc/auth_gss/gss_rpc_xdr.c:              return -ENOSPC;
> 
> ... that's an authentication failure, not "I've run out of disc space".

