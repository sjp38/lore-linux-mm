Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6FEDB6B00B9
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 18:55:09 -0500 (EST)
Date: Tue, 22 Nov 2011 15:55:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/memblock.c: return -ENOMEM instead of -ENXIO on
 failure of debugfs_create_dir in memblock_init_debugfs
Message-Id: <20111122155507.af6c10e9.akpm@linux-foundation.org>
In-Reply-To: <4EB9DEF6.4080905@gmail.com>
References: <4EB9DEF6.4080905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 09 Nov 2011 10:01:26 +0800
Wang Sheng-Hui <shhuiw@gmail.com> wrote:

> On the failure of debugfs_create_dir, we should return -ENOMEM
> instead of -ENXIO.
> 
> The patch is against 3.1.
> 
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> ---
>  mm/memblock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index ccbf973..4d4d5ee 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -852,7 +852,7 @@ static int __init memblock_init_debugfs(void)
>  {
>  	struct dentry *root = debugfs_create_dir("memblock", NULL);
>  	if (!root)
> -		return -ENXIO;
> +		return -ENOMEM;
>  	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
>  	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);

Well, we don't know what we should return because
debugfs_create_file() is misdesigned - it should return an ERR_PTR.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
