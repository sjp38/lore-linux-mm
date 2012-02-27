Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id AF3F96B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 17:46:05 -0500 (EST)
Date: Mon, 27 Feb 2012 14:46:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tmpfs: security xattr setting on inode creation
Message-Id: <20120227144602.07f5ec33.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1202241904070.22389@eggly.anvils>
References: <1329990365-23779-1-git-send-email-jarkko.sakkinen@intel.com>
	<alpine.LRH.2.02.1202241913400.30742@tundra.namei.org>
	<alpine.LSU.2.00.1202241904070.22389@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jarkko Sakkinen <jarkko.sakkinen@intel.com>, James Morris <jmorris@namei.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org

On Fri, 24 Feb 2012 19:19:22 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> +/*
> + * Callback for security_inode_init_security() for acquiring xattrs.
> + */
> +static int shmem_initxattrs(struct inode *inode,
> +			    const struct xattr *xattr_array,
> +			    void *fs_info)
> +{
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	const struct xattr *xattr;
> +	struct shmem_xattr *new_xattr;
> +	size_t len;
> +
> +	for (xattr = xattr_array; xattr->name != NULL; xattr++) {
> +		new_xattr = shmem_xattr_alloc(xattr->value, xattr->value_len);
> +		if (!new_xattr)
> +			return -ENOMEM;
> +
> +		len = strlen(xattr->name) + 1;
> +		new_xattr->name = kmalloc(XATTR_SECURITY_PREFIX_LEN + len,
> +					  GFP_KERNEL);
> +		if (!new_xattr->name) {
> +			kfree(new_xattr);
> +			return -ENOMEM;
> +		}
> +
> +		memcpy(new_xattr->name, XATTR_SECURITY_PREFIX,
> +		       XATTR_SECURITY_PREFIX_LEN);
> +		memcpy(new_xattr->name + XATTR_SECURITY_PREFIX_LEN,
> +		       xattr->name, len);
> +
> +		spin_lock(&info->lock);
> +		list_add(&new_xattr->list, &info->xattr_list);
> +		spin_unlock(&info->lock);
> +	}
> +
> +	return 0;
> +}

So if there's a kmalloc failure partway through the array, we leave a
partially xattrified inode in place.

Are we sure this is OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
