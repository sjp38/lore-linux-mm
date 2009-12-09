Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1168060021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 00:04:33 -0500 (EST)
Message-ID: <4B1F2FC6.7040406@cn.fujitsu.com>
Date: Wed, 09 Dec 2009 13:04:06 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
References: <200912081016.198135742@firstfloor.org> <20091208211639.8499FB151F@basil.firstfloor.org>
In-Reply-To: <20091208211639.8499FB151F@basil.firstfloor.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +#ifdef	CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +u64 hwpoison_filter_memcg;
> +EXPORT_SYMBOL_GPL(hwpoison_filter_memcg);
> +static int hwpoison_filter_task(struct page *p)
> +{
> +	struct mem_cgroup *mem;
> +	struct cgroup_subsys_state *css;
> +	unsigned long ino;
> +
> +	if (!hwpoison_filter_memcg)
> +		return 0;
> +
> +	mem = try_get_mem_cgroup_from_page(p);
> +	if (!mem)
> +		return -EINVAL;
> +
> +	css = mem_cgroup_css(mem);
> +	ino = css->cgroup->dentry->d_inode->i_ino;

I have a question, can try_get_mem_cgroup_from_page() return
root_mem_cgroup?

if it can, then css->cgroup->dentry is NULL, if memcg is
not mounted and there is no subdir in memcg. Because the root
cgroup of an inactive subsystem has no dentry.

> +	css_put(css);
> +
> +	if (ino != hwpoison_filter_memcg)
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +#else
> +static int hwpoison_filter_task(struct page *p) { return 0; }
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
