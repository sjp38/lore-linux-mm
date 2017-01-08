Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CEB2B6B026B
	for <linux-mm@kvack.org>; Sun,  8 Jan 2017 04:55:15 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 75so111012003pgf.3
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 01:55:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h10si50573882pgn.139.2017.01.08.01.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jan 2017 01:55:14 -0800 (PST)
Date: Sun, 8 Jan 2017 01:55:11 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 1/3] xattr: add simple initxattrs function
Message-ID: <20170108095511.GB4203@infradead.org>
References: <1483653823-22018-1-git-send-email-david.graziano@rockwellcollins.com>
 <1483653823-22018-2-git-send-email-david.graziano@rockwellcollins.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1483653823-22018-2-git-send-email-david.graziano@rockwellcollins.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Graziano <david.graziano@rockwellcollins.com>
Cc: linux-security-module@vger.kernel.org, paul@paul-moore.com, agruenba@redhat.com, hch@infradead.org, linux-mm@kvack.org, sds@tycho.nsa.gov, linux-kernel@vger.kernel.org

> +/*
> + * Callback for security_inode_init_security() for acquiring xattrs.
> + */
> +int simple_xattr_initxattrs(struct inode *inode,
> +			    const struct xattr *xattr_array,
> +			    void *fs_info)
> +{
> +	struct simple_xattrs *xattrs;
> +	const struct xattr *xattr;
> +	struct simple_xattr *new_xattr;
> +	size_t len;
> +
> +	if (!fs_info)
> +		return -ENOMEM;

This probablt should be an EINVAL, and also a WARN_ON_ONCE.

> +	xattrs = (struct simple_xattrs *) fs_info;

No need for the cast.  In fact we should probably just declarate it
as struct simple_xattrs *xattrs in the protoype and thus be type safe.

> +
> +	for (xattr = xattr_array; xattr->name != NULL; xattr++) {
> +		new_xattr = simple_xattr_alloc(xattr->value, xattr->value_len);
> +		if (!new_xattr)
> +			return -ENOMEM;

We'll need to unwind the previous allocations here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
