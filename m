Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88D2AC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:19:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F46F2171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:19:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F46F2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D472D8E0004; Mon, 28 Jan 2019 15:19:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF58C8E0001; Mon, 28 Jan 2019 15:19:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0CC28E0004; Mon, 28 Jan 2019 15:19:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6945A8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:19:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so6932556edb.22
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:19:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BDAKtUsr5f44NB9dyT9y3+NCA6/+FlkIoVLXHu48R/4=;
        b=pS+LXWtRNI905GC0saGE2zSlsIG5wkjDOEfRckqzeOywh/VYB8l8SHiclYdKuTF6nu
         nSOajFbsumWyORijEcsmZSyEwjb5YPokNlpY/qbPP/yosUbtyBAxNmkGMELZoq/1hNo1
         8eDPYOe/ZUwYlqiCwT7fv+sEaSIjagSb25FmYGBCJrJkEa0DFfMPIrXyrYknAJWdpWKd
         yJpJD26Mt4SBnXdQkRG1vu2OSZW4oJg223iK3YtsCyvxKkzQcqUZ5MJPm9T6AfWZdF1U
         xJjdWGe4GKC992aNmQNmRhfocXrk8qN+wut2TnRcHi6x98SDO5YCsSDKhXzWwJrta7HJ
         d/bQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeRflGFvRh9sJVxn7A/2ZY3LmXyyUS4RWORVRW8A2iuaxb0krBG
	KIDMaC3NdLFF79uOiMBKMh4zcN8E/4HjFjl7MIhIf/N4cbB4POUS3aGl0/RttcOhRAVQjG3jTbW
	R8ax4u49uqbfoAeP16QkpHQH2cqARCApDhZiqcYRGpKgQ4sH4NW9Qs1VN7YUe+94=
X-Received: by 2002:a50:de49:: with SMTP id a9mr23185839edl.18.1548706745970;
        Mon, 28 Jan 2019 12:19:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4FWVcyblzJFic24qUw21o7YlFlPDX3/Ur+g0tF8SdbR0v/qctAk6/fm07p1ikH5cACThsP
X-Received: by 2002:a50:de49:: with SMTP id a9mr23185802edl.18.1548706745055;
        Mon, 28 Jan 2019 12:19:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548706745; cv=none;
        d=google.com; s=arc-20160816;
        b=KZ/Ppii28rYMFUPZj+oU3LwdCXwI2k6jxhI8bskv6yJQY/8ZkIyo7oWcn574AL32pR
         d5ThA0Nn0N1TNLJO72mrAJg/I/mp01UWU4JWLz6qBuDZwm33hHPdmp4qyzDdIYeJ39+o
         kw0f3e1oq+WLdLT3H2h2lW55MiBws/3iDjIzEr8wCJVe/1LyTYmNocmyUX1zN14/mP6Q
         c8u8gNn37oLhLfabwXGj1HyUnOilKbg8i6GcQZLVX94F4b5UzaUPuweWLBBMtwR1mSxc
         Q9vmwRbJ6IqIhobZDRXpcugooBxmln7Nc3whgMy922fOFRITuNXQbkoS+h4Ce9QfMzA9
         b4eA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BDAKtUsr5f44NB9dyT9y3+NCA6/+FlkIoVLXHu48R/4=;
        b=oEUbdIKMdsvIXnofELRUSWVoQpGCnE8wxbgLTwER/7esnG4XnQUb5grN7ddnrGuGZQ
         AA8NP9eMQAhGWMsL72gsijv0wOorq4C6SscA5CuCkTXmkv2sasnakj+dZn2uv1lLqK1a
         6io7o60XvDDrhC7DxfTTGU5txKZuoHKLUScOAEi3UQ/BczPUsvmFNkFGqJdKQ1m3V6ph
         oTbLAFi7Deb8M8TTYMHX5MF2n7Z9iqL2mz7+JSBUyY77SpDJ6ScadOMFrU/XXESPbldU
         IErKVZMXFjB9KceZaDU7QSaKta0+/UGmnvFN4BroYfhyBXKJVAH49gk6AuV9rLfnUAKt
         HWeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19si937194edt.34.2019.01.28.12.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 12:19:05 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0C148AF74;
	Mon, 28 Jan 2019 20:19:04 +0000 (UTC)
Date: Mon, 28 Jan 2019 21:19:02 +0100
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vratislav Bendel <vbendel@redhat.com>,
	Rafael Aquini <aquini@redhat.com>,
	Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
	Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org
Subject: Re: [PATCH v1] mm: migrate: don't rely on PageMovable() of newpage
 after unlocking it
Message-ID: <20190128201902.GW18811@dhcp22.suse.cz>
References: <20190128160403.16657-1-david@redhat.com>
 <e3247625-b25c-a18a-a494-f1e9a0148932@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3247625-b25c-a18a-a494-f1e9a0148932@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 21:02:52, David Hildenbrand wrote:
> On 28.01.19 17:04, David Hildenbrand wrote:
> > While debugging some crashes related to virtio-balloon deflation that
> > happened under the old balloon migration code, I stumbled over a race
> > that still exists today.
> > 
> > What we experienced:
> > 
> > drivers/virtio/virtio_balloon.c:release_pages_balloon():
> > - WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
> > - list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100
> > 
> > Turns out after having added the page to a local list when dequeuing,
> > the page would suddenly be moved to an LRU list before we would free it
> > via the local list, corrupting both lists. So a page we own and that is
> > !LRU was moved to an LRU list.
> > 
> > In __unmap_and_move(), we lock the old and newpage and perform the
> > migration. In case of vitio-balloon, the new page will become
> > movable, the old page will no longer be movable.
> > 
> > However, after unlocking newpage, there is nothing stopping the newpage
> > from getting dequeued and freed by virtio-balloon. This
> > will result in the newpage
> > 1. No longer having PageMovable()
> > 2. Getting moved to the local list before finally freeing it (using
> >    page->lru)
> > 
> > Back in the migration thread in __unmap_and_move(), we would after
> > unlocking the newpage suddenly no longer have PageMovable(newpage) and
> > will therefore call putback_lru_page(newpage), modifying page->lru
> > although that list is still in use by virtio-balloon.
> > 
> > To summarize, we have a race between migrating the newpage and checking
> > for PageMovable(newpage). Instead of checking PageMovable(newpage), we
> > can simply rely on is_lru of the original page.
> > 
> > Looks like this was introduced by d6d86c0a7f8d ("mm/balloon_compaction:
> > redesign ballooned pages management"), which was backported up to 3.12.
> > Old compaction code used PageBalloon() via -_is_movable_balloon_page()
> > instead of PageMovable(), however with the same semantics.
> > 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: Vratislav Bendel <vbendel@redhat.com>
> > Cc: Rafael Aquini <aquini@redhat.com>
> > Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: stable@vger.kernel.org # 3.12+
> > Fixes: d6d86c0a7f8d ("mm/balloon_compaction: redesign ballooned pages management")
> > Reported-by: Vratislav Bendel <vbendel@redhat.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Acked-by: Rafael Aquini <aquini@redhat.com>
> > Signed-off-by: David Hildenbrand <david@redhat.com>
> > ---
> >  mm/migrate.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 4512afab46ac..31e002270b05 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1135,10 +1135,12 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  	 * If migration is successful, decrease refcount of the newpage
> >  	 * which will not free the page because new page owner increased
> >  	 * refcounter. As well, if it is LRU page, add the page to LRU
> > -	 * list in here.
> > +	 * list in here. Don't rely on PageMovable(newpage), as that could
> > +	 * already have changed after unlocking newpage (e.g.
> > +	 * virtio-balloon deflation).
> >  	 */
> >  	if (rc == MIGRATEPAGE_SUCCESS) {
> > -		if (unlikely(__PageMovable(newpage)))
> > +		if (unlikely(!is_lru))
> >  			put_page(newpage);
> >  		else
> >  			putback_lru_page(newpage);
> > 
> 
> Vratislav just pointed out that this issue should not happen on upstream
> as __PageMovable(newpage) will still return true even after
> __ClearPageMovable(newpage). Only PageMovable(newpage) would actually
> return false.
> 
> (not sure if I am happy about this, this is horribly confusing and
> complicated)

It is confusing as hell! __ClearPageMovable is a misnomer and I have to
admit I have misread the implementation to actually ~PAGE_MAPPING_MOVABLE.

> I am not 100% sure yet, but I guess Vratislav is right. So it was
> effectively fixed by
> 
> b1123ea6d3b3 ("mm: balloon: use general non-lru movable page feature"),
> which checks for __PageMovable(newpage) instead of
> __is_movable_balloon_page(newpage).

So this is not just a clean up. Sigh!

> Anybody wanting to fix stable kernels either has to backport something
> proposed in this patch or b1123ea6d3b3.

I think we should go with a simple patch for stable so this patch sounds
like a good thing. *PageMovable thingy needs a much better documentation
and ideally a cleaner implementation as well. The current state is just
incomprehensible. 

David, could you reformulate the changelog accordingly please? My ack
still holds.
-- 
Michal Hocko
SUSE Labs

