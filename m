Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07949C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:08:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C38E0208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:08:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C38E0208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D2B26B0005; Wed, 19 Jun 2019 05:08:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65CCC8E0002; Wed, 19 Jun 2019 05:08:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5252F8E0001; Wed, 19 Jun 2019 05:08:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 177926B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:08:27 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so25210045edm.21
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:08:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mZsuX4TMlp1jaOP3ktEcbI0oP2KshBOzh69rXQmxxaw=;
        b=DwlTuriVNXsaUz/7v26LZSa7D2Vj9XU+JUhZtJ0ZxR8PfK58ppNBP1cOsdVP7xpiPG
         2KwPX1Z7KhuL/6FJsTqJdyriX4GCRT5SlrC6vOEOFwty+JX7ZF+LHwbNXwhZ6VuodXmQ
         iA0/+7CEV2QCPyHGWU4RiG8rSphSQbCbjXovqZbHpB7Lfh264G9/ec7OdxpDPwjgdBCC
         wzzL4Zi6/UNq5hUBz/duLBax+g8stCMlIF8v1/4i3P48uAU/8+UmdXMsgaH97V9TnZTN
         zXZA0q0t/CelnIc4PICWhYw5rEDw529EC1vSDgQyDma9e7ICSu7TnmqNPlRJgpb4dWz2
         zn/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWhENRrx89jVddyuf5ElnDRLHtC3Xb7tneJct78eCblr1AeS9V5
	g58DcqUZpe8cm4YhFXosWSE92+TwYb2j5ddJeM+I7Vn4ZUfhBQiReoslG7Oub8ARncqprEIrYru
	+ElCjaIOjMeVKvlpMBhe+vr4brX4b8MWQSeBulNpC+18+eQrmmbe7zjYs/igR+qfj0w==
X-Received: by 2002:a50:976d:: with SMTP id d42mr4119830edb.77.1560935306689;
        Wed, 19 Jun 2019 02:08:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxZDdxCEBfSbfCBYNONBY2PY9ZQ9Mwdj7p7HcVkzDU2e7WpTNVerAKMlhmDOzGCIcmbDbR
X-Received: by 2002:a50:976d:: with SMTP id d42mr4119785edb.77.1560935306110;
        Wed, 19 Jun 2019 02:08:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560935306; cv=none;
        d=google.com; s=arc-20160816;
        b=DJc+LZ4sxjDyzACSlCKvyhSuQXMjRq4kfVYFyXgWolIXHdwQrPyOpzsPMbIKi4H2ew
         xK9CY3OcMFDxvs7B+IOihPq+yFkm8zHauLoyaTaqjksPeJ9AP4W2fHt1OCB/6GTPKoxa
         yKmGgAfhTiKYj0r9lrC7z9KiGNkDf9RlBUd4DWLJeiNLK65RlRXkelOhHsoA8MJzku6j
         shptmM0u2rtb6eIB66y14Yg0sutHJhZgNFZH2SaNFowhujywRGK7rT+Yp/0l+DBqEUrw
         FV2mII4S33zZ7lpV45NLtUK9nvJ7+mckmhYHZkEzRpM8dcvvRXbZYRZxTqP4gTcU1D8H
         FClw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mZsuX4TMlp1jaOP3ktEcbI0oP2KshBOzh69rXQmxxaw=;
        b=irzj4o+QUvX20ZiJn7t/5q/AoV/lvyf+5TqXgs/lRwmv+lpWyzG5WyTbbtFQqLKQwx
         w6IQagsuYdTzQ/i7ztAH3OzGoMggSw8GdUkeR3Q4cfVzgGoMR3FUj8vINQGrMYcF364C
         mle7iWbrrQi9ygLZsgh+zGibIkrAcjjv0XU+rfaEAunwMS3aqBkGC6OkzgHNrtd+08J3
         TP2As1rmXuawrr40vrR8r/iLmg0rPARtLRhz9JMQZQy8lfpAN/ZV4HHyeEKQS6ai9jdU
         +0B6/NZ8ZxRMST5B9byADTlZr2MCOCaBezWKG/LvrRB6KPp0DI4upG6S5K/2IxRMJuNh
         Essg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l22si7447136ejb.205.2019.06.19.02.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:08:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 618CBAF57;
	Wed, 19 Jun 2019 09:08:25 +0000 (UTC)
Date: Wed, 19 Jun 2019 11:08:24 +0200
From: Michal Hocko <mhocko@suse.com>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
	Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
	akpm@linux-foundation.org, anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190619090824.GK2968@dhcp22.suse.cz>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190618074900.GA10030@linux>
 <20190618083212.GA24738@richard>
 <93d7ea6c-135e-7f12-9d75-b3657862dea0@redhat.com>
 <20190619061025.GA5717@dhcp22.suse.cz>
 <aaa9d3af-0472-ffde-a565-fe6a067a4c49@redhat.com>
 <20190619090126.GI2968@dhcp22.suse.cz>
 <5630056e-cc60-c451-714b-f8524eb70839@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5630056e-cc60-c451-714b-f8524eb70839@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 11:03:49, David Hildenbrand wrote:
> On 19.06.19 11:01, Michal Hocko wrote:
[...]
> > And if they do need a smaller granularity to describe their
> > memory topology then we need a different user API rather the fiddle with
> > implementation details I would argue.
> > 
> 
> It is not about supporting it, it is about properly blocking it.

We already do that in test_pages_in_a_zone, right? Albeit in
MAX_ORDER_NR_PAGES granularity.

-- 
Michal Hocko
SUSE Labs

