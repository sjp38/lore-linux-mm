Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59FCEC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:32:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AC9A21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:32:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AC9A21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B02726B0008; Tue, 21 May 2019 11:32:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB1616B000A; Tue, 21 May 2019 11:32:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A15A6B000C; Tue, 21 May 2019 11:32:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 799B36B0008
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:32:14 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id p4so15884874qkj.17
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:32:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qvYnwZC6jFUuIM+ALwxc+F2HuuuthAmCvbW66l4fovk=;
        b=fZKw67E+h3YZAZpLuGCiEvkn6iK+UqB3rqj0p9JFo7ejw+eUktaPMfFRFYQmmUowFe
         ja+RXKRIEYc92pZqeiI4YbmS0DlV42BStrTghXC9aupJyZWUlDZu/fB0gJzaNFaUQUOc
         JtTc0WhTpynKwlR6kNHfwU/tJy17BC/1TAnOqvPaF/KT0Cq23JmMLLhqSVLw7/URh64d
         Q61pU6Sm4+w6/lRGbWzQ2DD75a/5cMn6061fNqcw2dsgu/vSQ2oBxsOsIyMSeQk3L9lU
         IXeFm+BoffGSVaVtkIYVDcQaj4Vf67ggjIIU8MqonN8ZSeDFJjd0EBg61evujRSJzIiw
         H75w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWPwqXDfGo2fCjqkeSexxXgVU9Y/U8M9mJ/TPTvffwQvpEATGF1
	/9KFIMJw10uf/LeKDWSiSGcU+SfDAZxDePVu+UDp4jvf3LT4rnKNG+l+OyB55dojzj0E+ewVjst
	jo7MCmJqDVlte70VTBP2TFTPgcyD/+i8uqtoWcibFObTj2JR5wn38wlCjz6xTAo/jTg==
X-Received: by 2002:aed:39e5:: with SMTP id m92mr56440226qte.106.1558452734253;
        Tue, 21 May 2019 08:32:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDd+njsIylNSLEc4rKwKcox9v0kHlSZzFI167+PwO9HDmXqU38IXqN7fW7y6TRnKc7Jp3j
X-Received: by 2002:aed:39e5:: with SMTP id m92mr56440140qte.106.1558452733370;
        Tue, 21 May 2019 08:32:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558452733; cv=none;
        d=google.com; s=arc-20160816;
        b=UEvNuuvMlV0OJdrEEXpajN2vL2mKrxCXO8qpnje9wL9bsSfkzJb+9Dg2Uj9Z9ZAxYB
         OEtQqcjrdy81jZJ/YPPZojQuzf7gXZCrmD49NhDPYNDLALhyk1wIdb7x5kRgl9WiUGG9
         uOnh/2FUwhdNCUJi47p8CabfVxdztH9pW35/KKAgVjupWPRG950LZDwMYDbCw0VEpShO
         yreMb//RFwsTN5rCESlwtqUQpNMUsD5U+T7ceheY85f8V3tAnnuFePTIi+08bA9ZT7WY
         fT7QQoMQF+g3PjZTV+21npPYK4AoaRyynH/gIWSpY9v5p+1uWGFM9wCXBOAmn9nBAgqS
         7HLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=qvYnwZC6jFUuIM+ALwxc+F2HuuuthAmCvbW66l4fovk=;
        b=AMVBLzGt36uPP8BSey4Bt0s0YeiG4nk3UzFsf0Jz3Ea7iHQ5UmJHc1O7yddTHf8AVE
         wW3JITUBs0BsI1ebvVi2qa6kFeNkDoduZnigf69QMbUknqPAyByU2euBI0D0yTIIfrvi
         DgmkhEk9FoIsrEPWqZSu3/AlWbBwtXgWHJKcEKxgdCENMkpxkCUksXNJhLU8TiSH9DZ4
         3h38mRxYnoYcnH322lUYJn5fTIBGt4Ok9nbH2xZdQjKyIsPBfe8SL0fydlb/3wRA8LeV
         jKaJEystI7vRSpsLV0xZF2S0C7Lk8jWhHf/Mcm4mMQpUPlXt0qva0svRks1UNOTsDnaP
         2Zgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b44si13358595qvh.104.2019.05.21.08.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 08:32:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 18E00883D7;
	Tue, 21 May 2019 15:32:05 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1505C5378A;
	Tue, 21 May 2019 15:32:02 +0000 (UTC)
Date: Tue, 21 May 2019 11:32:00 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 3/4] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190521153200.GB3836@redhat.com>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190520213945.17046-3-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520213945.17046-3-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 21 May 2019 15:32:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 11:39:44PM +0200, Daniel Vetter wrote:
> We need to make sure implementations don't cheat and don't have a
> possible schedule/blocking point deeply burried where review can't
> catch it.
> 
> I'm not sure whether this is the best way to make sure all the
> might_sleep() callsites trigger, and it's a bit ugly in the code flow.
> But it gets the job done.
> 
> Inspired by an i915 patch series which did exactly that, because the
> rules haven't been entirely clear to us.
> 
> v2: Use the shiny new non_block_start/end annotations instead of
> abusing preempt_disable/enable.
> 
> v3: Rebase on top of Glisse's arg rework.
> 
> v4: Rebase on top of more Glisse rework.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "Christian König" <christian.koenig@amd.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Reviewed-by: Christian König <christian.koenig@amd.com>
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> ---
>  mm/mmu_notifier.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index c05e406a7cd7..a09e737711d5 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -176,7 +176,13 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_start) {
> -			int _ret = mn->ops->invalidate_range_start(mn, range);
> +			int _ret;
> +
> +			if (!mmu_notifier_range_blockable(range))
> +				non_block_start();
> +			_ret = mn->ops->invalidate_range_start(mn, range);
> +			if (!mmu_notifier_range_blockable(range))
> +				non_block_end();

This is a taste thing so feel free to ignore it as maybe other
will dislike more what i prefer:

+			if (!mmu_notifier_range_blockable(range)) {
+				non_block_start();
+				_ret = mn->ops->invalidate_range_start(mn, range);
+				non_block_end();
+			} else
+				_ret = mn->ops->invalidate_range_start(mn, range);

If only we had predicate on CPU like on GPU :)

In any case:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>


>  			if (_ret) {
>  				pr_info("%pS callback failed with %d in %sblockable context.\n",
>  					mn->ops->invalidate_range_start, _ret,
> -- 
> 2.20.1
> 

