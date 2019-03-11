Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB4B8C10F0C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A46C206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:21:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A46C206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00F2D8E0006; Mon, 11 Mar 2019 03:21:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F00928E0002; Mon, 11 Mar 2019 03:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC7DA8E0006; Mon, 11 Mar 2019 03:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B38608E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:21:51 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s65so3776168qke.16
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 00:21:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Y52LpBlfkCcD5WypOh9Z92oifQDw6mcloQnd94AsOeo=;
        b=TI89kt8VfG7LhLg7F2F2kGqaSWXTM3zzdyOmJejMXYyVQv4ejwlla1mgQJM/xOA/2v
         raATJLeDg4XteV5kltZC5mtSCs0xwd+j2w4jJAlLadAqVYgC8sjNHPXPXudTEZklLZB4
         Av0nBA2LR5JU/ueCUVXvBFuyxB79Hv7xdRZg/MpBIJd4Sg+FAkfqG58XZTiE4aK5KuiH
         0dpFvXXop2FAMrTK3Jw/6QYA4UfzmM4myqEAOtZAk8WWgNl+pp1Jodo8I1HqK20ZFfMl
         +bDkcjXcreB6qwJp7oA7khB6+9q/xfWI/pX3UtmRYZK3Vf/93fK25m49duyIEJVcqo7r
         WnaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUbPLsA1YiQhWwx/zIt0g/s8Zivpo6z/PrAwTzPKNMUGhp8tJt3
	3dIVQ5OsQ+HdF6rkzX3BWwhqyr6vfiq0+AlPJYGNTeyBEsk1cDTQOjoogzcmM/sSY4lMiwQfaHv
	+7kC8+iiqnd9bW9m1esnCaGN3abhGr7QFVhCH8QL+8SlS4oszmwp/zK0XCST/nD9edg==
X-Received: by 2002:ac8:48c5:: with SMTP id l5mr4196519qtr.46.1552288911527;
        Mon, 11 Mar 2019 00:21:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYLPuad8Pp2HlXxcmsLKMJZuzH3XE9VjKLknr6zKbY58yoWQ1MX6V4CDtlt+W+f8yAQLo6
X-Received: by 2002:ac8:48c5:: with SMTP id l5mr4196490qtr.46.1552288910880;
        Mon, 11 Mar 2019 00:21:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552288910; cv=none;
        d=google.com; s=arc-20160816;
        b=tPnhIUxDc1nCBe93AQR4taYliNBjYeIbhAXQLzNNZInQte6LVmFdgV2S2c/YjPD0Us
         hE3tsigBgR202n8oIBVGAC+M1KW9xso6WeBPF0JnfRrlmQrsZj/FHLk1QFqxgZBvJ5zK
         azVQl0v8u1oaSC1TrSWr4MiMRIf9lOCPRc0KnmGLJHe1AWHM8pNRowsY95WW9soRZwmP
         A/mv4Ie48R7RVhukle1aW2YNc74KxD+pJ4D8W22eeDYa0Ye3GA+vxc4yVF2B9sPtp99u
         8SoODf3htfNMrO+ijzbHEEC5QlBLBQJwWnnJEnGPkjWEaUghH7lcqb4usYcDq4czeH6f
         CX6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Y52LpBlfkCcD5WypOh9Z92oifQDw6mcloQnd94AsOeo=;
        b=QBpizQxEB6+eqhtcCThvMpdIvwy7NEqQwydrJScGbHClBxB37VUjCKWz5dztWVlex0
         ACfbtc/70ajfyBxleRTD8UrCjpwocMyjur4S1mH0ywc5DhK4jqPnDyJATBa69JlYdWV9
         AL+GsMHT5fBgPrfaayQN0ISBE9KqNjnPFwscWTKjcmNz0M/VflTcpeXj1NJZMGge0PIn
         ooMBHLCII0htlavbEdchb0vLZCMDJfHB767P+vxPnsD2kyvBZ8AKX8R9ATckoI7IfHVb
         NA8k9RhcExaf1KPbUZN/Nyb9IIOAsNhr4FcZiLoeGtDoTqm+YD+d/yGnuA4UHsztVzlZ
         KfbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l3si748244qtr.291.2019.03.11.00.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 00:21:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 21B0D30821F9;
	Mon, 11 Mar 2019 07:21:50 +0000 (UTC)
Received: from [10.72.12.54] (ovpn-12-54.pek2.redhat.com [10.72.12.54])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EAD25611C3;
	Mon, 11 Mar 2019 07:21:43 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 Jan Kara <jack@suse.cz>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
 <20190307190910.GE3835@redhat.com> <20190307193838.GQ23850@redhat.com>
 <20190307201722.GG3835@redhat.com> <20190307212717.GS23850@redhat.com>
 <671c4a98-4699-836e-79fc-0ce650c7f701@redhat.com>
 <20190308191108.GA26923@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <189b7839-3208-fb2e-4ac0-e6ca50e397bb@redhat.com>
Date: Mon, 11 Mar 2019 15:21:41 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190308191108.GA26923@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 11 Mar 2019 07:21:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/9 上午3:11, Andrea Arcangeli wrote:
> On Fri, Mar 08, 2019 at 05:13:26PM +0800, Jason Wang wrote:
>> Actually not wrapping around,  the pages for used ring was marked as
>> dirty after a round of virtqueue processing when we're sure vhost wrote
>> something there.
> Thanks for the clarification. So we need to convert it to
> set_page_dirty and move it to the mmu notifier invalidate but in those
> cases where gup_fast was called with write=1 (1 out of 3).
>
> If using ->invalidate_range the page pin also must be removed
> immediately after get_user_pages returns (not ok to hold the pin in
> vmap until ->invalidate_range is called) to avoid false positive gup
> pin checks in things like KSM, or the pin must be released in
> invalidate_range_start (which is called before the pin checks).
>
> Here's why:
>
> 		/*
> 		 * Check that no O_DIRECT or similar I/O is in progress on the
> 		 * page
> 		 */
> 		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
> 			set_pte_at(mm, pvmw.address, pvmw.pte, entry);
> 			goto out_unlock;
> 		}
> 		[..]
> 		set_pte_at_notify(mm, pvmw.address, pvmw.pte, entry);
> 			  ^^^^^^^ too late release the pin here, the
> 				  above already failed
>
> ->invalidate_range cannot be used with mutex anyway so you need to go
> back with invalidate_range_start/end anyway, just the pin must be
> released in _start at the latest in such case.


Yes.


>
> My prefer is generally to call gup_fast() followed by immediate
> put_page() because I always want to drop FOLL_GET from gup_fast as a
> whole to avoid 2 useless atomic ops per gup_fast.


Ok, will do this (if I still plan to use vmap() in next version).


>
> I'll write more about vmap in answer to the other email.
>
> Thanks,
> Andrea


Thanks

