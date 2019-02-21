Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A816C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:17:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0272B2083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:17:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0272B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81EA68E008C; Thu, 21 Feb 2019 10:17:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F5FE8E0089; Thu, 21 Feb 2019 10:17:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B918E008C; Thu, 21 Feb 2019 10:17:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44ACD8E0089
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:17:58 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 203so5435707qke.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 07:17:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=gQiUHiKrym1YgLK+Vlr+RYXJmr31GmNoTPr4FWSCuto=;
        b=HBUSHPmd6K3v3mFUWZK+HZkze3Da4WmAZMVR/Vi/oK/dzqGGuq7HBgBQSQbLyJ2DIg
         1COWkxP2no6NYDkioduZKB34+MPCFUNQZzuo024BzHwN+eKAk2ckJisC+o/p1IOBs3+Y
         how6VTRKcu5NSdGVFfJi0UCSwRW8RKdprgMGNRpCGSIAv4KBAqLyhUuAoknFghSag9vc
         tBuuQpAHQp8AvH5blhGDh8BnROp73jGeVTjVmcri6ZXcY5fBBksY6VT00lq8M1gmwIOf
         A1LjnVTCCcoTjBMK2x7tGPUft+TyDS4mMBHcEOgzscXJFzofLdR55s18vIHXDqFHux0s
         U7gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubwemsphNjogbK7u7e34P7+5bkBHPMUTCHC1q11Zp0gmi6aJkF5
	uVuZwZczk+cpbLFPrmO2VS2akjsrTlZEvAAZi527hG5OaHMXYkk8CCyVXFjtCGOtTXR4TQozjkZ
	Ed6ZLVx8aPC4d1GT354h8s7uty9ZYe2SHSXmL9OQT9mDfh3hAlusxG7frG17VLjS6KQ==
X-Received: by 2002:ac8:3209:: with SMTP id x9mr32343378qta.315.1550762277944;
        Thu, 21 Feb 2019 07:17:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+NvxTih01GrcnOcvq2E+VY9cjzJx1WN6TRznbdnbIYQQ7BjD2UV6iVKlK02g4uxyIKok1
X-Received: by 2002:ac8:3209:: with SMTP id x9mr32343309qta.315.1550762277085;
        Thu, 21 Feb 2019 07:17:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550762277; cv=none;
        d=google.com; s=arc-20160816;
        b=x0jPn3Gf7SFoOxCOuldtGJaF3FoU0khSLdkgAv18DHnDUwWCCQGac2cyjoLuFiSVVH
         /cc5HLx10SLGpb7W58SB4qUByJze8uWmIPw8QE7iCYHF+xrf9A4XOvXMjwN0GGJ4CtNm
         fNlAd61UwPktB+IgWy7J670i4hLSd61uZGCRR9LxQ6BSLiNTmGqWHMsv10S8EwCQbKyS
         GbBjVnbPRKfCIH2JncIbUoNVrh8wfA6Uy6c+Il3snRMMNVJIzA+AUiH8iMZpm0mezWG+
         /W8EIfoQnDUzqn1AIhZ6BGxufYJre/dyVLYtqfwk2IVaWWu+21yyro0UGWKCtbcy5d/h
         unFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=gQiUHiKrym1YgLK+Vlr+RYXJmr31GmNoTPr4FWSCuto=;
        b=XTlJUesbHu4egl+a87Dp3ICInoOmDt8qO+KmKrPzpU3aSk1TTarf9M81zmMhsZStY1
         YOxIf1XTlpoY1fnq0JiXiEZL+s9EzDC6pHZU/icsORbWH40kDGGAjO9iVjKIrXagklv7
         dcS3IuevVOr6WV9gJtH0TtK5tVeEplg0zV2P3dvmiW1KHDlaHFYBvjMytO6keUEO60Et
         vTf5XaBAxMlBLX0hjqoGJ2PeYmY4InRlK9D8d853vfLlM85qUhRWAppOYcLuA0sBNova
         qzDqvt0EQACFNZxJb0tR7jxVoXW584m+o4r94zXAs7ijTtZCL4lrvBd8wBWq/M82uo3y
         I6iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g72si5451816qke.4.2019.02.21.07.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 07:17:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4E7F7859FE;
	Thu, 21 Feb 2019 15:17:54 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D65295D9D4;
	Thu, 21 Feb 2019 15:17:44 +0000 (UTC)
Date: Thu, 21 Feb 2019 10:17:42 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 01/26] mm: gup: rename "nonblocking" to "locked" where
 proper
Message-ID: <20190221151742.GA2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-2-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-2-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 21 Feb 2019 15:17:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:07AM +0800, Peter Xu wrote:
> There's plenty of places around __get_user_pages() that has a parameter
> "nonblocking" which does not really mean that "it won't block" (because
> it can really block) but instead it shows whether the mmap_sem is
> released by up_read() during the page fault handling mostly when
> VM_FAULT_RETRY is returned.
> 
> We have the correct naming in e.g. get_user_pages_locked() or
> get_user_pages_remote() as "locked", however there're still many places
> that are using the "nonblocking" as name.
> 
> Renaming the places to "locked" where proper to better suite the
> functionality of the variable.  While at it, fixing up some of the
> comments accordingly.
> 
> Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Minor issue see below

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

[...]

> @@ -656,13 +656,11 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
>   * appropriate) must be called after the page is finished with, and
>   * before put_page is called.
>   *
> - * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
> - * or mmap_sem contention, and if waiting is needed to pin all pages,
> - * *@nonblocking will be set to 0.  Further, if @gup_flags does not
> - * include FOLL_NOWAIT, the mmap_sem will be released via up_read() in
> - * this case.
> + * If @locked != NULL, *@locked will be set to 0 when mmap_sem is
> + * released by an up_read().  That can happen if @gup_flags does not
> + * has FOLL_NOWAIT.

I am not a native speaker but i believe the correct wording is:
     @gup_flags does not have FOLL_NOWAIT

