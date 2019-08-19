Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ED4DC3A59B
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 09:03:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3110A20989
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 09:03:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3110A20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 847B36B0007; Mon, 19 Aug 2019 05:03:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F8A46B000D; Mon, 19 Aug 2019 05:03:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70DCF6B000E; Mon, 19 Aug 2019 05:03:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 51F0D6B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 05:03:48 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 00839180AD805
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:03:47 +0000 (UTC)
X-FDA: 75838589736.03.spot15_3e311e15a3b23
X-HE-Tag: spot15_3e311e15a3b23
X-Filterd-Recvd-Size: 2489
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:03:47 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 193E6307D95F;
	Mon, 19 Aug 2019 09:03:46 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-120-255.rdu2.redhat.com [10.10.120.255])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 190ED82489;
	Mon, 19 Aug 2019 09:03:44 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <2b20bc62-d09c-d340-4f13-e20a850f4d47@suse.cz>
References: <2b20bc62-d09c-d340-4f13-e20a850f4d47@suse.cz> <26518.1565273511@warthog.procyon.org.uk>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: dhowells@redhat.com, Christoph Lameter <cl@linux.com>,
    linux-mm@kvack.org
Subject: Re: [PATCH] Add a slab corruption tracepoint
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8355.1566205424.1@warthog.procyon.org.uk>
Date: Mon, 19 Aug 2019 10:03:44 +0100
Message-ID: <8356.1566205424@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 19 Aug 2019 09:03:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vlastimil Babka <vbabka@suse.cz> wrote:

> Shouldn't that include SLUB?

I've been using SLAB.  Looking in SLUB it's much less obvious where to insert
the tracepoint.  check_bytes_and_report() maybe?

> I'm surprised to see SLAB used for debugging refcounting these days,

The refcount debugging in question is not in SLAB, but rather in rxrpc; it's
just SLAB detected the resulting memory corruption.  rxrpc has tracepoints
that track the refcounting, but SLAB printks a message to indicate the
corruption and it's a bit tricky to work out where the printk happened with
respect to the trace.

> as the SLUB debugging features are vastly superior, while SLAB ones are
> being sometimes found to be broken for years and removed.

If SLUB is better than SLAB, shouldn't SLAB be removed?

David

