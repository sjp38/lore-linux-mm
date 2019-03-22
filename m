Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FA10C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:47:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35F5A206BA
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:47:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="C9e2KlVV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35F5A206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC43C6B0005; Fri, 22 Mar 2019 13:47:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C74606B0006; Fri, 22 Mar 2019 13:47:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B64C26B0007; Fri, 22 Mar 2019 13:47:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89D3A6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:47:19 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b3so3004113qtr.21
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:47:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=rFwzn/BBO25AP0s77MXmb0hXGtOvd/fOwhwfuRoZrBw=;
        b=jkKCbqtYr4xblFl/b5Al+RFEQG5124DSe5QHb0UdWcXd8NdH3lxFHw+WdiuVHUthxh
         QoIMny9fbceVySy3YHGEFMU5Z2xCe5uzI7MxwfHEAnAhfHqcxD43je07UXwLwCVpGl//
         fkszfYE79/F6JvNWIIydI2PP3A+bwTZMREuRGzNwinGZ6Ol8VpqBL+ngmxdGSVK24taQ
         NVtRtKW2vptoNuY/JN2jZB3gRgOjM/9ESG7VRwThx0Ys+itgv2opJ3v39BNgNeK204jx
         VV0TWiLTYH3quxSVtASt0799XXOBB0Dl6wH59wxDBJSs56SXB1Y9cI90D7L+zPC/q4Ek
         xtgQ==
X-Gm-Message-State: APjAAAVLF7jGmhlcrhOughu1sreNH4gfk9ug/VOtTW6VA0MPQmfH6LNX
	RRhp+mQqhlNiQj4ecVHxDX2jpHjC0B4h5R2g8lBiMtNbf09fNO+ESljLZV+WME0GXgUkaz2WDTD
	2lUtqyUYThCsoc/5SDEXe+142D8xfHpao/N/jll37L1in05wlY+Vc0f2vm/pfBXQ=
X-Received: by 2002:a0c:b597:: with SMTP id g23mr9087429qve.142.1553276839348;
        Fri, 22 Mar 2019 10:47:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxByWAr+zXjHm/pBhuoGsLtfDcL2cCDXW3L47ZGSTaGlTHmp2PLyF01QB7QAEJs29UurUKE
X-Received: by 2002:a0c:b597:: with SMTP id g23mr9087383qve.142.1553276838640;
        Fri, 22 Mar 2019 10:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553276838; cv=none;
        d=google.com; s=arc-20160816;
        b=rhWOvObH5huYjswLApOe/hdsbG+ELILRbKK/kt7DknB+F+QpoYZ9xJ8OWnYy2/0fZv
         JJUlQKpUJO8q8BRNT3OfYqz+TJAk67GrhuqGploDOAdZ8B5Y1pApNarkON8MmbSX8obd
         IuSkKJsH38kXoOglyfcZpw5TwMMHS3NCoGvSHOVaC6KB8DC+uX8ivLEzl0Nh8IckCk73
         io3LUQp/KbcFtJ672yKDogSG8fE7/H0GB10baKlmu8KZIEXW2bxvyHFNM394bek/3Ox3
         TD4kGj0B0IC7P/FyknbhMWhPidocuN1NB6ow2nYSzTt3ZHCoRh/OtDgp/gZDV5DYFs6p
         en3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=rFwzn/BBO25AP0s77MXmb0hXGtOvd/fOwhwfuRoZrBw=;
        b=kIt788htsvCkbYU8/UEPuFkEgP3yeESSnmUXEqZfqgoa4VE1xI2JQ9597wz7lGe4hg
         ISXMQw6XLVqOavdCRbmPq/1CemRfBGv6r8N+F8P/EIqRzqhuovPkm02sbYgYwmXqX21e
         6j+CdJQ39ueTIJugLplzYe4ISvFkzEoi3lG+Y/NRPKsy9Gvx6/E4akeO71xfspEsLG5L
         f1XoVrkJajqj2lwCdmUOVWLlb2BVHpH9GokswgFMj8skHDDY9QrQ4jscMTTJ02PXCJWq
         oKiJLAPoACqggvEs8i7NcQj+fb//GmLzbujdd6qJZzeMMYtgYNiSZ7cdNg+z2BxEv+RS
         bO0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=C9e2KlVV;
       spf=pass (google.com: domain of 01000169a683a0ed-3fa1b014-8efa-4c8f-a7e1-958e9eccd693-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000169a683a0ed-3fa1b014-8efa-4c8f-a7e1-958e9eccd693-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id d26si293307qkk.57.2019.03.22.10.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Mar 2019 10:47:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169a683a0ed-3fa1b014-8efa-4c8f-a7e1-958e9eccd693-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=C9e2KlVV;
       spf=pass (google.com: domain of 01000169a683a0ed-3fa1b014-8efa-4c8f-a7e1-958e9eccd693-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000169a683a0ed-3fa1b014-8efa-4c8f-a7e1-958e9eccd693-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553276838;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=rFwzn/BBO25AP0s77MXmb0hXGtOvd/fOwhwfuRoZrBw=;
	b=C9e2KlVV2mDdwR48uPojXdogeRsWVjBuGjnXSR99D/1/hWBT97akhkkrahqu9rfV
	nN5akCDSy2A3KAjstu1nDudPH1zBtFR02pVvL1AikDrtcJvXvztaWo8qYvkiIriJfTL
	NBMJ+uk3vWOjFYWC7WnzRVoNt+tbkkEx+reCBk/c=
Date: Fri, 22 Mar 2019 17:47:18 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Waiman Long <longman@redhat.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, selinux@vger.kernel.org, 
    Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, 
    Eric Paris <eparis@parisplace.org>, 
    "Peter Zijlstra (Intel)" <peterz@infradead.org>, 
    Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/4] mm: Implement kmem objects freeing queue
In-Reply-To: <20190321214512.11524-2-longman@redhat.com>
Message-ID: <01000169a683a0ed-3fa1b014-8efa-4c8f-a7e1-958e9eccd693-000000@email.amazonses.com>
References: <20190321214512.11524-1-longman@redhat.com> <20190321214512.11524-2-longman@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.22-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019, Waiman Long wrote:

> When releasing kernel data structures, freeing up the memory
> occupied by those objects is usually the last step. To avoid races,
> the release operation is commonly done with a lock held. However, the
> freeing operations do not need to be under lock, but are in many cases.
>
> In some complex cases where the locks protect many different memory
> objects, that can be a problem especially if some memory debugging
> features like KASAN are enabled. In those cases, freeing memory objects
> under lock can greatly lengthen the lock hold time. This can even lead
> to soft/hard lockups in some extreme cases.
>
> To make it easer to defer freeing memory objects until after unlock,
> a kernel memory freeing queue mechanism is now added. It is modelled
> after the wake_q mechanism for waking up tasks without holding a lock.

It is already pretty easy. You just store the pointer to the slab object
in a local variable, finish all the unlocks and then free the objects.
This is done in numerous places of the kernel.

I fear that the automated mechanism will make the code more difficult to
read and result in a loss of clarity of the sequencing of events in
releasing locks and objects.

Also there is already kfree_rcu which does a similar thing to what you are
proposing here and is used in numerous places.

