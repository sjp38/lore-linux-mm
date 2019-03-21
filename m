Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C63A0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CB1D21925
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:28:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CB1D21925
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C5516B0003; Thu, 21 Mar 2019 16:28:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24DF16B0006; Thu, 21 Mar 2019 16:28:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EFB96B0007; Thu, 21 Mar 2019 16:28:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD8E06B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:28:19 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d8so24964868qkk.17
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:28:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Ss+RWMSfm5RImlciyWs3VoUSarnxyv2F5jgUeScDYys=;
        b=Rw+qy7Mhd8+Nsma/mawTCwV/ySpJWfpDvpS7Tg/IZddbgENs/eBhiwysToHrdOZpzE
         sN9tQozvGaz39w6SxWyv9jjc0zv7luvyoUEVsdee/cZZbyvuFB8wCeCKxhvm20ljXRqW
         bPZdbhbUUL12LRBmRlq//t5UH73KAqQVjvMlZLGBrVNkdgKkaDz6mSO7/ImN+/ePcEd0
         prM85DwQzDgGPVYtuOwpBVFqngo7eqKWL2B+n6Lgno5oJzQlxeYvQnkb5lkbKoisAM6o
         tX3Uc29ybScFrCgqHxNHc9oP+KFX/WoTrR4/4Am4z31Rr3uy8LbBugQNwhE4rORDmlbq
         /t1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzCkc6ndjm7YE2DTANIlu2kUY1i5FPazzlm/84IoYxtbWezXRm
	hZ8qbo8kMQ+nt+HbNJ1n7VW9yR6SJGiYuxBfJdI1+fbx9e5O/uLwIXeSjyQ1GERWvZxrxmV8vtY
	NSCasOBwtZRGyqk80MASfYJL+XOZrXaQs10LtW2FONrkncT3bWXwVuMRi6KuWzJ+nPw==
X-Received: by 2002:a37:4a12:: with SMTP id x18mr4396198qka.184.1553200098150;
        Thu, 21 Mar 2019 13:28:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyg86VYiWF828Ph+bZr0lU3RSU94TwQ0yiN0kRZCb8p4gx25+JmrQa659dpWACzvv3hrakG
X-Received: by 2002:a37:4a12:: with SMTP id x18mr4396073qka.184.1553200095692;
        Thu, 21 Mar 2019 13:28:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553200095; cv=none;
        d=google.com; s=arc-20160816;
        b=O+MjTWJnhqY8BpzixJFtBtX93Ee4HFbfd9+YedyBZFKOQG4w7jz79m3PYyh7HXpCqX
         trmHehfaNG0sPPxMGaEcWi7mWDtmbPUfc/9tgQRQ55jubtExGMzfHO7ZQl+JR9k7Swyl
         bL5YEGLVmLAjnlwJK2poryrKMRzuhVK6e9CpmEAKt7FGYGl0Toilcfe52BP5PEJK2GXQ
         Y/iXldXu+3s+LfJnFnPE30fN+R8QpGSGdgvnuk+/YvH1h0HkA3Uhh6KypRIDEZ7BZvYu
         mDKljYtxSEPSr4zCHcRf+5UcssNSvp6PoLIHXp0X96gzKO/YvD0Ow5EvSw0rJU8cIyIY
         TOiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Ss+RWMSfm5RImlciyWs3VoUSarnxyv2F5jgUeScDYys=;
        b=0uldURnksJOfxn42ACmMSI9U4IS4FcEJe4K3S3xkISNkqh/ZC/HK1FVFKIT3KuGHo7
         nJ9wkF//ylKOQHhVmgoStEOwN2txIQtznugydmraXE1/ik8OmgWg1C4lKrVlgofVRqOR
         i0em9TiuH5LpBDFATTrQ06GOHwKnSHkacQDc7Mcv4jm0r4ty2kfjp/dccUfFcceKtU00
         niSlOtIyPUNIY/BUtUWfjxiw8CZXW8h1LS+LoGejlaQHSoK6FA0WGb1dPw021UyCvBcK
         tgAzPYgtprktYlk2pd5ltz/RNd/g9Shbnj9Acr1AYSbeu1QsjRVOKcFdNh85Z64Ebffm
         z7+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r41si1782534qvc.109.2019.03.21.13.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:28:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ACF8A85541;
	Thu, 21 Mar 2019 20:28:14 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 419DF5C659;
	Thu, 21 Mar 2019 20:28:13 +0000 (UTC)
Date: Thu, 21 Mar 2019 16:28:11 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"willy@infradead.org" <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"jrdr.linux@gmail.com" <jrdr.linux@gmail.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"mhocko@suse.com" <mhocko@suse.com>,
	"ying.huang@intel.com" <ying.huang@intel.com>,
	"riel@surriel.com" <riel@surriel.com>
Subject: Re: [RFC PATCH RESEND 0/3] mm modifications / helpers for emulated
 GPU coherent memory
Message-ID: <20190321202811.GB15074@redhat.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
 <20190321134603.GB2904@redhat.com>
 <428b30355f4df864235428eaa24e207b8ba6c1ea.camel@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <428b30355f4df864235428eaa24e207b8ba6c1ea.camel@vmware.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 21 Mar 2019 20:28:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 07:51:16PM +0000, Thomas Hellstrom wrote:
> Hi, Jérôme,
> 
> Thanks for commenting. I have a couple of questions / clarifications
> below.
> 
> On Thu, 2019-03-21 at 09:46 -0400, Jerome Glisse wrote:
> > On Thu, Mar 21, 2019 at 01:22:22PM +0000, Thomas Hellstrom wrote:
> > > Resending since last series was sent through a mis-configured SMTP
> > > server.
> > > 
> > > Hi,
> > > This is an early RFC to make sure I don't go too far in the wrong
> > > direction.
> > > 
> > > Non-coherent GPUs that can't directly see contents in CPU-visible
> > > memory,
> > > like VMWare's SVGA device, run into trouble when trying to
> > > implement
> > > coherent memory requirements of modern graphics APIs. Examples are
> > > Vulkan and OpenGL 4.4's ARB_buffer_storage.
> > > 
> > > To remedy, we need to emulate coherent memory. Typically when it's
> > > detected
> > > that a buffer object is about to be accessed by the GPU, we need to
> > > gather the ranges that have been dirtied by the CPU since the last
> > > operation,
> > > apply an operation to make the content visible to the GPU and clear
> > > the
> > > the dirty tracking.
> > > 
> > > Depending on the size of the buffer object and the access pattern
> > > there are
> > > two major possibilities:
> > > 
> > > 1) Use page_mkwrite() and pfn_mkwrite(). (GPU buffer objects are
> > > backed
> > > either by PCI device memory or by driver-alloced pages).
> > > The dirty-tracking needs to be reset by write-protecting the
> > > affected ptes
> > > and flush tlb. This has a complexity of O(num_dirty_pages), but the
> > > write page-fault is of course costly.
> > > 
> > > 2) Use hardware dirty-flags in the ptes. The dirty-tracking needs
> > > to be reset
> > > by clearing the dirty bits and flush tlb. This has a complexity of
> > > O(num_buffer_object_pages) and dirty bits need to be scanned in
> > > full before
> > > each gpu-access.
> > > 
> > > So in practice the two methods need to be interleaved for best
> > > performance.
> > > 
> > > So to facilitate this, I propose two new helpers,
> > > apply_as_wrprotect() and
> > > apply_as_clean() ("as" stands for address-space) both inspired by
> > > unmap_mapping_range(). Users of these helpers are in the making,
> > > but needs
> > > some cleaning-up.
> > 
> > To be clear this should _only be use_ for mmap of device file ? If so
> > the API should try to enforce that as much as possible for instance
> > by
> > mandating the file as argument so that the function can check it is
> > only use in that case. Also big scary comment to make sure no one
> > just
> > start using those outside this very limited frame.
> 
> Fine with me. Perhaps we could BUG() / WARN() on certain VMA flags 
> instead of mandating the file as argument. That can make sure we
> don't accidently hit pages we shouldn't hit.

You already provide the mapping as argument it should not be hard to
check it is a mapping to a device file as the vma flags will not be
enough to identify this case.

> 
> > 
> > > There's also a change to x_mkwrite() to allow dropping the mmap_sem
> > > while
> > > waiting.
> > 
> > This will most likely conflict with userfaultfd write protection. 
> 
> Are you referring to the x_mkwrite() usage itself or the mmap_sem
> dropping facilitation?

Both i believe, however i have not try to apply your patches on top of
the userfaultfd patchset

Cheers,
Jérôme

