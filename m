Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id AB29E6B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 06:23:05 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Sm0G5-0002fU-Rc
	for linux-mm@kvack.org; Tue, 03 Jul 2012 12:23:01 +0200
Received: from 117.57.172.73 ([117.57.172.73])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 12:23:01 +0200
Received: from xiyou.wangcong by 117.57.172.73 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 12:23:01 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 4/4] mm: change slob's struct page definition to
 accomodate struct page changes
Date: Tue, 3 Jul 2012 10:22:46 +0000 (UTC)
Message-ID: <jsuh5m$fdo$1@dough.gmane.org>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
 <1341287837-7904-4-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Tue, 03 Jul 2012 at 03:57 GMT, Jiang Liu <jiang.liu@huawei.com> wrote:
> Changeset fc9bb8c768abe7ae10861c3510e01a95f98d5933 "mm: Rearrange struct page"
> rearranges fields in struct page, so change slob's "struct page" definition
> to accomodate the changes.
>

struct page gets changed too after that commit.

>  	union {
>  		struct {
>  			unsigned long flags;	/* mandatory */
> -			atomic_t _count;	/* mandatory */
> -			slobidx_t units;	/* free units left in page */
> -			unsigned long pad[2];
> +			unsigned long pad1;
>  			slob_t *free;		/* first free slob_t in page */
> +			slobidx_t units;	/* free units left in page */
> +			atomic_t _count;	/* mandatory */
>  			struct list_head list;	/* linked list of free pages */
>  		};
>  		struct page page;

I think we should put two BUILD_ON()'s for this, to prevent future breakage,
something like:

BUILD_BUG_ON(offsetof(struct slob_page, _count) != offsetof(struct
page, _count));
BUILD_BUG_ON(offsetof(struct slob_page, flags) != offsetof(struct
page, flags));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
