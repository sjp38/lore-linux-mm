Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D359DC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:48:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9455D20840
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:48:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9455D20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 409006B0005; Mon,  1 Apr 2019 10:48:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 390076B0008; Mon,  1 Apr 2019 10:48:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2591C6B000A; Mon,  1 Apr 2019 10:48:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00FF46B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 10:48:00 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d8so8661280qkk.17
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 07:47:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=Nt8nCkiL/lmRXg5mImkQVFR8ydDkGxqOHtXpP9B9HMI=;
        b=nxXGooJI33q3OnJT/MHrJmJ80i6pX2rDEyo9NWT3ez6cNjgXRZEDo8wh31VjzMgS3q
         ECyfVSddScADl3cqFsZuJzko9DOM5WPe0lnLellAzTau2wi/sBPGFmZal8NeOazoP3GN
         cDDG9iGyloZkgY05Up4XFrunUcXiUxgQEkdRLUINMo9spJqFWHVjJK3MZVfQ3vtLCi7+
         uMKQlTXJ1eDbqAHdd0sJLy9V6US937RKF4cJ1L5xG2PvFB8e4v+FKJ5JkZRSOj3ZWrds
         5wb5vl5EpIyq7VJ3viZCkuAad4i7yH+eGNbeYJ3327l3KOzgUCb2cS+6XOweNR3NxPv4
         GDKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUupzbHI2I3AoCpitrsuPVFNP7plZj/tBYhO6fTHCb1xfAXmkCu
	RubEW6dhC1wijOgcWFcKEQqP+xZMAsrQTd/eLjMkJFGNtxbCJV2dq+lTe8/zIdo6vrg41zuCYYi
	lgD5Gy+mWGlWYVJcgdBtGpHWk1t8OcPfe6Y7UCwIFsrmptzhadI4/5/BumWXIbCx6Ng==
X-Received: by 2002:a05:620a:1407:: with SMTP id d7mr47352563qkj.189.1554130079771;
        Mon, 01 Apr 2019 07:47:59 -0700 (PDT)
X-Received: by 2002:a05:620a:1407:: with SMTP id d7mr47352537qkj.189.1554130079310;
        Mon, 01 Apr 2019 07:47:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554130079; cv=none;
        d=google.com; s=arc-20160816;
        b=PtgH2/u9cdKlTnf+GImM/Wrb+eyyc5yT33w3LK7CUcTAVFnQp/pnaPHuvzVttu/X+W
         kQUJyt0hAjWsqHoqcW230QJ8u1EvYq5XAK5R7sY1iAT1Zks+UOfRO5BKEAApcYgpcUz7
         031lRg2AzWAeKWB/oiZEQFIPSAqHqW3Rsblaoc4LjNTNrRxOKnaaAFvepuPYVHHK6hDu
         0acYqOkT0p8xyb4uxjffYL7FUtCgESgQfY7+glX/2VVpgxbViRJYTz1Kp7w8yr/+o/lV
         68VFvRnDQd5FKgX1KuExMcp3TrDAS2iiNyVz9hBVDaCs37C5Bib+1anzfjYYBbXpwxzu
         J4uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=Nt8nCkiL/lmRXg5mImkQVFR8ydDkGxqOHtXpP9B9HMI=;
        b=HicGAAUgGnomWmtuzrcFTqglOGdrKApezmNt1yGcujrrSLmj7h1fVUFcs9bjyboGjr
         77Drm5srjVOTEe4fQ80tAiz3Ule92vXs1Ydbd4g5VEbHpcVnOa0ky403pQrptVBoLhIj
         CxeGIKlj/KQlaQBq5zyZ/51ZzOfsDaRBp/VirDS/y2EdASQ52VRcoIWUIafVCVvFuHCM
         iWHC1kiHtYELSMkGhRh2HJxm5N+E8SOJx7wB09W5PWbdGHcxaWwhQya48ugzAeu21iaJ
         IrQv837IVYUCb063P+FIlSxMcSDRHcd5Q7KXFNTJmF8Pmvzh1ba1Lfqv0bWgMF0ZEQGJ
         yHzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u2sor10594621qvi.67.2019.04.01.07.47.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 07:47:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwzMFehCXyKpzmyvfdZzFoZbM7plT1F+hAXxH2SANmhbRwnjoxXtZ7V+qdz4DDg0+b8E538ew==
X-Received: by 2002:a0c:d1a6:: with SMTP id e35mr53515321qvh.174.1554130079126;
        Mon, 01 Apr 2019 07:47:59 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id u16sm7752118qtc.84.2019.04.01.07.47.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 07:47:58 -0700 (PDT)
Date: Mon, 1 Apr 2019 10:47:56 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190401104608-mutt-send-email-mst@kernel.org>
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org>
 <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 04:11:42PM +0200, David Hildenbrand wrote:
> > The interesting thing is most probably: Will the hinting size usually be
> > reasonable small? At least I guess a guest with 4TB of RAM will not
> > suddenly get a hinting size of hundreds of GB. Most probably also only
> > something in the range of 1GB. But this is an interesting question to
> > look into.
> > 
> > Also, if the admin does not care about performance implications when
> > already close to hinting, no need to add the additional 1Gb to the ram size.
> 
> "close to OOM" is what I meant.

Problem is, host admin is the one adding memory. Guest admin is
the one that knows about performance.

> 
> -- 
> 
> Thanks,
> 
> David / dhildenb

