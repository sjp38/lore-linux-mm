Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05669C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 18:14:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF9DC20657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 18:14:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF9DC20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A4FB8E0003; Mon, 11 Mar 2019 14:14:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 055248E0002; Mon, 11 Mar 2019 14:14:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAC908E0003; Mon, 11 Mar 2019 14:14:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 925CB8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 14:14:18 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e14so2992866wrt.12
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 11:14:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=z82DJTNv0RtjwNfeYbFce+N6vaDCseFRWSioEJbSsLI=;
        b=jeIkHVioEIFi3zsZYQjqKEu4N4jWgSo4rrCDW7Ll3ilpymWS6dnm1rnXsuL4AD0aQq
         mW9WTajpagfFkAjD6rbLJ0davxzTMejUQnNk8wzkfYmx1DNZIvqMRK48lMLGxbML7fFq
         qeN/hwREEGIBfCo96o+14ouOIIaYp6lXZ8auuPdGhn8qpHVauL4lxsTjsWryd4xKuL6K
         LDdQSh++58BNAPOTCkdbt+2depvYJKqQZ5PI7aZ/psjbPN9ZLW/JlMfGTwOXuNKnHCVZ
         Gz2WvjrVIuKg0TQ1h27yLSGL04ssggn3MTcuIn/No1M1vZldxCmp+4z0a3aQitZU0xO1
         Lv5Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVakA0XbaRXtKW4mjUStPyJcOM6w8Ji0TdLSY06Q+/l21vkwg+V
	v4i6GT+U2Guf1doN5eeuzbYXTCOsrDvBsM1ucPhtqzKONHZAn3F41bvsn2+k3Yd9H95rFzq9fpz
	LcI5pqKxYVffWgbzeq+HLYNSjfOo7xJX3+4IC3BsO+5JZs9631iywcPmUwy5DJzE=
X-Received: by 2002:a1c:6555:: with SMTP id z82mr197208wmb.125.1552328058118;
        Mon, 11 Mar 2019 11:14:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0ul5nqJv56L49LUnIyhFe9Cd6HaGHLDPyRzV+Z1l2+d3iG5ISqdgOJ1JbrQUwKMJKQzqJ
X-Received: by 2002:a1c:6555:: with SMTP id z82mr197161wmb.125.1552328056933;
        Mon, 11 Mar 2019 11:14:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552328056; cv=none;
        d=google.com; s=arc-20160816;
        b=snZ03Lh76LRsBzcYpFXo6bU/uC9Qp58OYt/QBsM9bHc8GwLFXEezZYdalG11JJryFE
         9d95CtW35r90kDdfR1glii+t7ZydZS1/KStpIRyClo5RGqK6ZABbz9fJIgAgOlaaoVEb
         5ZK/2jNmGuqh4ZXRqPIRYIgRFJYO1AXVQvKxz3GN5/TYCLFONaifsxKPhewWAW+VuHQW
         DO0ZwDa30N0Iw1udH2LNHtzbbeUFiiFs72R4TMNItqV0CxhPtlOoLYsvKSumuXxIs4eP
         8beC2+oa8RyBJRSf/zeNtrv6LaM25jv4EboLy4RJD+fBREURb8zAeAt+Bk1Li8htM163
         So8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=z82DJTNv0RtjwNfeYbFce+N6vaDCseFRWSioEJbSsLI=;
        b=BlstCTNMzsRmqCmq4dHqj2rdGmxprUpbF/8jUzR9dSWlPpIvZQ101exIAsIDNKUx67
         uC9SIN8kTtW9KojWkewWJKmjgD+5UE88hcpKOIy9yk3vl2X8oBt9+ldR45CRPEo6dWxT
         cGWfhBTvovKRA61Ggp/2PU4EfGYqtQDPqOPRKh+PIb/Igaw0yd/xXLXIWmzFu4YlGSzz
         HmPtKdAe5ha84aZWiff9fjrAdSQ0D0Mwaj2t6X4eDM3wAquVLzBLAUz9RK684Z8M9w28
         ArxKDAdNQjypPFR0KEpHeqLa4kPtQvfOerQ5rlJTEOLigsl76vunzC1kcuOgpWSElFk1
         h9rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id o9si1972154wrm.230.2019.03.11.11.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 11:14:16 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id ECD2F14C61512;
	Mon, 11 Mar 2019 11:14:13 -0700 (PDT)
Date: Mon, 11 Mar 2019 11:14:13 -0700 (PDT)
Message-Id: <20190311.111413.1140896328197448401.davem@davemloft.net>
To: mst@redhat.com
Cc: jasowang@redhat.com, hch@infradead.org, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 aarcange@redhat.com, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190311095405-mutt-send-email-mst@kernel.org>
References: <20190308141220.GA21082@infradead.org>
	<56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
	<20190311095405-mutt-send-email-mst@kernel.org>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Mon, 11 Mar 2019 11:14:14 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 11 Mar 2019 09:59:28 -0400

> On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
>> 
>> On 2019/3/8 下午10:12, Christoph Hellwig wrote:
>> > On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
>> > > This series tries to access virtqueue metadata through kernel virtual
>> > > address instead of copy_user() friends since they had too much
>> > > overheads like checks, spec barriers or even hardware feature
>> > > toggling. This is done through setup kernel address through vmap() and
>> > > resigter MMU notifier for invalidation.
>> > > 
>> > > Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
>> > > obvious improvement.
>> > How is this going to work for CPUs with virtually tagged caches?
>> 
>> 
>> Anything different that you worry?
> 
> If caches have virtual tags then kernel and userspace view of memory
> might not be automatically in sync if they access memory
> through different virtual addresses. You need to do things like
> flush_cache_page, probably multiple times.

"flush_dcache_page()"

