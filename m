Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 65B666B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 17:19:47 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so59998335qgd.3
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 14:19:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y89si11616646qgd.82.2015.08.14.14.19.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Aug 2015 14:19:46 -0700 (PDT)
Date: Fri, 14 Aug 2015 14:19:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: validate the creation of debugfs files
Message-Id: <20150814141944.4172fee6c9d7ae02a6258c80@linux-foundation.org>
In-Reply-To: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
References: <1439579011-14918-1-git-send-email-kuleshovmail@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Baoquan He <bhe@redhat.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 15 Aug 2015 01:03:31 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

There's no changelog.

> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1692,16 +1692,34 @@ static const struct file_operations memblock_debug_fops = {
>  
>  static int __init memblock_init_debugfs(void)
>  {
> +	struct dentry *f;
>  	struct dentry *root = debugfs_create_dir("memblock", NULL);
>  	if (!root)
>  		return -ENXIO;
> -	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
> -	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
> +
> +	f = debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
> +	if (!f) {
> +		pr_err("Failed to create memory debugfs file\n");
> +		goto err_out;

Why?  Ignoring the debugfs API return values is standard practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
