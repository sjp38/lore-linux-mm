Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F23E9C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 23:46:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A643277D8
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 23:46:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A643277D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2DCD6B0003; Sat,  1 Jun 2019 19:46:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDEC86B0005; Sat,  1 Jun 2019 19:46:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF4BB6B0006; Sat,  1 Jun 2019 19:46:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9533E6B0003
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 19:46:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f15so18876526ede.8
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 16:46:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zOIkGWUsP2A+d8mupldtZwz0DvLmG/x6khE8L3q/G64=;
        b=Ew7oxV+pO60jA4euKEc1qzXmPpLz+8q2pAejqnpfJ4DkZMHFOWliWxFpLJfFrpXB9z
         g5neow5eNAE+snp9fjUCqXrDVG8AENOLTTb/ove7m5EDm1xVxROaFtb9w5AtacOT7IQb
         QFLMvEqdObhszZM5lzjz/QmRhio9GWYMFG+MjQxXcNSe2Lsqphiq6ONEMB/LPNIFz6mp
         5nq56uXogCO2by3gxQUxQnd5AgcXGzVpxByefLldX18Y7ykKypV2z4KPicCxh3ICGeLa
         gU4b6cRmLKoaVTNsJMyKsdMcMNKd6ry+xn1G/kPDKAwoHexDKiQ7GjNyizafCsgmRlz9
         ry3A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAXL4P7Zh2R6REonZFbE6EgWyMIK/T8Xael7Ik8obwABIAMt5bMc
	WwDIZoSFWfn3FuGS/78yMeuz5fsMofgD71CUfxtcRBeREazZ+gJR+zbPzggljHJ5BEh7Bc4SR3o
	txRpMJzeNGcBLM8zWVJpewgvj6Wrf2dOq15oyykmxeuit6XDjDdyL+eIJfQJKgZA=
X-Received: by 2002:a17:906:4e9a:: with SMTP id v26mr2853115eju.80.1559432808084;
        Sat, 01 Jun 2019 16:46:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1IEOGWqr3ROYoC43G9d9HK3MLoq5nWVsDpIq/TuRf9P0NdY2JA2Nm4lcPZcmIwYBIaG5u
X-Received: by 2002:a17:906:4e9a:: with SMTP id v26mr2853071eju.80.1559432807165;
        Sat, 01 Jun 2019 16:46:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559432807; cv=none;
        d=google.com; s=arc-20160816;
        b=LmIvVzVq9xBRF2Pw2EeJ1R9Vh5VPnIXOuoHpWs9Qm3h9oL9T/DQlY5ohFt+BLw28ju
         AKMzbOVtNOhEzrqsDl9Ac/vP10I+Ry75ir01syIto9oesFAdxIyK0zqtnRpvAvZP+j2y
         NHviUbmMdIq3LaghZ4MXQiiDLwUVW9uDbzdSb5fgP1BZ1FjDtWvZB40fuyf/CSPkbabs
         mXGauph5fciAfd0/ZAufFe4ktzFuWRC3WMe9RTVYq/4Gi7DHsXHNAjkBDaryvgQ2K8+2
         j2rOzL1Jd8XfWCKhhkWcE45lmGOKbM7uw+rz6qBSkI3VbrBSDnwOhlyLirjWZ9x+iPGD
         RLCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=zOIkGWUsP2A+d8mupldtZwz0DvLmG/x6khE8L3q/G64=;
        b=MqVvp/Jgbqu0LweTrLduC1isjcmIIfNJ0JRUpnMRN//OwaX01dHa5HQHHgPaudJws3
         7m1P6vSzKyG2coKdGSH8xupeXIPiKKId+VSDYiBc2LTwUm5Vum2uv7xy/TeavQQjnKR5
         vZiV6Q9kxuFk/dIu+qBlt+4UsjJjlPylhN3SgFSObxdyOUOvy56AOebD7jmGx/J5+ITe
         qVoDM3CzAtQ1P6xLeczJlFWdS4oQt8BkL+cn/JZP6KqQOgcokpgeK+rUVlhqNbog7pvN
         vCm83qeiLpcMBTiUY6vLZlpvUpWNziPk4/8FNuMcJT+TXKQbBWNbG7s4NWf1iBsrg5h/
         X/ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id p25si7528503edq.356.2019.06.01.16.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 16:46:46 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 12DA014FA9CFA;
	Sat,  1 Jun 2019 16:46:44 -0700 (PDT)
Date: Sat, 01 Jun 2019 16:46:43 -0700 (PDT)
Message-Id: <20190601.164643.756724745563418604.davem@davemloft.net>
To: hch@lst.de
Cc: torvalds@linux-foundation.org, paul.burton@mips.com, jhogan@kernel.org,
 ysato@users.sourceforge.jp, dalias@libc.org, npiggin@gmail.com,
 khalid.aziz@oracle.com, andreyknvl@google.com, benh@kernel.crashing.org,
 paulus@samba.org, mpe@ellerman.id.au, linux-mips@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: RFC: switch the remaining architectures to use generic GUP v2
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190601074959.14036-1-hch@lst.de>
References: <20190601074959.14036-1-hch@lst.de>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Sat, 01 Jun 2019 16:46:44 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>
Date: Sat,  1 Jun 2019 09:49:43 +0200

> below is a series to switch mips, sh and sparc64 to use the generic
> GUP code so that we only have one codebase to touch for further
> improvements to this code.  I don't have hardware for any of these
> architectures, and generally no clue about their page table
> management, so handle with care.
> 
> Changes since v1:
>  - fix various issues found by the build bot
>  - cherry pick and use the untagged_addr helper form Andrey
>  - add various refactoring patches to share more code over architectures
>  - move the powerpc hugepd code to mm/gup.c and sync it with the generic
>    hup semantics

I will today look seriously at the sparc64 stuff wrt. tagged pointers.

