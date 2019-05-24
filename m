Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0141C46470
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6918321872
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:06:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="g/ueHChD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6918321872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2092D6B0273; Fri, 24 May 2019 13:06:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BBF76B0274; Fri, 24 May 2019 13:06:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05BFC6B0275; Fri, 24 May 2019 13:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1AB26B0273
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:06:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f1so7422953pfb.0
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:06:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Nd2Lj9Q7aDsjzQ8w/THzJxRiwvjWHcaNNXAaDuTseEo=;
        b=S0/gf/rA8UxVwRLk9JydDnmxc+WEIesQhU8UL6LHEauRyniMy38XKk0bCjywKjWO7s
         DKah/tYZMPLXkmxzT7Ab+5CTgt75lRiMFsK/lnYsXtvGtnyF58X7RcXj2Niv8Rl033aO
         4VQn5vQGgfVAH1vx1ved4wROSDEj5QwtLfYGM3gRtT9duH1bslQHqvVVlq58bIQygync
         VBaX9vSnjlgqnTOpUeeX8hwgaFjlGf0jaweO/dx4qi9Ze11qUls8RBqN3FKHt+CUOXV3
         wV4DI+YPxe7Y5RKOJzlUdv+ddZzmm4pcH+tkuvtnXTXncgkzHs/wCKEM50SEeJfvJbWC
         /Ayw==
X-Gm-Message-State: APjAAAWyg/cxMQMZMPCRIttF3t2RVSWDjQD/eDq6cuiXOCOcRB96u3oV
	h/RL19Aia+bpJCdIFcZ4lKbxV1yNdSqkrjexYiyC7cwyJHKe+ees4eSNy0ET9Pdble6DyPErj3g
	kwIt2wjDEAKeTqTk0Qr+8htNmJCO4VtM2zSacyMvC0JBYPgY6YvYwa4LofgPsbYvvuQ==
X-Received: by 2002:a63:e408:: with SMTP id a8mr19551585pgi.146.1558717609292;
        Fri, 24 May 2019 10:06:49 -0700 (PDT)
X-Received: by 2002:a63:e408:: with SMTP id a8mr19551514pgi.146.1558717608272;
        Fri, 24 May 2019 10:06:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558717608; cv=none;
        d=google.com; s=arc-20160816;
        b=r27aQtmhBxCagi7TwBvk/Y6kXXZiKyzrOO0P95ghdA7evXKx8YPXYrHx9MnGBwLAmx
         HV0OuMLEI67d/y/EgPPnwUiZ5vxGK7tqz++PipZUNHkNJQk63+PKeQoCmysfmI0GGjRr
         W0EZ3x3B2SGq4zXeXsC6/n7A3yGcTzMQ4gsq+xTqpGgKqx6KCYBIAYJV8fugRigav15U
         ErYDj4jrx4IETx0KXkZUaTOZ0jTfcTivKl5viqH7uwWxjokpVe8W2yURzDXdoQwA1v7m
         Kuy6ziqCF+KC+/9zpY9zauVj1RcYSqURrcX38NM24WQBFOJS6iaqA2d4clzNd3W1qB81
         MV+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Nd2Lj9Q7aDsjzQ8w/THzJxRiwvjWHcaNNXAaDuTseEo=;
        b=XyJgo34M4NyE42VgpNKiQJc8/XVzd00PuzfH0moegZDxQZGmvX1ipksTcpymKGrkpI
         8o9Xu7h/JGJmk7phn62kCz3fe/pApM9qr9xRdcq0yAqVxk/HTwifcfBWepFrRsTd/YTh
         jWAq49gCnCuJtyvsiiDGqxSoRM9dpydz02zKyYecOFlLPFzTY8/jbI4dZ/L6omaYit7P
         N7oiLNcW4hkizATHGzZVp0XvOjen2ILnM/WMm0XqoLtEQGnJMUC6/NZG5T8PMgcJEnDF
         IfrrYb3OVdW8K0k57t5Mpc/bkLxTg7L991Eobn2qEos2RgBoL8PWAfbC8bEPQ64MhMYg
         ht4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="g/ueHChD";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m30sor3425990pje.13.2019.05.24.10.06.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 10:06:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="g/ueHChD";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Nd2Lj9Q7aDsjzQ8w/THzJxRiwvjWHcaNNXAaDuTseEo=;
        b=g/ueHChDmzv10RhToAZSHSTBKjmteHa2+GUrTouq4WT3zsId5XyPYsDLo0VEZ2lsk8
         xxwdc+zYgqElB7Hvgr2sCKnjTYGslk7l0zl7pL6buSlo4cp3mxDXesT1bju4whIW9YTD
         Xuy4SOumA5cjyBIoyw9VlY9FgRNaGt/IqUr+XyQYlD5nDnja70C44raTby78ZUIDd1gl
         a5Sp9sBHrPzzyBHOEJQJe5yj3Kd+hIFzn2zlMyvZHtC4Byo12tj+FkG/59LC1tfn7w8G
         Pxe7hqzs2TKDKBOdg5W94Xk89woskg4bqexiagAxDpcv/zg5EhumBoaR1/Fa0bIqYdRx
         aAIQ==
X-Google-Smtp-Source: APXvYqyCulQRmI3PhrXkVMrT+R32nDK0uKlw4vnyyo1uY2kcnPUkhXPwQBLT45X7DGw97sr105YGzg==
X-Received: by 2002:a17:90a:a616:: with SMTP id c22mr10749010pjq.46.1558717605295;
        Fri, 24 May 2019 10:06:45 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::805])
        by smtp.gmail.com with ESMTPSA id h5sm3485126pfk.163.2019.05.24.10.06.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 10:06:44 -0700 (PDT)
Date: Fri, 24 May 2019 13:06:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190524170642.GA20546@cmpxchg.org>
References: <20190523174349.GA10939@cmpxchg.org>
 <20190523183713.GA14517@bombadil.infradead.org>
 <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
 <20190523190032.GA7873@bombadil.infradead.org>
 <20190523192117.GA5723@cmpxchg.org>
 <20190523194130.GA4598@bombadil.infradead.org>
 <20190523195933.GA6404@cmpxchg.org>
 <20190524161146.GC1075@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524161146.GC1075@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 09:11:46AM -0700, Matthew Wilcox wrote:
> On Thu, May 23, 2019 at 03:59:33PM -0400, Johannes Weiner wrote:
> > My point is that we cannot have random drivers' internal data
> > structures charge to and pin cgroups indefinitely just because they
> > happen to do the modprobing or otherwise interact with the driver.
> > 
> > It makes no sense in terms of performance or cgroup semantics.
> 
> But according to Roman, you already have that problem with the page
> cache.
> https://lore.kernel.org/linux-mm/20190522222254.GA5700@castle/T/
> 
> So this argument doesn't make sense to me.

You haven't addressed the rest of the argument though: why every user
of the xarray, and data structures based on it, should incur the
performance cost of charging memory to a cgroup, even when we have no
interest in tracking those allocations on behalf of a cgroup.

Which brings me to repeating the semantics argument: it doesn't make
sense to charge e.g. driver memory, which is arguably a shared system
resource, to whoever cgroup happens to do the modprobe / ioctl etc.

Anyway, this seems like a fairly serious regression, and it would make
sense to find a self-contained, backportable fix instead of something
that has subtle implications for every user of the xarray / ida code.

