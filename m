Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1569D6B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 07:51:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v14so8515099pgq.11
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 04:51:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b123si11488425pgc.14.2018.04.24.04.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 04:51:08 -0700 (PDT)
Date: Tue, 24 Apr 2018 04:50:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 7/9] Pmalloc Rare Write: modify selected pools
Message-ID: <20180424115050.GD26636@bombadil.infradead.org>
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-8-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423125458.5338-8-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net, labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>, Carlos Chinea Perez <carlos.chinea.perez@huawei.com>, Remi Denis Courmont <remi.denis.courmont@huawei.com>

On Mon, Apr 23, 2018 at 04:54:56PM +0400, Igor Stoppa wrote:
> While the vanilla version of pmalloc provides support for permanently
> transitioning between writable and read-only of a memory pool, this
> patch seeks to support a separate class of data, which would still
> benefit from write protection, most of the time, but it still needs to
> be modifiable. Maybe very seldom, but still cannot be permanently marked
> as read-only.

This seems like a horrible idea that basically makes this feature useless.
I would say the right way to do this is to have:

struct modifiable_data {
	struct immutable_data *d;
	...
};

Then allocate a new pool, change d and destroy the old pool.
