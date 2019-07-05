Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CC9CC468A9
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 18:13:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF54D216FD
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 18:13:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="d/qRYpWa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF54D216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52BE56B0003; Fri,  5 Jul 2019 14:13:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DC498E0003; Fri,  5 Jul 2019 14:13:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CC7C8E0001; Fri,  5 Jul 2019 14:13:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 271646B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 14:13:48 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id b139so8931722qkc.21
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 11:13:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=TeLEUHqZcS2XHWs9Stu73yoSxS785h8O3OY1oogKKCQ=;
        b=lOLsg8WnO+igeO+8eCyalumJbC+l8X5eTtlu2zobCP0bGWW/Jj2kGrHY/zEGJeYbTp
         9NQg/IQDdE74kbpibZdw32Ir9Y9FnFKIAx2OkIdVv4W8NrNHpBuJwT7TreP9ViKuc/8k
         TN8TXbMFBhAj7qFxDsGs9QTE1tslMUVp/wpHZzVafCz0pCjN059oZsiTYFe9msgf3cGi
         j7m6jREvXD/hyv2W2fkW30fUEmxjg2432rSZtolOjmTO/qgxHSuClV4DrgtuugxyYF93
         XjnqAlbV3ekyw9kS6OHSCCBda4pQlnDTY8BrSD9l+8/FZNX/lGd2jixi2zQLhjHGZ075
         DY4g==
X-Gm-Message-State: APjAAAVVp+OVXuRkCa7uAHvvIlmTWRGR/p7RxWbDbmAwOjYvjpDU4AKc
	WjZi63coBALsrJlDZyMy4JfxTIwwMZ57XjSxgdl7M70Yev3ymj4/qeZJKyGvNpgJ0Dfofg2HltE
	7/hbxV+JPcLFjbijothDE3ooDzayuQ2//RPK5oMa9P3UkDQj/kQiTCTMzRxL0gYE=
X-Received: by 2002:a05:620a:69c:: with SMTP id f28mr4167469qkh.274.1562350427840;
        Fri, 05 Jul 2019 11:13:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdAPaIOHsqf2KlyNUbNnou6+zXlDtMN+Ao/CTfXLUN8SOWcb6/owmLazSV1Na5m7jXGH+v
X-Received: by 2002:a05:620a:69c:: with SMTP id f28mr4167402qkh.274.1562350426728;
        Fri, 05 Jul 2019 11:13:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562350426; cv=none;
        d=google.com; s=arc-20160816;
        b=fvvJabZQxNw1YXZCytickDkMDnuZTSXiVobUkWvLIVHI4JdI9W4JponWAYrr/mXtnQ
         tLjuQYze/6ATPLtaWFzj8jRq7JH0JZcPkubWlcnSqqZ0nOODrYsqLeHsyYM+ag5uXVsU
         mEycJMAOv2up58XiToSFY/06RulGPYiYwhcPqJ8CV/5N0VSgBI1XTDIDg6Bm7+KpsWO6
         IAB84IY3f6Xk7IyDE3SL8tJsODsQ//uuM1JZXDmJCg8wx66GAoYMllmCSb1RtqdQ4YuY
         wWCcFFQA3uSsvvJv9MowLNwIsTmYhhvrG99rZHnEcScQS+MNC940b+FwysFHTAO2M0Hw
         /Otw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=TeLEUHqZcS2XHWs9Stu73yoSxS785h8O3OY1oogKKCQ=;
        b=OouqAh3CGm66O0IRsmn+a8zJHfncK0DLzXImiCNzZkWAWsQbYLRoHZPr5XvGtKOk00
         4JwKEZSBJu0081o8dYyQ6W5JXMgT/6dJUyPSyGvOuGAT3BUyUgnC5NYXkijJAFLZOu7y
         Yv5JbY2X49SRiSvuek9ud7gp14Gi/vMhX4G9JgbbkGRglDm+ykc4TlYvdY8Fj2HKTV4R
         jf0aA9CKzkzyGsSHSfxR5xqa0O5lfaH0gfslXMfPZo3MnvDl8oe+07SDvn4tsoIvb0be
         OjvqMU3i2hdm0mseab3il++qOjIxLpjDtQX0LbelldKp7wHaw4vijByqkwHntmzlO96/
         M73g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="d/qRYpWa";
       spf=pass (google.com: domain of 0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id g16si6462609qtg.377.2019.07.05.11.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 05 Jul 2019 11:13:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b="d/qRYpWa";
       spf=pass (google.com: domain of 0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1562350426;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=TeLEUHqZcS2XHWs9Stu73yoSxS785h8O3OY1oogKKCQ=;
	b=d/qRYpWaFqeZw3rhjpieZ+DQmq9wVRn+D6yyjyKsBLpC+G1oQ8n5Hdrk2PCoN+lE
	Hs0N/jxd1qmxGuQEsOz299CAgUsjE71Ku2gRi8totodbwfUaGj8nLY5aVsnAu/F8ViW
	Yb98szIbMYFFAnIkBFuj6JkLBhrEyz7hpnu4Zo+8=
Date: Fri, 5 Jul 2019 18:13:46 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Markus Elfring <Markus.Elfring@web.de>
cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
    kernel-janitors@vger.kernel.org
Subject: Re: [PATCH] mm/slab: One function call less in
 verify_redzone_free()
In-Reply-To: <c724416e-c8bc-6927-00c5-7a4c433c562f@web.de>
Message-ID: <0100016bc3579800-ee6cd00b-6f59-4d86-be0c-f63e2b137d18-000000@email.amazonses.com>
References: <c724416e-c8bc-6927-00c5-7a4c433c562f@web.de>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.07.05-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jul 2019, Markus Elfring wrote:

> Avoid an extra function call by using a ternary operator instead of
> a conditional statement for a string literal selection.

Well. I thought the compiler does that on its own? And the tenary operator
makes the code difficult to read.

