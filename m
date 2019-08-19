Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FC21C41514
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6296322CF5
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 22:13:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kI9kp010"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6296322CF5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EE276B0007; Mon, 19 Aug 2019 18:13:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09F316B0008; Mon, 19 Aug 2019 18:13:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F260A6B000A; Mon, 19 Aug 2019 18:13:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id CA91B6B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:13:49 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 68C24127C
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:13:49 +0000 (UTC)
X-FDA: 75840580578.05.cart50_78a5187665b17
X-HE-Tag: cart50_78a5187665b17
X-Filterd-Recvd-Size: 2739
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:13:48 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AF79C214DA;
	Mon, 19 Aug 2019 22:13:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566252827;
	bh=4OL6nVB0qLhHMLV1A+Hg935diBRpXnS4haw7ngoM9j4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=kI9kp010sbLvA9Ywre7pB5dBfmLhakbFcsuorxWOsdV6NmA+5vidwNG0D1bwcxfD5
	 EJ/hFdkoCAooP46shHMKoYGA4ahBsfgPgTI244f/fzMjmQ5//XKRM3TegfNa+TLMJ2
	 sdG4xBNmgNek2PkqFsbwyptx/+1k3hlw6wZ10qXE=
Date: Mon, 19 Aug 2019 15:13:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Subject: Re: tmpfs: fixups to use of the new mount API
Message-Id: <20190819151347.ecbd915060278a70ddeebc91@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1908191503290.1253@eggly.anvils>
References: <alpine.LSU.2.11.1908191503290.1253@eggly.anvils>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Aug 2019 15:09:14 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> Several fixups to shmem_parse_param() and tmpfs use of new mount API:
> 
> mm/shmem.c manages filesystem named "tmpfs": revert "shmem" to "tmpfs"
> in its mount error messages.
> 
> /sys/kernel/mm/transparent_hugepage/shmem_enabled has valid options
> "deny" and "force", but they are not valid as tmpfs "huge" options.
> 
> The "size" param is an alternative to "nr_blocks", and needs to be
> recognized as changing max_blocks.  And where there's ambiguity, it's
> better to mention "size" than "nr_blocks" in messages, since "size" is
> the variant shown in /proc/mounts.
> 
> shmem_apply_options() left ctx->mpol as the new mpol, so then it was
> freed in shmem_free_fc(), and the filesystem went on to use-after-free.
> 
> shmem_parse_param() issue "tmpfs: Bad value for '%s'" messages just
> like fs_parse() would, instead of a different wording.  Where config
> disables "mpol" or "huge", say "tmpfs: Unsupported parameter '%s'".

Is this

Fixes: 144df3b288c41 ("vfs: Convert ramfs, shmem, tmpfs, devtmpfs, rootfs to use the new mount API")?

and a Cc:stable is appropriate?

