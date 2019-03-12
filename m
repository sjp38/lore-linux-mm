Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FD44C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:53:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E89012077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:53:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E89012077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 845818E0003; Tue, 12 Mar 2019 17:53:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F6D68E0002; Tue, 12 Mar 2019 17:53:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C0288E0003; Tue, 12 Mar 2019 17:53:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42ECF8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:53:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d49so3702342qtd.15
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:53:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pm5NAJrXyOCdpuH/d+P09yVt/xJySkPki7oB6uY3cPI=;
        b=tGOG73gK2zlg1SqMUyLPnBRpAZO5ijNgdmRm7aU/dA+0I4fjyCHFea/2ByfR6G+sUo
         Vy1NY4JeYmewQcD9UEl90pFSZdTuKTBkaRGHl5d7fX4zSXKOcq5v/8JmBntRSE2DVSUS
         XHlPIeDX0kzwgPaYM9oRkB/5TiSipjO4fp3st9caaJD/nlohbdcnEw9JXPsZNL7EHvnE
         3JxT//CkpwIF+VNMuk5o8JLypUJwltReqf7snRlLnSt2M7sGE6nqlyLs5xJ/SvDpyins
         T0Sb+ovsSXdIBoNPCgf0/pSBTl7lUmzgOLWdNob35h54vHA9GnNf/a4vAKShLLRx7f9b
         9/Hg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUkGT16pFoj6HIDZNfcxWFEd2P8/qqmX6yUlTRsn448JvGSwSjU
	FbTNzOj+uxIRqhCgIuiErgjp6hRhKarDSMSkVGvaLmqJOygRtVw6B4p4uH/w99eN3Kwi1/nbyiJ
	ULVhVUzQnX7M7fr4ksr0mO3VcNU3fk+0glXzMqA0V0R95lK81VDjl+zg0VMLp1quA6A==
X-Received: by 2002:aed:3a41:: with SMTP id n59mr32142498qte.344.1552427609060;
        Tue, 12 Mar 2019 14:53:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQ9ky443AcZA0aqlMPaOgs7EWqDPqDuQv9g5bY0fZplKFZlNxyzUq11zeRLdpUeoueq4JO
X-Received: by 2002:aed:3a41:: with SMTP id n59mr32142470qte.344.1552427608436;
        Tue, 12 Mar 2019 14:53:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552427608; cv=none;
        d=google.com; s=arc-20160816;
        b=gdGu6QQRH1hd6ry7h2ZAIGOGUcGLUvPJFpv4FWqWrhCUtKobXDR+l8sz0rXlNncJ5z
         J6XI5USF3l4VImc99P6IWDMKskk2abzS7F0d0WI9lL30P2uwWKSD8BT65D8C+KlKB+N9
         Eoev79DrTbFahtRSzyB1OVz+QDuV6WbDeOxdYdVfBwV7J/XenIdfiHLx+foMP4+xQ0bP
         BVTb9Qv18bbOy1ktffxlgMGp88L7BKa6aFNVHAC8b9ccEhyLNRCyvQ/j2rRaYnTh0jqJ
         HvWbrcPaZi4T7E58117RT5rcCr8HLiG9SRidCTU87tklZjaNnvHUS6Sf6YxYb4fYth3I
         vmJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pm5NAJrXyOCdpuH/d+P09yVt/xJySkPki7oB6uY3cPI=;
        b=shd8QjEllOsk/S23EfhTRGeb0p/u/aex76uhlPbWTBYAIqLELJYLBngDO2Yl8eZCXt
         r0UAL8ZrQXHnQiHfWBKzm2mQbdZ3kNGL2L2Si/RByYgGJWSwL4O9UJQV65/4zeQcttIp
         9Hm260vgYu6AnxY/eaEEAWaAGPm52dtcyO398SC6K02c6wdicvQq/seZJ7p4fSh0uQLz
         VE694XQvgB3B73SsXDtAXw8TcPDtR0p59U83D7fHLj8DmcoDkdsh9NPmtSm9S1Dr/adp
         dKpzlnAj/vVtdGMIAYuedPBR1AKBX5yhmvjB/TlGUBfumJdYk6XwSHGNm0LpD5fTfOZX
         DyAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z82si2958209qkz.122.2019.03.12.14.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 14:53:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8D2298666A;
	Tue, 12 Mar 2019 21:53:27 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 35DAB60C6E;
	Tue, 12 Mar 2019 21:53:22 +0000 (UTC)
Date: Tue, 12 Mar 2019 17:53:21 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, hch@infradead.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190312215321.GC25147@redhat.com>
References: <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
 <20190312200450.GA25147@redhat.com>
 <1552424017.14432.11.camel@HansenPartnership.com>
 <20190312211117.GB25147@redhat.com>
 <1552425555.14432.14.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552425555.14432.14.camel@HansenPartnership.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 12 Mar 2019 21:53:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 02:19:15PM -0700, James Bottomley wrote:
> I mean in the sequence
> 
> flush_dcache_page(page);
> flush_dcache_page(page);
> 
> The first flush_dcache_page did all the work and the second it a
> tightly pipelined no-op.  That's what I mean by there not really being
> a double hit.

Ok I wasn't sure it was clear there was a double (profiling) hit on
that function.

void flush_kernel_dcache_page_addr(void *addr)
{
	unsigned long flags;

	flush_kernel_dcache_page_asm(addr);
	purge_tlb_start(flags);
	pdtlb_kernel(addr);
	purge_tlb_end(flags);
}

#define purge_tlb_start(flags)	spin_lock_irqsave(&pa_tlb_lock, flags)
#define purge_tlb_end(flags)	spin_unlock_irqrestore(&pa_tlb_lock, flags)

You got a system-wide spinlock in there that won't just go away the
second time. So it's a bit more than a tightly pipelined "noop".

Your logic of adding the flush on kunmap makes sense, all I'm saying
is that it's sacrificing some performance for safety. You asked
"optimized what", I meant to optimize away all the above quoted code
that will end running twice for each vhost set_bit when it should run
just once like in other archs. And it clearly paid off until now
(until now it run just once and it was the only safe one).

Before we can leverage your idea to flush the dcache on kunmap in
common code without having to sacrifice performance in arch code, we'd
need to change all other archs to add the cache flushes on kunmap too,
and then remove the cache flushes from the other places like copy_page
or we'd waste CPU. Then you'd have the best of both words, no double
flush and kunmap would be enough.

Thanks,
Andrea

