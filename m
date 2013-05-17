Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 17 May 2013 11:17:08 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm:
 hotplug: implement non-movable version of get_user_pages() called
 get_user_pages_non_movable())
Message-ID: <20130517181708.GG318@lenny.home.zabbo.net>
References: <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130205120137.GG21389@suse.de>
 <20130206004234.GD11197@blaptop>
 <20130206095617.GN21389@suse.de>
 <5190AE4F.4000103@cn.fujitsu.com>
 <20130513091902.GP11497@suse.de>
 <5191B5B3.7080406@cn.fujitsu.com>
 <20130515132453.GB11497@suse.de>
 <5194748A.5070700@cn.fujitsu.com>
 <20130517002349.GI1008@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130517002349.GI1008@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

> I ended up working on this a bit today, and managed to cobble together 
> something that somewhat works -- please see the patch below.

Just some quick observations:

> +	ctx->ctx_file = anon_inode_getfile("[aio]", &aio_ctx_fops, ctx, O_RDWR);
> +	if (IS_ERR(ctx->ctx_file)) {
> +		ctx->ctx_file = NULL;
> +		return -EAGAIN;
> +	}

It's too bad that aio contexts will now be accounted against the filp
limits (get_empty_filp -> files_stat.max_files, etc). 

> +	for (i=0; i<nr_pages; i++) {
> +		struct page *page;
> +		void *ptr;
> +		page = find_or_create_page(ctx->ctx_file->f_inode->i_mapping,
> +					   i, GFP_KERNEL);
> +		if (!page) {
> +			break;
> +		}
> +		ptr = kmap(page);
> +		clear_page(ptr);
> +		kunmap(page);
> +		SetPageUptodate(page);
> +		SetPageDirty(page);
> +		unlock_page(page);
> +	}

If they're GFP_KERNEL then you don't need to kmap them.  But we probably
want to allocate with GFP_HIGHUSER and then use clear_user_highpage() to
zero them?

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
