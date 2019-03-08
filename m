Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7BF6C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:55:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 847A820840
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:55:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 847A820840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F11F8E0003; Thu,  7 Mar 2019 21:55:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17A088E0002; Thu,  7 Mar 2019 21:55:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 041318E0003; Thu,  7 Mar 2019 21:55:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA60A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:55:51 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 35so17386059qtq.5
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:55:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=A3iH2HTbABp3ickW4JmD9ns9qg2Y1Ax799dGBIkjkjE=;
        b=BsNdx7jml/N6OkEoKqv82br1Ze/oHt/A2X4bJ/Lm2kRzocdbsZa/+aogex9FINUMtw
         ZZMwHrrkp93ELkOQWIIZpLO1cx/r0YqnJ8ev+hjvTuQGixnrhFKOn5FU01UfS9m4EF6e
         jA4tbkzWCQ/c+sIC/AlipVhA46gncUTMBJbEL369FW7wZs0mawvMAxkOEn7anIDUIwCB
         +8r7qCZKPoEWxr9tQ/RHuDUNkh1aXng/MS849vRYphhNngF6kT4D5Y1ROfi/KWP+LXW9
         Rl++fu9bNCaFl9XLkQhbPR1jWf6bsCM8x+6Kzc9m2sUPyF7aEMlrhsx2X6KUN2FzyKuf
         q8Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUpZVc3qw05dWUESIBqW8bIAOo+0kD0NedGZJrwMfpO5jYvaer0
	UXSUZw6WuAsYTw1qm3GkjO5rns1HvZFJ320etFTVhI0r4gGFhRCqG6L0kJOTeex+Soc8CL5WN/m
	5vry88bjTRtrTDD1YoET2vVNFwzIA+fBLVNDvT8iu1XgiNuXfUZdnb22+AoUtZSJekQ==
X-Received: by 2002:a05:620a:1665:: with SMTP id d5mr12143640qko.94.1552013751595;
        Thu, 07 Mar 2019 18:55:51 -0800 (PST)
X-Google-Smtp-Source: APXvYqw2nNg73tu+uaKrbnS8E3f8k2OHjU2//ThQp+2v6xpMyhJUdCUgb8Oc0O3pegW9AvQqDZvW
X-Received: by 2002:a05:620a:1665:: with SMTP id d5mr12143619qko.94.1552013750869;
        Thu, 07 Mar 2019 18:55:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552013750; cv=none;
        d=google.com; s=arc-20160816;
        b=lzaEvzCE4ImrbdOWJHL9LjgyOE+rO/5XbQI//fJarmBmzr7+Abnycp/BMxC+/KmFF1
         uGzIbOL80Mzvxl2siGjPvbWx8KuZShYZkOTzkWoNUyoSXR7LJL4NqDLC63oJ0lfRPHLQ
         9lEQKkh8fM84RpOVp0LWXaXgoFgOHE48tV5CBHZ+E+TQuTF7cKJwJZ1TJ8y7P3DvriU1
         CNo8dsRy0dEB7UlD+/7ygkq2XeQFTO+AY9YDEBH+yfI32D8e+AVHwM8CeSvn5zSePz8r
         4USFNbvSIeEC11gsE4A+RM58aUQX7Wg0uifvAuYJbNxsHHE0mezqsGkmPrYc7g7bNzN+
         Mmsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=A3iH2HTbABp3ickW4JmD9ns9qg2Y1Ax799dGBIkjkjE=;
        b=lT/q5QxA3Xc/GMPk9g+LcjpeZIYt5Sj5ZEffDewPxZIfvkDCLdoMZPRYJRznzLAfML
         FCVg1ppd8FY8ucfJ+/6QtoC2gUXt4Hvc9TMmGQtRW38O5RNyuaNTJcEsxlS9tMKiRuR+
         FAwd5pMdyRc8KBd5f5QwgUeLVORJfXWhAIMTBby+xtI/NHcL+2am5oVQpZEji6aKD3au
         P0NOPTDrQG7dkPU0T+BpDA617qD20MB33foGbNwzD5ionc0w0/czpaN+zwmp0cr4ljeU
         xbFtr8QFkyDsIwVJPCA9C0Ww2UAcDF/maHM/71ChJ2vIcuMA5K3iCQy+SJcSsYhldbOH
         N7Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x13si3099397qtx.196.2019.03.07.18.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 18:55:50 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1A3E58110C;
	Fri,  8 Mar 2019 02:55:50 +0000 (UTC)
Received: from redhat.com (ovpn-125-54.rdu2.redhat.com [10.10.125.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3FC766760E;
	Fri,  8 Mar 2019 02:55:41 +0000 (UTC)
Date: Thu, 7 Mar 2019 21:55:39 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308025539.GA5562@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
 <20190307211506-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190307211506-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 08 Mar 2019 02:55:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 09:21:03PM -0500, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 02:17:20PM -0500, Jerome Glisse wrote:
> > > It's because of all these issues that I preferred just accessing
> > > userspace memory and handling faults. Unfortunately there does not
> > > appear to exist an API that whitelists a specific driver along the lines
> > > of "I checked this code for speculative info leaks, don't add barriers
> > > on data path please".
> > 
> > Maybe it would be better to explore adding such helper then remapping
> > page into kernel address space ?
> 
> I explored it a bit (see e.g. thread around: "__get_user slower than
> get_user") and I can tell you it's not trivial given the issue is around
> security.  So in practice it does not seem fair to keep a significant
> optimization out of kernel because *maybe* we can do it differently even
> better :)

Maybe a slightly different approach between this patchset and other
copy user API would work here. What you want really is something like
a temporary mlock on a range of memory so that it is safe for the
kernel to access range of userspace virtual address ie page are
present and with proper permission hence there can be no page fault
while you are accessing thing from kernel context.

So you can have like a range structure and mmu notifier. When you
lock the range you block mmu notifier to allow your code to work on
the userspace VA safely. Once you are done you unlock and let the
mmu notifier go on. It is pretty much exactly this patchset except
that you remove all the kernel vmap code. A nice thing about that
is that you do not need to worry about calling set page dirty it
will already be handle by the userspace VA pte. It also use less
memory than when you have kernel vmap.

This idea might be defeated by security feature where the kernel is
running in its own address space without the userspace address
space present.

Anyway just wanted to put the idea forward.

Cheers,
Jérôme

