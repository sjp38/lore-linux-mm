Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A754DC4151A
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:03:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 469522147A
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:03:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 469522147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90EF78E0002; Mon, 28 Jan 2019 15:03:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86FD38E0001; Mon, 28 Jan 2019 15:03:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C1248E0002; Mon, 28 Jan 2019 15:03:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36CCE8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:03:11 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 80so19464323qkd.0
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:03:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=p5hDVUG9Pv9vb/0nAJrPF0XFczUlmKMzKPslT/FLMxE=;
        b=rhDWIYx+j6nvqsRXAgRzoAJvug34BNaPSru/r+G3rDO/rgFzdVGFRxyNz53bwPtxCd
         aenw06cIFpQC+u4pt7i4bh4LaZBjMh2Kp8y5VsdPXPb+b+BbQUahtY6oSXLiHQTdDYau
         SvgKpIURjVksZRlYEWGa8IsNL9SL15DV2SqxzgE4wGmvrPULmcdLOKB9hJnhPpcif2oQ
         RnwgwqnXbBio5FEE6J4BOMnNZaPhoKhshVMNTHuN7Tu2Pp7JZLTQSfuXYbO45LBVlutZ
         4WjX5RrzfarFxvPCPj5fCYoXeWw6S3mj+pQ6O+JlF0LfOm11qk9G/1Dz9iSiwtmXwKHV
         C5dA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfG9sg/9GX+jQI+ZCq+A7oKsZ9YYrO6Fk8QwBN+V+lvWlOCByIK
	pUOZSrOuFY7KnyyPT3ZvhS0fg8o1f03P2H6mN7MWeRDC5zFkUvBrCKEkg+Sv9a6VBwlGTH5r0F8
	ZFl071vj5+bemaQacULywkag3SFCrj8Iy2m3aCb1PvhWfIMEmo8ljUCmTM5p6roRQQQ==
X-Received: by 2002:ac8:8ca:: with SMTP id y10mr23100556qth.153.1548705790935;
        Mon, 28 Jan 2019 12:03:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7yVG51fTlo/96s4ntFO+tBH/GB10wimE7u6hAWM8Rx9EDWdEJPg5cNJegRCRHKly93E++b
X-Received: by 2002:ac8:8ca:: with SMTP id y10mr23100504qth.153.1548705790188;
        Mon, 28 Jan 2019 12:03:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548705790; cv=none;
        d=google.com; s=arc-20160816;
        b=araW2ckUmJkY+BE3oKWI/QjLmfpVMM9ZyXjKPoDgSq1Tn30pII7sCMhOfs+6HUXOgX
         GOZ6VdtlBdiIiqjTxbAj4tjG53XUZd905uSvuVVZpyrTy11KLmX4Df2bT5KfO4qNDz/Y
         sjj4rPofkXuWsjonPPtU09ROxdPOCX1nIubi9eMC/WYmz7qAmfKqqBgdVM2nM7weNMe8
         nE/LF9zfgmh74Y9wF3QzeolRvWXsZYvBbsGG/xsvJ7+9JcEuQ83U+1LthxOsYlZe3yCI
         WhkPxK8tXBmcN8TgZPw8POBvvGiDXopgkneT53s1Yi21welaIrInNQI7Rc0A2HPMmWeK
         1Ytw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=p5hDVUG9Pv9vb/0nAJrPF0XFczUlmKMzKPslT/FLMxE=;
        b=EFbStlCOyhm6NaS9hCiE2tjpIkox8K6cWA7ckyqSf+tf7tr+tOmkNXvPbYBsIncu1W
         1uLwqML1ehbiV71XEj5O69LvPaV/YK9q0e2lP1iVnXOYpdqXhXIZSjNmmmSKXvlnKkyk
         7hEyJv3fAPw/3QdzL9eokeHN6FZtZrYOU6S1ooV9FjEmeZeYBX3gkGGEww75Mdn007uL
         7mBzbKAYXajpvvd+aRcfpMRky5drSxbXSjvZ2AAd0zo/eZh8r7u4F3/8JExvJ1xhOCbe
         7+92Hl0tWPK4agd1XhcCn0XwMHJjYTqatbo8dPyiMzmAKWsoXnqEnvMSFFRLRifAnIqc
         eBPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 40si88288qvu.207.2019.01.28.12.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 12:03:10 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CF02B7FD41;
	Mon, 28 Jan 2019 20:03:08 +0000 (UTC)
Received: from [10.36.116.25] (ovpn-116-25.ams2.redhat.com [10.36.116.25])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B4C32BA91;
	Mon, 28 Jan 2019 20:02:53 +0000 (UTC)
Subject: Re: [PATCH v1] mm: migrate: don't rely on PageMovable() of newpage
 after unlocking it
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
 Dominik Brodowski <linux@dominikbrodowski.net>,
 Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>,
 Rafael Aquini <aquini@redhat.com>,
 Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
 Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org
References: <20190128160403.16657-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e3247625-b25c-a18a-a494-f1e9a0148932@redhat.com>
Date: Mon, 28 Jan 2019 21:02:52 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190128160403.16657-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 28 Jan 2019 20:03:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.01.19 17:04, David Hildenbrand wrote:
> While debugging some crashes related to virtio-balloon deflation that
> happened under the old balloon migration code, I stumbled over a race
> that still exists today.
> 
> What we experienced:
> 
> drivers/virtio/virtio_balloon.c:release_pages_balloon():
> - WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
> - list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100
> 
> Turns out after having added the page to a local list when dequeuing,
> the page would suddenly be moved to an LRU list before we would free it
> via the local list, corrupting both lists. So a page we own and that is
> !LRU was moved to an LRU list.
> 
> In __unmap_and_move(), we lock the old and newpage and perform the
> migration. In case of vitio-balloon, the new page will become
> movable, the old page will no longer be movable.
> 
> However, after unlocking newpage, there is nothing stopping the newpage
> from getting dequeued and freed by virtio-balloon. This
> will result in the newpage
> 1. No longer having PageMovable()
> 2. Getting moved to the local list before finally freeing it (using
>    page->lru)
> 
> Back in the migration thread in __unmap_and_move(), we would after
> unlocking the newpage suddenly no longer have PageMovable(newpage) and
> will therefore call putback_lru_page(newpage), modifying page->lru
> although that list is still in use by virtio-balloon.
> 
> To summarize, we have a race between migrating the newpage and checking
> for PageMovable(newpage). Instead of checking PageMovable(newpage), we
> can simply rely on is_lru of the original page.
> 
> Looks like this was introduced by d6d86c0a7f8d ("mm/balloon_compaction:
> redesign ballooned pages management"), which was backported up to 3.12.
> Old compaction code used PageBalloon() via -_is_movable_balloon_page()
> instead of PageMovable(), however with the same semantics.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Vratislav Bendel <vbendel@redhat.com>
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: stable@vger.kernel.org # 3.12+
> Fixes: d6d86c0a7f8d ("mm/balloon_compaction: redesign ballooned pages management")
> Reported-by: Vratislav Bendel <vbendel@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/migrate.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4512afab46ac..31e002270b05 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1135,10 +1135,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  	 * If migration is successful, decrease refcount of the newpage
>  	 * which will not free the page because new page owner increased
>  	 * refcounter. As well, if it is LRU page, add the page to LRU
> -	 * list in here.
> +	 * list in here. Don't rely on PageMovable(newpage), as that could
> +	 * already have changed after unlocking newpage (e.g.
> +	 * virtio-balloon deflation).
>  	 */
>  	if (rc == MIGRATEPAGE_SUCCESS) {
> -		if (unlikely(__PageMovable(newpage)))
> +		if (unlikely(!is_lru))
>  			put_page(newpage);
>  		else
>  			putback_lru_page(newpage);
> 

Vratislav just pointed out that this issue should not happen on upstream
as __PageMovable(newpage) will still return true even after
__ClearPageMovable(newpage). Only PageMovable(newpage) would actually
return false.

(not sure if I am happy about this, this is horribly confusing and
complicated)

I am not 100% sure yet, but I guess Vratislav is right. So it was
effectively fixed by

b1123ea6d3b3 ("mm: balloon: use general non-lru movable page feature"),
which checks for __PageMovable(newpage) instead of
__is_movable_balloon_page(newpage).

Anybody wanting to fix stable kernels either has to backport something
proposed in this patch or b1123ea6d3b3.

-- 

Thanks,

David / dhildenb

